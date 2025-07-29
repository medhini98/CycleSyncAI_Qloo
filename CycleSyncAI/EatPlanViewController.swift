import UIKit
import WebKit

class EatPlanViewController: UIViewController {

    let backButton = UIButton(type: .system)
    let promptLabel = UILabel()
    let mealPreferenceField = UITextField()
    let generateButton = UIButton(type: .system)
    let dietPlanWebView = WKWebView()
    let gradientLayer = CAGradientLayer()
    let dietPlanContainerView = UIView()
    let dateSegmentedControl = UISegmentedControl(items: ["Today", "Custom"])
    let startDateContainer = UIView()
    let endDateContainer = UIView()
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()
    let taglineLabel = UILabel()
    
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    
    let sectionTextColor = UIColor(red: 230/255, green: 100/255, blue: 140/255, alpha: 1)  // #E6648C
    
    var userProfileData: UserProfile?
    var generatedHTML: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        setupPromptLabel()
        setupMealPreferenceField()
        setupDateControls()           // ✅ moved up
        setupGenerateButton()        // depends on endDateContainer
        setupDietPlanWebView()
        setupTapToDismissKeyboard()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        styleEatPlanButton(backButton)
        styleEatPlanButton(generateButton)
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
    
    func applyGradient(to view: UIView, colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.cornerRadius = 12
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupBackButton() {
        backButton.setTitle("← Back", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = UIColor(red: 230/255, green: 130/255, blue: 150/255, alpha: 1)
        backButton.layer.cornerRadius = 12
        backButton.clipsToBounds = true
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 6
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(goBackToHome), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func setupPromptLabel() {
        promptLabel.text = "What do you feel like eating today?"
        promptLabel.font = UIFont(name: "Avenir", size: 18)
        promptLabel.textAlignment = .center
        promptLabel.textColor = sectionTextColor
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptLabel)

        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupMealPreferenceField() {
        mealPreferenceField.placeholder = "Optional: e.g., South Indian"
        mealPreferenceField.borderStyle = .roundedRect
        mealPreferenceField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mealPreferenceField)

        NSLayoutConstraint.activate([
            mealPreferenceField.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 10),
            mealPreferenceField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mealPreferenceField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mealPreferenceField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupDateControls() {
        // Segmented control
        dateSegmentedControl.selectedSegmentIndex = 0
        dateSegmentedControl.selectedSegmentTintColor = UIColor(red: 230/255, green: 130/255, blue: 150/255, alpha: 1)
        dateSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        dateSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
        dateSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateSegmentedControl)

        // Styled container views
        self.startDateContainer.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.startDateContainer.layer.cornerRadius = 12
        self.startDateContainer.layer.shadowColor = UIColor.black.cgColor
        self.startDateContainer.layer.shadowOpacity = 0.2
        self.startDateContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.startDateContainer.layer.shadowRadius = 4
        self.startDateContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.startDateContainer)
        
        applyGradient(to: self.startDateContainer, colors: [
            UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1).cgColor,
            UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1).cgColor
        ])

        self.endDateContainer.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.endDateContainer.layer.cornerRadius = 12
        self.endDateContainer.layer.shadowColor = UIColor.black.cgColor
        self.endDateContainer.layer.shadowOpacity = 0.2
        self.endDateContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.endDateContainer.layer.shadowRadius = 4
        self.endDateContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.endDateContainer)
        
        applyGradient(to: self.endDateContainer, colors: [
            UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1).cgColor,
            UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1).cgColor
        ])

        self.startDatePicker.datePickerMode = .date
        self.startDatePicker.preferredDatePickerStyle = .compact
        self.startDatePicker.backgroundColor = .clear
        self.startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        self.startDateContainer.addSubview(self.startDatePicker)
        self.startDatePicker.layer.cornerRadius = 8
        self.startDatePicker.clipsToBounds = true
        
        self.endDatePicker.datePickerMode = .date
        self.endDatePicker.preferredDatePickerStyle = .compact
        self.endDatePicker.backgroundColor = .clear
        self.endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        self.endDateContainer.addSubview(self.endDatePicker)
        self.endDatePicker.layer.cornerRadius = 8
        self.endDatePicker.clipsToBounds = true

        // Actions
        dateSegmentedControl.addTarget(self, action: #selector(dateSegmentChanged), for: .valueChanged)
        startDatePicker.addTarget(self, action: #selector(validateDateRange), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(validateDateRange), for: .valueChanged)
        
        let datePickerStack = UIStackView(arrangedSubviews: [self.startDateContainer, self.endDateContainer])
        datePickerStack.axis = .horizontal
        datePickerStack.distribution = .fillEqually
        datePickerStack.spacing = 12
        datePickerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePickerStack)

        NSLayoutConstraint.activate([
            dateSegmentedControl.topAnchor.constraint(equalTo: mealPreferenceField.bottomAnchor, constant: 20),
            dateSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateSegmentedControl.widthAnchor.constraint(equalToConstant: 240),
            dateSegmentedControl.heightAnchor.constraint(equalToConstant: 36),

            datePickerStack.topAnchor.constraint(equalTo: dateSegmentedControl.bottomAnchor, constant: 12),
            datePickerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePickerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            datePickerStack.heightAnchor.constraint(equalToConstant: 40),

            self.startDatePicker.centerYAnchor.constraint(equalTo: self.startDateContainer.centerYAnchor),
            self.startDatePicker.leadingAnchor.constraint(equalTo: self.startDateContainer.leadingAnchor, constant: 10),

            self.endDatePicker.centerYAnchor.constraint(equalTo: self.endDateContainer.centerYAnchor),
            self.endDatePicker.leadingAnchor.constraint(equalTo: self.endDateContainer.leadingAnchor, constant: 10)
        ])
    }

    func setupGenerateButton() {
        taglineLabel.text = "Click below to get a personalized plan in minutes!"
        taglineLabel.font = UIFont(name: "Avenir", size: 16)
        taglineLabel.textAlignment = .center
        taglineLabel.textColor = sectionTextColor
        taglineLabel.numberOfLines = 0
        taglineLabel.lineBreakMode = .byWordWrapping
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taglineLabel)

        generateButton.setTitle("Generate Diet Plan", for: .normal)
        generateButton.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.backgroundColor = UIColor(red: 230/255, green: 130/255, blue: 150/255, alpha: 1)  // pastel rose
        generateButton.layer.cornerRadius = 12
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateDietPlan), for: .touchUpInside)
        view.addSubview(generateButton)
        
        NSLayoutConstraint.activate([
            taglineLabel.topAnchor.constraint(equalTo: endDateContainer.bottomAnchor, constant: 12),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            generateButton.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 16),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 200),
            generateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupDietPlanWebView() {
        // Container view for the web view (card-style)
        dietPlanContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        dietPlanContainerView.layer.cornerRadius = 16
        dietPlanContainerView.layer.shadowColor = UIColor.black.cgColor
        dietPlanContainerView.layer.shadowOpacity = 0.1
        dietPlanContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dietPlanContainerView.layer.shadowRadius = 6
        dietPlanContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dietPlanContainerView)

        // Web view for rich HTML rendering
        dietPlanWebView.backgroundColor = .clear
        dietPlanWebView.scrollView.isScrollEnabled = true
        dietPlanWebView.translatesAutoresizingMaskIntoConstraints = false
        dietPlanContainerView.addSubview(dietPlanWebView)

        NSLayoutConstraint.activate([
            dietPlanContainerView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 30),
            dietPlanContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dietPlanContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dietPlanContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            dietPlanWebView.topAnchor.constraint(equalTo: dietPlanContainerView.topAnchor, constant: 12),
            dietPlanWebView.leadingAnchor.constraint(equalTo: dietPlanContainerView.leadingAnchor, constant: 12),
            dietPlanWebView.trailingAnchor.constraint(equalTo: dietPlanContainerView.trailingAnchor, constant: -12),
            dietPlanWebView.bottomAnchor.constraint(equalTo: dietPlanContainerView.bottomAnchor, constant: -12)
        ])
    }
    
    func formattedDateLabel(start: Date, end: Date?, planType: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"

        let readableLabel: String
        if let end = end, Calendar.current.isDate(start, inSameDayAs: end) == false {
            readableLabel = "\(dateFormatter.string(from: start))–\(dateFormatter.string(from: end))"
        } else {
            readableLabel = dateFormatter.string(from: start)
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: Date())

        let prefix = planType.capitalized + " Plan"  // "Diet Plan" or "Workout Plan"

        return "\(prefix) \(readableLabel) • \(timeString)"
    }

    @objc func generateDietPlan() {
        print("✅ Generate Diet Plan button tapped!")
        
        let loadingHTML = """
        <html>
          <body style="font-family: -apple-system; text-align: center; font-size: 20px; padding-top: 100px;">
            ⏳ Generating your personalized diet plan...
          </body>
        </html>
        """
        self.dietPlanWebView.loadHTMLString(loadingHTML, baseURL: nil)

        guard let profile = self.userProfileData else {
            print("❌ No user profile data found.")
            self.dietPlanWebView.loadHTMLString("<html><body><p>⚠️ Please complete your user profile first.</p></body></html>", baseURL: nil)
            return
        }
        
        generateButton.isEnabled = false
        generateButton.alpha = 0.5  // Optional: gray it out

        HealthManager.shared.requestAuthorization { success, error in
            if success {
                HealthManager.shared.fetchCurrentCycleStartDate { cycleStartDate in
                    guard let cycleStartDate = cycleStartDate else {
                        DispatchQueue.main.async {
                            self.dietPlanWebView.loadHTMLString("<html><body><p>⚠️ ⚠️ No menstrual data found. Please log your period in the Health app.</p></body></html>", baseURL: nil)
                            self.generateButton.isEnabled = true
                            self.generateButton.alpha = 1.0
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        let startDate: Date
                        var endDate: Date? = nil

                        if self.dateSegmentedControl.selectedSegmentIndex == 1 {
                            // Custom range
                            startDate = self.startDatePicker.date
                            endDate = self.endDatePicker.date
                        } else {
                            // Today
                            startDate = Date()
                        }

                        self.selectedStartDate = startDate
                        self.selectedEndDate = endDate

                        if let end = endDate, startDate != end {
                            var phases: [(date: Date, cycleDay: Int, phase: String)] = []

                            var current = startDate
                            let calendar = Calendar.current

                            while current <= end {
                                let day = HealthManager.shared.calculateCycleDay(from: cycleStartDate, to: current) ?? -1
                                let phase = HealthManager.shared.determinePhase(for: day, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)
                                phases.append((date: current, cycleDay: day, phase: phase))

                                current = calendar.date(byAdding: .day, value: 1, to: current)!
                            }

                            self.buildAndSendPrompt(for: phases)
                        } else {
                            let cycleDay = HealthManager.shared.calculateCycleDay(from: cycleStartDate, to: startDate) ?? -1
                            let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)

                            self.buildAndSendPrompt(for: [(date: startDate, cycleDay: cycleDay, phase: phase)])
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.dietPlanWebView.loadHTMLString("<html><body><p>⚠️ HealthKit authorization failed.</p></body></html>", baseURL: nil)
                    self.generateButton.isEnabled = true
                    self.generateButton.alpha = 1.0
                }
            }
        }
    }
    
    func buildAndSendPrompt(for days: [(date: Date, cycleDay: Int, phase: String)]) {
        guard let profile = self.userProfileData else {
            self.dietPlanWebView.loadHTMLString("<html><body><p>⚠️ Please complete your user profile first.</p></body></html>", baseURL: nil)
            return
        }

        let preference = self.mealPreferenceField.text ?? "No preference"
        
        let phase = days.first?.phase ?? "Unknown"
        
        let sortedDays = days.sorted { $0.date < $1.date }
        guard let startDate = sortedDays.first?.date else { return }
        let endDate = sortedDays.last?.date

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let startStr = DateFormatter.localizedString(from: startDate, dateStyle: .medium, timeStyle: .none)
        let endStr = endDate != nil ? DateFormatter.localizedString(from: endDate!, dateStyle: .medium, timeStyle: .none) : startStr

        let isDateRange = (endDate != nil && startDate != endDate!)
        let phaseList = Array(Set(days.map { $0.phase })).joined(separator: ", ")
        let cycleDay = sortedDays.first?.cycleDay ?? 1
        
        let today = Date()
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let todayStr = isoFormatter.string(from: today)
        let firstPlanDateStr = UserDefaults.standard.string(forKey: "firstPlanDate") ?? todayStr
        
        let (x, N, P) = TrackerManager.shared.adherenceSummary(since: firstPlanDateStr, to: todayStr, planType: "diet")  // or "workout"

        let adherenceNote = "The user has followed their diet plan for \(x)/\(N) days with an average adherence of \(Int(P * 100))%."

        let prompt: String

        if isDateRange {
            prompt = """
        You are an expert nutritionist. Please generate a complete, well-structured HTML document.

        <h2>Formatting Instructions:</h2>
        - The output must be a complete, valid HTML document.
        - Use <h2> for major section headings (e.g., "Personalized Diet Plan", "Tips", "Sources").
        - Use <p> for paragraphs.
        - Use <ul><li> for bullet lists.
        - For the diet plan section, use a single <table> wrapped in:
          <div style="overflow-x:auto;"> ... </div> to allow horizontal scrolling on small screens:
          • One row per day from \(startStr) to \(endStr)
          • Columns: Date, Phase, Wake-up & Bedtime, Early Morning Drink, Breakfast, Mid-Morning Snack, Lunch, Evening Snack, Dinner, Hydration, Seed Suggestion
        - Use <tr><td> for each table row and data cell.
        - **Character limit per cell: 200 characters**. If info exceeds this, truncate with ellipsis and summarize.
        - Ensure each <td> cell is filled. If not applicable (e.g., no snack), write "—".
        - The entire <table> must be wrapped inside a <div style="overflow-x:auto;"> to enable horizontal scrolling if needed.
        - Apply this layout strictly. Never skip or reorder columns. Never omit the header row.

        <h2>Personalized Diet Plan</h2>
        Generate a daily meal plan for each day from \(startStr) to \(endStr) (inclusive of both), based on:
        - Age group: \(profile.ageGroup)
        - Height: \(profile.height) and Weight: \(profile.weight)
        - Country: \(profile.country)
        - Goal: \(profile.goal)
        - Activity level: \(profile.activityLevel)
        - Medical conditions: \(profile.medicalConditions)
        - Dietary restrictions: \(profile.dietaryRestrictions)
        - Menstrual phase (one of: \(phaseList))
        - Starting from cycle day \(cycleDay)
        - Meal preference: \(mealPreferenceField.text ?? "No preference")
        - \(adherenceNote)

        <h2>Meal Structure Guidelines (Biology-Based)</h2>
        - Always include: Early Drink, Breakfast, Mid-Morning Snack, Lunch, Evening Snack, Dinner. For each item, clearly state the suggested time in the same table cell (e.g., @ 10:30 AM).
        - Adjust meals based on menstrual phase guidelines

        <h2>Other Instructions</h2>
        - Mention hydration and seed suggestion per day
        - Do not repeat profile inside cells

        <h2>Additional Sections</h2>
        1. <h2>Tips</h2> – 4–5 helpful bullet points
        2. <h2>Grocery List</h2>
        3. <h2>Motivation</h2>
        4. <h2>Sources</h2>

        <h2>IMPORTANT</h2>
        - Stick to table structure exactly
        - Fill empty cells with “—”
        - Format output using <br> inside <td> if needed
        - Return only valid, complete HTML
        - Be sure to include meal plans for both the start date (\(startStr)) and end date (\(endStr)), inclusive
        """
        } else {
            prompt = """
                    You are an expert nutritionist. Please generate a complete, formatted HTML document.

                    - Use <h2> for section headings.
                    - Use <b> for important terms.
                    - Use <ul><li> lists for bullet points.
                    - Use <p> to separate paragraphs.

                    Provide:
                    1. A brief bullet list (5–6 points) summarizing the key dietary focuses and nutritional priorities relevant to the user’s menstrual phase \(phase), goal \(profile.goal), activity level \(profile.activityLevel), age group \(profile.ageGroup), country \(profile.country), medical conditions \(profile.medicalConditions), and dietary restrictions \(profile.dietaryRestrictions).

                    2. Generate a personalized diet plan for a \(profile.ageGroup) woman, from , country \(profile.country) \(profile.height), \(profile.weight), with \(profile.medicalConditions) and \(profile.dietaryRestrictions), on day \(cycleDay) of her menstrual cycle (\(phase) phase). The user's goal is \(profile.goal) and current activity level is \(profile.activityLevel). Meal preference for today is \(preference). Include meal timings as well for each meal. Title this section as ‘Personalized Diet Plan’ (no need to include age, height, weight, or phase details in the subheading). Make sure to include seed suggestion in the diet based on \(phase) like 'Eat Flax & pumpkin seeds 🎃.' Make sure to include hydration instructions based on \(profile.ageGroup), \(profile.height), \(profile.weight), \(phase), \(profile.medicalConditions), \(profile.activityLevel), and \(profile.goal). Include meal timings.

                    3. Provide a brief (2–3 sentence) explanation of why eating the recommended seeds is helpful during the \(phase) phase.

                    4. Add a one-line suggestion for ideal wake-up and bedtime routines for this user, based on their age, activity, and goal.

                    5. Provide additional quick diet tips (not mentioned in the main diet plan) to help achieve \(profile.goal) during the \(phase) phase, considering the user’s medical conditions \(profile.medicalConditions) and dietary restrictions \(profile.dietaryRestrictions).
                    
                    6. Provide a concise grocery list for today’s meals, focusing on fresh, special, or phase-specific ingredients, excluding common pantry staples.

                    7. A kind, appreciative line recognizing the user’s commitment to their health. Optionally include a motivational line if it aligns well with the user’s goal (\(profile.goal)).

                    8. At the end, include a <h2>Sources</h2> section listing all the real, verifiable citations you used, numbered like. Format each citation on a separate line, like:
                    [1] https://...
                    [2] https://...
                    [3] https://...
                    [4] https://...
                    etc.

                    These sources should be real, verifiable, and drawn from reputable resources (such as scientific publications, reputable health sites, or official guidelines). If no reliable citation is available, omit rather than fabricating one.

                    Please separate responses for each section clearly using headings (but do not label them as ‘Task 1’, ‘Task 2’, etc.).

                    While generating the diet plan and creating the grocery list, ensure you:
                    - Suggest meals/ingredients that support \(phase), \(profile.medicalConditions), and \(profile.goal).
                    - Include foods beneficial for women in age group \(profile.ageGroup).
                    - Make sure most ingredients are locally available in country \(profile.country).
                    - Avoid any foods harmful or exacerbating for \(profile.medicalConditions).
                    - Respect all \(profile.dietaryRestrictions).
                    - Avoid foods that may worsen PMS or related symptoms during \(phase).
                    - Take into consideration: \(adherenceNote)
                    """
        }

        callSonarAPI(with: prompt, startDate: startDate, endDate: endDate)
    }
    
    func generateDateArray(from start: Date, to end: Date?) -> [String] {
        let calendar = Calendar.current
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"

        var dates: [String] = []
        var current = start
        let endDate = end ?? start

        while current <= endDate {
            dates.append(isoFormatter.string(from: current))
            guard let next = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }

        return dates
    }
    
    func callSonarAPI(with prompt: String, startDate: Date, endDate: Date?) {
        guard let url = URL(string: "https://api.perplexity.ai/chat/completions") else {
            print("❌ Invalid API URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": "sonar-pro",
            "messages": [["role": "user", "content": prompt]]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to encode request body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from API.")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let choices = json?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   var content = message["content"] as? String {

                    print("✅ Got API content!")

                    // 💡 Strip ```html ... ``` if present
                    if content.hasPrefix("```html") && content.hasSuffix("```") {
                        content = content
                            .replacingOccurrences(of: "```html", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                    DispatchQueue.main.async {
                        self.dietPlanWebView.loadHTMLString(content, baseURL: nil)
                        self.generatedHTML = content
                        
                        self.generateButton.isEnabled = true
                        self.generateButton.alpha = 1.0
                        
                        print("✅ Saving content to plan: \(content.prefix(300))")

                        let planDates = self.generateDateArray(from: startDate, to: endDate)
                        print("📅 Saving dates to plan: \(planDates)") // 👈 To verify the list of ISO date strings saved
                        let plan = PlanModel(
                            type: "diet",
                            dateLabel: self.formattedDateLabel(start: startDate, end: endDate, planType: "diet"),
                            content: content,
                            dates: planDates
                        )
                        PlanHistoryManager.shared.savePlan(plan)
                        print("✅ Diet plan saved to history!")
                    }

                } else {
                    print("❌ Unexpected API response format.")
                    DispatchQueue.main.async {
                        self.generateButton.isEnabled = true
                        self.generateButton.alpha = 1.0
                    }
                }
            } catch {
                print("❌ Failed to parse API response: \(error)")
                DispatchQueue.main.async {
                    self.generateButton.isEnabled = true
                    self.generateButton.alpha = 1.0
                }
            }
        }

        task.resume()
    }
    
    func styleEatPlanButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)  // ✅ white text
        button.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6

        button.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = 12
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1).cgColor,    // #FFC3B9
            UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1).cgColor   // #FEB2DC
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        button.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func dateSegmentChanged() {
        let isCustom = dateSegmentedControl.selectedSegmentIndex == 1
        startDatePicker.isHidden = !isCustom
        endDatePicker.isHidden = !isCustom

        // Delegate to validation logic
        validateDateRange()
    }

    @objc func validateDateRange() {
        selectedStartDate = startDatePicker.date
        selectedEndDate = endDatePicker.date

        guard let start = selectedStartDate else { return }

        // Prevent end < start
        if let end = selectedEndDate, end < start {
            endDatePicker.date = start
            selectedEndDate = start
        }

        // Limit to 7 days max
        if let end = selectedEndDate {
            let days = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
            if days > 6 {
                let capped = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
                endDatePicker.date = capped
                selectedEndDate = capped
            }
        }
    }
    
    @objc func goBackToHome() {
        dismiss(animated: true, completion: nil)
    }
}
