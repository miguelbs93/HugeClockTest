import Foundation

struct Clock: Hashable {
    let city: String
    let timezoneIdentifier: String
}

extension Clock {
    /// Get date with Clock's corresponding timezone
    /// **Parameters:
    /// - Date: Date to be formatted
    func getFormattedDate(from date: Date) -> String {
        let dateToStringFormatter = DateFormatter()
        dateToStringFormatter.timeZone = TimeZone(identifier: self.timezoneIdentifier)
        dateToStringFormatter.defaultDate = date
        dateToStringFormatter.dateFormat = "HH:mm:ss a"
        return dateToStringFormatter.string(from: date)
    }
}
