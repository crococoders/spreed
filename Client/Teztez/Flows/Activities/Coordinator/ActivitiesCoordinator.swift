//
//  ActivitiesCoordinator.swift
//  Teztez
//
//  Created by Almas Zainoldin on 4/22/20.
//  Copyright © 2020 crococoders. All rights reserved.
//

import Foundation

final class ActivitiesCoordinator: ParentCoordinator {
    private let moduleFactory: ActivitiesModuleFactory
    private let coordinatorFactory: CoordinatorFactory

    init(moduleFactory: ActivitiesModuleFactory, coordinatorFactory: CoordinatorFactory, router: Router) {
        self.moduleFactory = moduleFactory
        self.coordinatorFactory = coordinatorFactory
        super.init(router: router)
    }

    override func start() {
        showActivites()
    }

    private func showActivites() {
        var activities = moduleFactory.makeActivities()
        activities.onItemDidSelect = { [weak self] itemType in
            self?.runFlow(by: itemType)
        }
        router.setRootModule(activities)
    }

    private func runFlow(by itemType: ActivitiesItemType) {
        switch itemType {
        case .coach:
            break
//            runPersoalCoachFlow()
        case .schulte:
            runSchulteFlow()
        case .backwards:
            runBackwardsFlow()
        case .blender:
            runBlenderFlow()
        case .suggestion:
            runSuggestActivityFlow()
        case .colorMatch:
            runMatchingFlow()
        }
    }

    private func runPersoalCoachFlow() {
        let (coordinator, module) = coordinatorFactory.makePersonalCoachCoordinator()
        coordinator.onFlowDidFinish = { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.dismiss(child: coordinator)
        }
        show((coordinator, module), with: .presentInFullScreen(animated: true))
    }

    private func runSchulteFlow() {
        let (coordinator, module) = coordinatorFactory.makeSchulteCoordinator()
        coordinator.onFlowDidFinish = { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.dismiss(child: coordinator)
        }
        show((coordinator, module), with: .presentInFullScreen(animated: true))
    }

    private func runBackwardsFlow() {
        let (coordinator, module) = coordinatorFactory.makeBackwardsCoordinator()
        coordinator.onFlowDidFinish = { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.dismiss(child: coordinator)
        }
        show((coordinator, module), with: .presentInFullScreen(animated: true))
    }

    private func runBlenderFlow() {
        let (coordinator, module) = coordinatorFactory.makeBlenderCoordinator()
        coordinator.onFlowDidFinish = { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.dismiss(child: coordinator)
        }
        show((coordinator, module), with: .presentAsPage)
    }

    private func runSuggestActivityFlow() {
        let (coordinator, module) = coordinatorFactory.makeSuggestActivityCoordinator()
        coordinator.onFlowDidFinish = { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.dismiss(child: coordinator)
        }
        show((coordinator, module), with: .presentInSheet(dismissable: false))
    }

    private func runMatchingFlow() {
        let (coordinator, module) = coordinatorFactory.makeMatchingCoordinator()
        coordinator.onFlowDidFinish = { [weak self, weak coordinator] in
            guard let coordinator = coordinator else { return }
            self?.dismiss(child: coordinator)
        }
        show((coordinator, module), with: .presentInFullScreen(animated: true))
    }
}
