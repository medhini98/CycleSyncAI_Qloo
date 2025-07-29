import UIKit
import WebKit

class PlanDetailViewController: UIViewController {

    let plan: PlanModel
    let webView = WKWebView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let calendarPicker = UIDatePicker()
    let dateButton = UIButton(type: .system)
    var calendarContainer: UIView?
    let checklistStackView = UIStackView()
    let gradientLayer = CAGradientLayer()
    var selectedDate: String = ""
    var dateOptions: [String] = []
    let completionProgress = UIProgressView(progressViewStyle: .default)
    var calendarHeightConstraint: NSLayoutConstraint?
    var mealMap: [String: [String: String]] = [:]
    
    init(plan: PlanModel) {
        self.plan = plan

        if !plan.dates.isEmpty {
            self.dateOptions = plan.dates
            print("🗓️ Using saved dates from PlanModel: \(plan.dates)")
        } else {
            let label = plan.dateLabel
                .replacingOccurrences(of: "Diet Plan", with: "")
                .replacingOccurrences(of: "Workout Plan", with: "")
                .components(separatedBy: "•").first?
                .trimmingCharacters(in: .whitespaces) ?? plan.dateLabel

            self.dateOptions = PlanDetailViewController.extractDates(from: label)
            print("🧪 Parsed dateOptions from label: \(self.dateOptions)")
        }

        self.selectedDate = PlanDetailViewController.chooseDefaultDate(from: self.dateOptions)
        print("🔢 Date Options Extracted: \(self.dateOptions)")

        if plan.type == "diet" {
            self.mealMap = PlanDetailViewController.parseMeals(from: plan.content, dates: self.dateOptions)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupScrollView()
        setupWebView()

        let trackerLabel = UILabel()
        trackerLabel.text = "📌 Tracker"
        trackerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        trackerLabel.textColor = UIColor(red: 0.176, green: 0.231, blue: 0.298, alpha: 1)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerLabel)
        NSLayoutConstraint.activate([
            trackerLabel.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 16),
            trackerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        setupDateTogglePicker(below: trackerLabel.bottomAnchor)
        setupChecklist()
        loadPlanContent()
        title = plan.dateLabel
    }

    func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupScrollView() {
        scrollView.isScrollEnabled = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    func setupWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layer.cornerRadius = 10
        webView.layer.borderWidth = 1
        webView.layer.borderColor = UIColor.systemGray4.cgColor
        webView.layer.shadowColor = UIColor.black.cgColor
        webView.layer.shadowOpacity = 0.1
        webView.layer.shadowOffset = CGSize(width: 0, height: 2)
        webView.layer.shadowRadius = 4
        webView.clipsToBounds = false
        contentView.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            webView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            webView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            webView.heightAnchor.constraint(equalToConstant: 400)
        ])
    }
    
    func setupDateTogglePicker(below anchor: NSLayoutYAxisAnchor) {
        let label = UILabel()
        label.text = "Plan for:"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(red: 0.176, green: 0.231, blue: 0.298, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        let defaultDateDisplay = formatDateForDisplay(selectedDate)
        self.dateButton.setTitle("[\(defaultDateDisplay)]", for: .normal)
        self.dateButton.setTitleColor(.systemBlue, for: .normal)
        self.dateButton.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        self.dateButton.translatesAutoresizingMaskIntoConstraints = false
        self.dateButton.addTarget(self, action: #selector(toggleCalendar), for: .touchUpInside)
        self.dateButton.isEnabled = dateOptions.count > 1
        contentView.addSubview(self.dateButton)

        // 🟦 Container to hold the calendar (for show/hide cleanly)
        let calendarWrapper = UIView()
        calendarWrapper.translatesAutoresizingMaskIntoConstraints = false
        calendarWrapper.isHidden = dateOptions.count <= 1
        contentView.addSubview(calendarWrapper)
        self.calendarContainer = calendarWrapper  // save ref
        self.calendarHeightConstraint = calendarWrapper.heightAnchor.constraint(equalToConstant: 0)
        self.calendarHeightConstraint?.isActive = true

        // 🟨 Add date picker inside wrapper
        calendarPicker.datePickerMode = .date
        calendarPicker.preferredDatePickerStyle = .inline
        calendarPicker.translatesAutoresizingMaskIntoConstraints = false
        calendarPicker.addTarget(self, action: #selector(calendarDatePicked(_:)), for: .valueChanged)
        calendarWrapper.addSubview(calendarPicker)

        self.calendarHeightConstraint = calendarWrapper.heightAnchor.constraint(equalToConstant: 0)



        let defaultHeight = calendarPicker.intrinsicContentSize.height
        self.calendarHeightConstraint = calendarWrapper.heightAnchor.constraint(equalToConstant: dateOptions.count <= 1 ? 0 : defaultHeight)


        self.calendarHeightConstraint?.isActive = true

        if let first = dateOptions.first,
           let last = dateOptions.last {
            let iso = DateFormatter()
            iso.dateFormat = "yyyy-MM-dd"
            calendarPicker.minimumDate = iso.date(from: first)
            calendarPicker.maximumDate = iso.date(from: last)
        }

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: anchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            self.dateButton.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            self.dateButton.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6),

            calendarWrapper.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            calendarWrapper.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            calendarWrapper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            calendarPicker.topAnchor.constraint(equalTo: calendarWrapper.topAnchor),
            calendarPicker.leadingAnchor.constraint(equalTo: calendarWrapper.leadingAnchor),
            calendarPicker.trailingAnchor.constraint(equalTo: calendarWrapper.trailingAnchor),
            calendarPicker.bottomAnchor.constraint(equalTo: calendarWrapper.bottomAnchor)
        ])

        // Default date selection
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        if let parsedDate = isoFormatter.date(from: selectedDate) {
            calendarPicker.date = parsedDate
        }
    }

    func setupChecklist() {
        let headerLabel = UILabel()
        headerLabel.text = "Log your accomplishments"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headerLabel.textColor = .darkGray
        headerLabel.textAlignment = .center
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: calendarContainer!.bottomAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        checklistStackView.axis = .vertical
        checklistStackView.spacing = 12
        checklistStackView.translatesAutoresizingMaskIntoConstraints = false
        checklistStackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        checklistStackView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        contentView.addSubview(checklistStackView)

        NSLayoutConstraint.activate([
            checklistStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            checklistStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checklistStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            // Removed — progress bar will anchor the bottom of contentView
        ])
        
        let phaseNoteLabel = UILabel()
        phaseNoteLabel.text = "Note: Some phases may not require all sessions. Log what you did!"
        phaseNoteLabel.font = UIFont.italicSystemFont(ofSize: 13)
        phaseNoteLabel.textColor = UIColor.darkGray
        phaseNoteLabel.numberOfLines = 0
        phaseNoteLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(phaseNoteLabel)

        NSLayoutConstraint.activate([
            phaseNoteLabel.topAnchor.constraint(equalTo: checklistStackView.bottomAnchor, constant: 10),
            phaseNoteLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            phaseNoteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        completionProgress.translatesAutoresizingMaskIntoConstraints = false
        completionProgress.progressTintColor = .systemGreen
        completionProgress.trackTintColor = UIColor.systemGray4
        completionProgress.layer.cornerRadius = 5
        completionProgress.clipsToBounds = true
        contentView.addSubview(completionProgress)

        NSLayoutConstraint.activate([
            completionProgress.topAnchor.constraint(equalTo: phaseNoteLabel.bottomAnchor, constant: 15),
            completionProgress.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            completionProgress.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            completionProgress.heightAnchor.constraint(equalToConstant: 6)
        ])
        completionProgress.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true

        refreshChecklist()
    }

    func refreshChecklist() {
        guard dateOptions.contains(selectedDate) else {
            print("⚠️ Skipping checklist refresh — '\(selectedDate)' not found in plan range: \(dateOptions)")
            return
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.checklistStackView.alpha = 0
        }) { _ in
            self.checklistStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let componentsToTrack: [String] =
                self.plan.type == "diet" ? (dietComponents + hydrationComponent)
                : (workoutComponents)

            for component in componentsToTrack {
                let checkbox = UIButton(type: .system)
                if let meal = self.mealMap[self.selectedDate]?[component], !meal.isEmpty {
                    checkbox.setTitle("\(component): \(meal)", for: .normal)
                } else {
                    checkbox.setTitle(component, for: .normal)
                }
                checkbox.contentHorizontalAlignment = .left
                checkbox.titleLabel?.font = UIFont(name: "Avenir", size: 16)
                checkbox.tintColor = UIColor(red: 0.663, green: 0.776, blue: 1.0, alpha: 1)
                checkbox.setTitleColor(UIColor(red: 0.176, green: 0.231, blue: 0.298, alpha: 1), for: .normal)

                let dateForCheckbox = self.selectedDate  // 🔐 capture correct date
                let isDone = TrackerManager.shared.isComplete(component: component, for: dateForCheckbox)
                checkbox.setImage(UIImage(systemName: isDone ? "checkmark.square" : "square"), for: .normal)

                checkbox.addAction(UIAction { _ in
                    TrackerManager.shared.toggle(component: component, for: dateForCheckbox)
                    let updated = TrackerManager.shared.isComplete(component: component, for: dateForCheckbox)
                    checkbox.setImage(UIImage(systemName: updated ? "checkmark.square" : "square"), for: .normal)

                    self.updateCompletionProgress()
                    if TrackerManager.shared.isAllComplete(for: dateForCheckbox, planType: self.plan.type) {
                        self.showCompletionBanner(for: dateForCheckbox)
                    }
                }, for: .touchUpInside)

                self.checklistStackView.addArrangedSubview(checkbox)
            }

            UIView.animate(withDuration: 0.2) {
                self.checklistStackView.alpha = 1
            }

            self.updateCompletionProgress()
        }
    }
    
    func updateCompletionProgress() {
        let components: [String] =
            plan.type == "diet" ? (dietComponents + hydrationComponent)
            : (workoutComponents)

        let completed = components.filter {
            TrackerManager.shared.isComplete(component: $0, for: selectedDate)
        }.count

        let progress = components.isEmpty ? 0 : Float(completed) / Float(components.count)
        completionProgress.setProgress(progress, animated: true)
    }

    func loadPlanContent() {
        webView.loadHTMLString(plan.content, baseURL: nil)
    }

    func showCompletionBanner(for date: String) {
        let banner = UILabel()
        banner.text = "🎉 All tasks completed for \(formatDateForDisplay(date))!"
        banner.textAlignment = .center
        banner.font = UIFont.boldSystemFont(ofSize: 16)
        banner.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.9)
        banner.textColor = .white
        banner.layer.cornerRadius = 10
        banner.clipsToBounds = true
        banner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(banner)

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: checklistStackView.bottomAnchor, constant: 20),
            banner.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            banner.heightAnchor.constraint(equalToConstant: 40),
            banner.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20) // 👈 prevent clipping
        ])

        // ⏳ Fade out after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 0.5, animations: {
                banner.alpha = 0
            }) { _ in
                banner.removeFromSuperview()
            }
        }
    }

    // MARK: - Meal Parsing

    static func parseMeals(from html: String, dates: [String]) -> [String: [String: String]] {
        var result: [String: [String: String]] = [:]

        // Grab table rows
        guard let rowRegex = try? NSRegularExpression(pattern: "<tr>(.*?)</tr>", options: [.dotMatchesLineSeparators]) else {
            return result
        }
        let nsHtml = html as NSString
        let rowMatches = rowRegex.matches(in: html, options: [], range: NSRange(location: 0, length: nsHtml.length))
        var dateIndex = 0
        for match in rowMatches.dropFirst() { // drop header
            guard dateIndex < dates.count else { break }
            let rowContent = nsHtml.substring(with: match.range(at: 1))
            guard let cellRegex = try? NSRegularExpression(pattern: "<td[^>]*>(.*?)</td>", options: [.dotMatchesLineSeparators]) else { continue }
            let cellMatches = cellRegex.matches(in: rowContent, options: [], range: NSRange(location: 0, length: (rowContent as NSString).length))
            if cellMatches.count >= 9 {
                var map: [String: String] = [:]
                let labels = ["Morning Drink", "Breakfast", "Mid-Morning Snack", "Lunch", "Evening Snack", "Dinner"]
                for (i,label) in labels.enumerated() {
                    let idx = i + 3
                    if idx < cellMatches.count {
                        let cell = (rowContent as NSString).substring(with: cellMatches[idx].range(at: 1))
                        map[label] = stripHTML(from: cell)
                    }
                }
                result[dates[dateIndex]] = map
            }
            dateIndex += 1
        }
        return result
    }

    static func stripHTML(from string: String) -> String {
        return string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil).trimmingCharacters(in: .whitespacesAndNewlines)
    }


    // MARK: - Date Formatting

    static func extractDates(from label: String) -> [String] {
        let cleaned = label.replacingOccurrences(of: "–", with: "-")
                            .replacingOccurrences(of: "—", with: "-")
                            .replacingOccurrences(of: " to ", with: "-")

        let components = cleaned.components(separatedBy: "-")
        let currentYear = Calendar.current.component(.year, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"

        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"

        guard let startStr = components.first?.trimmingCharacters(in: .whitespaces),
              let startDate = dateFormatter.date(from: "\(startStr) \(currentYear)") else {
            return []
        }

        if components.count == 2,
           let endDayStr = components.last?.trimmingCharacters(in: .whitespaces),
           let endDate = dateFormatter.date(from: "\(startStr.prefix(3)) \(endDayStr) \(currentYear)") {

            var current = startDate
            var result: [String] = []

            while current <= endDate {
                result.append(isoFormatter.string(from: current))
                current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
            }
            return result
        }

        // If it's a single date
        return [isoFormatter.string(from: startDate)]
    }

    static func chooseDefaultDate(from options: [String]) -> String {
        let today = Date()
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        let todayStr = isoFormatter.string(from: today)

        return options.contains(todayStr) ? todayStr : options.first ?? todayStr
    }

    func formatDateForDisplay(_ isoDate: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM-dd"

        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "MMM dd"

        if let date = inFormatter.date(from: isoDate) {
            return outFormatter.string(from: date)
        }
        return isoDate
    }
    
    @objc func toggleCalendar() {
        guard let container = calendarContainer, dateOptions.count > 1 else { return }

        let wasHidden = container.isHidden
        container.isHidden.toggle()
        // Intrinsic size can report zero before layout; use a safe default
        let targetHeight = wasHidden ? max(calendarPicker.intrinsicContentSize.height, 320) : 0
        calendarHeightConstraint?.constant = targetHeight


        let showing = container.isHidden
        container.isHidden.toggle()
        // Intrinsic size can report zero before layout; use a safe default
        let targetHeight = showing ? max(calendarPicker.intrinsicContentSize.height, 320) : 0
        calendarHeightConstraint?.constant = targetHeight


        guard let container = calendarContainer else { return }

        let showing = container.isHidden
        container.isHidden.toggle()
        calendarHeightConstraint?.constant = showing ? calendarPicker.intrinsicContentSize.height : 0

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func calendarDatePicked(_ sender: UIDatePicker) {
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate = isoFormatter.string(from: sender.date)

        let display = formatDateForDisplay(selectedDate)
        dateButton.setTitle("[\(display)]", for: .normal)

        refreshChecklist()
    }
    
}
