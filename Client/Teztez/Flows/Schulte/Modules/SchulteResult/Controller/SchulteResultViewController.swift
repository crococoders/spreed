//
//  SchulteResultViewController.swift
//  Teztez
//
//  Created by Almas Zainoldin on 04/05/2020.
//  Copyright © 2020 Crococoders. All rights reserved.
//

import Combine
import UIKit

protocol SchulteResultPresentable: Presentable {
    var onHomeButtonDidTap: Callback? { get set }
    var onRestartButtonDidTap: Callback? { get set }
}

final class SchulteResultViewController: ViewController, SchulteResultPresentable {
    var onHomeButtonDidTap: Callback?
    var onRestartButtonDidTap: Callback?

    private let store: SchulteResultStore
    private var cancellables = Set<AnyCancellable>()

    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var homeButton: PrimaryButton!
    @IBOutlet var restartButton: SecondaryButton!

    init(store: SchulteResultStore) {
        self.store = store
        super.init(nibName: String(describing: Self.self), bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        store.dispatch(action: .didLoadView)
    }

    @IBAction func homeButtonDidTap(_ sender: PrimaryButton) {
        navigationController?.dismiss(animated: true)
    }

    @IBAction func restartButtonDidTap(_ sender: UIButton) {
        let store = SchulteConfigurationStore()
        let viewController = SchulteConfigurationViewController(store: store)
        navigationController?.setViewControllers([viewController], animated: true)
    }

    private func setupObservers() {
        store.$state.sink { [weak self] state in
            guard
                let self = self,
                let state = state else { return }
            switch state {
            case let .initial(totalTime):
                self.resultLabel.text = R.string.schulteResult.resultMessage() + totalTime
                self.resultLabel.heroModifiers = [.fade, .scale(0.5)]
                self.messageLabel.heroModifiers = [.fade, .scale(0.5)]
                self.homeButton.heroModifiers = [.fade]
                self.restartButton.heroModifiers = [.fade]
                self.restartButton.heroID = "button"
            }
        }.store(in: &cancellables)
    }

    private func setupUI() {
        setupNavigationBar()
        setupLocalization()
    }

    private func setupNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }

    private func setupLocalization() {
        homeButton.setTitle(R.string.schulteResult.home(), for: .normal)
        restartButton.setTitle(R.string.schulteResult.restart(), for: .normal)
        messageLabel.text = R.string.schulteResult.goodJob()
    }
}
