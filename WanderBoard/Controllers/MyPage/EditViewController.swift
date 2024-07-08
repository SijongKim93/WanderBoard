//
//  EditViewController.swift
//  WanderBoard
//
//  Created by 이시안 on 5/29/24.
//

import UIKit
import PhotosUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import CoreData

class EditViewController: BaseViewController, UITextFieldDelegate, PHPickerViewControllerDelegate {
    
    let doneButton = UIButton()
    let addImage = UIImageView().then {
        let config = UIImage.SymbolConfiguration(weight: .bold)
        $0.image = UIImage(systemName: "plus", withConfiguration: config)
        $0.tintColor = .lightblack
        $0.contentMode = .scaleAspectFit
    }
    let addImageLayer = UIView().then(){
        $0.backgroundColor = UIColor(white: 1, alpha: 0.7)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 53
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.contentMode = .scaleAspectFit
        label.font = UIFont.systemFont(ofSize: 42, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
    
        return label
    }()
    
    let profile = UIImageView()
    
    private let nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " 닉네임을 입력하세요"
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
    
    private let duplicateCheckButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("중복확인", for: .normal)
        button.backgroundColor = .font
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        return button
    }()
    
    let nameAlert = UILabel()
    var IDArea = UIView()
    var IDIcon = UIImageView()
    var myID = UILabel()
    let subLine = UIView()
    let withdrawalB = UIButton()
    var previousImage: UIImage?
    var previousName: String = ""
    var ID: String = ""
    var userData: User?
    var progressViewController: ProgressViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIcon()
        view.backgroundColor = .systemBackground
        // Firestore에서 isDefaultProfile 값
        fetchUserData()
        
        //뒤로가기 버튼을 눌렀을때 기존의 프로필에서 수정사항이 있는지 체크하기 위해 현재 남아있는 정보값은 이전의 값이라고 정의
        previousImage = profile.image
        previousName = nicknameTextField.text ?? ""
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(tapGestureRecognizer:)))
        profile.isUserInteractionEnabled = true
        profile.addGestureRecognizer(tapGestureRecognizer)
        
        doneButton.isEnabled = false
        
        // 기본 네비게이션 뒤로가기 버튼 숨기기
        self.navigationItem.hidesBackButton = true
        // 커스텀 뒤로가기 버튼 추가
        let backButton = createCustomBackButton()
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    private func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let isDefaultProfile = data?["isDefaultProfile"] as? Bool ?? true
                self.profile.tag = isDefaultProfile ? 1 : 0
            }
        }
    }
    
    override func configureUI(){
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.lightgray, for: .normal)
        doneButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        doneButton.addTarget(self, action: #selector(moveToMyPage), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: doneButton)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        profile.image = previousImage
        profile.clipsToBounds = true
        profile.contentMode = .scaleAspectFill
        profile.layer.cornerRadius = 53
        
        nicknameTextField.placeholder = previousName
        nicknameTextField.clearButtonMode = .never
        nicknameTextField.delegate = self
        
        duplicateCheckButton.addTarget(self, action: #selector(duplicateCheckTapped), for: .touchUpInside)
        
        IDIcon.contentMode = .scaleAspectFit
        
        nameAlert.text = "😗 글자 수를 맞춰주세요 (2자 이상, 16자 이하)"
        nameAlert.font = UIFont.systemFont(ofSize: 12)
        nameAlert.textColor = .darkgray
        
        myID.text = ID
        myID.font = UIFont.systemFont(ofSize: 13)
        myID.textColor = .font
        
        subLine.backgroundColor = .babygray
        subLine.layer.cornerRadius = 10
        
        withdrawalB.setTitle("회원탈퇴", for: .normal)
        withdrawalB.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        withdrawalB.setTitleColor(UIColor(named: "lightgray"), for: .normal)
        withdrawalB.addTarget(self, action: #selector(TappedWithdrawalB), for: .touchUpInside)
    }
    
    func getUserLogin() -> AuthDataResultModel? {
        guard let currentUser = Auth.auth().currentUser else {
            return nil
        }
        
        let authProvider = AuthProviderOption(rawValue: currentUser.providerData.first?.providerID ?? "") ?? .email
        return AuthDataResultModel(user: currentUser, authProvider: authProvider)
    }
    
    func setIcon() {
        
        guard let userData = self.userData else {
            print("등록된 로그인 정보가 없습니다")
            return
        }
        let kakaoColor = traitCollection.userInterfaceStyle == .dark ? UIColor.kakaoYellow : UIColor(red: 60/255, green: 29/255, blue: 30/255, alpha: 1)
        
        switch userData.authProvider {
        case AuthProviderOption.google.rawValue:
            self.IDIcon.image = UIImage(named: "googleLogo")
        case AuthProviderOption.apple.rawValue:
            self.IDIcon.image = UIImage(named: "appleLogo")?.withTintColor(UIColor.font)
        case AuthProviderOption.kakao.rawValue:
            self.IDIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            self.IDIcon.tintColor = kakaoColor
        case AuthProviderOption.email.rawValue:
            self.IDIcon.image = UIImage(named: "kakaoLogo")?.withRenderingMode(.alwaysTemplate)
            self.IDIcon.tintColor = kakaoColor // 이메일 로그인은 추가 안함, 카카오랑 같은 아이콘 뜨도록 설정
        default:
            print("등록된 로그인 정보가 없습니다")
        }
    }
    
    override func constraintLayout() {
        super.constraintLayout() //부모뷰의 설정을 가져온다
        [profile, nameLabel, addImage, nicknameTextField, nameAlert, duplicateCheckButton, IDArea, subLine, withdrawalB].forEach(){
            view.addSubview($0)
        }
        logo.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.width.equalTo(143)
            $0.height.equalTo(18.24)
            $0.bottom.equalTo(view).offset(-55)
        }
        
        profile.snp.makeConstraints(){
            $0.centerX.equalTo(view)
            $0.top.equalTo(view).offset(112)
            $0.width.height.equalTo(106)
        }
        profile.addSubview(addImageLayer)
        profile.addSubview(addImage)
        profile.addSubview(nameLabel)
        
        addImageLayer.snp.makeConstraints(){
            $0.edges.equalToSuperview()
        }
        
        addImage.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(25)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints(){
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        IDArea.addSubview(myID)
        IDArea.addSubview(IDIcon)
        IDIcon.snp.makeConstraints(){
            $0.left.equalTo(IDArea)
            $0.centerY.equalTo(IDArea)
            $0.width.height.equalTo(18)
        }
        
        IDArea.snp.makeConstraints(){
            $0.top.equalTo(profile.snp.bottom).offset(24)
            $0.centerX.equalTo(view)
            $0.width.lessThanOrEqualTo(view).inset(32)
        }
        
        myID.snp.makeConstraints(){
            $0.centerY.equalTo(IDArea)
            $0.left.equalTo(IDIcon.snp.right).offset(10)
            $0.right.equalTo(IDArea)
        }
        
        nicknameTextField.snp.makeConstraints(){
            $0.top.equalTo(IDArea.snp.bottom).offset(36)
            $0.left.equalToSuperview().inset(30)
            $0.right.equalTo(duplicateCheckButton.snp.left).offset(-10)
            $0.height.equalTo(43)
        }
        
        duplicateCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameTextField.snp.centerY)
            make.right.equalToSuperview().inset(30)
            make.height.equalTo(45)
            make.width.equalTo(100)
        }
        
        nameAlert.snp.makeConstraints(){
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.left.equalToSuperview().inset(30)
        }
        
        subLine.snp.makeConstraints(){
            $0.left.right.equalTo(view).inset(24)
            $0.height.equalTo(1)
            $0.top.equalTo(nameAlert.snp.bottom).offset(15)
        }
        
        withdrawalB.snp.makeConstraints(){
            $0.top.equalTo(subLine.snp.bottom).offset(15)
            $0.right.equalTo(subLine.snp.right).inset(16)
        }
    }
    //MARK: - 백버튼 커스텀
    func createCustomBackButton() -> UIBarButtonItem {
        // 커스텀 UIButton 생성
        //이미지 두껍게 설정
        let backButton = UIButton(type: .system)
        let largeConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let backImage = UIImage(systemName: "chevron.left", withConfiguration: largeConfig)
        backButton.setImage(backImage, for: .normal)
        
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backButton.sizeToFit()
        
        //글자와 이미지 사이 3만큼
        // 이미지와 텍스트 사이의 간격 설정
        let spacing: CGFloat = 3.0
        
        // iOS 버전에 따라 설정을 다르게 함
        //ios15에선 타이틀과 이미지인셋 직접 설정하는 방식 x
        if #available(iOS 15.0, *) {
            backButton.configuration?.imagePadding = spacing
        } else {
            //ios15 아래 버전은 이 방식을 참고
            backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
            backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        }
        
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        
        // 이미지와 텍스트 색상 설정
        backButton.setTitleColor(.font, for: .normal)
        backButton.tintColor = .font
        
        // 커스텀 버튼을 UIBarButtonItem으로 설정
        let barButtonItem = UIBarButtonItem(customView: backButton)
        return barButtonItem
    }
    
    @objc func backButtonPressed() {
        if unsavedChanges() {
            let alertController = UIAlertController(title: "저장 미완료", message: "변경사항이 저장되지 않았습니다.\n수정을 종료하고 돌아가시겠습니까?", preferredStyle: .alert)
            let leaveAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            let stayAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alertController.addAction(stayAction)
            alertController.addAction(leaveAction)
            present(alertController, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func unsavedChanges() -> Bool {
        let currentImage = profile.image
        let currentName = nicknameTextField.text ?? ""
        return currentImage != previousImage || currentName != previousName
    }
    
    //MARK: - 마이페이지로 돌아갈 때 해 줄 작업들
    
    @objc func moveToMyPage() {
        // 이미지와 이름 저장
        var nameToSave = nicknameTextField.text?.isEmpty ?? true ? previousName : nicknameTextField.text
        showProgressView()
        
        Task {
            do {
                // 사용자 정보를 Firestore에서 가져오기
                if nameToSave?.isEmpty ?? true {
                    guard let user = Auth.auth().currentUser else {
                        throw NSError(domain: "UserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어있지 않습니다"])
                    }
                    
                    let userRef = Firestore.firestore().collection("users").document(user.uid)
                    let document = try await userRef.getDocument()
                    
                    if let documentData = document.data() {
                        nameToSave = documentData["displayName"] as? String ?? previousName
                    }
                }
                
                // Firebase 사용자 프로필 업데이트
                try await updateProfile(displayName: nameToSave, photoURL: profile.image)
                
                // 사용자 정보를 Firestore에 저장
                guard let user = Auth.auth().currentUser else {
                    throw NSError(domain: "UserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어있지 않습니다"])
                }
                
                var dataToSave: [String: Any] = [
                    "email": user.email ?? "",
                    "displayName": nameToSave ?? "",
                    "authProvider": user.providerData.first?.providerID ?? "",
                    "isProfileComplete": true,
                    "isDefaultProfile": profile.tag == 1
                ]
                
                if let photoURL = user.photoURL?.absoluteString {
                    dataToSave["photoURL"] = photoURL
                }
                
                let userRef = Firestore.firestore().collection("users").document(user.uid)
                try await userRef.setData(dataToSave, merge: true)
                
                // MyPageViewController에 업데이트된 정보 반영
                if let navigationController = navigationController, let myPageVC = navigationController.viewControllers.first(where: { $0 is MyPageViewController }) as? MyPageViewController {
                    myPageVC.updateUserData(name: nameToSave!, image: profile.image)
                }
                
                let alert = UIAlertController(title: "", message: "수정이 완료되었습니다.", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                hideProgressView()
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            } catch {
                print("프로필 업데이트 실패: \(error.localizedDescription)")
                let alert = UIAlertController(title: "오류", message: "프로필 업데이트 중 오류가 발생했습니다. 다시 시도해주세요.", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "확인", style: .default)
                alert.addAction(confirm)
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - 로딩중 똑딱버튼
        private func showProgressView() {
            let progressVC = ProgressViewController()
            addChild(progressVC)
            view.addSubview(progressVC.view)
            progressVC.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            progressVC.didMove(toParent: self)
            progressViewController = progressVC
        }

        private func hideProgressView() {
            if let progressVC = progressViewController {
                progressVC.willMove(toParent: nil)
                progressVC.view.removeFromSuperview()
                progressVC.removeFromParent()
                progressViewController = nil
            }
        }
    
    // Firestore에 사용자 프로필 정보 업데이트
    func updateProfile(displayName: String?, photoURL: UIImage?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "UserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인되어있지 않습니다"])
        }
        
        let changeRequest = user.createProfileChangeRequest()
        
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        
        if let photoURL = photoURL, let photoData = photoURL.jpegData(compressionQuality: 0.75) {
            let storageRef = Storage.storage().reference().child("profileimages/\(user.uid).jpg")
            do {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                let _ = try await storageRef.putDataAsync(photoData, metadata: metadata)
                let downloadURL = try await storageRef.downloadURL()
                changeRequest.photoURL = downloadURL
                print("이미지 업로드 성공")
            } catch {
                throw NSError(domain: "StorageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 업로드 실패: \(error.localizedDescription)"])
            }
        }
        
        do {
            try await changeRequest.commitChanges()
            print("사용자 프로필 업데이트 성공")
        } catch {
            throw NSError(domain: "ProfileError", code: -1, userInfo: [NSLocalizedDescriptionKey: "프로필 업데이트 실패: \(error.localizedDescription)"])
        }
    }
    
    @objc private func duplicateCheckTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else {
            showAlert(title: "😗", message: "변경할 닉네임을 입력해주세요 \n입력하신 닉네임은 다른 사용자에게 노출됩니다.")
            return
        }
        
        if nickname.count < 2 || nickname.count > 16 {
            showAlert(title: "😱", message: "글자 수를 맞춰주세요 \n 닉네임은 2자 이상, 16자 이하여야 합니다.")
            return
        }
        
        // 특수문자 검증
        let nicknamePattern = "^[a-zA-Z0-9가-힣]+$"
        let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknamePattern)
        if !nicknamePredicate.evaluate(with: nickname) {
            showAlert(title: "🤬", message: "닉네임에 특수문자를 포함할 수 없습니다.")
            return
        }
        
        Task {
            do {
                let isDuplicate = try await FirestoreManager.shared.checkDisplayNameExists(displayName: nickname)
                if isDuplicate {
                    showAlert(title: "😱", message: "아쉽네요.. 다른 사용자가 먼저 등록했어요")
                } else {
                    showConfirmationAlert(title: "😁\n\(nickname)", message: "당신만의 멋진 닉네임이네요! \n이 닉네임을 사용하시겠습니까?", nickname: nickname)
                    
                }
            } catch {
                showAlert(title: "😵‍💫", message: "닉네임 확인 중 오류가 발생했습니다: \(error.localizedDescription)")
            }
        }
    }
    
    private func nickNameEditedProfileImageSetting(with nickname: String) {
        let fetchNicknameIfEmpty: (@escaping (String?) -> Void) -> Void = { completion in
            if let text = self.nicknameTextField.text, !text.isEmpty {
                completion(text)
            } else {
                guard let user = Auth.auth().currentUser else {
                    completion(nil)
                    return
                }
                
                let userRef = Firestore.firestore().collection("users").document(user.uid)
                userRef.getDocument { document, error in
                    if let document = document, document.exists {
                        let fetchedNickname = document.data()?["displayName"] as? String
                        completion(fetchedNickname)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
        
        fetchNicknameIfEmpty { [weak self] nicknameToUse in
            guard let self = self, let nicknameToUse = nicknameToUse else {
                print("Failed to fetch nickname")
                return
            }
            
            let shortNickname = String(nicknameToUse.prefix(2))
            self.nameLabel.text = shortNickname

            let backgroundColors = [
                UIColor(named: "ProfileBackgroundColor1"),
                UIColor(named: "ProfileBackgroundColor2"),
                UIColor(named: "ProfileBackgroundColor3"),
                UIColor(named: "ProfileBackgroundColor4"),
                UIColor(named: "ProfileBackgroundColor5"),
                UIColor(named: "ProfileBackgroundColor6"),
                UIColor(named: "ProfileBackgroundColor7")
            ]
            
            self.profile.backgroundColor = backgroundColors.randomElement()!
            self.nameLabel.text = shortNickname.uppercased()

            let temporaryView = UIView(frame: self.profile.bounds)
            temporaryView.backgroundColor = self.profile.backgroundColor
            let tempImageView = UIImageView(image: self.profile.image)
            tempImageView.frame = self.profile.bounds
            tempImageView.layer.cornerRadius = self.profile.layer.cornerRadius
            tempImageView.clipsToBounds = true
            temporaryView.addSubview(tempImageView)

            let tempLabel = UILabel()
            tempLabel.text = self.nameLabel.text
            tempLabel.font = self.nameLabel.font
            tempLabel.textColor = self.nameLabel.textColor
            tempLabel.textAlignment = self.nameLabel.textAlignment
            tempLabel.sizeToFit()
            tempLabel.center = tempImageView.center
            temporaryView.addSubview(tempLabel)

            let profileImageWithLabel = temporaryView.asImage()
            self.profile.image = profileImageWithLabel
        }
    }
    
    private func updateDuplicateCheckButtonState() {
        let nicknameLength = nicknameTextField.text?.count ?? 0
        let isValidLength = nicknameLength >= 2 && nicknameLength <= 16
        duplicateCheckButton.isEnabled = isValidLength
        let lightGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "lightgray")
        duplicateCheckButton.backgroundColor = isValidLength ? .font : lightGTocustomB
        duplicateCheckButton.setTitleColor(isValidLength ? UIColor(named: "textColor") : .darkgray, for: .normal)
    }
    
    private func showConfirmationAlert(title: String, message: String, nickname: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let useAction = UIAlertAction(title: "사용", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.nicknameTextField.isEnabled = false
            self.duplicateCheckButton.isEnabled = false
            let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
            self.duplicateCheckButton.backgroundColor = babyGTocustomB
            
            if profile.tag == 1 {
                self.profile.image = nil
                self.addImage.isHidden = true
                self.addImageLayer.isHidden = true
                
                let nickname = self.nicknameTextField.text
                self.nickNameEditedProfileImageSetting(with: nickname ?? "")
            }
            
            self.updateDoneButtonState()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.nicknameTextField.isEnabled = true
            self.duplicateCheckButton.isEnabled = true
        }
        
        alert.addAction(useAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //저장버튼은 이 경우에서만 활성화 되도록
    private func updateDoneButtonState() {
        let isImageSelected = profile.image != previousImage
        let isNicknameVaild = isNicknameValid(nicknameTextField.text)
        doneButton.isEnabled = isImageSelected || isNicknameVaild
        doneButton.setTitleColor(.font, for: .normal)
    }
    
    private func isNicknameValid(_ nickname: String?) -> Bool {
        guard let nickname = nickname, !nickname.isEmpty else { return false }
        return nickname.count >= 2 && nickname.count <= 16 && nickname.range(of: "^[a-zA-Z0-9가-힣]+$", options: .regularExpression) != nil
    }
    
    //작성완료시 엔터 누르면 키보드 내려가기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func imageViewTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //하단에서 이미지선택지 알람 등장(액션시트)
        let alert = UIAlertController(title: "프로필 사진 변경", message: nil, preferredStyle: .actionSheet)
        let changeToDefault = UIAlertAction(title: "기본으로 변경", style: .default) { _ in
            self.addImageLayer.backgroundColor = UIColor(white: 1, alpha: 0.7)
            self.addImage.image = UIImage(systemName: "plus")
            self.addImage.tintColor = UIColor.textColorSub

            self.profile.image = nil
            self.addImage.isHidden = true
            self.addImageLayer.isHidden = true
        
            let nickname = self.nicknameTextField.text
            
            self.nickNameEditedProfileImageSetting(with: nickname ?? "")
            self.profile.tag = 1
            
            self.updateDoneButtonState()
            
            self.profile.image = nil
            self.addImage.isHidden = true
            self.addImageLayer.isHidden = true
            self.nickNameEditedProfileImageSetting(with: nickname ?? "")
        }
        
        let selectImage = UIAlertAction(title: "새로운 사진 등록", style: .default) { _ in
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        self.addImageLayer.backgroundColor = UIColor(white: 1, alpha: 0)
        self.addImage.tintColor = UIColor.clear
        
        [changeToDefault, selectImage, cancel].forEach(){
            alert.addAction($0)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider else { return }
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let selectedImage = image as? UIImage {
                        self?.profile.image = selectedImage
                        self?.addImageLayer.backgroundColor = .clear
                        self?.addImage.tintColor = .clear
                        self?.nameLabel.isHidden = true
                        self?.profile.tag = 0 // 기본 이미지 x
                        self?.updateDoneButtonState()
                    }
                }
            }
        }
    }
    
    override func updateColor() {
        super.updateColor()
        let lineBackgroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "babygray")
        subLine.backgroundColor = lineBackgroundColor
        
        let nameAlertColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightgray") : UIColor(named: "darkgray")
        nameAlert.textColor = nameAlertColor
        
        let myNameColor = traitCollection.userInterfaceStyle == .dark ? CGColor(gray: 100, alpha: 1) : CGColor(gray: 0, alpha: 1)
        nicknameTextField.layer.borderColor = myNameColor
        
        //카카오톡 한정으로 다크모드시 아이콘 색상 변경
        let iconColor = traitCollection.userInterfaceStyle == .dark ? UIColor(red: 254/255, green: 229/255, blue: 0, alpha: 1) : UIColor(red: 60/255, green: 29/255, blue: 30/255, alpha: 1)
        IDIcon.tintColor = iconColor
        setIcon()
        
        _ = traitCollection.userInterfaceStyle == .dark ? CGColor(gray: 100, alpha: 1) : CGColor(gray: 0, alpha: 1)
        
        let withdrawalColor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        withdrawalB.setTitleColor(withdrawalColor, for: .normal)
        
        let doneButtonCollor = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "lightblack") : UIColor(named: "lightgray")
        doneButton.setTitleColor(doneButtonCollor, for: .normal)
        
    }
    
    // ManagedObjectContext 가져오기
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // 회원 탈퇴 액션
    @objc func TappedWithdrawalB(_ sender: UIButton) {
        let confirmAlert = UIAlertController(title: "회원 탈퇴", message: "정말로 회원 탈퇴하시겠습니까? \n 지금까지의 모든 기록이 사라집니다.", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { _ in
            self.performAccountDeletion()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        confirmAlert.addAction(confirmAction)
        confirmAlert.addAction(cancelAction)
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    private func performAccountDeletion() {
        guard let user = Auth.auth().currentUser else { return }
        let userId = user.uid
        
        Task {
            do {
                // 7월 2일 추가: 사용자와 관련된 모든 핀로그 이미지를 삭제
                let pinLogs = try await PinLogManager.shared.fetchPinLogs(forUserId: userId)
                for pinLog in pinLogs {
                    do {
                        try await PinLogManager.shared.deleteImages(from: pinLog)
                    } catch {
                        print("Failed to delete images for pinLog \(pinLog.id ?? "unknown ID"): \(error)")
                        // Continue with the next pinLog
                        continue
                    }
                }
                
                // 7월 2일 추가: 사용자와 관련된 모든 핀로그를 삭제
                for pinLog in pinLogs {
                    do {
                        try await PinLogManager.shared.deletePinLog(pinLogId: pinLog.id!)
                    } catch {
                        print("Failed to delete pinLog \(pinLog.id ?? "unknown ID"): \(error)")
                        continue
                    }
                }
                // 모든 사용자 데이터 삭제
                try await AccountDeletionManager.shared.deleteUser(uid: userId, context: context)
                
                // 모든 데이터 삭제가 성공하면 로그아웃
                try Auth.auth().signOut()
                
                // 성공 알림 및 로그인 화면으로 이동
                showAlert(title: "회원 탈퇴 완료", message: "회원 탈퇴가 완료되었습니다. \n 지금까지의 모든 기록이 삭제되었습니다.") {
                    self.navigateToLoginScreen()
                }
            } catch {
                print("회원 탈퇴 실패: \(error.localizedDescription)")
                showAlert(title: "오류", message: "회원 탈퇴 중 오류가 발생했습니다.") {
                    self.navigateToLoginScreen()
                }
            }
        }
    }
    
    // 로그인 화면으로 이동하는 함수
    func navigateToLoginScreen() {
        DispatchQueue.main.async {
            let loginVC = AuthenticationVC()
            let navigationController = UINavigationController(rootViewController: loginVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.view.window?.rootViewController = navigationController
            self.view.window?.makeKeyAndVisible()
        }
    }
    
    // 오류 메시지를 표시하는 함수
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) { _ in
                completion?()
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
