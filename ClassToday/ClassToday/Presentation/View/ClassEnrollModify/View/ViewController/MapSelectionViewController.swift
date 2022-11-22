//
//  MapSelectionViewController.swift
//  ClassToday
//
//  Created by 박태현 on 2022/07/26.
//

import UIKit
import NMapsMap
import Moya

protocol MapSelectionViewControllerDelegate: AnyObject {
    func didSelectLocation(location: Location?, place: String?)
}

class MapSelectionViewController: UIViewController {

    // MARK: - Views
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "수업 장소를 선택하세요"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()

    private lazy var mapView: NMFNaverMapView = {
        let naverMapView = NMFNaverMapView()
        let mapView = naverMapView.mapView
        mapView.mapType = NMFMapType.basic
        mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: true)
        mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)
        mapView.positionMode = NMFMyPositionMode.direction
        mapView.touchDelegate = self
        mapView.isTiltGestureEnabled = false
        mapView.isRotateGestureEnabled = false
        mapView.layer.cornerRadius = 16
        mapView.layer.masksToBounds = true
        return naverMapView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = """
                    ⋇ 지도 영역을 탭하면, 해당 위치가 수업 장소로 등록됩니다.
                    """
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.lightGray
        return label
    }()

    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 2
        label.text = "선택한 수업의 위치"
        return label
    }()

    private lazy var locationDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        return label
    }()

    private lazy var currentLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("현재 위치로 설정하기", for: .normal)
        button.setTitleColor(UIColor.mainColor, for: .normal)
        button.addTarget(self, action: #selector(didTapCurrentLocationButton(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.setTitle("설정하기", for: .normal)
        button.setTitle("장소를 선택해주세요", for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.setBackgroundColor(UIColor.mainColor, for: .normal)
        button.setBackgroundColor(UIColor.gray, for: .disabled)
        button.addTarget(self, action: #selector(didTapSubmitButton(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var marker: NMFMarker = {
        let marker = NMFMarker()
        marker.iconImage = NMF_MARKER_IMAGE_BLACK
        marker.iconTintColor = UIColor.mainColor
        marker.iconPerspectiveEnabled = true
        marker.width = 30
        marker.height = 40
        return marker
    }()

    // MARK: - Properties
    weak var delegate: MapSelectionViewControllerDelegate?
    private let viewModel: MapSelectionViewModel

    init(viewModel: MapSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        bindingViewModel()
        viewModel.viewDidLoad()
        modalPresentationStyle = .pageSheet
    }

    // MARK: - Methods
    func configure(location: Location? = nil) {
        viewModel.configure(location: location)
    }

    private func setUpLayout() {
        view.backgroundColor = .white
        [
            titleLabel, mapView, descriptionLabel, locationLabel,
            currentLocationButton ,locationDescriptionLabel, submitButton
        ].forEach { view.addSubview($0)}
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(25)
            $0.leading.equalToSuperview().offset(20)
        }
        currentLocationButton.snp.makeConstraints {
            $0.trailing.equalTo(mapView)
            $0.bottom.equalTo(mapView.snp.top)
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(mapView)
        }
        locationLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.leading.equalTo(descriptionLabel)
            $0.trailing.equalTo(currentLocationButton).offset(8)
        }
        locationDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(locationLabel.snp.bottom).offset(4)
            $0.leading.equalTo(locationLabel)
        }
        submitButton.snp.makeConstraints {
            $0.top.equalTo(locationDescriptionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(mapView)
            $0.height.equalTo(60)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func bindingViewModel() {
        viewModel.userPosition.bind { [weak self] position in
            guard let position = position else {
                return
            }
            self?.mapView.mapView.moveCamera(NMFCameraUpdate(scrollTo: position))
        }

        viewModel.selectedPosition.bind { [weak self] position in
            guard let position = position else {
                self?.marker.mapView = nil
                self?.viewModel.setPlaceName(with: nil)
                return
            }
            self?.marker.position = position
            self?.marker.mapView = self?.mapView.mapView
            self?.viewModel.setPlaceName(with: position)
        }

        viewModel.placeName.bind { [weak self] name in
            self?.locationDescriptionLabel.text = name
        }

        viewModel.isSubmitButtonOn.bind { [weak self] isTrue in
            if isTrue {
                self?.submitButton.isEnabled = true
            } else {
                self?.submitButton.isEnabled = false
            }
        }
    }

    // MARK: - objc function
    @objc func didTapSubmitButton(_ sender: UIButton) {
        delegate?.didSelectLocation(location: viewModel.selectedPositionToLocation, place: viewModel.placeName.value)
        dismiss(animated: true)
    }

    @objc func didTapCurrentLocationButton(_ sender: UIButton) {
        viewModel.didTapCurrentLocationButton()
    }
}

// MARK: - NMFMapViewTouchDelegate
extension MapSelectionViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        viewModel.didTapMapView(with: latlng)
    }
}
