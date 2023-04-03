import Foundation

// MARK: - DateComponentType

internal enum DatePickerComponentType {
    case hours
    case minutes
    case seconds
    
    var intervals: Int {
        switch self {
        case .hours:
            return 24
        case .minutes:
            return 60
        case .seconds:
            return 60
        }
    }
}

// MARK: - Date Component

internal struct DatePickerComponent {
    let type: DatePickerComponentType
    let value: Int
    
    init(type: DatePickerComponentType, value: Int = 0) {
        self.type = type
        self.value = value
    }
}

internal extension DatePickerComponent {
    func with(value: Int) -> Self {
        DatePickerComponent(
            type: type,
            value: value
        )
    }
}
