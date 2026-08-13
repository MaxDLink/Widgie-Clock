import Foundation

struct HandAngles: Equatable {
    let hour: Double
    let minute: Double
    let second: Double
}

enum ClockMath {
    static func angles(for date: Date, calendar: Calendar = .current) -> HandAngles {
        let parts = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        let seconds = Double(parts.second ?? 0) + Double(parts.nanosecond ?? 0) / 1_000_000_000
        let minutes = Double(parts.minute ?? 0) + seconds / 60
        let hours = Double((parts.hour ?? 0) % 12) + minutes / 60

        return HandAngles(hour: hours * 30, minute: minutes * 6, second: seconds * 6)
    }
}
