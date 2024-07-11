//
//  SummaryViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/26/24.
//

import UIKit
import SnapKit


protocol SummaryViewControllerDelegate: AnyObject {
    func didSaveExpense(_ expense: Expense)
}

class SummaryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    weak var delegate: SummaryViewControllerDelegate?
    
    var selectedCategory: String?
    var selectedDate: Date?
    var amount: Double?
    var pinLogId: String?
    var selectedImageName: String?
//    var buttonFeedBackViewController: ButtonFeedBackViewController?


    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " Title.."
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.darkgray.cgColor
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.layer.borderColor = UIColor.darkgray.cgColor
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.backgroundColor = .systemBackground
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8

        let attributedString = NSAttributedString(string: "", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraphStyle
        ])
        
        textView.attributedText = attributedString
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.backgroundColor = .font
        button.tintColor = UIColor(named: "textColor")
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        populateData()
        
        titleTextField.delegate = self
        memoTextView.delegate = self
    }

    let categories = CategoryData.categories.map { $0.1 }
    let categoryImageMapping = CategoryData.categoryImageMapping
    
    private func setupUI() {
        view.addSubview(categoryLabel)
        view.addSubview(dateLabel)
        view.addSubview(amountLabel)
        view.addSubview(titleTextField)
        view.addSubview(memoTextView)
        view.addSubview(saveButton)

        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(160)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(memoTextView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        saveButton.setTitle("Save Expense", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    private func provideHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    
    private func populateData() {
        categoryLabel.text = " ✔︎ 지출 구분: \(selectedCategory ?? "")"
        if let date = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            dateLabel.text = " ✔︎ 지출 날짜: \(dateFormatter.string(from: date))"
        }
        if let amount = amount {
            amountLabel.text = " ✔︎ 지출 금액: \(Formatter.withSeparator.string(from: NSNumber(value: amount)) ?? "")"
        }
    }

    @objc private func saveButtonTapped() {
        guard let category = selectedCategory, !category.isEmpty else {
            showAlert(title: "카테고리 선택", message: "카테고리를 선택해주세요.")
            return
        }
        guard let date = selectedDate else {
            showAlert(title: "날짜 선택", message: "유효한 날짜를 선택해주세요.")
            return
        }
        guard let amount = amount, amount > 0 else {
            showAlert(title: "금액 입력", message: "유효한 금액을 입력해주세요.")
            return
        }
        let title = titleTextField.text ?? ""
        saveButton.isEnabled = false
        let imageName = CategoryData.categoryImageMapping[category] ?? ""
        let expense = Expense(
            date: date,
            expenseContent: title.isEmpty ? "" : title,
            expenseAmount: Int(amount),
            category: category,
            memo: memoTextView.text,
            imageName: imageName
        )

        delegate?.didSaveExpense(expense)
        showButtonFeedBackView()
        dismiss(animated: true, completion: nil)
        saveButton.isEnabled = true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            memoTextView.becomeFirstResponder()
        }
        return true
    }
    
    private func showButtonFeedBackView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let buttonFeedBackVC = ButtonFeedBackViewController()
            let feedbackWindow = UIWindow(windowScene: windowScene)
            feedbackWindow.rootViewController = buttonFeedBackVC
            feedbackWindow.backgroundColor = .clear
            feedbackWindow.windowLevel = .alert + 1
            feedbackWindow.isHidden = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                feedbackWindow.isHidden = true
            }
        }
    }

    @objc func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note.."
            textView.textColor = .darkgray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.darkgray {
            textView.textColor = UIColor.font
            textView.text = nil
        }
    }
    
    @objc func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkgray {
            textView.text = nil
            textView.textColor = .font
        }
    }
    
    @objc func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note.."
            textView.textColor = UIColor.darkgray
        }
    }
    
    func textField(_ _textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = titleTextField.text as NSString? else { return true }
        let newText = text.replacingCharacters(in: range, with: string)
        
        if newText.count <= 18 {
            titleTextField.layer.borderColor = UIColor.darkgray.cgColor
            return true
        } else {
            provideHapticFeedback()
            titleTextField.layer.borderColor = UIColor.red.withAlphaComponent(0.1).cgColor
            return false
        }
    }
    
    func textView(_ _textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {
        guard let text = memoTextView.text as NSString? else { return true }
        let newText = text.replacingCharacters(in: range, with: string)
        
        if newText.count <= 36 {
            memoTextView.layer.borderColor = UIColor.darkgray.cgColor
            return true
        } else {
            provideHapticFeedback()
            memoTextView.layer.borderColor = UIColor.red.withAlphaComponent(0.1).cgColor
            return false
        }
    }
}
