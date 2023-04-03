import UIKit

class ClockCell: UITableViewCell {

    struct Constants {
        static let textFontSize = 20
        static let leadingTrailing = 20.0
        static let topBottom = 15.0
        static let accessoryHeight = 20.0
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
        return label
    }()
    
    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "world-clock-tab")
        return imageView
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

private extension ClockCell {
    private func setupView() {
        contentView.addSubview(contentStack)
        contentView.addSubview(accessoryImageView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.leadingTrailing),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leadingTrailing),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topBottom),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.topBottom),
            
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.leadingTrailing),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentStack.centerYAnchor),
            accessoryImageView.heightAnchor.constraint(equalToConstant: Constants.accessoryHeight),
            accessoryImageView.widthAnchor.constraint(equalTo: accessoryImageView.heightAnchor, multiplier: 1)
        ])
    }
}

// MARK: - Configuration

extension ClockCell {
    func configure(with title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
}

// MARK: - DefaultCellIdentifiable

extension ClockCell: DefaultCellIdentifiable { }
