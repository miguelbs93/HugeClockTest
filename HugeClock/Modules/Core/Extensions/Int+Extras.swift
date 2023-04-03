import Foundation

extension Int {
    var secondsToHoursMinutesSeconds: (h: Int, m: Int, s: Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
    
    var timerStringRepresentation: String {
        let (hour, minutes, seconds) = self.secondsToHoursMinutesSeconds
        var value = ""
        if hour > 0 {
            value += String(format: "%02d:", hour)
        }
        value += String(format: "%02d:%02d", minutes, seconds)
        return value
    }
    
    var dateComponent: DateComponents {
        let date = Date(timeIntervalSinceNow: TimeInterval(self))
        return date.dateComponents
    }
}
