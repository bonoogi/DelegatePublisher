//
//  ViewController.swift
//  SampleApp
//
//  Created by 구본욱 on 2022/11/19.
//

import UIKit

class ViewController: UIViewController {

    let scrollStateLabel = UILabel()
    let scrollView = UIScrollView()
    let stackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollStateLabel)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        configureViews()
        configureLayouts()
        addScrollItems()
    }

    private func configureViews() {
        view.backgroundColor = .systemBackground

        scrollStateLabel.textAlignment = .center
        scrollStateLabel.contentMode = .center
        scrollStateLabel.textColor = .label
        scrollStateLabel.text = "Current ContentOffset Y: \(scrollView.contentOffset.y)"

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 8
    }

    private func configureLayouts() {
        scrollStateLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollStateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollStateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        scrollStateLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: scrollStateLabel.bottomAnchor, constant: 16).isActive = true
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
}

