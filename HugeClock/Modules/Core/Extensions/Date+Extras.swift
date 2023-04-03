import Foundation

extension Date {
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm a"
        return dateFormatter.string(from: self)
    }
    
    var dateComponents: DateComponents {
        Calendar.current.dateComponents(in: TimeZone.current, from: self)
    }
}
