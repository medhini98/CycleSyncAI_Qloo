import UIKit

class CuratedForYouViewController: UIViewController {
    let backButton = UIButton(type: .system)
    let textView = UITextView()
    let containerView = UIView()
    let spinner = UIActivityIndicatorView(style: .medium)
    let loadingLabel = UILabel()
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        setupTextView()
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

    func setupTextView() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 6
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textView)

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

            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

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
        return """
1. 🍽️ Taste-Inspired Meals
Based on the user’s current menstrual phase (\(phase)) and preferred cuisines (\(cuisineStr)), suggest 3 culturally relevant meal options. These should be healthy, aligned with menstrual needs during the \(phase) phase, and rooted in \(profile.country).

2. 🎵 Move with Rhythm
Suggest 2 culturally relevant workout styles or routines inspired by the user’s location (\(profile.country)), music taste (\(musicStr)), and fitness level (\(profile.activityLevel)). Include suggested music or playlist genres if applicable.

3. 📚 Mood Boosters for This Phase
The user is currently in the \(phase) phase. Based on this, recommend 1 book, 1 movie, and 1 music genre to uplift the user’s mood. Base this on Qloo’s cultural insights about user’s tastes (\(tasteSummary)), and make it phase-appropriate.

4. ✈️ Places & Plates to Explore
Based on the user’s taste in food, activities, and music (\(cuisineStr), \(musicStr)), suggest one restaurant (in \(profile.country)) and one future travel destination. Tie them to the user’s menstrual wellness theme if possible (e.g., relaxation, rejuvenation).
"""
    }

    func formattedText(from content: String) -> NSAttributedString {
        let sections = content.components(separatedBy: "\n\n")
        let attributed = NSMutableAttributedString()
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        for section in sections {
            let parts = section.components(separatedBy: "\n")
            if let heading = parts.first {
                let headingAttr = NSAttributedString(string: heading + "\n", attributes: [
                    .font: UIFont(name: "Avenir-Heavy", size: 18)!,
                    .paragraphStyle: paragraph
                ])
                attributed.append(headingAttr)
                let body = parts.dropFirst().joined(separator: "\n")
                if !body.isEmpty {
                    let bodyAttr = NSAttributedString(string: body + "\n\n", attributes: [
                        .font: UIFont(name: "Avenir", size: 16)!,
                        .paragraphStyle: paragraph
                    ])
                    attributed.append(bodyAttr)
                }
            }
        }
        return attributed
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
                self.textView.attributedText = self.formattedText(from: content)
            }
        }.resume()
    }

    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }
}
