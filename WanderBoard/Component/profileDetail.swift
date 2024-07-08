//
//  profileDetail.swift
//  WanderBoard
//
//  Created by 이시안 on 6/28/24.
//

import UIKit
import SnapKit
import Then

class profileDetail: UIViewController {
    
    let backGroundView = UIView().then(){
        $0.backgroundColor = UIColor(white: 1, alpha: 0.9)
    }
    let profileImage = UIImageView().then(){
        $0.backgroundColor = .font
        $0.layer.cornerRadius = 105.5
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    let nameLabel = UILabel().then(){
        $0.text = "닉네임"
        $0.textColor = .font
        $0.font = UIFont.boldSystemFont(ofSize: 17)
        $0.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        constraintLayout()
        updateColor()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissModal(_:)))
        backGroundView.isUserInteractionEnabled = true
        backGroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func constraintLayout(){
        view.addSubview(backGroundView)
        [profileImage, nameLabel].forEach(){
            backGroundView.addSubview($0)
        }
        backGroundView.snp.makeConstraints(){
            $0.edges.equalTo(view)
        }
        profileImage.snp.makeConstraints(){
            $0.centerY.equalToSuperview().offset(-70)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(211)
        }
        nameLabel.snp.makeConstraints(){
            $0.top.equalTo(profileImage.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor() {
        let Bcolor = traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0, alpha: 0.9) : UIColor(white: 1, alpha: 0.9)
        backGroundView.backgroundColor = Bcolor
    }
    
    @objc func dismissModal(_ sender: UITapGestureRecognizer){
        dismiss(animated: true, completion: nil)
    }
}
