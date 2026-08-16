import Foundation
import XCTest
@testable import WidgieClock

final class WeatherServiceTests: XCTestCase {
    func testParsesOpenMeteoSnapshot() throws {
        let location = Data("""
        {"success":true,"latitude":30.2672,"longitude":-97.7431,"city":"Austin"}
        """.utf8)
        let forecast = Data("""
        {"current":{"temperature_2m":72.4}}
        """.utf8)

        let snapshot = try WeatherService.snapshot(locationJSON: location, forecastJSON: forecast)

        XCTAssertEqual(snapshot.city, "Austin")
        XCTAssertEqual(snapshot.temperature, 72.4, accuracy: 0.001)
    }
}
