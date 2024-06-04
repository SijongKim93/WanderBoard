//
//  DatePresentationController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 6/3/24.
//

import UIKit
import SnapKit
import Then

class DatePresentationController: UIPresentationController {
    
    private let dimmingView = UIView()
    private let messageLabel = UILabel().then {
        $0.text = "날짜를 선택해 주세요"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textAlignment = .center
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        return CGRect(x: 0, y: containerView.bounds.height * 0.3, width: containerView.bounds.width, height: containerView.bounds.height * 0.7)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView else { return }
        
        dimmingView.frame = containerView.bounds
        dimmingView.backgroundColor = UIColor.black
        dimmingView.alpha = 0
        containerView.insertSubview(dimmingView, at: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tapGesture)
        dimmingView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(containerView.bounds.height * 0.2)
        }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
        
        presentedView.frame = frameOfPresentedViewInContainerView
        containerView.addSubview(presentedView)
    }
    
    @objc func dimmingViewTapped() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    override func containerViewDidLayoutSubviews() {
        dimmingView.frame = containerView?.bounds ?? CGRect.zero
    }
    
    func shouldRemovePresentersView() -> Bool {
        return false
    }
    
}
