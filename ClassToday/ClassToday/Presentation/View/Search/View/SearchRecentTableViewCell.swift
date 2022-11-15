//
//  SearchRecentTableViewCell.swift
//  ClassToday
//
//  Created by poohyhy on 2022/05/01.
//

import UIKit

class SearchRecentTableViewCell: UITableViewCell {
    
    static let identifier = "SearchRecentTableViewCell"

    //MARK: - Cell 내부  UI Components
    private lazy var recentImage: UIImageView = {
        let recentImage = UIImageView()
        recentImage.image = UIImage(systemName: "clock.arrow.circlepath")
        recentImage.tintColor = .mainColor
        return recentImage
    }()

    private lazy var recentLabel: UILabel = {
        let recentLabel = UILabel()
        recentLabel.font = .systemFont(ofSize: 18.0, weight: .regular)
        return recentLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
        self.selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - set autolayout
    private func layout() {
        [
            recentImage,
            recentLabel
        ].forEach { contentView.addSubview($0)}
        
        let commonInset: CGFloat = 16.0
        
        recentImage.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(commonInset)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(24.0)
            $0.width.equalTo(26.0)
        }
        recentLabel.snp.makeConstraints {
            $0.leading.equalTo(recentImage.snp.trailing).offset(commonInset)
            $0.top.trailing.bottom.equalToSuperview().inset(5.0)
        }
    }

    func configure(with text: String) {
        recentLabel.text = text
    }

    override func prepareForReuse() {
        recentLabel.text = nil
    }
}
