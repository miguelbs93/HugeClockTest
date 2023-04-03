import Combine
import UIKit

class WorldClockViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ClockCell.self, forCellReuseIdentifier: ClockCell.defaultCellIdentifier)
        return tableView
    }()
    
    private enum Section {
        case clocks
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<Section, Clock> = {
        let dataSource = UITableViewDiffableDataSource<Section, Clock>(tableView: tableView) { [weak self] tableView, indexPath, clock -> UITableViewCell in
            guard let self,
                  let cell = tableView.dequeueReusableCell(withIdentifier: ClockCell.defaultCellIdentifier, for: indexPath) as? ClockCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: clock.city, detail: clock.getFormattedDate(from: Date()))
            
            self.viewModel.timerPublisher
                .sink { date in
                    cell.configure(with: clock.city, detail: clock.getFormattedDate(from: date))
                }
                .store(in: &self.subscriptions)
            
            return cell
        }
        return dataSource
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .appFont.normal(withSize: 17)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = viewModel.emptyText
        return label
    }()
    
    private lazy var addBarButton: UIButton = {
        UIButton(type: .contactAdd)
    }()

    private let viewModel: WorldClockViewModelType
    
    private lazy var subscriptions: Set<AnyCancellable> = []
    
    init(viewModel: WorldClockViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateDataSource(with: [])
        bind(to: viewModel)
    }
}

// MARK: - UI

private extension WorldClockViewController {
    func setupView() {
        view.addSubview(tableView)
        tableView.addSubview(emptyLabel)
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addBarButton)
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
            emptyLabel.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 30),
            emptyLabel.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -30)
        ])
    }
    
    func updateDataSource(with clocks: [Clock]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Clock>()
        snapshot.appendSections([.clocks])
        snapshot.appendItems(clocks)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

//  MARK: - Bindings

private extension WorldClockViewController {
    func bind(to viewModel: WorldClockViewModelType) {
        bind(outputs: viewModel)
        bind(inputs: viewModel)
    }
    
    func bind(outputs: WorldClockViewModelOutputs) {
        outputs.clocks
            .sink(receiveValue: { [weak self] clocks in
                self?.updateDataSource(with: clocks)
            })
            .store(in: &subscriptions)
        
        outputs.clocks
            .map { $0.count < outputs.maxClocks }
            .assign(to: \.isEnabled, on: addBarButton)
            .store(in: &subscriptions)
        
        outputs.clocks
            .map { $0.count > 0 }
            .assign(to: \.isHidden, on: emptyLabel)
            .store(in: &subscriptions)
    }
    
    func bind(inputs: WorldClockViewModelInputs) {
        addBarButton
            .publisher(for: .touchUpInside)
            .subscribe(inputs.addButtonPublisher)
            .store(in: &subscriptions)
    }
}
