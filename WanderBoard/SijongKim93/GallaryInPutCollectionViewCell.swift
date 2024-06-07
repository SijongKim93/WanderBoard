//
//  InPutGallaryCollectionViewCell.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 6/4/24.
//

import UIKit

class GallaryInPutCollectionViewCell: UICollectionViewCell {
    static let identifier = "GallaryInPutCollectionViewCell"
    
    let imageView = UIImageView()
    let addButton = UIButton(type: .system)
    
    let deleteButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(systemName: "xmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        $0.backgroundColor = .red
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(addButton)
        contentView.addSubview(deleteButton)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addButton.setTitle("+", for: .normal)
        addButton.setTitleColor(#colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
, for: .normal)
        addButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        addButton.backgroundColor = .clear
        addButton.layer.cornerRadius = 16
        addButton.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        addButton.layer.borderWidth = 1
        addButton.clipsToBounds = true
        addButton.isHidden = true
        addButton.isUserInteractionEnabled = false
        addButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-8)
            $0.trailing.equalToSuperview().offset(8)
            $0.width.height.equalTo(24)
        }
        
        deleteButton.addTarget(nil, action: #selector(DetailInputViewController.deletePhoto(_:)), for: .touchUpInside)
    }
    func configure(with image: UIImage?, isEditing: Bool) {
        if let image = image {
            imageView.image = image
            imageView.isHidden = false
            addButton.isHidden = true
        } else {
            imageView.isHidden = true
            addButton.isHidden = false
        }
        showDeleteButton(isEditing)
        if isEditing {
            startShaking()
        } else {
            stopShaking()
        }
    }
    
    func showDeleteButton(_ show: Bool) {
        deleteButton.isHidden = !show
    }
    
    func startShaking() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = -0.05
        animation.toValue = 0.05
        animation.duration = 0.1
        animation.repeatCount = .greatestFiniteMagnitude
        animation.autoreverses = true
        layer.add(animation, forKey: "shake")
    }
    
    func stopShaking() {
        layer.removeAllAnimations()
    }
}
