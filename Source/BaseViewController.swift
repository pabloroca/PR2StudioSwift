//
//  BaseViewController.swift
//
//  Created by Pablo Roca Rozas
//  Copyright © 2018 PR2Studio. All rights reserved.
//

import UIKit

open class BaseViewController: UIViewController {

    // MARK: - properties

    open var shouldShowViewWaiting: Bool = false {
        didSet {
            shouldShowViewWaiting ? showViewWaiting() : hideViewWaiting()
        }
    }

    private let pr2FontHeader: UIFont = {
        return UIFont.boldSystemFont(ofSize: 15)
    }()

    private let pr2ColorMain: UIColor = {
        return UIColor.black
    }()

    private(set) var didSetupConstraints: Bool = false

    private var hidesBackButton: Bool = false {
        didSet {
            self.navigationItem.setHidesBackButton(hidesBackButton, animated: false)
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        var label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.7
        label.adjustsFontSizeToFitWidth = true
        label.font = pr2FontHeader
        label.textColor = pr2ColorMain
        label.backgroundColor = UIColor.clear
        self.navigationItem.titleView = label
        return label
    }()

    private let viewWaiting: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.isHidden = true
        return view
    }()

    private lazy var lblWaiting: UILabel = {
        let label = UILabel()
        label.textColor = pr2ColorMain
        label.font = pr2FontHeader
        label.textAlignment = .center
        label.text = NSLocalizedString("loadingdata", comment: "")
        return label
    }()

    private let waitingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = .gray
        return activityIndicator
    }()

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
    }

    // MARK: - Constraints

    override open func updateViewConstraints() {
        if !didSetupConstraints {
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true

            setupConstraints()
            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    override open func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white

        setupLoadView()

        view.setNeedsUpdateConstraints()
    }

    private func setupLoadView() {
        view.addSubview(viewWaiting)
        viewWaiting.addSubview(lblWaiting)
        viewWaiting.addSubview(waitingIndicator)

        view.bringSubview(toFront: viewWaiting)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activateAndAutoresizingMask([
            viewWaiting.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewWaiting.topAnchor.constraint(equalTo: view.topAnchor),
            viewWaiting.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewWaiting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lblWaiting.bottomAnchor.constraint(lessThanOrEqualTo: waitingIndicator.topAnchor, constant: -PR2Constants.kMarginBig),
            lblWaiting.rightAnchor.constraint(equalTo: view.leftAnchor),
            lblWaiting.rightAnchor.constraint(equalTo: view.rightAnchor),
            waitingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waitingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
    }

    func setupTitle() -> String {
        return self.title ?? ""
    }

    // MARK: - Setup

    func setupNavigationBar() {
        titleLabel.text = setupTitle()
        //        showBackButton(true)
    }

    //    func showBackButton(_ show: Bool) {
    //        if show {
    //            let backButton = UIBarButtonItem(image: UIImage(named: "back_icon"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(BaseViewController.goBack))
    //
    //            self.navigationItem.leftBarButtonItem = backButton
    //        } else {
    //            self.navigationItem.leftBarButtonItem = nil
    //            self.hidesBackButton = true
    //        }
    //    }

    //    @objc func goBack() {
    //        self.navigationController?.popViewController(animated: true)
    //    }

    // MARK: - Custom methods

    private func showViewWaiting() {
        viewWaiting.isHidden = false
        waitingIndicator.startAnimating()
    }

    private func hideViewWaiting() {
        lblWaiting.text = NSLocalizedString("loadingdata", comment: "")
        waitingIndicator.stopAnimating()
        viewWaiting.isHidden = true
    }

    @objc open func showSlowInterNet() {
        lblWaiting.text = NSLocalizedString("slowinternet", comment: "")
        showViewWaiting()
    }
}
