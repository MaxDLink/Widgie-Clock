import Foundation
import XCTest
@testable import WidgieClock

final class ClockMathTests: XCTestCase {
    func testHandAnglesAtThreeFifteenThirty() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let date = try XCTUnwrap(calendar.date(from: DateComponents(
            year: 2026, month: 1, day: 1, hour: 3, minute: 15, second: 30
        )))

        let angles = ClockMath.angles(for: date, calendar: calendar)

        XCTAssertEqual(angles.hour, 97.75, accuracy: 0.001)
        XCTAssertEqual(angles.minute, 93, accuracy: 0.001)
        XCTAssertEqual(angles.second, 180, accuracy: 0.001)
    }
}
