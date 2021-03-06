//
//  FeedController.swift
//  App
//
//  Created by Aidar Nugmanov on 5/1/20.
//

import Vapor
import Models

extension Block: Content {}

final class FeedController: RouteCollection {
    private enum Parameter: String {
        case userId

        var queryParameter: PathComponent {
            return .init(stringLiteral: ":\(rawValue)")
        }
    }
    private let analyticsService: AnalyticsService
    private let contentService: ContentService
    
    
    init(analyticsService: AnalyticsService = MockAnalyticsService(),
         contentService: ContentService = MockContentService()) {
        self.analyticsService = analyticsService
        self.contentService = contentService
    }

    func boot(routes: RoutesBuilder) throws {
        let group = routes.grouped("feed")
        group.get(Parameter.userId.queryParameter, use: get)
    }

    private func get(request: Request) throws -> EventLoopFuture<[Block]> {
        
        return try getStatistics(request: request)
            .and(
               try getContent(request: request))
            .map{ (blocks) in
                let (statisticsBlocks, informationBlocks) = blocks
                let facade = LayoutFacade(statisticsModels: statisticsBlocks, informationModels: informationBlocks)
                return facade.getBlocks()
            }
        }
    
    
    func getStatistics(request: Request) throws -> EventLoopFuture<[StatisticsBlock]> {
        guard let userId = request.parameters.get(Parameter.userId.rawValue)
        else {throw Abort(.internalServerError)}
        
        let client = request.client
        let url = URI(string: "http://\(Service.analytics.host!):\(Service.analytics.port!)/analytics/\(userId)")
        request.logger.info("url is: \(url.description)")
        var headers = request.headers
        headers.replaceOrAdd(name: .host, value: Service.analytics.host!)
        let request = ClientRequest(method: request.method, url: url, headers: headers, body: request.body.data)
        
        return client.send(request).flatMapThrowing{ response in
            let userStatsPayload = try response.content.decode(UserStatsPayload.self)
            
            var result: [StatisticsBlock] = []
            for gameIndex in 0 ..< userStatsPayload.userStats.count {
                for statIndex in 0 ..< userStatsPayload.userStats[gameIndex].gameStats.count {
                    let gameStat = userStatsPayload.userStats[gameIndex].gameStats[statIndex]
                    
                    let (title, subtitle) = gameStat.eventType.getStatTitleAndSubtitle(valueType: gameStat.valueType, dateFilter: gameStat.dateFilter, gameType: userStatsPayload.userStats[gameIndex].gameType)
                    result.append(
                        StatisticsBlock(icon: nil,
                                        title: title,
                                        subtitle: subtitle,
                                        number: gameStat.value,
                                        color: ColorProvider().getRandom())
                    )
                }
            }
            return result
        }
    }
    
    func getContent(request: Request) throws -> EventLoopFuture<[InformationBlock]> {
        let client = request.client
        let url = URI(string: "http://\(Service.content.host!):\(Service.content.port!)/content/articles")
        request.logger.info("url is: \(url.description)")
        var headers = request.headers
        headers.replaceOrAdd(name: .host, value: Service.content.host!)
        let request = ClientRequest(method: request.method, url: url, headers: headers, body: request.body.data)
        
        return client.send(request).flatMapThrowing{ response in
            let articles:[Article]  = try response.content.decode([Article].self)
            
            var result: [InformationBlock] = []
            for index in 0 ..< articles.count {
                let article = articles[index]
                    
                if let subtitle = article.shortDescription{
                    result.append(.detailed(date: article.createdAt, model:
                        DetailedInformationBlock(
                            coverImage: article.imageUrl,
                            metaTitle: article.type,
                            title: article.title,
                            subtitle: subtitle)
                        )
                    )
                }
                else{
                    result.append(.headlined(date: article.createdAt, model:
                        HeadlinedInformationBlock(
                            coverImage: article.imageUrl,
                            metaTitle: article.type,
                            title: article.title)
                        )
                    )
                }
                   
            }
            return result
        }
    }
}


struct Article: Content {
    var id: UUID
    var title: String
    var text: String
    var type: String
    var shortDescription: String?
    var imageUrl: String
    var createdAt: Date
}
