import UIKit
import WebKit

class CuratedForYouViewController: UIViewController {
    let backButton = UIButton(type: .system)
    let webView = WKWebView()
    let containerView = UIView()
    let spinner = UIActivityIndicatorView(style: .medium)
    let loadingLabel = UILabel()
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        setupWebView()
        loadRecommendations()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func styleCuratedButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 224/255, green: 176/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 195/255, green: 139/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: 80, height: 36)
        gradient.cornerRadius = 12
        button.layer.insertSublayer(gradient, at: 0)
    }

    func setupBackButton() {
        backButton.setTitle("← Back", for: .normal)
        styleCuratedButton(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        view.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func setupWebView() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        webView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(webView)

        loadingLabel.text = "Gathering tailored suggestions..."
        loadingLabel.font = UIFont(name: "Avenir", size: 18)
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loadingLabel)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(spinner)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 30),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            webView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            webView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            webView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            webView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),

            loadingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),

            spinner.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 10)
        ])
    }

    func loadRecommendations() {
        spinner.startAnimating()
        let defaults = UserDefaults.standard
        let profile = UserProfile(
            name: defaults.string(forKey: "name") ?? "Friend",
            ageGroup: defaults.string(forKey: "age") ?? "",
            height: defaults.string(forKey: "height") ?? "",
            weight: defaults.string(forKey: "weight") ?? "",
            country: defaults.string(forKey: "country") ?? "USA",
            medicalConditions: (defaults.array(forKey: "medical") as? [String])?.joined(separator: ", ") ?? "",
            dietaryRestrictions: (defaults.array(forKey: "dietary") as? [String])?.joined(separator: ", ") ?? "",
            preferredCuisines: (defaults.array(forKey: "preferredCuisines") as? [String])?.joined(separator: ", ") ?? "",
            preferredMusicGenres: (defaults.array(forKey: "preferredMusicGenres") as? [String])?.joined(separator: ", ") ?? "",
            goal: defaults.string(forKey: "goal") ?? "",
            activityLevel: defaults.string(forKey: "activity") ?? ""
        )

        QlooManager.shared.fetchAllData(profile: profile) { qloo in
            self.fetchCurrentPhase { phase in
                let prompt = self.buildPrompt(phase: phase, qloo: qloo, profile: profile)
                self.callLLM(prompt: prompt)
            }
        }
    }

    func fetchCurrentPhase(completion: @escaping (String) -> Void) {
        HealthManager.shared.requestAuthorization { success, _ in
            guard success else { completion("Unknown"); return }
            HealthManager.shared.fetchCurrentCycleStartDate { start in
                if let start = start, let day = HealthManager.shared.calculateCycleDay(from: start) {
                    let phase = HealthManager.shared.determinePhase(for: day, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)
                    completion(phase)
                } else {
                    completion("Unknown")
                }
            }
        }
    }

    func buildPrompt(phase: String, qloo: QlooResults, profile: UserProfile) -> String {
        let cuisineStr = qloo.cuisines.joined(separator: ", ")
        let musicStr = qloo.music.joined(separator: ", ")
        let tasteSummary = [qloo.movies.joined(separator: ", "), qloo.books.joined(separator: ", ")].joined(separator: ", ")
        let formatting = """
Generate a complete, formatted HTML document. Answers should be direct and to the point.

- Use <h2> for section headings.
- Use <b> for important terms.
- Use <ul><li> lists for bullet points.
- Use <p> to separate paragraphs.
"""

        return """
\(formatting)

User details:
- Age group: \(profile.ageGroup)
- Height: \(profile.height)
- Weight: \(profile.weight)
- Country: \(profile.country)
- Medical Conditions: \(profile.medicalConditions)
- Dietary Restrictions: \(profile.dietaryRestrictions)
- Activity Level: \(profile.activityLevel)
- Preferred Cuisines: \(profile.preferredCuisines)
- Preferred Music Genres: \(profile.preferredMusicGenres)

1. 🍽️ Taste-Inspired Meals
Based on the user’s current menstrual phase (\(phase)) and preferred cuisines (\(cuisineStr)), suggest 3 culturally relevant meal options that align with \(phase) needs and the user’s locale.

2. 🎵 Move with Rhythm
Recommend 2 workout styles inspired by \(profile.country) culture and the user’s music taste (\(musicStr)). Tailor to activity level \(profile.activityLevel).

3. 📚 Mood Boosters for This Phase
The user is currently in the \(phase) phase. Suggest 1 book, 1 movie and 1 music genre to uplift their mood, leveraging Qloo insights (\(tasteSummary)).

4. ✈️ Places & Plates to Explore
Given the tastes above (\(cuisineStr), \(musicStr)), suggest a restaurant in \(profile.country) and a future travel destination tied to menstrual wellness.
"""
    }

    func callLLM(prompt: String) {
        guard let url = URL(string: "https://api.perplexity.ai/chat/completions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = [
            "model": "sonar-pro",
            "messages": [["role": "user", "content": prompt]]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.loadingLabel.isHidden = true
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let message = choices.first?["message"] as? [String: Any],
                  var content = message["content"] as? String else { return }
            if content.hasPrefix("```html") && content.hasSuffix("```") {
                content = content.replacingOccurrences(of: "```html", with: "").replacingOccurrences(of: "```", with: "")
            }
            DispatchQueue.main.async {
                self.webView.loadHTMLString(content, baseURL: nil)
            }
        }.resume()
    }

    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }
}
