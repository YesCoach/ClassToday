//
//  MapClassListCell.swift
//  ClassToday
//
//  Created by 박태현 on 2022/07/09.
//

import UIKit

class MapClassListCell: UITableViewCell {

    // MARK: - Views
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var costLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private lazy var recommendLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    static let identifier = "MapClassListCell"
    
    override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure(with classItem: ClassItem) {
        titleLabel.text = classItem.name
        let location = LocationManager.shared.getAddress(of: classItem.location) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let location):
                self.addressLabel.text = location
            case .failure:
                self.addressLabel.text = "failed"
            }
        }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: classItem.createdTime, to: Date())
        if let month = components.month, month != 0 {
            timeLabel.text = " | \(month)개월 전"
        } else if let day = components.day, day != 0 {
            timeLabel.text = " | \(day)일 전"
        } else if let hour = components.hour, hour != 0 {
            timeLabel.text = " | \(hour)시간 전"
        } else if let minute = components.minute, minute != 0 {
            timeLabel.text = " | \(minute)분 전"
        } else {
            timeLabel.text = " | 방금 전"
        }
        costLabel.text = classItem.price
        countLabel.text = String(classItem.match?.count ?? 0)
    }

    private func setUpLayout() {
        [titleLabel, addressLabel, timeLabel, costLabel, countLabel, recommendLabel].forEach { self.addSubview($0)}
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.leading.equalTo(self.snp.leading)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.bottom.equalTo(self.snp.bottom)
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.top)
            $0.leading.equalTo(addressLabel.snp.trailing)
            $0.bottom.equalTo(addressLabel.snp.bottom)
        }
        recommendLabel.snp.makeConstraints {
            $0.trailing.equalTo(self.snp.trailing)
            $0.bottom.equalTo(self.snp.bottom)
        }
        countLabel.snp.makeConstraints {
            $0.trailing.equalTo(recommendLabel.snp.leading)
            $0.bottom.equalTo(recommendLabel.snp.bottom)
        }
        costLabel.snp.makeConstraints {
            $0.trailing.equalTo(countLabel.snp.leading)
            $0.bottom.equalTo(recommendLabel.snp.bottom)
        }
    }
}
