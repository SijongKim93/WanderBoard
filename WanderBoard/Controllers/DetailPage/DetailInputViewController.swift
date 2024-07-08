//
//  ViewController.swift
//  WanderBoardSijong
//
//  Created by 김시종 on 5/28/24.
//

import UIKit
import FirebaseAuth
import SnapKit
import Then
import Photos
import PhotosUI
import MapKit
import SwiftUI
import CoreLocation
import FirebaseStorage
import FirebaseFirestore
import Contacts
import Kingfisher


protocol DetailInputViewControllerDelegate: AnyObject {
    func didSavePinLog(_ pinLog: PinLog)
}

class DetailInputViewController: UIViewController, CalendarHostingControllerDelegate, SingleDayCalendarHostingControllerDelegate, AmountInputHostingControllerDelegate, CategoryInputCollectionViewCellDelegate, SpendingListViewControllerDelegate, SummaryViewControllerDelegate {
    func didSelectCategory(category: String, imageName: String) {
        selectedCategory = category
        selectedImageName = imageName
        showSingleDayCalendar()
    }
    
    func didSelectCategory(category: String) {
        selectedCategory = category
        showSingleDayCalendar()
    }
    
    var progressViewController: ProgressViewController?
    var savedLocation: CLLocationCoordinate2D?
    var savedPinLogId: String?
    var savedAddress: String?
    weak var delegate: DetailInputViewControllerDelegate?
    var selectedImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = []
    var selectedFriends: [UserSummary] = []
    var isInitialLoad = true
    var representativeImageIndex: Int? = 0
    var totalSpendingAmountText: String? {
        didSet {
            consumLeftLabel.text = totalSpendingAmountText
        }
    }
    
    let categories = CategoryData.categories
    let categoryImageMapping = CategoryData.categoryImageMapping
    var selectedCategory: String?
    var selectedImageName: String?
    var selectedDate: Date?
    var imageLocations: [CLLocationCoordinate2D] = []
    let pinLogManager = PinLogManager()
    var pinLog: PinLog?
    var expenses: [DailyExpenses] = []
    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?
    var publicViewHeightConstraint: Constraint?
    
    lazy var detailInputViewCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GallaryInputCollectionViewCell.self, forCellWithReuseIdentifier: "GallaryInputCollectionViewCell")
        collectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: "TextInputCollectionViewCell")
        collectionView.register(CategoryInputCollectionViewCell.self, forCellWithReuseIdentifier: "CategoryInputCollectionViewCell")
        return collectionView
    }()
    
    let layout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
    }
    
    lazy var detailInputViewButton = UIHostingController(rootView: DetailInputPageControlButton(onIndexChanged: { [weak self] index in
        self?.switchToPage(index)
    }))
    
    let publicLabel = UILabel().then {
        $0.text = "게시물 공개"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .font
    }
    
    let publicSwitch = UISwitch().then {
        $0.isOn = true
        $0.thumbTintColor = UIColor(named: "textColor")
        $0.onTintColor = .font
    }
    
    let publicStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    let spendingPublicSwitch = UISwitch().then {
        $0.isOn = true
        $0.thumbTintColor = UIColor(named: "textColor")
        $0.onTintColor = .font
    }
    
    let spendingPublicLabel = UILabel().then {
        $0.text = "지출 공개"
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = .font
    }
    
    let spendingPublicStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 20
    }
    
    let locationLeftLabel = UILabel().then {
        $0.text = "지역을 선택하세요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkgray
    }
    
    let locationRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .font
    }
    
    let locationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜를 선택하세요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkgray
        $0.isHidden = false
    }
    
    let dateRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .font
    }
    
    let dateStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    let dateButton = UIButton().then {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .babygray
        configuration.baseForegroundColor = .font
        configuration.cornerStyle = .medium
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        $0.configuration = configuration
        $0.tintColor = .font
    }
    
    let locationButton = UIButton().then {
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 8
    }
    
    let consumButton = UIButton().then {
        $0.backgroundColor = .babygray
        $0.layer.cornerRadius = 8
    }
    
    let consumLeftLabel = UILabel().then {
        $0.text = "지출 내역을 추가하세요"
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .darkgray
    }
    
    let consumRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .darkgray
    }
    
    let consumStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
        $0.isUserInteractionEnabled = false
    }
    
    lazy var galleryInputCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()
    
    let mateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        $0.textColor = .font
        
        let imageAttachment = NSTextAttachment()
        let systemImage = UIImage(systemName: "person.2")?.withTintColor(.font, renderingMode: .alwaysOriginal)
        imageAttachment.image = systemImage
        imageAttachment.bounds = CGRect(x: 0, y: -5, width: 24, height: 16.61)
        
        let fullString = NSMutableAttributedString(string: "")
        fullString.append(NSAttributedString(attachment: imageAttachment))
        fullString.append(NSAttributedString(string: " 메이트", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold)]))
        
        $0.attributedText = fullString
    }
    
    lazy var mateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 32, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    // MARK: 토글토글
    
    private var selectedStartDate: Date?
    private var selectedEndDate: Date?
        
    func didSelectDates(startDate: Date, endDate: Date) {
        print("didSelectDates 호출됨")
        updateDateLabel(with: startDate, endDate: endDate)
        selectedStartDate = startDate
        selectedEndDate = endDate
    }
    
    
    func updateDateLabel(with startDate: Date, endDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        let dateRangeString = "\(startDateString) ~ \(endDateString)"
        print("updateDateLabel 호출됨: \(dateRangeString)")
        
        // dateLabel의 텍스트 업데이트
        self.dateLabel.text = dateRangeString
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupConstraints()
        actionButton()
        setupNavigationBar()
        setupCollectionView()
        requestPhotoLibraryAccess()
        updateColor()
        
        if let pinLog = pinLog {
            configureView(with: pinLog)
        }
        
        if let spendingListVC = self.presentingViewController as? SpendingListViewController {
            spendingListVC.delegate = self
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        setupNavigationBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let spendingListVC = segue.destination as? SpendingListViewController {
            spendingListVC.delegate = self
            spendingListVC.pinLog = pinLog
        }
    }

    func didUpdateExpenses(_ expenses: [DailyExpenses]) {
        pinLog?.expenses = expenses
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        let selectedCategoryTuple = categories[sender.tag]
        selectedCategory = selectedCategoryTuple.1
        selectedImageName = selectedCategoryTuple.0
        showSingleDayCalendar()
    }

    @objc private func showCalendar() {
        let calendarVC = CalendarHostingController()
        calendarVC.delegate = self
        calendarVC.modalPresentationStyle = .pageSheet
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 460 })]
            sheet.prefersGrabberVisible = true
        }
        present(calendarVC, animated: true, completion: nil)
    }
    
    
    func didSelectDate(_ date: Date) {
        self.selectedDate = date
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            let amountVC = AmountInputHostingController()
            amountVC.delegate = self
            amountVC.modalPresentationStyle = .pageSheet
            if let sheet = amountVC.sheetPresentationController {
                sheet.detents = [.custom(resolver: { _ in 460 })]
                sheet.prefersGrabberVisible = true
            }
            self.present(amountVC, animated: true, completion: nil)
        }
    }
    
    func didEnterAmount(_ amount: Double) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.showSummaryViewController(withAmount: amount)
        }
    }
    
    private func showSummaryViewController(withAmount amount: Double) {
        let summaryVC = SummaryViewController()
        summaryVC.selectedCategory = selectedCategory
        summaryVC.selectedDate = selectedDate
        summaryVC.amount = amount
        summaryVC.delegate = self
        summaryVC.modalPresentationStyle = .formSheet
        if let sheet = summaryVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 460 })]
            sheet.prefersGrabberVisible = true
        }
        present(summaryVC, animated: true, completion: nil)
    }

    func setupUI() {
        view.addSubview(detailInputViewCollectionView)
        view.addSubview(detailInputViewButton.view)
        addChild(detailInputViewButton)
        detailInputViewButton.didMove(toParent: self)
        
        view.addSubview(publicStackView)
        view.addSubview(spendingPublicStackView)
        view.addSubview(locationButton)
        locationButton.addSubview(locationStackView)
        view.addSubview(dateButton)
        dateButton.addSubview(dateStackView)
        
        publicStackView.addArrangedSubview(publicLabel)
        publicStackView.addArrangedSubview(publicSwitch)
        spendingPublicStackView.addArrangedSubview(spendingPublicLabel)
        spendingPublicStackView.addArrangedSubview(spendingPublicSwitch)
        
        dateStackView.addArrangedSubview(dateLabel)
        dateStackView.addArrangedSubview(dateRightLabel)
        
        locationStackView.addArrangedSubview(locationLeftLabel)
        locationStackView.addArrangedSubview(locationRightLabel)
        
        view.addSubview(mateLabel)
        view.addSubview(mateCollectionView)
    }
    
    func setupConstraints() {
        let screenHeight = UIScreen.main.bounds.height
        let collectionViewHeightMultiplier: CGFloat = screenHeight < 750 ? 0.35 : 0.4
      
        detailInputViewCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(collectionViewHeightMultiplier)
        }
        
        detailInputViewButton.view.snp.makeConstraints {
            $0.top.equalTo(detailInputViewCollectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.1)
        }
        
        publicStackView.snp.makeConstraints {
            $0.top.equalTo(detailInputViewButton.view.snp.bottom)
            $0.leading.equalToSuperview().inset(32)
        }
        
        spendingPublicStackView.snp.makeConstraints {
            $0.top.equalTo(detailInputViewButton.view.snp.bottom)
            $0.trailing.equalToSuperview().inset(32)
        }
        
        locationButton.snp.makeConstraints {
            $0.top.equalTo(publicStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(44)
        }
        
        locationStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        dateButton.snp.makeConstraints {
            $0.top.equalTo(locationButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(32)
            $0.height.equalTo(44)
        }
        
        dateStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        mateLabel.snp.makeConstraints {
            $0.top.equalTo(dateButton.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(32)
        }
        
        mateCollectionView.snp.makeConstraints {
            $0.top.equalTo(mateLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(70)
        }
    }
    
    func switchToPage(_ index: Int) {
        detailInputViewCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        if !self.galleryInputCollectionView.frame.contains(location) && !self.mateCollectionView.frame.contains(location) {
            view.endEditing(true)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColor()
        }
    }
    
    func updateColor(){
        //베이비그레이-커스텀블랙
        let babyGTocustomB = traitCollection.userInterfaceStyle == .dark ? UIColor(named: "customblack") : UIColor(named: "babygray")
        dateButton.configuration?.baseBackgroundColor = babyGTocustomB
        locationButton.backgroundColor = babyGTocustomB
        consumButton.backgroundColor = babyGTocustomB
        
    }
    
    func setupCollectionView() {
        galleryInputCollectionView.delegate = self
        galleryInputCollectionView.dataSource = self
        
        mateCollectionView.delegate = self
        mateCollectionView.dataSource = self
        
        detailInputViewCollectionView.register(GallaryInputCollectionViewCell.self, forCellWithReuseIdentifier: GallaryInputCollectionViewCell.identifier)
        detailInputViewCollectionView.register(TextInputCollectionViewCell.self, forCellWithReuseIdentifier: TextInputCollectionViewCell.identifier)
        
        mateCollectionView.register(FriendInputCollectionViewCell.self, forCellWithReuseIdentifier: FriendInputCollectionViewCell.identifier)
    }
    
    func actionButton() {
        dateButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
    }
    
    @objc private func locationButtonTapped() {
        presentMapViewController()
    }
    
    private func presentMapViewController() {
        let mapVC = MapViewController(region: MKCoordinateRegion(), startDate: Date(), endDate: Date(), onLocationSelected: { [weak self] (selectedLocation: CLLocationCoordinate2D, address: String) in
            guard let self = self else { return }
            self.updateLocationLabel(with: address)
            self.savedLocation = selectedLocation
            self.savedAddress = address
        })
        let backButton = ButtonFactory.createBackButton()
        self.navigationItem.backBarButtonItem = backButton
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissDetailView))
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        navigationItem.rightBarButtonItems = [doneButton]
        navigationController?.navigationBar.tintColor = .font
    }
    
    func didSaveExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: expense.date) }) {
            expenses[index].expenses.append(expense)
        } else {
            let newDailyExpense = DailyExpenses(date: expense.date, expenses: [expense])
            expenses.append(newDailyExpense)
        }
        sortDailyExpensesByDate()
        updateTotalSpendingAmount(with: expenses)
    }
    
    func sortDailyExpensesByDate() {
        expenses.sort { $0.date > $1.date }
    }
    
    @objc private func showSingleDayCalendar() {
        let calendarVC = SingleDayCalendarHostingController()
        calendarVC.delegate = self
        calendarVC.modalPresentationStyle = .pageSheet
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.custom(resolver: { _ in 460 })]
            sheet.prefersGrabberVisible = true
        }
        present(calendarVC, animated: true, completion: nil)
    }
    
    @objc func dismissDetailView(_ sender:UIButton) {
        dismiss(animated: true)
    }
    
    func updateLocationLabel(with address: String) {
        self.locationLeftLabel.text = address
    }
    
    func configureView(with pinLog: PinLog) {
        DispatchQueue.main.async {
            self.expenses = pinLog.expenses ?? []
            self.spendingPublicSwitch.isOn = pinLog.isSpendingPublic
            self.locationLeftLabel.text = pinLog.location
            self.publicSwitch.isOn = pinLog.isPublic
            self.spendingPublicSwitch.isOn = pinLog.isSpendingPublic

            self.updateDateLabel(with: pinLog.startDate, endDate: pinLog.endDate)

            self.selectedImages.removeAll()
            self.imageLocations.removeAll()

            var representativeImage: (UIImage, Bool, CLLocationCoordinate2D?)? = nil
            var otherImages: [(UIImage, Bool, CLLocationCoordinate2D?)] = []

            let dispatchGroup = DispatchGroup()

            for media in pinLog.media {
                dispatchGroup.enter()
                if let url = URL(string: media.url) {
                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            let location = media.latitude != nil && media.longitude != nil ? CLLocationCoordinate2D(latitude: media.latitude!, longitude: media.longitude!) : nil
                            let imageData = (image, media.isRepresentative, location)

                            if media.isRepresentative {
                                representativeImage = imageData
                            } else {
                                otherImages.append(imageData)
                            }
                        } else {
                            print("Error loading image: \(String(describing: error))")
                        }
                        dispatchGroup.leave()
                    }.resume()
                } else {
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                if let repImage = representativeImage {
                    self.selectedImages.append(repImage)
                }
                self.selectedImages.append(contentsOf: otherImages)

                self.representativeImageIndex = self.selectedImages.firstIndex { $0.1 }
                self.updateRepresentativeImage()

                if let galleryCell = self.detailInputViewCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? GallaryInputCollectionViewCell {
                    galleryCell.selectedImages = self.selectedImages
                    galleryCell.photoInputCollectionView.reloadData()
                }
            }

            if self.isInitialLoad {
                self.loadSelectedFriends(pinLog: pinLog) {
                    self.mateCollectionView.reloadData()
                    self.isInitialLoad = false
                }
            } else {
                self.mateCollectionView.reloadData()
            }

            if let textInputCell = self.detailInputViewCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TextInputCollectionViewCell {
                textInputCell.configure(with: pinLog)
            } else {
                self.detailInputViewCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredHorizontally, animated: false)
                DispatchQueue.main.async {
                    if let textInputCell = self.detailInputViewCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TextInputCollectionViewCell {
                        textInputCell.configure(with: pinLog)
                    }
                }
            }
            self.switchToPage(0)
        }
    }

    func loadSavedLocation() {
        let userId = Auth.auth().currentUser?.uid ?? ""
        let documentRef = Firestore.firestore().collection("users").document(userId)
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists, let data = document.data() {
                if let latitude = data["latitude"] as? CLLocationDegrees,
                   let longitude = data["longitude"] as? CLLocationDegrees {
                    self.savedLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let address = data["address"] as? String ?? ""
                    self.updateLocationLabel(with: address)
                }
            }
        }
    }
    
    private func saveImageWithLocation(image: UIImage, location: CLLocationCoordinate2D?, address: String, completion: @escaping (Error?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"]))
            return
        }
        
        let filename = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("images/\(filename)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            if let error = error {
                completion(error)
                return
            }
            
            storageRef.downloadURL { [weak self] url, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                guard let downloadURL = url else {
                    completion(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"]))
                    return
                }
                
                guard let self = self else {
                    completion(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                    return
                }
                
                let mediaItem = Media(
                    url: downloadURL.absoluteString,
                    latitude: location?.latitude,
                    longitude: location?.longitude,
                    dateTaken: Date(),
                    isRepresentative: false
                )
                
                self.saveMediaItemToFirestore(mediaItem: mediaItem, address: address, completion: completion)
            }
        }
    }
    
    private func saveMediaItemToFirestore(mediaItem: Media, address: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        db.collection("images").addDocument(data: [
            "url": mediaItem.url,
            "latitude": mediaItem.latitude ?? 0,
            "longitude": mediaItem.longitude ?? 0,
            "timestamp": Timestamp(date: mediaItem.dateTaken ?? Date())
        ]) { error in
            completion(error)
        }
    }
    
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
    
    @objc func doneButtonTapped() {
        guard let locationTitle = locationLeftLabel.text, !locationTitle.isEmpty, locationTitle != "지역을 선택하세요" else {
            showAlert(title: "지역 선택", message: "지역을 선택해주세요.")
            return
        }

        guard let dateRange = dateLabel.text, dateRange != "날짜를 선택하세요" else {
            showAlert(title: "날짜 선택", message: "유효한 날짜를 선택해주세요.")
            return
        }

        guard !selectedImages.isEmpty else {
            showAlert(title: "앨범 추가", message: "최소한 하나의 이미지를 선택해주세요.")
            return
        }

        navigationItem.rightBarButtonItem?.isEnabled = false

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dates = dateRange.split(separator: " ~ ")
        guard dates.count == 2,
              let startDate = dateFormatter.date(from: String(dates[0])),
              let endDate = dateFormatter.date(from: String(dates[1])) else {
            showAlert(title: "오류", message: "유효한 날짜를 선택해주세요.")
            return
        }

        var title: String?
        var content: String?
        if let textInputCell = detailInputViewCollectionView.cellForItem(at: IndexPath(item: 1, section: 0)) as? TextInputCollectionViewCell {
            title = textInputCell.titleTextField.text
            content = textInputCell.contentTextView.text
        }

        let isPublic = publicSwitch.isOn
        let isSpendingPublic = spendingPublicSwitch.isOn
        let address = savedAddress ?? "Unknown Address"
        let latitude = savedLocation?.latitude ?? 0.0
        let longitude = savedLocation?.longitude ?? 0.0
        let totalSpendingAmount = calculateTotalSpendingAmount()
        let maxSpendingAmount = calculateMaxSpendingAmount()

        let imageLocations = selectedImages.compactMap { $0.2 }

        showProgressView()

        Task {
            do {
                var pinLog: PinLog

                if let existingPinLog = self.pinLog {
                    pinLog = existingPinLog
                    pinLog.location = locationTitle
                    pinLog.address = address
                    pinLog.latitude = latitude
                    pinLog.longitude = longitude
                    pinLog.startDate = startDate
                    pinLog.endDate = endDate
                    pinLog.title = title ?? ""
                    pinLog.content = content ?? ""
                    pinLog.isPublic = isPublic
                    pinLog.isSpendingPublic = isSpendingPublic
                    pinLog.attendeeIds = selectedFriends.map { $0.uid }
                    pinLog.totalSpendingAmount = totalSpendingAmount
                    pinLog.maxSpendingAmount = maxSpendingAmount
                    pinLog.expenses = self.expenses
                } else {
                    pinLog = PinLog(location: locationTitle,
                                    address: address,
                                    latitude: latitude,
                                    longitude: longitude,
                                    startDate: startDate,
                                    endDate: endDate,
                                    title: title ?? "",
                                    content: content ?? "",
                                    media: [],
                                    authorId: Auth.auth().currentUser?.uid ?? "",
                                    attendeeIds: selectedFriends.map { $0.uid },
                                    isPublic: isPublic,
                                    createdAt: Date(),
                                    pinCount: 0,
                                    pinnedBy: [],
                                    totalSpendingAmount: totalSpendingAmount,
                                    isSpendingPublic: isSpendingPublic,
                                    maxSpendingAmount: maxSpendingAmount,
                                    expenses: self.expenses)
                }

                if let representativeIndex = selectedImages.firstIndex(where: { $0.1 }) {
                    for i in 0..<selectedImages.count {
                        selectedImages[i].1 = (i == representativeIndex)
                    }
                } else if !selectedImages.isEmpty {
                    selectedImages[0].1 = true
                }

                let isRepresentativeFlags = selectedImages.map { $0.1 }

                let savedPinLog = try await pinLogManager.createOrUpdatePinLog(pinLog: &pinLog, images: selectedImages.map { $0.0 }, imageLocations: imageLocations, isRepresentativeFlags: isRepresentativeFlags)
                self.savedPinLogId = savedPinLog.id
                self.pinLog = savedPinLog
                self.pinLog?.expenses = self.expenses // 추가된 부분
                delegate?.didSavePinLog(savedPinLog)

                hideProgressView()
                navigationItem.rightBarButtonItem?.isEnabled = true

                dismiss(animated: true, completion: nil)
            } catch {
                let alert = UIAlertController(title: "오류", message: "데이터 저장에 실패했습니다.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true, completion: nil)
            }
            hideProgressView()
            showButtonFeedBackView()

            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    private func showButtonFeedBackView() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func calculateTotalSpendingAmount() -> Int {
        return expenses.flatMap { $0.expenses }.reduce(0) { $0 + $1.expenseAmount }
    }
    
    func calculateMaxSpendingAmount() -> Int {
        return expenses.flatMap { $0.expenses }.map { $0.expenseAmount }.max() ?? 0
    }
    
    func loadSelectedFriends(pinLog: PinLog, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        selectedFriends.removeAll()

        // 기존 핀로그에 저장된 attendeeIds 가져오기
        for userId in pinLog.attendeeIds {
            group.enter()
            fetchUserSummary(userId: userId) { [weak self] userSummary in
                guard let self = self else {
                    group.leave()
                    return
                }
                if var userSummary = userSummary {
                    userSummary.isMate = true
                    self.selectedFriends.append(userSummary)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            print("로드된 메이트 목록: \(self.selectedFriends)")
            completion()
        }
    }

    func fetchUserSummary(userId: String, completion: @escaping (UserSummary?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                let userSummary = UserSummary(
                    uid: userId,
                    email: data["email"] as? String ?? "",
                    displayName: data["displayName"] as? String ?? "",
                    photoURL: data["photoURL"] as? String,
                    isMate: false
                )
                completion(userSummary)
            } else {
                completion(nil)
            }
        }
    }
    
    func createCollectionViewFlowLayout(for collectionView: UICollectionView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        return layout
    }
    
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("사진 접근 권한이 허용되었습니다.")
            case .denied, .restricted, .notDetermined:
                print("사진 접근 권한이 거부되었습니다.")
            case .limited:
                print("사진 접근 권한이 제한되었습니다.")
            @unknown default:
                fatalError("새로운 권한 상태")
            }
        }
    }
    
    @objc func showPHPicker() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    var config = PHPickerConfiguration()
                    config.selectionLimit = 10 - self.selectedImages.count
                    config.filter = .images
                    let picker = PHPickerViewController(configuration: config)
                    picker.delegate = self
                    self.present(picker, animated: true, completion: nil)
                case .denied, .restricted:
                    self.showPhotoAccessDeniedAlert()
                case .notDetermined:
                    break
                @unknown default:
                    fatalError("새로운 권한 상태")
                }
            }
        }
    }
    
    private func showPhotoAccessDeniedAlert() {
        let alertController = UIAlertController(
            title: "사진 접근 권한 필요",
            message: "사진을 선택하려면 설정에서 사진 접근 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "설정으로 이동", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func fetchAddress(for location: CLLocationCoordinate2D, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let error = error {
                print("Error fetching address: \(error.localizedDescription)")
                completion("No Address")
                return
            }
            if let placemark = placemarks?.first {
                let address = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                completion(address)
            } else {
                completion("No Address")
            }
        }
    }
    
    func updateRepresentativeImage() {
        if let index = representativeImageIndex, index < selectedImages.count {
            for i in 0..<selectedImages.count {
                selectedImages[i].1 = (i == index)
            }
        } else {
            representativeImageIndex = selectedImages.isEmpty ? nil : 0
            if let index = representativeImageIndex {
                selectedImages[index].1 = true
            }
        }
        
        if let galleryCell = detailInputViewCollectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? GallaryInputCollectionViewCell {
            galleryCell.selectedImages = selectedImages
            galleryCell.photoInputCollectionView.reloadData()
        }
    }
    
    func updateTotalSpendingAmount(with dailyExpenses: [DailyExpenses]) {
        let totalAmount = dailyExpenses.flatMap { $0.expenses }.reduce(0) { $0 + $1.expenseAmount }
        consumLeftLabel.text = "\(formatCurrency(totalAmount))원"
    }
    
    func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? "0"
    }
}


extension DetailInputViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mateCollectionView {
            return selectedFriends.count + 1
        } else if collectionView == detailInputViewCollectionView {
            return 3
        } else if collectionView == galleryInputCollectionView {
            return selectedImages.isEmpty ? 1 : selectedImages.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == detailInputViewCollectionView {
            switch indexPath.item {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GallaryInputCollectionViewCell.identifier, for: indexPath) as! GallaryInputCollectionViewCell
                cell.delegate = self
                cell.selectedImages = selectedImages
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInputCollectionViewCell.identifier, for: indexPath) as! TextInputCollectionViewCell
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryInputCollectionViewCell.identifier, for: indexPath) as! CategoryInputCollectionViewCell
                cell.categories = categories
                cell.delegate = self
                return cell
            default:
                fatalError("Unexpected index path")
            }
        } else if collectionView == mateCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendInputCollectionViewCell.identifier, for: indexPath) as? FriendInputCollectionViewCell else {
                fatalError("FriendInputCollectionViewCell 오류")
            }
            
            if indexPath.item == 0 {
                cell.configure(with: nil)
            } else {
                let friend = selectedFriends[indexPath.item - 1]
                if let photoURL = friend.photoURL, let url = URL(string: photoURL) {
                    cell.configure(with: url)
                } else {
                    cell.configure(with: nil)
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mateCollectionView {
            if indexPath.item == 0 {
                let mateVC = MateViewController()
                mateVC.delegate = self
                mateVC.addedMates = selectedFriends
                navigationController?.pushViewController(mateVC, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mateCollectionView {
            return CGSize(width: 60, height: 60)
        } else if collectionView == galleryInputCollectionView {
            let width = collectionView.bounds.width * 0.8
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        } else if collectionView == detailInputViewCollectionView {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        } else {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
}

extension DetailInputViewController: MateViewControllerDelegate {
    func didSelectMates(_ mates: [UserSummary]) {
        selectedFriends = mates
        mateCollectionView.reloadData()
    }
}

extension DetailInputViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard !results.isEmpty else {
            print("No result found.")
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            let provider = result.itemProvider
            if provider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    guard let self = self else {
                        dispatchGroup.leave()
                        return
                    }
                    
                    if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let uiImage = object as? UIImage else {
                        print("Image is nil or not UIImage.")
                        dispatchGroup.leave()
                        return
                    }
                    
                    provider.loadDataRepresentation(forTypeIdentifier: "public.jpeg") { data, error in
                        if let error = error {
                            print("Error loading data representation: \(error.localizedDescription)")
                            dispatchGroup.leave()
                            return
                        }
                        guard let data = data else {
                            print("No data found.")
                            dispatchGroup.leave()
                            return
                        }
                        
                        let location = StorageManager.shared.extractLocation(from: data)
                        self.selectedImages.append((uiImage, false, location))
                        
                        dispatchGroup.leave()
                    }
                }
            } else {
                print("No provider or provider cannot load UIImage.")
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if let indexPath = self.detailInputViewCollectionView.indexPathsForVisibleItems.first(where: { $0.item == 0 }) {
                if let cell = self.detailInputViewCollectionView.cellForItem(at: indexPath) as? GallaryInputCollectionViewCell {
                    cell.selectedImages = self.selectedImages
                }
            }
        }
    }
}

extension DetailInputViewController: GallaryInputCollectionViewCellDelegate {
    func didSelectAddPhoto() {
        showPHPicker()
    }
    
    func didSelectRepresentativeImage(at index: Int) {
        representativeImageIndex = index
        updateRepresentativeImage()
    }
    
    func didDeleteImage(at index: Int) {
        selectedImages.remove(at: index)
        if selectedImages.isEmpty {
            representativeImageIndex = nil
        } else {
            representativeImageIndex = selectedImages.firstIndex { $0.1 } ?? 0
            if !selectedImages.contains(where: { $0.1 }) {
                selectedImages[0].1 = true
            }
            updateRepresentativeImage()
        }
    }
}

extension DetailInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        let placeholderColor: UIColor = {
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.darkgray
            } else {
                return UIColor.lightgray
            }
        }()
        
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = .font
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            textView.isScrollEnabled = false
            self.subTextFieldHeightConstraint?.update(offset: max(newSize.height, subTextFieldMinHeight))
            UIView.setAnimationsEnabled(true)
            textView.layoutIfNeeded()
        }
    }
}
