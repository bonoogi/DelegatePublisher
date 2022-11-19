//
//  ViewController.swift
//  SampleApp
//
//  Created by 구본욱 on 2022/11/19.
//

import Combine
import UIKit

import DelegatePublisher

class ViewController: UIViewController {

    let button = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "DelegatePublisher"
        view.addSubview(button)

        configureViews()
        configureLayouts()
    }

    private func configureViews() {
        view.backgroundColor = .systemBackground

        button.setTitle("스크롤뷰 보기", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
    }

    private func configureLayouts() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        button.widthAnchor.constraint(equalToConstant: 120).isActive = true
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }

    @objc private func buttonTap() {
        let scrollView = SampleScrollViewController()
        navigationController?.pushViewController(scrollView, animated: true)
    }
}

