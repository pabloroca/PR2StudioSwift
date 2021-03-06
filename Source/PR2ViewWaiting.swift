//
//  PR2ViewWaiting.swift
//  PR2StudioSwift
//
//  Created by Pablo Roca Rozas on 3/6/18.
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import UIKit

public final class PR2ViewWaiting: UIView {

    public var message: String = "" {
        didSet {
            self.lblWaiting.text = message
        }
    }

    private lazy var lblWaiting: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()

    private lazy var waitingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .gray
        return activityIndicator
    }()

    public init(message: String = "Loading data ...") {
        super.init(frame: .zero)
        self.lblWaiting.text = message
        configureUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        backgroundColor = UIColor.white
        isHidden = true

        addSubview(waitingIndicator)
        waitingIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waitingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            waitingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])

        addSubview(lblWaiting)
        lblWaiting.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lblWaiting.topAnchor.constraint(equalTo: topAnchor),
            lblWaiting.leadingAnchor.constraint(equalTo: leadingAnchor),
            lblWaiting.trailingAnchor.constraint(equalTo: trailingAnchor),
            lblWaiting.bottomAnchor.constraint(equalTo: waitingIndicator.topAnchor, constant: 15.0)
            ])
    }

    // MARK: - Custom methods

    public func show() {
        isHidden = false
        waitingIndicator.startAnimating()
    }

    public func hide() {
        waitingIndicator.stopAnimating()
        isHidden = true
    }
}
