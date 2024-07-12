//
//  SignUpViewController.swift
//  WanderBoard
//
//  Created by David Jang on 6/7/24.
//

import UIKit
import PhotosUI
import SnapKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, PHPickerViewControllerDelegate, UITextFieldDelegate {
    
    var uid: String?
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 53
        imageView.clipsToBounds = true
        
        let backgroundColors = [
            UIColor(named: "ProfileBackgroundColor1"),
            UIColor(named: "ProfileBackgroundColor2"),
            UIColor(named: "ProfileBackgroundColor3"),
            UIColor(named: "ProfileBackgroundColor4"),
            UIColor(named: "ProfileBackgroundColor5"),
            UIColor(named: "ProfileBackgroundColor6"),
            UIColor(named: "ProfileBackgroundColor7")
        ]
        
        imageView.backgroundColor = backgroundColors.randomElement()!
        
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.contentMode = .scaleAspectFit
        label.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
    
        return label
    }()

    

    private let emailArea = UIView()
    
    private let emailIcon = UIImageView().then(){
        $0.contentMode = .scaleAspectFit
    }
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "닉네임을 입력하세요"
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.black.cgColor
        textField.autocapitalizationType = .none
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 45))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let nicknameHintLabel: UILabel = {
        let label = UILabel()
        label.text = "*2글자 이상, 16글자 이하, 공백과 특수문자 불가."
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .darkgray
        return label
    }()
    
    private let duplicateCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복확인", for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true

        
        return button
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    private lazy var genderButtons: [UIButton] = {
        let titles = ["남성", "여성", "선택안함"]
        return titles.map { title in
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.baseBackgroundColor = title == "선택안함" ? .font : UIColor(named: "textColor")
            configuration.baseForegroundColor = title == "선택안함" ? UIColor(named: "textColor") : .font
            configuration.cornerStyle = .capsule
            if title != "선택안함" {
                configuration.background.strokeColor = UIColor(named: "textColor")
                configuration.background.strokeWidth = 1
            }
            
            let button = UIButton(configuration: configuration, primaryAction: nil)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            button.isSelected = title == "선택안함"
            button.configurationUpdateHandler = { button in
                var updatedConfiguration = button.configuration
                updatedConfiguration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)
                if button.isSelected {
                    updatedConfiguration?.baseBackgroundColor = .font
                    updatedConfiguration?.baseForegroundColor = UIColor(named: "textColor")
                    updatedConfiguration?.background.strokeWidth = 0
                } else {
                    updatedConfiguration?.baseBackgroundColor = UIColor(named: "textColor")
                    updatedConfiguration?.baseForegroundColor = .font
                    updatedConfiguration?.background.strokeColor = .font
                    updatedConfiguration?.background.strokeWidth = 1
                }
                button.configuration = updatedConfiguration
            }
            return button
        }
    }()
    
    private let interestsLabel: UILabel = {
        let label = UILabel()
        label.text = "관심 여행지"
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        return label
    }()
    
    private let interestsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " #관심 여행지를 입력해보세요"
        textField.borderStyle = .none
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 10
        textField.layer.borderColor = UIColor.font.cgColor
        textField.isUserInteractionEnabled = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 45))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let tagScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let tagContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let privacyCheckBox: UIButton = {
        var configuration = UIButton.Configuration.plain()
//        configuration.image = UIImage(systemName: "circle")
//        configuration.imagePadding = 8
//        configuration.baseForegroundColor = .font
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.isEnabled = false
        
        let titleText = NSMutableAttributedString(
            string: " 이용약관 및 개인정보처리방침 ",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.font
            ]
        )
        
        let mandatoryText = NSAttributedString(
            string: "(필수)",
            attributes: [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.darkgray
            ]
        )
        
        titleText.append(mandatoryText)
        button.setAttributedTitle(titleText, for: .normal)
        
        button.configurationUpdateHandler = { button in
//            let image = button.isSelected ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle")
            var updatedConfiguration = button.configuration
//            updatedConfiguration?.image = image
            button.configuration = updatedConfiguration
        }
        
        return button
    }()
    
    private let privacyPolicyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인하기 ＞", for: .normal)
        button.titleLabel?.font.withSize(10)
        button.setTitleColor(.font, for: .normal)
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var selectedImage: UIImage?
    private var gender: String = "선택안함"
    private var interests: [String] = []
    private var isProfileComplete: Bool = false
    private var interestTags: [String] = []
    var activeTextField: UITextField?
    
    var agreedToTerms: Bool = false
    var agreedToPrivacyPolicy: Bool = false
    var agreedToMarketing: Bool = false
    var agreedToThirdParty: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        checkProfileCompletion()
        interestsTextField.delegate = self
        
        self.title = "회원가입"
        setupNavigationBar()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        interestsTextField.addTarget(self, action: #selector(interestsTextFieldDidChange(_:)), for: .editingChanged)
        updateDuplicateCheckButtonState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let user = Auth.auth().currentUser {
            emailLabel.text = user.email
            setEmailIcon(for: user.providerData.first?.providerID)
        } else if let uid = uid {
            Task {
                let email = try? await AuthenticationManager.shared.fetchEmailFromFirestore(uid: uid)
                DispatchQueue.main.async {
                    self.emailLabel.text = email
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.tintColor = .font
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.font]
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let keyboardTop = self.view.frame.height - keyboardHeight
            let activeTextFieldBottom = activeTextField?.frame.maxY ?? 0
            
            if activeTextFieldBottom > keyboardTop {
                let offset = activeTextFieldBottom - keyboardTop + 70
                self.view.frame.origin.y = -offset
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        if textField == interestsTextField, textField.text?.isEmpty ?? true {
            textField.text = "#"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if activeTextField == textField {
            activeTextField = nil
            self.view.frame.origin.y = 0
        }
    }
    
    
    
    private func setupViews() {
        
        signUpButton.isEnabled = false
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        signUpButton.backgroundColor = babyGTocustomB
        
        view.addSubview(profileImageView)
        profileImageView.addSubview(nameLabel)
        view.addSubview(emailArea)
        emailArea.addSubview(emailIcon)
        emailArea.addSubview(emailLabel)
        view.addSubview(nickNameLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameHintLabel)
        view.addSubview(duplicateCheckButton)
        view.addSubview(genderLabel)
        genderButtons.forEach { view.addSubview($0) }
        view.addSubview(interestsLabel)
        view.addSubview(interestsTextField)
        view.addSubview(tagScrollView)
        tagScrollView.addSubview(tagContainerView)
        view.addSubview(privacyCheckBox)
        view.addSubview(privacyPolicyButton)
        view.addSubview(signUpButton)
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(106)
            make.height.equalTo(106)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
//            make.width.equalTo(profileImageView.snp.width).multipliedBy(0.9)
//            make.height.equalTo(profileImageView.snp.height).multipliedBy(0.9)
        }
        
        emailArea.snp.makeConstraints(){
            $0.top.equalTo(profileImageView.snp.bottom).offset(30)
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(view).inset(32)
        }
        
        emailIcon.snp.makeConstraints { make in
            make.left.equalTo(emailArea)
            make.centerY.equalTo(emailArea)
            make.width.height.equalTo(18)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.left.equalTo(emailIcon.snp.right).offset(10)
            make.centerY.equalTo(emailArea)
            make.right.equalTo(emailArea)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(emailArea.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(48)
        }
        
        nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(32)
            make.right.equalTo(duplicateCheckButton.snp.left).offset(-10)
            make.height.equalTo(44)
        }
        
        duplicateCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameTextField.snp.centerY)
            make.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.width.equalTo(100)
        }
        
        nicknameHintLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(32)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameHintLabel.snp.bottom).offset(41)
            make.left.equalToSuperview().inset(48)
        }
        
        var lastButton: UIButton?
        for (index, button) in genderButtons.enumerated() {
            view.addSubview(button)
            button.snp.makeConstraints { make in
                if index == 0 {
                    make.left.equalTo(genderLabel.snp.right).offset(36)
                    make.centerY.equalTo(genderLabel.snp.centerY)
                } else {
                    make.left.equalTo(lastButton!.snp.right).offset(10)
                    make.centerY.equalTo(genderLabel.snp.centerY)
                }
                if index == genderButtons.count - 1 {
                    make.right.equalToSuperview().inset(32)
                }
                make.height.equalTo(44)
            }
            lastButton = button
            button.addTarget(self, action: #selector(selectGender(_:)), for: .touchUpInside)
        }
        
        interestsLabel.snp.makeConstraints { make in

            make.top.equalTo(lastButton!.snp.bottom).offset(24)
            make.left.equalToSuperview().inset(48)

        }
        
        interestsTextField.snp.makeConstraints { make in
            make.top.equalTo(interestsLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(32)
            make.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
        }
        
        tagScrollView.snp.makeConstraints { make in
            make.top.equalTo(interestsTextField.snp.bottom).offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(36)
        }
        
        tagContainerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        privacyCheckBox.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top).offset(-16)
            make.left.equalToSuperview().inset(32)
        }
        
        privacyPolicyButton.snp.makeConstraints { make in
            make.bottom.equalTo(signUpButton.snp.top).offset(-16)
            make.right.equalToSuperview().inset(32)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(32)
            make.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(30)
        }
        
        privacyCheckBox.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        duplicateCheckButton.addTarget(self, action: #selector(duplicateCheckTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        privacyCheckBox.addTarget(self, action: #selector(updatePrivacyPolicyButtonState), for: .valueChanged)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
        }
    }
    
    private func checkProfileCompletion() {
        if let uid = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    self.isProfileComplete = data?["isProfileComplete"] as? Bool ?? false
                    if self.isProfileComplete {
                        self.switchToPageViewController()
                    }
                }
            }
        }
    }
    
    @objc private func profileImageTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    private func setEmailIcon(for providerID: String?) {
        guard let providerID = providerID else { return }
        let kakaoColor = traitCollection.userInterfaceStyle == .dark ? UIColor.kakaoYellow : UIColor(red: 60/255, green: 29/255, blue: 30/255, alpha: 1)
        
        switch providerID {
            case "google.com":
                emailIcon.image = UIImage(named: "googleLogo")
            case "apple.com":
                emailIcon.image = UIImage(named: "appleLogo")?.withTintColor(UIColor.font)
            case "kakao.com":
            emailIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            emailIcon.tintColor = kakaoColor
            default:
            emailIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            emailIcon.tintColor = kakaoColor
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let image = image as? UIImage else { return }
            DispatchQueue.main.async {
                self.profileImageView.image = image
                self.selectedImage = image
                self.nameLabel.isHidden = true
            }
        }
    }
    
    @objc private func duplicateCheckTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "😗", message: "닉네임을 입력해주세요. \n입력하신 닉네임은 다른 사용자에게 노출됩니다.🤭")
            return
        }
        
        // 특수문자 검증
        let nicknamePattern = "^[a-zA-Z0-9가-힣]+$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        if !nicknamePredicate.evaluate(with: nickname) {
            showAlert(title: "🤬", message: "닉네임에 특수문자 및 공백을 포함할 수 없습니다.")
            return
        }
        
        Task {
            do {
                let isDuplicate = try await FirestoreManager.shared.checkDisplayNameExists(displayName: nickname)
                if isDuplicate {
                    showAlert(title: "😱", message: "아쉽네요. 다른 사용자가 먼저 등록했어요")
                } else {
                    showConfirmationAlert(title: "😁\n\(nickname)", message: "당신만의 멋진 닉네임이네요. \n이 닉네임을 사용하시겠습니까?", nickname: nickname)
                }
            } catch {
                showAlert(title: "😵‍💫", message: "닉네임 확인 중 오류가 발생했습니다: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: 관심여행지 관련 메서드
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        updateSignUpButtonState()
        updateDuplicateCheckButtonState()
    }
    
    @objc private func interestsTextFieldDidChange(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.hasPrefix("#"), isValidInterest(text) {
            addInterestTag(text)
            textField.text = "#"
        }
        textField.becomeFirstResponder() // 커서 유지
        return true
    }
    
    private func isValidInterest(_ text: String) -> Bool {
        let pattern = "^#[a-zA-Z0-9가-힣]+$"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
    
    private func addInterestTag(_ text: String) {
        let tagLabel = UILabel()
        tagLabel.text = text
        tagLabel.font = UIFont.systemFont(ofSize: 14)
        tagLabel.textColor = .darkgray
        
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        tagLabel.backgroundColor = babyGTocustomB
        tagLabel.layer.cornerRadius = 10
        tagLabel.clipsToBounds = true
        tagLabel.textAlignment = .center
        tagLabel.sizeToFit()

        let tagWidth = tagLabel.frame.width + 32
        
        tagContainerView.addSubview(tagLabel)
        
        let previousTagLabel = tagContainerView.subviews.dropLast().last
        tagLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            if let previous = previousTagLabel {
                make.left.equalTo(previous.snp.right).offset(8)
            } else {
                make.left.equalToSuperview().inset(30)
            }
            make.width.equalTo(tagWidth)
        }
        
        tagContainerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.right.equalTo(tagLabel.snp.right).offset(8)
        }
        
        interestTags.append(text)
        updateSignUpButtonState()
        
        // Scroll to the added tag
        tagScrollView.layoutIfNeeded()
        let contentWidth = tagContainerView.frame.width
        let offsetX = max(contentWidth - tagScrollView.bounds.width, 0)
        tagScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    private func updateDuplicateCheckButtonState() {
        let nicknameLength = nicknameTextField.text?.count ?? 0
        let isValidLength = nicknameLength >= 2 && nicknameLength <= 16
        duplicateCheckButton.isEnabled = isValidLength
        let lightGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "lightgray")
               duplicateCheckButton.backgroundColor = isValidLength ? .font : lightGTocustomB
               duplicateCheckButton.setTitleColor(isValidLength ? UIColor(named: "textColor") : .darkgray, for: .normal)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    // 확인 및 취소
    private func showConfirmationAlert(title: String, message: String, nickname: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let useAction = UIAlertAction(title: "사용", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.confirmButtonTapped(with: nickname)
            self.nicknameTextField.isEnabled = false
            self.duplicateCheckButton.isEnabled = false
            let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
            self.duplicateCheckButton.backgroundColor = babyGTocustomB
            self.updateSignUpButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.nicknameTextField.text = ""
            self.nicknameTextField.isEnabled = true
            self.duplicateCheckButton.isEnabled = true
            let lightGTodarkG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "darkgray") : UIColor(named: "lightgray")
            self.duplicateCheckButton.backgroundColor = lightGTodarkG
            let darkGTolightG = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightgray") : UIColor(named: "darkgray")
            self.nicknameTextField.textColor = darkGTolightG
        }
        
        alert.addAction(useAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmButtonTapped(with nickname: String) {
        let shortNickname = String(nickname.prefix(2))
        
        // Only set the nameLabel if no image is selected
        if selectedImage == nil {
            nameLabel.text = shortNickname
            nameLabel.isHidden = false
        } else {
            nameLabel.isHidden = true
        }

        let backgroundColors = [
            UIColor(named: "ProfileBackgroundColor1"),
            UIColor(named: "ProfileBackgroundColor2"),
            UIColor(named: "ProfileBackgroundColor3"),
            UIColor(named: "ProfileBackgroundColor4"),
            UIColor(named: "ProfileBackgroundColor5"),
            UIColor(named: "ProfileBackgroundColor6"),
            UIColor(named: "ProfileBackgroundColor7")
        ]
        
        profileImageView.backgroundColor = backgroundColors.randomElement()!
        
        if selectedImage == nil {
            nameLabel.text = shortNickname.uppercased()
        }
    }
    
    @objc private func selectGender(_ sender: UIButton) {
        genderButtons.forEach { $0.isSelected = false }
        sender.isSelected = true
    }
    
    @objc private func privacyPolicyTapped() {
        let privacyVC = PrivacyPolicyViewController()
        privacyVC.completionHandler = { [weak self] agreedToTerms, agreedToPrivacyPolicy, agreedToMarketing, agreedToThirdParty in
            guard let self = self else { return }
            self.agreedToTerms = agreedToTerms
            self.agreedToPrivacyPolicy = agreedToPrivacyPolicy
            self.agreedToMarketing = agreedToMarketing
            self.agreedToThirdParty = agreedToThirdParty
            self.privacyCheckBox.isSelected = agreedToTerms && agreedToPrivacyPolicy
            self.updateSignUpButtonState()
            self.updatePrivacyPolicyButtonState()
        }
        privacyVC.modalPresentationStyle = .formSheet
        present(privacyVC, animated: true, completion: nil)
    }
    
    @objc private func updatePrivacyPolicyButtonState() {
        privacyPolicyButton.isEnabled = !privacyCheckBox.isSelected
        privacyPolicyButton.setTitleColor(privacyCheckBox.isSelected ? .lightGray : .font, for: .normal)
    }
    
    private func updateSignUpButtonState() {
        let isFormValid = nicknameTextField.isEnabled == false && privacyCheckBox.isSelected
        signUpButton.isEnabled = isFormValid
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        signUpButton.backgroundColor = isFormValid ? .font : babyGTocustomB
        signUpButton.setTitleColor(isFormValid ? UIColor(named: "textColor") : .darkgray, for: .normal )
    }
    
    @objc private func signUpTapped() {
        guard signUpButton.isEnabled else { return }
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "🧐", message: "닉네임을 입력하세요.")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 이미지를 업로드할 UIImage 결정
        let imageToUpload: UIImage
        let isDefaultProfile: Bool

        if let selectedImage = selectedImage {
            // 이미지가 선택되었으면 해당 이미지 사용
            imageToUpload = selectedImage
            isDefaultProfile = false
        } else {
            // 기본 이미지 사용
            // 임시 뷰 생성 및 캡쳐
            let temporaryView = UIView(frame: profileImageView.bounds)
            temporaryView.backgroundColor = profileImageView.backgroundColor
            let tempImageView = UIImageView(image: profileImageView.image)
            tempImageView.frame = profileImageView.bounds
            tempImageView.layer.cornerRadius = profileImageView.layer.cornerRadius
            tempImageView.clipsToBounds = true
            temporaryView.addSubview(tempImageView)
            
            let tempLabel = UILabel(frame: nameLabel.frame)
            tempLabel.text = nameLabel.text
            tempLabel.font = nameLabel.font
            tempLabel.textColor = nameLabel.textColor
            tempLabel.textAlignment = nameLabel.textAlignment
            tempLabel.center = tempImageView.center
            temporaryView.addSubview(tempLabel)
            
            imageToUpload = temporaryView.asImage()
            isDefaultProfile = true
        }
        
        let storageRef = Storage.storage().reference().child("profileImages/\(uid).jpg")
        
        if let imageData = imageToUpload.jpegData(compressionQuality: 0.75) {
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading profile image: \(error)")
                    return
                }
                
                storageRef.downloadURL { url, error in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    Firestore.firestore().collection("users").document(uid).updateData([
                        "displayName": nickname,
                        "photoURL": downloadURL.absoluteString,
                        "gender": self.gender,
                        "interests": self.interestTags,
                        "isProfileComplete": true,
                        "isLoggedIn": true,
                        "agreedToTerms": self.agreedToTerms,
                        "agreedToPrivacyPolicy": self.agreedToPrivacyPolicy,
                        "agreedToMarketing": self.agreedToMarketing,
                        "agreedToThirdParty": self.agreedToThirdParty,
                        "isDefaultProfile": isDefaultProfile, // 프로필 이미지 상태 저장
                        "joinedDate": FieldValue.serverTimestamp(),
                    ]) { error in
                        if let error = error {
                            print("Error updating user data: \(error)")
                            return
                        }
                        self.switchToPageViewController()
                    }
                }
            }
        }
    }
    
    private func switchToPageViewController() {
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) {
            window.rootViewController = PageViewController()
            window.makeKeyAndVisible()
        }
    }
}

extension SignUpViewController {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == interestsTextField {
            let regex = "^#\\w*$" // 유효한 입력은 #으로 시작하고 문자나 숫자가 뒤따름
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            return predicate.evaluate(with: updatedText)
        }
        
        return true
    }
}

extension UIViewController {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
