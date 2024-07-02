//
//  SpendingTableViewCell.swift
//  WanderBoard
//
//  Created by t2023-m0049 on 6/3/24.
//

import Foundation
import UIKit

class SpendingTableViewCell: UITableViewCell {
    static let identifier = "cell"
    
    let categoryImageView: UIImageView = {
        let categoryImageView = UIImageView()
        categoryImageView.tintColor = .lightgray
        return categoryImageView
    }()
    
    let expenseContent: UILabel = {
        let expenseContent = UILabel()
        expenseContent.font = UIFont.systemFont(ofSize: 15)
        expenseContent.numberOfLines = 1
        return expenseContent
    }()
    
    let memo: UILabel = {
        let memo = UILabel()
        memo.font = UIFont.systemFont(ofSize: 12)
        memo.numberOfLines = 2
        return memo
    }()
    
    let expenseAmount: UILabel = {
        let expenseAmount = UILabel()
        expenseAmount.font = UIFont.systemFont(ofSize: 17)
        expenseAmount.adjustsFontSizeToFitWidth = true
        expenseAmount.textAlignment = .right
        return expenseAmount
    }()
    
    let expenseStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView
    }()
    
    override init(style: SpendingTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
        makeConstraints()
        updateColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        contentView.addSubview(categoryImageView)
        contentView.addSubview(expenseStackView)
        contentView.addSubview(expenseAmount)
        
        expenseStackView.addArrangedSubview(expenseContent)
        expenseStackView.addArrangedSubview(memo)
    }
    
    func makeConstraints() {
        categoryImageView.snp.makeConstraints {
            $0.leading.equalTo(contentView.safeAreaLayoutGuide).inset(32)
            $0.height.width.equalTo(44)
            $0.centerY.equalTo(contentView)
        }
        
        expenseStackView.snp.makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.equalTo(categoryImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(expenseAmount.snp.leading).offset(-12)
        }
        
        expenseAmount.snp.makeConstraints {
            $0.centerY.equalTo(contentView.snp.centerY)
            $0.leading.greaterThanOrEqualTo(expenseStackView.snp.trailing).offset(12)
            $0.width.equalTo(80)
            $0.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(32)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        let lightGTodarkG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "darkgray") : UIColor(named: "lightgray")
        categoryImageView.tintColor = lightGTodarkG
    }
    
    func configure(with expense: Expense) {
        expenseContent.text = expense.expenseContent
        memo.text = expense.memo
        expenseAmount.text = "\(formatCurrency(expense.expenseAmount))원"
        
        if !expense.imageName.isEmpty {
            categoryImageView.image = UIImage(named: expense.imageName)
        } else {
            categoryImageView.image = nil
        }

        if expense.memo.isEmpty {
            memo.isHidden = true
            expenseStackView.spacing = 0
        } else {
            memo.isHidden = false
            expenseStackView.spacing = 4
        }
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}
