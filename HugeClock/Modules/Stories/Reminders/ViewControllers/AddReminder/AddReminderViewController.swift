import Combine
import UIKit

class AddReminderViewController: UIViewController {

    private struct Constants {
        static let textSize = 20.0
        static let navigationButtonFontSize = 12.0
        static let componentHeight = 50.0
        static let horizontalPadding = 15.0
        static let verticalPadding = 10.0
        static let dataViewScale: CGFloat = 1/4
        static let cornerRadius = 15.0
    }
    
    private let viewModel: AddReminderViewModelType
    
    private lazy var titleField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .appFont.normal(withSize: Constants.textSize)
        textField.placeholder = viewModel.titleFieldPlaceHolder
        return textField
    }()
    
    private lazy var descriptionField: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .appFont.normal(withSize: Constants.textSize)
        textView.text = viewModel.descriptionFieldPlaceHolder
        textView.textColor = .placeholder
        return textView
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.cornerRadius
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .dateAndTime
        datePicker.setDate(Date(), animated: true)
        datePicker.minimumDate = Date()
        return datePicker
    }()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.saveButtonTitle, for: .normal)
        button.titleLabel?.font = .appFont.normal(withSize: Constants.navigationButtonFontSize)
        button.setTitleColor(.defaultApp, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind(to: viewModel)
    }
    
    init(viewModel: AddReminderViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI

private extension AddReminderViewController {
    func setupView() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = viewModel.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(titleField)
        backgroundView.addSubview(separatorView)
        backgroundView.addSubview(descriptionField)
        view.addSubview(datePicker)
        setupConstratints()
    }
    
    func setupConstratints() {
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.verticalPadding),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            backgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: Constants.dataViewScale),
            
            titleField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: Constants.horizontalPadding),
            titleField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -Constants.horizontalPadding),
            titleField.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: Constants.verticalPadding),
            titleField.heightAnchor.constraint(equalToConstant: Constants.componentHeight),
            
            separatorView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            separatorView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: Constants.verticalPadding),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionField.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            descriptionField.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            descriptionField.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: Constants.verticalPadding),
            descriptionField.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -Constants.verticalPadding),
            
            datePicker.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 20),
            datePicker.heightAnchor.constraint(equalToConstant: Constants.componentHeight),
            datePicker.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor)
        ])
    }
}

// MARK: - Binding

private extension AddReminderViewController {
    func bind(to viewModel: AddReminderViewModelType) {
        bind(inputs: viewModel)
        bind(outputs: viewModel)
    }
    
    func bind(outputs: AddReminderViewModelOutputs) {
        
    }
    
    func bind(inputs: AddReminderViewModelInputs) {
        
        // Title Text Field
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: titleField)
            .map( {
                ($0.object as? UITextField)?.text
            })
            .sink { text in
                inputs.titlePublisher.send(text ?? "")
            }
            .store(in: &subscriptions)
        
        // Description Text Field
        
        NotificationCenter.default
            .publisher(
                for: UITextView.textDidEndEditingNotification,
                object: descriptionField
            )
            .map { (notification) -> (UITextView?, String?) in
                let textView = notification.object as? UITextView
                return (textView, textView?.text)
            }
            .sink { [weak self] textView, text in
                if text?.isEmpty ?? true {
                    textView?.text = self?.viewModel.descriptionFieldPlaceHolder
                    textView?.textColor = .placeholder
                }
                inputs.descriptionPublisher.send(text ?? "")
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(
                for: UITextView.textDidChangeNotification,
                object: descriptionField
            )
            .map { (notification) -> String in
                let textView = notification.object as? UITextView
                return textView?.text ?? ""
            }
            .sink { inputs.descriptionPublisher.send($0) }
            .store(in: &subscriptions)
        
        NotificationCenter.default
            .publisher(
                for: UITextView.textDidBeginEditingNotification,
                object: descriptionField
            )
            .map { (notification) -> (UITextView?, String?) in
                let textView = notification.object as? UITextView
                return (textView, textView?.text)
            }
            .sink { [weak self] textView, text in
                textView?.text = (text == self?.viewModel.descriptionFieldPlaceHolder) ? "" : text
                textView?.textColor = .black
            }
            .store(in: &subscriptions)
        
        // Date Picker
        
        datePicker
            .publisher(for: .valueChanged)
            .map { [unowned self] _ in
                return self.datePicker.date
            }
            .subscribe(inputs.datePublisher)
            .store(in: &subscriptions)
        
        // Save Button
        
        saveButton
            .publisher(for: .touchUpInside)
            .subscribe(inputs.savePublisher)
            .store(in: &subscriptions)
        
        // Validators
        
        inputs.titlePublisher
            .combineLatest(inputs.datePublisher)
            .combineLatest(inputs.descriptionPublisher)
            .map { !$0.0.isEmpty && !$1.isEmpty }
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)
    }
}
