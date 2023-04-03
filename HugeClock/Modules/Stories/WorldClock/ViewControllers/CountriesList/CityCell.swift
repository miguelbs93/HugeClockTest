import UIKit

class CityCell: UITableViewCell {
    
    private struct Constants {
        static let horizontalPaddings = 20.0
        static let verticalPaddings = 10.0
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont.normal()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(titleLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalPaddings),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalPaddings),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPaddings),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.horizontalPaddings)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
}

// MARK: - Configuration

extension CityCell {
    func configure(with title: String) {
        titleLabel.text = title
    }
}

// MARK: - DefaultCellIdentifiable

extension CityCell: DefaultCellIdentifiable { }
