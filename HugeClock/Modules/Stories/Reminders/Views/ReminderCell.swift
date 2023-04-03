//
//  ReminderCell.swift
//  HugeClock
//
//  Created by Miguel Bou Sleiman on 26.03.23.
//

import UIKit

class ReminderCell: UITableViewCell {
    
    struct Constants {
        static let textFontSize = 20
        static let leadingTrailing = 20.0
        static let topBottom = 15.0
    }
    
    // MARK: - Views
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont.bold(withSize: 20)
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont.normal(withSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont.bold(withSize: 15)
        label.textColor = .appRed
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, detailLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI

private extension ReminderCell {
    private func setupView() {
        contentView.addSubview(contentStack)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingTrailing),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leadingTrailing),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topBottom),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.topBottom),
        ])
    }
}

// MARK: - Configuration

extension ReminderCell {
    func configure(with title: String, detail: String, date: String) {
        titleLabel.text = title
        detailLabel.text = detail
        dateLabel.text = date
    }
}

// MARK: - DefaultCellIdentifiable

extension ReminderCell: DefaultCellIdentifiable { }
