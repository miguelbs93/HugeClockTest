import Combine
import UIKit

class TimerViewController: UIViewController {
    
    private struct Constants {
        static let buttonHeight = 50.0
        static let horizontalPaddings = 20.0
        static let verticalPaddings = 40.0
    }
    
    private struct Images {
        static let pauseImage = UIImage(named: "pause-button")
        static let playImage = UIImage(named: "play-button")
        static let cancelImage = UIImage(named: "cancel-button")
    }
    
    // MARK: - Views
    
    private let viewModel: TimerViewModelType
    
    private lazy var datePicker: DatePickerView = {
        let picker = DatePickerView(4 * 60 * 60)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .defaultApp
        button.layer.borderColor = UIColor.defaultApp.cgColor
        button.setImage(Images.playImage, for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = Constants.buttonHeight/2
        return button
    }()
    
    private lazy var pauseButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .defaultApp
        button.layer.borderColor = UIColor.defaultApp.cgColor
        button.setImage(Images.pauseImage, for: .normal)
        button.setImage(Images.playImage, for: .selected)
        button.layer.borderWidth = 1
        button.isHidden = true
        button.layer.cornerRadius = Constants.buttonHeight/2
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderColor = UIColor.defaultApp.cgColor
        button.tintColor = .defaultApp
        button.layer.borderWidth = 1
        button.setImage(Images.cancelImage, for: .normal)
        button.isHidden = true
        button.isSelected = true
        button.layer.cornerRadius = Constants.buttonHeight/2
        return button
    }()
    
    private lazy var buttonsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pauseButton, startButton, cancelButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.spacing = Constants.horizontalPaddings
        return stackView
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.font = .appFont.bold(withSize: 50)
        label.layer.borderWidth = 5
        label.layer.borderColor = UIColor.defaultApp.cgColor
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var viewStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timerLabel, datePicker, buttonsStack])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = Constants.verticalPaddings
        return stackView
    }()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(viewModel: TimerViewModelType) {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timerLabel.layer.cornerRadius = timerLabel.frame.size.height/2
    }
}

// MARK: - UI

private extension TimerViewController {
    func setupView () {
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(viewStack)
        view.backgroundColor = .white
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            viewStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            viewStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            viewStack.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor),
            viewStack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            viewStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            timerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            timerLabel.heightAnchor.constraint(equalTo: timerLabel.widthAnchor, multiplier: 1),
            
            startButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            startButton.widthAnchor.constraint(equalTo: startButton.heightAnchor),
            
            pauseButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            pauseButton.widthAnchor.constraint(equalTo: pauseButton.heightAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight),
            cancelButton.widthAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
    }
}

// MARK: - Bindings

extension TimerViewController {
    
    func bind(to viewModel: TimerViewModelType) {
        bind(outputs: viewModel)
        bind(inputs: viewModel)
    }
    
    // MARK: - Binding Inputs
    
    func bind(inputs: TimerViewModelInputs) {
        inputs.viewDidLoad.send()
        
        datePicker.durationPublisher
            .dropFirst()
            .subscribe(inputs.duration)
            .store(in: &subscriptions)
        
        inputs.duration
            .map { $0 > 0 }
            .assign(to: \.isEnabled, on: startButton)
            .store(in: &subscriptions)
        
        pauseButton
            .publisher(for: .touchUpInside)
            .subscribe(inputs.pausePublisher)
            .store(in: &subscriptions)
        
        startButton
            .publisher(for: .touchUpInside)
            .subscribe(inputs.runPublisher)
            .store(in: &subscriptions)
        
        cancelButton
            .publisher(for: .touchUpInside)
            .subscribe(inputs.cancelPublisher)
            .store(in: &subscriptions)
        
        cancelButton
            .publisher(for: .touchUpInside)
            .delay(for: 0.1, scheduler: DispatchQueue.main)
            .subscribe(datePicker.resetPublisher)
            .store(in: &subscriptions)
    }
    
    // MARK: - Binding Outputs
    
    func bind(outputs: TimerViewModelOutputs) {
        // Pause Button
        
        outputs.state
            .map { $0 == .paused || $0 == .finished }
            .assign(to: \.isSelected, on: pauseButton)
            .store(in: &subscriptions)
        
        outputs.state
            .map { $0 == .initial }
            .assign(to: \.isHidden, on: pauseButton)
            .store(in: &subscriptions)
        
        // Cancel Button
        
        outputs.state
            .map { $0 == .initial }
            .assign(to: \.isHidden, on: cancelButton)
            .store(in: &subscriptions)
        
        // Start Button
        
        outputs.state
            .map { $0 != .initial }
            .assign(to: \.isHidden, on: startButton)
            .store(in: &subscriptions)
        
        // Date Picker
        
        outputs.state
            .map { $0 != .initial }
            .assign(to: \.isHidden, on: datePicker)
            .store(in: &subscriptions)
        
        // Timer Label
        
        outputs.state
            .map { $0 == .initial }
            .assign(to: \.isHidden, on: timerLabel)
            .store(in: &subscriptions)
        
        outputs.state
            .filter { $0 == .initial && $0 == .finished }
            .map { _ in "00:00" }
            .assign(to: \.text, on: timerLabel)
            .store(in: &subscriptions)
        
        outputs.timerPublisher
            .map { $0 }
            .assign(to: \.text, on: timerLabel)
            .store(in: &subscriptions)

        datePicker.durationPublisher
            .map { duration in
                return duration.timerStringRepresentation
            }
            .assign(to: \.text, on: timerLabel)
            .store(in: &subscriptions)
    }
}
