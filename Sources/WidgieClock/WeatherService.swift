import Foundation

struct WeatherSnapshot: Equatable, Sendable {
    let temperature: Double
    let city: String
}

enum WeatherService {
    static func fetch(useFahrenheit: Bool) async throws -> WeatherSnapshot {
        let location = try await loadLocation()
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(location.latitude)),
            URLQueryItem(name: "longitude", value: String(location.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m"),
            URLQueryItem(name: "temperature_unit", value: useFahrenheit ? "fahrenheit" : "celsius"),
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        return try snapshot(location: location, forecastJSON: data)
    }

    static func snapshot(locationJSON: Data, forecastJSON: Data) throws -> WeatherSnapshot {
        let location = try JSONDecoder().decode(GeoIP.self, from: locationJSON)
        return try snapshot(location: location, forecastJSON: forecastJSON)
    }

    private static func snapshot(location: GeoIP, forecastJSON: Data) throws -> WeatherSnapshot {
        guard location.success else {
            throw URLError(.cannotFindHost)
        }
        let forecast = try JSONDecoder().decode(OpenMeteo.self, from: forecastJSON)
        return WeatherSnapshot(temperature: forecast.current.temperature2m, city: location.city)
    }

    private static func loadLocation() async throws -> GeoIP {
        let url = URL(string: "https://ipwho.is/")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(GeoIP.self, from: data)
    }

    struct GeoIP: Decodable {
        let success: Bool
        let latitude: Double
        let longitude: Double
        let city: String
    }

    private struct OpenMeteo: Decodable {
        let current: Current

        struct Current: Decodable {
            let temperature2m: Double

            enum CodingKeys: String, CodingKey {
                case temperature2m = "temperature_2m"
            }
        }
    }
}
