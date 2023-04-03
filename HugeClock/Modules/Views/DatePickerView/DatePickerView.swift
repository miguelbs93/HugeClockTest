import Combine
import UIKit

class DatePickerView: UIView {
    
    private struct Constants {
        static let defaultMaxInterval = 4 * 60 * 60
    }
    
    private var dateComponents: [DatePickerComponent] = [
        .init(type: .hours),
        .init(type: .minutes),
        .init(type: .seconds)
    ]
    
    private typealias HoursMinutesSeconds = (h: Int, m: Int, s: Int)
    
    private lazy var datePicker: UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    private let hoursMinutesSeconds: HoursMinutesSeconds
    
    private var selectedTime: HoursMinutesSeconds {
        var hour = 0
        var minutes = 0
        var seconds = 0
        
        for component in dateComponents {
            switch component.type {
            case .hours:
                hour = component.value
            case .minutes:
                minutes = component.value
            case .seconds:
                seconds = component.value
            }
        }
        
        return (h: hour, m: minutes, s: seconds)
    }
    
    // MARK: - Publishers
    
    var durationPublisher: CurrentValueSubject<Int, Never> = .init(0)
    var resetPublisher: PassthroughSubject<Void, Never> = .init()
    private var durationUpdaterPublisher: PassthroughSubject<Void, Never> = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    /// Initializes the DatePickerView
    /// - Parameters:
    ///    - maxInterval: The max interval the timer can go for, with default 6 hours
    init(_ maxInterval: Int = Constants.defaultMaxInterval) {
        self.hoursMinutesSeconds = maxInterval.secondsToHoursMinutesSeconds
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        bindPublishers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI

private extension DatePickerView {
    func setupView() {
        addSubview(datePicker)
        setupConstraints()
    }
    
    func resetTimerSelections() {
        datePicker.selectRow(0, inComponent: 0, animated: false)
        datePicker.selectRow(0, inComponent: 1, animated: false)
        datePicker.selectRow(0, inComponent: 2, animated: false)
        
        pickerView(datePicker, didSelectRow: 0, inComponent: 0)
        pickerView(datePicker, didSelectRow: 0, inComponent: 1)
        pickerView(datePicker, didSelectRow: 0, inComponent: 2)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Bindings

private extension DatePickerView {
    func bindPublishers() {
        resetPublisher
            .sink { [weak self] _ in
                self?.resetTimerSelections()
            }
            .store(in: &subscriptions)

        resetPublisher.send()

        durationUpdaterPublisher
            .sink { [weak self] _ in
                guard let self else { return }
                let duration = self.getDuration(from: self.selectedTime)
                self.durationPublisher.send(duration)
            }
            .store(in: &subscriptions)
    }

    private func getDuration(from time: HoursMinutesSeconds) -> Int {
        var duration = time.h * 60 * 60
        duration += time.m * 60
        duration += time.s
        return duration
    }
}

// MARK: - PickerViewDelegate

extension DatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dateComponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hoursMinutesSeconds.h
        case 1:
            return 60
        case 2:
            return 60
        default:
            fatalError("Component doesn't exist")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = String(row)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let label = pickerView.view(forRow: row, forComponent: component) as? UILabel {
            if component == 0, row > 1 {
                label.text = String(row) + " hours"
            }
            else if component == 0 {
                label.text = String(row) + " hour"
            }
            else if component == 1 {
                label.text = String(row) + " min"
            }
            else if component == 2 {
                label.text = String(row) + " sec"
            }
        }
        dateComponents[component] = dateComponents[component].with(value: row)
        durationUpdaterPublisher.send()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)"
    }
}
