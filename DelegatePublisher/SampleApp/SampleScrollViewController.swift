//
//  SampleScrollViewController.swift
//  SampleApp
//
//  Created by 구본욱 on 2022/11/19.
//

import Combine
import UIKit

import DelegatePublisher

class SampleScrollViewController: UIViewController {

    private var cancellables = Set<AnyCancellable>()

    let scrollStateStack = UIStackView()
    let scrollStateDelegateLabel = UILabel()
    let scrollStateCombineLabel1 = UILabel()
    let scrollStateCombineLabel2 = UILabel()

    var scrollStateLabels: [UILabel] {
        return  [scrollStateDelegateLabel, scrollStateCombineLabel1, scrollStateCombineLabel2]
    }

    let scrollView = UIScrollView()
    let stackView = UIStackView()

    deinit {
        print("DEINIT-SampleScrollviewController")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIScrollView + DelegatePublisher"

        view.addSubview(scrollStateStack)
        scrollStateStack.addArrangedSubview(scrollStateDelegateLabel)
        scrollStateStack.addArrangedSubview(scrollStateCombineLabel1)
        scrollStateStack.addArrangedSubview(scrollStateCombineLabel2)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        configureViews()
        configureLayouts()
        addScrollItems()
        bind()
    }

    private func configureViews() {
        view.backgroundColor = .systemBackground

        scrollStateStack.axis = .vertical
        scrollStateStack.distribution = .fill
        scrollStateStack.alignment = .fill
        scrollStateStack.spacing = 4

        scrollStateLabels.forEach { label in
            label.textAlignment = .center
            label.contentMode = .center
            label.textColor = .label
        }
        scrollStateDelegateLabel.text = "Delegate: Waiting for Scrolling Event..."
        scrollStateCombineLabel1.text = "Combine1: Waiting for Scrolling Event..."
        scrollStateCombineLabel2.text = "Combine2: Waiting for Scrolling Event..."

        scrollView.delegate = self

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
    }

    private func configureLayouts() {
        scrollStateStack.translatesAutoresizingMaskIntoConstraints = false
        scrollStateStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollStateStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollStateStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true

        scrollStateLabels.forEach { label in
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: scrollStateStack.bottomAnchor, constant: 16).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true

        scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
    }

    private func addScrollItems() {
        for index in 0..<100 {
            let label = UILabel(frame: .zero)
            label.textAlignment = .center
            label.contentMode = .center
            label.textColor = .label
            label.backgroundColor = .secondarySystemBackground
            label.text = "\(index)"
            label.layer.cornerRadius = 16
            label.layer.masksToBounds = true

            stackView.addArrangedSubview(label)

            label.translatesAutoresizingMaskIntoConstraints = false
            label.heightAnchor.constraint(equalToConstant: 48).isActive = true
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        }
    }

    private func bind() {
        scrollView.delegatePublsher
            .map { event -> CGFloat in
                switch event {
                case .didScroll(let uiScrollView):
                    return uiScrollView.contentOffset.y
                }
            }
            .sink { [weak self] contentOffsetY in
                self?.scrollStateCombineLabel1.text = "Combine1-ContentOffset Y: \(Int(contentOffsetY))"
            }
            .store(in: &cancellables)
        scrollView.delegatePublsher
            .map { event -> CGFloat in
                switch event {
                case .didScroll(let uiScrollView):
                    return uiScrollView.contentOffset.y
                }
            }
            .sink { [weak self] contentOffsetY in
                self?.scrollStateCombineLabel2.text = "Combine2-ContentOffset Y: \(Int(contentOffsetY))"
            }
            .store(in: &cancellables)
    }
}

extension SampleScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollStateDelegateLabel.text = "Delegate-ContentOffset Y: \(Int(scrollView.contentOffset.y))"
    }
}
