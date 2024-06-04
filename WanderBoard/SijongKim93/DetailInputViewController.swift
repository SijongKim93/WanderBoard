import UIKit
import SnapKit
import Then
import PhotosUI

class DetailInputViewController: UIViewController {
    
    var selectedImages: [UIImage] = []
    var selectedFriends: [UIImage] = []
    
    let subTextFieldMinHeight: CGFloat = 90
    var subTextFieldHeightConstraint: Constraint?
    
    let topContainarView = UIView().then {
        $0.backgroundColor = .black
    }
    
    let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
    }
    
    let contentView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let publicLabel = UILabel().then {
        $0.text = "공개 여부"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let publicSwitch = UISwitch().then {
        $0.isOn = true
        $0.onTintColor = .black
    }
    
    let publicStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let topLine = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
    }
    
    let dateLabel = UILabel().then {
        $0.text = "날짜"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    let startDateButton = UIButton(type: .system).then {
        $0.setTitle("시작일자", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.layer.cornerRadius = 6
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        $0.tintColor = .black
    }
    
    let endDateLabel = UILabel().then {
        $0.text = "-"
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    let endDateButton = UIButton(type: .system).then {
        $0.setTitle("종료일자", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.layer.cornerRadius = 8
        $0.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        $0.tintColor = .black
    }
    
    let dateContainerView = UIView()
    
    let mainTextField = UITextView().then {
        $0.text = "여행 제목을 입력해주세요."
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
    }
    
    let subTextField = UITextView().then {
        $0.text = "기록을 담아 주세요."
        $0.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
        $0.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.isScrollEnabled = false
    }
    
    let locationButton = UIButton().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    let locationLeftLabel = UILabel().then {
        $0.text = "지역을 선택하세요"
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    let locationRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "greaterthan")
        $0.tintColor = .black
    }
    
    let locationStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let consumButton = UIButton().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
        $0.layer.cornerRadius = 8
    }
    
    let consumLeftLabel = UILabel().then {
        $0.text = "지출 내역을 추가하세요"
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    let consumRightLabel = UIImageView().then {
        $0.image = UIImage(systemName: "greaterthan")
        $0.tintColor = .black
    }
    
    let consumStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 10
    }
    
    let bodyLine = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.947927177, green: 0.9562781453, blue: 0.9702228904, alpha: 1)
    }
    
    let galleryLabel = UILabel().then {
        $0.text = "앨범 추가"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    lazy var galleryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    let mateLabel = UILabel().then {
        $0.text = "메이트"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    lazy var mateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        actionButton()
        setupTextView()
        setupCollectionView()
        
    }
    
    func setupUI() {
        view.addSubview(topContainarView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(publicStackView)
        contentView.addSubview(topLine)
        
        publicStackView.addArrangedSubview(publicLabel)
        publicStackView.addArrangedSubview(publicSwitch)
        
        contentView.addSubview(dateContainerView)
        dateContainerView.addSubview(dateLabel)
        dateContainerView.addSubview(startDateButton)
        dateContainerView.addSubview(endDateLabel)
        dateContainerView.addSubview(endDateButton)
        
        contentView.addSubview(mainTextField)
        contentView.addSubview(subTextField)
        contentView.addSubview(locationButton)
        locationButton.addSubview(locationStackView)
        contentView.addSubview(consumButton)
        consumButton.addSubview(consumStackView)
        
        locationStackView.addArrangedSubview(locationLeftLabel)
        locationStackView.addArrangedSubview(locationRightLabel)
        consumStackView.addArrangedSubview(consumLeftLabel)
        consumStackView.addArrangedSubview(consumRightLabel)
        
        contentView.addSubview(bodyLine)
        contentView.addSubview(galleryLabel)
        contentView.addSubview(galleryCollectionView)
        
        contentView.addSubview(mateLabel)
        contentView.addSubview(mateCollectionView)
    }
    
    func setupConstraints() {
        topContainarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(150)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(topContainarView.snp.bottom).offset(-40)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(1200)
        }
        
        publicStackView.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(40)
            $0.leading.trailing.equalTo(contentView).inset(32)
        }
        
        topLine.snp.makeConstraints {
            $0.top.equalTo(publicStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(1)
        }
        
        dateContainerView.snp.makeConstraints {
            $0.top.equalTo(topLine.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(44)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalTo(dateContainerView.snp.leading)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
        }
        
        endDateButton.snp.makeConstraints {
            $0.trailing.equalTo(dateContainerView.snp.trailing)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
            $0.height.equalTo(44)
        }
        
        endDateLabel.snp.makeConstraints {
            $0.trailing.equalTo(endDateButton.snp.leading).offset(-10)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
        }
        
        startDateButton.snp.makeConstraints {
            $0.trailing.equalTo(endDateLabel.snp.leading).offset(-10)
            $0.centerY.equalTo(dateContainerView.snp.centerY)
            $0.height.equalTo(44)
        }
        
        mainTextField.snp.makeConstraints {
            $0.top.equalTo(dateContainerView.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(37)
        }
        
        subTextField.snp.makeConstraints {
            $0.top.equalTo(mainTextField.snp.bottom).offset(10)
            $0.leading.trailing.equalTo(contentView).inset(32)
            self.subTextFieldHeightConstraint = $0.height.greaterThanOrEqualTo(subTextFieldMinHeight).constraint
        }
        
        locationButton.snp.makeConstraints {
            $0.top.equalTo(subTextField.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(46)
        }
        
        locationStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        consumButton.snp.makeConstraints {
            $0.top.equalTo(locationButton.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(32)
            $0.height.equalTo(46)
        }
        
        consumStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        bodyLine.snp.makeConstraints {
            $0.top.equalTo(consumButton.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(16)
            $0.height.equalTo(1)
        }
        
        galleryLabel.snp.makeConstraints {
            $0.top.equalTo(bodyLine.snp.bottom).offset(16)
            $0.leading.equalTo(contentView).inset(32)
        }
        
        galleryCollectionView.snp.makeConstraints {
            $0.top.equalTo(galleryLabel.snp.bottom).offset(16)
            $0.leading.equalTo(contentView).inset(32)
            $0.trailing.equalTo(contentView)
            $0.height.equalTo(100)
        }
        
        mateLabel.snp.makeConstraints {
            $0.top.equalTo(galleryCollectionView.snp.bottom).offset(50)
            $0.leading.equalTo(contentView).inset(32)
        }
        
        mateCollectionView.snp.makeConstraints {
            $0.top.equalTo(mateLabel.snp.bottom).offset(16)
            $0.leading.equalTo(contentView).inset(32)
            $0.trailing.equalTo(contentView)
            $0.height.equalTo(100)
        }
    }
    
    func setupCollectionView() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        mateCollectionView.delegate = self
        mateCollectionView.dataSource = self
        
        galleryCollectionView.register(GallaryInPutCollectionViewCell.self, forCellWithReuseIdentifier: GallaryInPutCollectionViewCell.identifier)
        mateCollectionView.register(FriendInputCollectionViewCell.self, forCellWithReuseIdentifier: FriendInputCollectionViewCell.identifier)
        
    }
    
    func setupTextView() {
        mainTextField.delegate = self
        subTextField.delegate = self
    }
    
    func actionButton() {
        startDateButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
        endDateButton.addTarget(self, action: #selector(showDatePicker(_:)), for: .touchUpInside)
    }
    
    @objc func showDatePicker(_ sender: UIButton) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        
        let alert = UIAlertController(title: "날짜 선택", message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(datePicker)
        
        datePicker.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(alert.view)
            $0.bottom.equalTo(alert.view.snp.bottom).offset(-44)
        }
        
        let selectAction = UIAlertAction(title: "선택", style: .default) { _ in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let selectedDate = dateFormatter.string(from: datePicker.date)
            sender.setTitle(selectedDate, for: .normal)
        }
        
        alert.addAction(selectAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createCollectionViewFlowLayout(for collectionView: UICollectionView) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 85, height: 85)
        return layout
    }
}

extension DetailInputViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == galleryCollectionView {
            return selectedImages.isEmpty ? 1 : selectedImages.count
        } else if collectionView == mateCollectionView {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == galleryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GallaryInPutCollectionViewCell.identifier, for: indexPath) as? GallaryInPutCollectionViewCell else {fatalError("컬렉션뷰 오류")}
            if selectedImages.isEmpty {
                cell.configure(with: nil)
            } else {
                cell.configure(with: selectedImages[indexPath.row])
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FriendInputCollectionViewCell.identifier, for: indexPath) as? FriendInputCollectionViewCell else { fatalError("컬렉션뷰 오류")}
            if selectedFriends.isEmpty {
                cell.configure(with: nil)
            }
            return cell
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedImages.isEmpty || indexPath.row == selectedImages.count {
            showPHPicker()
        }
    }
    
    func showPHPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension DetailInputViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        selectedImages.removeAll()
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.selectedImages.append(image)
                        self?.galleryCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension DetailInputViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1) {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView == mainTextField {
                textView.text = "여행 제목을 입력해주세요."
            } else if textView == subTextField {
                textView.text = "기록을 담아 주세요."
            }
            textView.textColor = #colorLiteral(red: 0.8522331715, green: 0.8522332311, blue: 0.8522332311, alpha: 1)
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
