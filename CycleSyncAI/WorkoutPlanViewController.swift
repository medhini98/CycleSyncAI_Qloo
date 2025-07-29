import UIKit
import WebKit

class WorkoutPlanViewController: UIViewController {

    let backButton = UIButton(type: .system)
    let datePickerLabel = UILabel()
    let generateButton = UIButton(type: .system)
    let gradientLayer = CAGradientLayer()
    let workoutPlanContainerView = UIView()
    let workoutPlanWebView = WKWebView()
    let dateSegmentedControl = UISegmentedControl(items: ["Today", "Custom"])
    let startDatePicker = UIDatePicker()
    let endDatePicker = UIDatePicker()

    var userProfileData: UserProfile?
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var generatedHTML: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        setupDateControls()
        setupGenerateButton()
        setupWorkoutPlanTextView()
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
    
    func applyGradientToSegmentedControl(_ control: UISegmentedControl) {
        let imageSize = CGSize(width: 1, height: 36)
        UIGraphicsBeginImageContext(imageSize)
        let context = UIGraphicsGetCurrentContext()!

        let colors = [
            UIColor(red: 204/255, green: 193/255, blue: 247/255, alpha: 1).cgColor,
            UIColor(red: 169/255, green: 198/255, blue: 255/255, alpha: 1).cgColor
        ]

        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: colors as CFArray,
                                  locations: [0.0, 1.0])!

        context.drawLinearGradient(gradient,
                                    start: CGPoint(x: 0, y: 0),
                                    end: CGPoint(x: imageSize.width, y: imageSize.height),
                                    options: [])

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        control.setBackgroundImage(image, for: .selected, barMetrics: .default)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
    }

    func setupBackButton() {
        backButton.setTitle("← Back", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 12
        backButton.translatesAutoresizingMaskIntoConstraints = false

        // Apply gradient to back button
        let backGradient = CAGradientLayer()
        backGradient.colors = [
            UIColor(red: 204/255, green: 193/255, blue: 247/255, alpha: 1).cgColor,
            UIColor(red: 169/255, green: 198/255, blue: 255/255, alpha: 1).cgColor
        ]
        backGradient.startPoint = CGPoint(x: 0, y: 0)
        backGradient.endPoint = CGPoint(x: 1, y: 1)
        backGradient.frame = CGRect(x: 0, y: 0, width: 80, height: 36)
        backGradient.cornerRadius = 12
        backButton.layer.insertSublayer(backGradient, at: 0)

        backButton.addTarget(self, action: #selector(goBackToHome), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    func setupDateControls() {
        datePickerLabel.text = "Plan for:"
        datePickerLabel.font = UIFont(name: "Avenir", size: 16)
        datePickerLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)
        datePickerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePickerLabel)
        
        dateSegmentedControl.selectedSegmentIndex = 0
        dateSegmentedControl.selectedSegmentTintColor = UIColor(red: 204/255, green: 193/255, blue: 247/255, alpha: 1)
        dateSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        dateSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
        dateSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dateSegmentedControl)

        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.translatesAutoresizingMaskIntoConstraints = false
        startDatePicker.isHidden = true
        view.addSubview(startDatePicker)

        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.translatesAutoresizingMaskIntoConstraints = false
        endDatePicker.isHidden = true
        view.addSubview(endDatePicker)

        dateSegmentedControl.addTarget(self, action: #selector(dateSegmentChanged), for: .valueChanged)
        startDatePicker.addTarget(self, action: #selector(validateDateRange), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(validateDateRange), for: .valueChanged)

        NSLayoutConstraint.activate([
            // "Plan for:" label
            datePickerLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            datePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePickerLabel.widthAnchor.constraint(equalToConstant: 80),

            // Segmented control
            dateSegmentedControl.centerYAnchor.constraint(equalTo: datePickerLabel.centerYAnchor),
            dateSegmentedControl.leadingAnchor.constraint(equalTo: datePickerLabel.trailingAnchor, constant: 10),
            dateSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateSegmentedControl.heightAnchor.constraint(equalToConstant: 36),

            // Start and end date pickers in same row
            startDatePicker.topAnchor.constraint(equalTo: dateSegmentedControl.bottomAnchor, constant: 12),
            startDatePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),

            endDatePicker.topAnchor.constraint(equalTo: dateSegmentedControl.bottomAnchor, constant: 12),
            endDatePicker.leadingAnchor.constraint(equalTo: startDatePicker.trailingAnchor, constant: 30)
        ])
        
        applyGradientToSegmentedControl(dateSegmentedControl)
    }
    
    @objc func dateSegmentChanged() {
        let isCustom = dateSegmentedControl.selectedSegmentIndex == 1
        startDatePicker.isHidden = !isCustom
        endDatePicker.isHidden = !isCustom

        if !isCustom {
            selectedStartDate = Date()
            selectedEndDate = nil
        } else {
            selectedStartDate = startDatePicker.date
            selectedEndDate = endDatePicker.date
        }
    }

    @objc func validateDateRange() {
        selectedStartDate = startDatePicker.date
        selectedEndDate = endDatePicker.date

        if let start = selectedStartDate, let end = selectedEndDate {
            // Prevent end < start
            if end < start {
                endDatePicker.date = start
                selectedEndDate = start
            }

            // Limit to 7 days max
            let days = Calendar.current.dateComponents([.day], from: start, to: endDatePicker.date).day ?? 0
            if days > 6 {
                endDatePicker.date = Calendar.current.date(byAdding: .day, value: 6, to: start) ?? start
                selectedEndDate = endDatePicker.date
            }
        }
    }

    func setupGenerateButton() {
        generateButton.setTitle("Generate Workout Plan", for: .normal)
        generateButton.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 12
        generateButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonGradient = CAGradientLayer()
        buttonGradient.colors = [
            UIColor(red: 204/255, green: 193/255, blue: 247/255, alpha: 1).cgColor,
            UIColor(red: 169/255, green: 198/255, blue: 255/255, alpha: 1).cgColor
        ]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0)
        buttonGradient.endPoint = CGPoint(x: 1, y: 1)
        buttonGradient.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        buttonGradient.cornerRadius = 12
        generateButton.layer.insertSublayer(buttonGradient, at: 0)

        generateButton.addTarget(self, action: #selector(generateWorkoutPlan), for: .touchUpInside)
        view.addSubview(generateButton)

        NSLayoutConstraint.activate([
            generateButton.topAnchor.constraint(equalTo: self.endDatePicker.bottomAnchor, constant: 16),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 200),
            generateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func formattedDateLabel(start: Date, end: Date?, planType: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"

        let readableLabel: String
        if let end = end, Calendar.current.isDate(start, inSameDayAs: end) == false {
            // ✅ Use en-dash (U+2013) — this is the fix
            readableLabel = "\(dateFormatter.string(from: start))–\(dateFormatter.string(from: end))"
        } else {
            readableLabel = dateFormatter.string(from: start)
        }

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: Date())

        let prefix = planType.capitalized + " Plan"  // "Workout Plan"

        return "\(prefix) \(readableLabel) • \(timeString)"
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
    
    @objc func generateWorkoutPlan() {
        print("✅ Generate Workout Plan button tapped!")
        
        self.workoutPlanWebView.loadHTMLString("<html><body><p style='font-size: 18px;'>⏳ Generating workout plan...</p></body></html>", baseURL: nil)

        guard let profile = self.userProfileData else {
            print("❌ No user profile data found.")
            self.workoutPlanWebView.loadHTMLString("<html><body><p>⚠️ Please complete your user profile first.</p></body></html>", baseURL: nil)
            return
        }

        HealthManager.shared.requestAuthorization { success, error in
            if success {
                HealthManager.shared.fetchCurrentCycleStartDate { cycleStartDate in
                    guard let cycleStartDate = cycleStartDate else {
                        DispatchQueue.main.async {
                            self.workoutPlanWebView.loadHTMLString("<html><body><p>⚠️ No menstrual data found. Please log your period in the Health app.</p></body></html>", baseURL: nil)
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        let startDate: Date
                        var endDate: Date? = nil

                        if self.dateSegmentedControl.selectedSegmentIndex == 1 {
                            startDate = self.startDatePicker.date
                            endDate = self.endDatePicker.date
                        } else {
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

                            self.buildAndSendWorkoutPrompt(for: phases)
                        } else {
                            DispatchQueue.main.async {
                                let cycleDay = HealthManager.shared.calculateCycleDay(from: cycleStartDate, to: startDate) ?? -1
                                let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)
                                
                                self.buildAndSendWorkoutPrompt(for: [(date: startDate, cycleDay: cycleDay, phase: phase)])
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.workoutPlanWebView.loadHTMLString("<html><body><p>⚠️ HealthKit authorization failed.</p></body></html>", baseURL: nil)
                }
            }
        }
    }

    func buildAndSendWorkoutPrompt(for days: [(date: Date, cycleDay: Int, phase: String)]) {
        guard let profile = self.userProfileData else {
            self.workoutPlanWebView.loadHTMLString("<html><body><p>⚠️ Please complete your user profile first.</p></body></html>", baseURL: nil)
            return
        }

        let sortedDays = days.sorted { $0.date < $1.date }
        guard let startDate = sortedDays.first?.date else { return }
        let endDate = sortedDays.last?.date

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let startStr = dateFormatter.string(from: startDate)
        let endStr = endDate != nil ? dateFormatter.string(from: endDate!) : startStr

        let isDateRange = (endDate != nil && startDate != endDate!)
        let phaseList = Array(Set(days.map { $0.phase })).joined(separator: ", ")
        let cycleDay = sortedDays.first?.cycleDay ?? 1
        
        let today = Date()
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let todayStr = isoFormatter.string(from: today)
        let firstPlanDateStr = UserDefaults.standard.string(forKey: "firstPlanDate") ?? todayStr
        
        let (x, N, P) = TrackerManager.shared.adherenceSummary(since: firstPlanDateStr, to: todayStr, planType: "workout")  // or "diet"

        let adherenceNote = "The user has followed their diet plan for \(x)/\(N) days with an average adherence of \(Int(P * 100))%."

        let prompt: String

        if isDateRange {
            prompt = """
            You are an expert fitness trainer and women's health coach. Please generate a complete, well-structured HTML document.

            <h2>Formatting Instructions:</h2>
            - The output must be a complete, valid HTML document.
            - Use <h2> for major section headings (e.g., "Personalized Workout Plan", "Tips", "Sources").
            - Use <p> for paragraphs.
            - Use <ul><li> for bullet points.
            - For the workout plan section, use a single <table> wrapped in:
              <div style="overflow-x:auto;"> ... </div> to allow horizontal scrolling on small screens:
              • One row per day from \(startStr) to \(endStr)
              • Columns: Date, Phase, Cycle Day, Intensity, Workout Category, Exercises, Weights 🏋️, Hydration 💧, Calories Burned, Wake/Bedtime
            - Use <tr><td> for each table row and data cell.
            - Character limit per cell: 200 characters. If info exceeds this, truncate with ellipsis.
            - If not applicable (e.g., no weights), write "—".
            - Apply this layout strictly. Never skip or reorder columns. Never omit the header row.

            <h2>Personalized Workout Plan</h2>
            Generate a daily workout plan for each day from \(startStr) to \(endStr) (inclusive of both), based on:
            - Age group: \(profile.ageGroup)
            - Height: \(profile.height), Weight: \(profile.weight)
            - Goal: \(profile.goal)
            - Activity level: \(profile.activityLevel)
            - Country: \(profile.country)
            - Medical conditions: \(profile.medicalConditions)
            - Dietary restrictions: \(profile.dietaryRestrictions)
            - Menstrual phases (one of: \(phaseList))
            - Starting from cycle day \(cycleDay), increasing daily
            - Adjust plan difficulty based on: \(adherenceNote):
              • Low adherence → lighter workouts, shorter sessions, more encouragement.
              • High adherence → more challenging, diverse routines with progression.

            For each day:
            - Specify the date, menstrual phase, and cycle day
            - State the recommended intensity (Low, Medium, or High)
            - Give a main workout category (e.g., Strength, HIIT, Yoga)
            - Provide detailed exercise instructions with short explanations
            - Mention workout timing within each cell, like `@ 6:30 AM`.
            - Suggest weights in kg and lbs or common substitutes 🏋️
            - Include hydration tips 💧
            - Estimate calories burned based on weight and intensity
            - Recommend wake-up and sleep times

            While generating the workout plan, use the following menstrual phase exercise intensity guidelines:
            - Menstrual: Low (light yoga, walk)
            - Follicular: Medium–High (strength, cardio)
            - Ovulation: High (HIIT, spin)
            - Mid Luteal: Medium (Pilates, light strength)
            - Late Luteal: Low (stretching, yoga)

            <h2>Additional Sections</h2>
            1. <h2>Tips</h2>: 4–5 movement tips based on \(profile.goal) and \(phaseList)
            2. <h2>Motivation</h2>: One kind, one motivational line
            3. <h2>Sources</h2>: Real citations formatted as:
               [1] https://...
               [2] https://...

            <h2>IMPORTANT</h2>
            - Fill all <td> values. Use “—” if empty.
            - Keep formatting consistent.
            - Use <br> inside cells to break up longer content.
            - Include workout plans for all days from \(startStr) to \(endStr), inclusive.

            Only return valid, complete HTML.
            """
        } else {
            let phase = days.first?.phase ?? "Unknown"
            let cycleDay = days.first?.cycleDay ?? 1

            prompt = """
            You are an expert nutritionist and women's fitness trainer. Generate a complete, formatted HTML document. Answers should be direct and to the point.

            - Use <h2> for section headings.
            - Use <b> for important terms.
            - Use <ul><li> lists for bullet points.
            - Use <p> to separate paragraphs.

            Provide:

            1. A brief bullet list (5–6 points) summarizing the key exercise/movement focuses and priorities relevant to the user’s menstrual phase \(phase), goal \(profile.goal), activity level \(profile.activityLevel), age group \(profile.ageGroup), medical conditions \(profile.medicalConditions), and dietary restrictions \(profile.dietaryRestrictions).

            2. Generate a personalized workout plan for a \(profile.ageGroup) woman, \(profile.height), \(profile.weight), with \(profile.medicalConditions) and \(profile.dietaryRestrictions), on day \(cycleDay) of her menstrual cycle (\(phase) phase). The user's goal is \(profile.goal) and current activity level is \(profile.activityLevel). Include workout timings. Title this section as ‘Personalized Workout Plan’ (no need to include age, height, weight, or phase details in the subheading).

            Inside the Personalized Workout Plan section:
            - Include a Workout Intensity subheading and state the intensity level (Low, Medium, or High), based on the menstrual phase \(phase).
            - Include the main workout category for the phase.
            - Provide detailed exercise names or specific instructions under each category so the user can follow a clear, actionable routine.
            - For each exercise, include a brief (1-line) explanation of what the exercise is or how to do it, written simply for someone new to fitness.
            - When mentioning weights (e.g., dumbbells, resistance), suggest the weight in kg and include the equivalent in lbs, tailoring recommendations to the phase \(phase), goal \(profile.goal), activity level \(profile.activityLevel), age group \(profile.ageGroup), and medical conditions \(profile.medicalConditions).
            - Add a dumbbell icon 🏋️ next to weight recommendations.
            - If suggesting household substitutes (like water bottles), label this in the workout details.
            - Add hydration instructions alongside the workout steps, highlighted using a water drop icon 💧 or hydration checklist.

            While generating the workout plan, use the following menstrual phase exercise intensity guidelines:
            - Menstrual (days 1–7): Low or no intensity → suggest light walks, gentle yoga, or light strength/cardio.
            - Follicular (days 8–14): Medium to high intensity → suggest brisk walks, weight training, high-intensity exercises, or swimming.
            - Ovulation (days 15–20): High intensity → suggest HIIT, cardio, spin classes, circuits, or swimming.
            - Mid Luteal (days 21–24): Low to medium intensity → suggest swimming, gentle strength training, or Pilates.
            - Late Luteal (days 25–35): Low intensity → suggest restorative yoga, long walks, or stretching.

            Explanations and suggestions throughout should be phase-based, as this is the core focus of the app.

            3. Provide a brief (2–3 sentence) explanation of why the recommended workout is helpful during the \(phase) phase, including which muscles it targets and why the warm-up and cool-down are important, taking into account the user’s age, goal, and medical conditions.

            4. Add a one-line suggestion for ideal wake-up and bedtime routines for this user, based on their age, activity, and goal.

            5. Provide additional quick movement tips (not mentioned in the main workout plan) to help achieve \(profile.goal) during the \(phase) phase, considering the user’s medical conditions \(profile.medicalConditions) and dietary restrictions \(profile.dietaryRestrictions).

            6. Provide an approximate estimate of total calories burned for the workout, tailored to the user’s weight \(profile.weight), intensity, and activity type.

            7. Add a kind, appreciative line recognizing the user’s commitment to their health. Optionally include a motivational line if it aligns well with the user’s goal (\(profile.goal)).

            8. Include a <h2>Sources</h2> section listing all real, verifiable citations used in the plan. Format each citation on a separate line, numbered like:
            [1] https://...
            [2] https://...
            [3] https://...
            [4] https://...

            These sources should come from reputable resources (scientific publications, health sites, or official guidelines). Omit if no reliable citation is available.

            Separate each section clearly using headings (do not label them as ‘Task 1’, ‘Task 2’, etc.).

            While generating the workout plan, ensure you:
            - Suggest workout plans/exercises that support \(phase), \(profile.medicalConditions), and \(profile.goal).
            - Include exercises beneficial for women in age group \(profile.ageGroup).
            - Avoid any exercises harmful or exacerbating for \(profile.medicalConditions).
            - Respect all \(profile.dietaryRestrictions).
            - Avoid exercises that may worsen PMS or related symptoms during \(phase).
            - Adjust plan difficulty based on: \(adherenceNote):
              • Low adherence → lighter workouts, shorter sessions, more encouragement.
              • High adherence → more challenging, diverse routines with progression.
            """
        }

        callSonarAPI(with: prompt, startDate: startDate, endDate: endDate)
    }
    
    func setupWorkoutPlanTextView() {
        // Card container
        workoutPlanContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        workoutPlanContainerView.layer.cornerRadius = 16
        workoutPlanContainerView.layer.shadowColor = UIColor.black.cgColor
        workoutPlanContainerView.layer.shadowOpacity = 0.1
        workoutPlanContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        workoutPlanContainerView.layer.shadowRadius = 6
        workoutPlanContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(workoutPlanContainerView)

        // Web view inside card
        workoutPlanWebView.backgroundColor = .clear
        workoutPlanWebView.scrollView.isScrollEnabled = true
        workoutPlanWebView.translatesAutoresizingMaskIntoConstraints = false
        workoutPlanContainerView.addSubview(workoutPlanWebView)

        NSLayoutConstraint.activate([
            workoutPlanContainerView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 30),
            workoutPlanContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutPlanContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            workoutPlanContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            workoutPlanWebView.topAnchor.constraint(equalTo: workoutPlanContainerView.topAnchor, constant: 12),
            workoutPlanWebView.leadingAnchor.constraint(equalTo: workoutPlanContainerView.leadingAnchor, constant: 12),
            workoutPlanWebView.trailingAnchor.constraint(equalTo: workoutPlanContainerView.trailingAnchor, constant: -12),
            workoutPlanWebView.bottomAnchor.constraint(equalTo: workoutPlanContainerView.bottomAnchor, constant: -12)
        ])
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
                   let content = message["content"] as? String {

                    print("✅ Got API content!")
                    
                    // ✅ Add this to print raw content length and raw text
                        print("✅ Raw API content length: \(content.count)")
                        print("✅ Raw API content:\n\(content)")

                    // 💡 Strip ```html ... ``` if present
                    var cleanedContent = content
                    if cleanedContent.hasPrefix("```html") && cleanedContent.hasSuffix("```") {
                        cleanedContent = cleanedContent
                            .replacingOccurrences(of: "```html", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                    if let htmlData = cleanedContent.data(using: .utf8) {
                        DispatchQueue.main.async {
                            self.workoutPlanWebView.loadHTMLString(cleanedContent, baseURL: nil)
                            self.generatedHTML = cleanedContent

                            let planDates = self.generateDateArray(from: startDate, to: endDate)
                            print("📅 Saving dates to plan: \(planDates)")
                            let plan = PlanModel(
                                type: "workout",
                                dateLabel: self.formattedDateLabel(start: startDate, end: endDate, planType: "workout"),
                                content: cleanedContent,
                                dates: planDates
                            )
                            PlanHistoryManager.shared.savePlan(plan)
                            print("✅ Workout plan saved to history!")
                        }
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

    @objc func goBackToHome() {
        dismiss(animated: true, completion: nil)
    }
}
