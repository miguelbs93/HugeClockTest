import Combine
import UIKit

class CitiesListViewController: UIViewController {
    
    private let viewModel: CitiesListViewModelType
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CityCell.self, forCellReuseIdentifier: CityCell.defaultCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    init(viewModel: CitiesListViewModelType) {
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

private extension CitiesListViewController {
    func setupView() {
        view.addSubview(tableView)
        view.backgroundColor = .white
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Bindings

private extension CitiesListViewController {
    func bind(to viewModel: CitiesListViewModelType) {
        bind(outputs: viewModel)
        bind(inputs: viewModel)
    }
    
    func bind(outputs: CitiesListViewModelOutputs) {
        outputs.citiesPublisher
            .sink(receiveValue: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .store(in: &subscriptions)
    }
    
    func bind(inputs: CitiesListViewModelInputs) { }
}

// MARK: - TableView DataSource

extension CitiesListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.citiesPublisher.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.defaultCellIdentifier, for: indexPath) as? CityCell else {
            return UITableViewCell()
        }
        let country = viewModel.citiesPublisher.value[indexPath.row]
        cell.configure(with: country.name)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = viewModel.citiesPublisher.value[indexPath.row]
        viewModel.citySelection.send(country)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
