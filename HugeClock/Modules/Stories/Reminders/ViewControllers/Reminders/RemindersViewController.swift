import Combine
import UIKit

final class RemindersViewController: UIViewController {
    
    private struct Constants {
        static let emptyLabelPaddings = 30.0
    }
    
    private let viewModel: RemindersViewModelType
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.defaultCellIdentifier)
        return tableView
    }()
    
    private enum Section {
        case reminders
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Reminder> = {
            let dataSource = UITableViewDiffableDataSource<Section, Reminder>(tableView: tableView) { [weak self] tableView, indexPath, reminder
                -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.defaultCellIdentifier, for: indexPath) as? ReminderCell else {
                    return UITableViewCell()
                }
                
                cell.configure(
                    with: reminder.title,
                    detail: reminder.detail,
                    date: reminder.date.formattedDate
                )
                
                return cell
            }
            return dataSource
        }()
    
    private lazy var addReminderButton: UIButton = {
        UIButton(type: .contactAdd)
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont.normal()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = viewModel.emptyText
        return label
    }()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    init(viewModel: RemindersViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind(to: viewModel)
    }
}

// MARK: - UI

private extension RemindersViewController {
    func setupView () {
        view.addSubview(tableView)
        tableView.addSubview(emptyLabel)
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addReminderButton)
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            emptyLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: Constants.emptyLabelPaddings),
            emptyLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -Constants.emptyLabelPaddings)
        ])
    }
}

// MARK: - Selectors

private extension RemindersViewController {
    private func updateDataSource(with reminders: [Reminder]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Reminder>()
        snapshot.appendSections([.reminders])
        snapshot.appendItems(reminders)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Bindings

private extension RemindersViewController {
    func bind(to viewModel: RemindersViewModelType) {
        bind(outputs: viewModel)
        bind(inputs: viewModel)
    }
    
    func bind(outputs: RemindersViewModelOutputs) {
        outputs.reminders
            .sink { [weak self] reminders in
                self?.updateDataSource(with: reminders)
            }
            .store(in: &subscriptions)
        
        outputs.reminders
            .map { $0.count > 0 }
            .assign(to: \.isHidden, on: emptyLabel)
            .store(in: &subscriptions)
    }
    
    func bind(inputs: RemindersViewModelInputs) {
        addReminderButton
            .publisher(for: .touchUpInside)
            .subscribe(inputs.addReminderPublisher)
            .store(in: &subscriptions)
    }
}
