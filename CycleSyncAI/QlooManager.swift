import Foundation

struct QlooResults {
    var cuisines: [String] = []
    var music: [String] = []
    var movies: [String] = []
    var books: [String] = []
    var places: [String] = []
    var restaurants: [String] = []
}

class QlooManager {
    static let shared = QlooManager()
    private init() {}

    private let baseURL = "https://hackathon.api.qloo.com"
    private let apiKey = "J2CV_pRU5Lpfx0d-_ePcXeVuijiw7BqsxyYUDXetj44"

    private func fetchStrings(from endpoint: String, params: [String: String] = [:], completion: @escaping ([String]) -> Void) {
        var components = URLComponents(string: baseURL + endpoint)!
        if !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else { completion([]); return }
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion([])
                return
            }
            if let arr = json["data"] as? [String] ?? json["results"] as? [String] {
                completion(arr)
            } else {
                completion([])
            }
        }
        task.resume()
    }

    func fetchAllData(profile: UserProfile, completion: @escaping (QlooResults) -> Void) {
        var results = QlooResults()
        let params = ["name": profile.name, "country": profile.country]
        let group = DispatchGroup()

        group.enter()
        fetchStrings(from: "/taste/cuisines", params: params) { list in
            results.cuisines = list
            group.leave()
        }

        group.enter()
        fetchStrings(from: "/taste/music", params: params) { list in
            results.music = list
            group.leave()
        }

        group.enter()
        fetchStrings(from: "/taste/movies", params: params) { list in
            results.movies = list
            group.leave()
        }

        group.enter()
        fetchStrings(from: "/taste/books", params: params) { list in
            results.books = list
            group.leave()
        }

        group.enter()
        fetchStrings(from: "/taste/places", params: params) { list in
            results.places = list
            group.leave()
        }

        group.enter()
        fetchStrings(from: "/taste/restaurants", params: params) { list in
            results.restaurants = list
            group.leave()
        }

        group.notify(queue: .main) {
            completion(results)
        }
    }
}
