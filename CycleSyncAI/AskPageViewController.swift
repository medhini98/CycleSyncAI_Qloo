//
//  AskPageViewController.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 18/06/25.
//

import Foundation
import UIKit

struct ChatMessage {
    let text: String
    let isFromUser: Bool
}

class AskPageViewController: UIViewController, UITableViewDataSource {

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let planTypeSegment = UISegmentedControl(items: ["Diet", "Workout"])
    let datePicker = UIDatePicker()
    let tableView = UITableView()
    var messages: [ChatMessage] = []
    var questionField = UITextField()
    let sendButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)
    let spinner = UIActivityIndicatorView(style: .medium)
    
    var contentView: UIView!
    var currentPlanContent: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        
        planTypeSegment.addTarget(self, action: #selector(planTypeChanged), for: .valueChanged)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPlanContent()
    }

    @objc func planTypeChanged() {
        loadPlanContent()
    }

    @objc func dateChanged() {
        loadPlanContent()
    }

    func setupUI() {
        // Scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])


        // Back Button
        contentView.addSubview(backButton)
        backButton.setTitle("Back", for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        styleButton(backButton, colors: [
            UIColor(red: 220/255, green: 239/255, blue: 234/255, alpha: 1),
            UIColor(red: 187/255, green: 220/255, blue: 210/255, alpha: 1)
        ])

        // Title
        contentView.addSubview(titleLabel)
        titleLabel.text = "AI Assistant"
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 24)
        titleLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = "Ask questions about your generated diet or workout plans"
        subtitleLabel.font = UIFont(name: "Avenir", size: 14)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        // Plan Type Segment
        // Label
        let planPickerLabel = UILabel()
        planPickerLabel.text = "Select plan type:"
        planPickerLabel.font = UIFont(name: "Avenir", size: 16)
        planPickerLabel.textColor = .darkGray

        let dateLabel = UILabel()
        dateLabel.text = "Select date:"
        dateLabel.font = UIFont(name: "Avenir", size: 16)
        dateLabel.textColor = .darkGray

        let planStack = UIStackView(arrangedSubviews: [planPickerLabel, planTypeSegment])
        planStack.axis = .horizontal
        planStack.spacing = 8
        planStack.alignment = .center

        let dateStack = UIStackView(arrangedSubviews: [dateLabel, datePicker])
        datePicker.datePickerMode = .date // ← NOT the right place
        dateStack.axis = .horizontal
        dateStack.spacing = 8
        dateStack.alignment = .center

        let inputStack = UIStackView(arrangedSubviews: [planStack, dateStack])
        inputStack.axis = .vertical
        inputStack.spacing = 16
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(inputStack)

        // Question Input
        let inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.layer.cornerRadius = 20
        inputContainer.backgroundColor = .white
        contentView.addSubview(inputContainer)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.isScrollEnabled = false
        contentView.addSubview(tableView)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10)
        ])

        questionField.placeholder = "Type your question here..."
        questionField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        questionField.translatesAutoresizingMaskIntoConstraints = false
        questionField.borderStyle = UITextField.BorderStyle.none
        questionField.font = UIFont(name: "Avenir", size: 16)
        questionField.textColor = UIColor.black
        questionField.autocorrectionType = UITextAutocorrectionType.yes

        // You may remove this cast if you’re not referencing questionField later
        // Instead, use `questionField` directly in handlers
        // questionField = questionField as! UITextView // NOT SAFE — comment this out

        inputContainer.addSubview(questionField)
        inputContainer.addSubview(sendButton)

        NSLayoutConstraint.activate([
            inputContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            inputContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inputContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            inputContainer.heightAnchor.constraint(equalToConstant: 44),

            questionField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            questionField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            questionField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Send Button
        let sendIcon = UIImage(systemName: "arrow.up.circle.fill")?.withRenderingMode(.alwaysTemplate)
        sendButton.setImage(sendIcon, for: .normal)
        sendButton.tintColor = .white
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 20
        styleButton(sendButton, colors: [
            UIColor(red: 220/255, green: 239/255, blue: 234/255, alpha: 1),
            UIColor(red: 187/255, green: 220/255, blue: 210/255, alpha: 1)
        ])
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)


        // Constraints
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 60),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
                subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            inputStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            inputStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            inputStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: inputStack.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor, constant: -20)
        ])
        
        contentView.bottomAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 40).isActive = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func styleButton(_ button: UIButton, colors: [UIColor]) {
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 12
        gradientLayer.name = "gradient"

        DispatchQueue.main.async {
            button.layoutIfNeeded()
            gradientLayer.frame = button.bounds
            
            // Remove existing gradient if any
            if let existing = button.layer.sublayers?.first(where: { $0.name == "gradient" }) {
                existing.removeFromSuperlayer()
            }
            button.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    @objc func backTapped() {
        dismiss(animated: true, completion: nil)
    }

    
    @objc func suggestionTapped(_ sender: UIButton) {
        questionField.text = sender.title(for: .normal)
    }

    func makeSuggestionButton(_ text: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 14)
        button.setTitleColor(.white, for: .normal)
        // button.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.8)
        styleButton(button, colors: [
            UIColor(red: 187/255, green: 220/255, blue: 210/255, alpha: 1), // slightly darker
            UIColor(red: 171/255, green: 206/255, blue: 195/255, alpha: 1)
        ])
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.contentHorizontalAlignment = .left // Optional: prevents overly stretched center text
        button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
        return button
    }
    
    func loadPlanContent() {
        let selectedType = planTypeSegment.selectedSegmentIndex == 0 ? "Diet" : "Workout"
        let selectedDate = datePicker.date
        let selectedDateISO = isoDateString(for: selectedDate)

        print("🔍 Looking for: \(selectedType) plan for \(selectedDateISO)")
        
        print("🔎 Selected ISO date to match: \(selectedDateISO)")
        
        print("🔍 Looking for: \(selectedType) plan for \(selectedDateISO)")

        let allPlans = PlanHistoryManager.shared.loadPlans()

        let matchingPlans = allPlans.filter { plan in
            guard plan.type == selectedType else { return false }
            //let planDates = !plan.dates.isEmpty ? plan.dates : extractDateOptions(from: plan.dateLabel)
            let planDates: [String]
            if !plan.dates.isEmpty {
                planDates = plan.dates
                print("📅 Using saved plan.dates: \(planDates)")
            } else {
                planDates = extractDateOptions(from: plan.dateLabel)
                print("📄 Fallback to label-based dates: \(planDates)")
            }
            return planDates.contains(selectedDateISO)
        }

        if let latest = matchingPlans.sorted(by: { $0.dateLabel > $1.dateLabel }).first {
            print("✅ Found matching plan: \(latest.dateLabel)")
            currentPlanContent = latest.content
        } else {
            print("❌ No matching plan found for selected type and date.")
            currentPlanContent = nil
        }
    }
    
    func isoDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func extractDateOptions(from label: String) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd"
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")

        let parts = label.components(separatedBy: " • ")
        guard let datePart = parts.first else { return [] }

        let cleaned = datePart
            .replacingOccurrences(of: "Diet Plan ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "Workout Plan ", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let currentYear = Calendar.current.component(.year, from: Date())

        // Handle range
        if cleaned.contains("–") || cleaned.contains("-") || cleaned.contains("—") {
            let separators = ["–", "-", "—"]
            let separator = separators.first(where: { cleaned.contains($0) }) ?? "-"
            let bounds = cleaned.components(separatedBy: separator)
            guard bounds.count == 2 else { return [] }

            let startString = bounds[0].trimmingCharacters(in: .whitespaces)
            let endDayStr = bounds[1].trimmingCharacters(in: .whitespaces)

            guard let startDateRaw = formatter.date(from: startString),
                  let endDay = Int(endDayStr) else {
                print("❌ Could not parse range: \(cleaned)")
                return []
            }

            var comps = Calendar.current.dateComponents([.month, .day], from: startDateRaw)
            comps.year = currentYear
            guard let startDate = Calendar.current.date(from: comps) else { return [] }

            comps.day = endDay
            guard let endDate = Calendar.current.date(from: comps) else { return [] }

            var allDates: [String] = []
            var current = startDate
            while current <= endDate {
                let iso = isoFormatter.string(from: current)
                allDates.append(iso.trimmingCharacters(in: .whitespacesAndNewlines))
                guard let next = Calendar.current.date(byAdding: .day, value: 1, to: current) else { break }
                current = next
            }

            print("🧪 Parsed dateOptions from range: \(allDates)")
            return allDates
        }

        // Handle single date
        if let singleDateRaw = formatter.date(from: cleaned) {
            var comps = Calendar.current.dateComponents([.month, .day], from: singleDateRaw)
            comps.year = currentYear
            if let fullDate = Calendar.current.date(from: comps) {
                let iso = isoFormatter.string(from: fullDate).trimmingCharacters(in: .whitespacesAndNewlines)
                print("🧪 Parsed dateOptions from single: [\"\(iso)\"]")
                return [iso]
            }
        }

        print("❌ Failed to parse dateOptions from: \(label)")
        return []
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleSend() {
        print("📩 Send button tapped!")
        guard let userText = questionField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userText.isEmpty else { return }

        messages.append(ChatMessage(text: userText, isFromUser: true))
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }

        questionField.text = ""
        
        textFieldDidChange() // update send button state
        spinner.startAnimating()
        sendButton.isEnabled = false

        // Simulate bot response or integrate your model API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = "This is a simulated answer for: \(userText)"
            self.messages.append(ChatMessage(text: response, isFromUser: false))
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollToBottom()
                self.spinner.stopAnimating()
                self.textFieldDidChange() // re-enable send button based on current text
            }
        }
    }
    
    @objc func textFieldDidChange() {
        let trimmedText = questionField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        sendButton.isEnabled = !trimmedText.isEmpty
        sendButton.alpha = trimmedText.isEmpty ? 0.5 : 1.0 // optional visual cue
    }

    func scrollToBottom() {
        guard messages.count > 0 else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}

extension AskPageViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.configure(with: message)
        return cell
    }
}
