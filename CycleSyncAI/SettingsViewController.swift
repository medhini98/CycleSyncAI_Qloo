//
//  SettingsViewController.swift
//  CycleSyncAI
//
//  Created by Medhini Sridharr on 16/06/25.
//

import Foundation
import UIKit
import UserNotifications

class SettingsViewController: UIViewController {

    let titleLabel = UILabel()
    let subheadingLabel = UILabel()
    let backButton = UIButton(type: .system)
    let stackView = UIStackView()

    let options: [(key: String, title: String, subtitle: String)] = [
        ("morningReminderEnabled", "Morning Reminder", "Get a daily reminder to generate your plan."),
        ("phaseChangeEnabled", "Phase Change Alerts", "Notifies when your menstrual phase changes."),
        ("hydrationEnabled", "Hydration Reminders", "Reminds you to drink water regularly."),
        ("followUpEnabled", "Meal/Workout Follow-ups", "Prompts you to log your  meals/workouts.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ SettingsViewController loaded")
        
        setupGradientBackground()
        setupTitle()
        setupBackButton()
        setupStackView()
        requestNotificationPermissionsIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradient = backButton.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = backButton.bounds
        }
    }

    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Settings"
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 24)
        titleLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        subheadingLabel.translatesAutoresizingMaskIntoConstraints = false
        subheadingLabel.text = "Notification Preferences"
        subheadingLabel.font = UIFont(name: "Avenir", size: 22)
        subheadingLabel.textColor = titleLabel.textColor
        subheadingLabel.textAlignment = .left
        view.addSubview(subheadingLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subheadingLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subheadingLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subheadingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupBackButton() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("← Back", for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        backButton.backgroundColor = UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1)
        backButton.layer.cornerRadius = 10
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1).cgColor,  // lighter purple
            UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 1).cgColor   // deeper purple
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = backButton.bounds
        gradient.cornerRadius = 10
        
        backButton.layer.insertSublayer(gradient, at: 0)
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        backButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }

    func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: subheadingLabel.bottomAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        for (key, title, subtitle) in options {
            let row = createToggleRow(title: title, subtitle: subtitle, key: key)
            stackView.addArrangedSubview(row)
        }
    }

    func createToggleRow(title: String, subtitle: String, key: String) -> UIView {
        let container = UIView()

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Avenir", size: 18)
        titleLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = UIColor(red: 153/255, green: 144/255, blue: 170/255, alpha: 1) // #9990AA
        subtitleLabel.numberOfLines = 0

        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = UIColor(red: 82/255, green: 43/255, blue: 122/255, alpha: 1) // darker purple
        toggle.isOn = UserDefaults.standard.bool(forKey: key)
        
        toggle.addAction(UIAction { _ in
            let trimmedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
            UserDefaults.standard.set(toggle.isOn, forKey: trimmedKey)

            if trimmedKey == "morningReminderEnabled" {
                if toggle.isOn {
                    let combinedFilenames = PlanHistoryManager.shared.getAllDateLabels()
                    NotificationManager.shared.scheduleMorningReminderIfNeeded(filenames: combinedFilenames)
                } else {
                    NotificationManager.shared.cancelMorningReminder()
                }
            }

            if trimmedKey == "phaseChangeEnabled" {
                if toggle.isOn {
                    NotificationManager.shared.triggerPhaseReminderIfNeeded()
                } else {
                    NotificationManager.shared.cancelPhaseChangeReminder()
                }
            }

            if trimmedKey == "hydrationEnabled" {
                if toggle.isOn {
                    self.triggerHydrationReminderManually()
                } else {
                    NotificationManager.shared.cancelHydrationReminders()
                }
            }

        }, for: .valueChanged)

        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        container.addSubview(toggle)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: toggle.leadingAnchor, constant: -10),

            toggle.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: container.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        return container
    }

    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }

    func requestNotificationPermissionsIfNeeded() {
        let hasAsked = UserDefaults.standard.bool(forKey: "notificationPermissionAsked")
        guard !hasAsked else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "notificationPermissionAsked")
                print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
            }
        }
    }
    
    func triggerHydrationReminderManually() {
        HealthManager.shared.fetchCurrentCycleStartDate { startDate in
            guard let start = startDate,
                  let cycleDay = HealthManager.shared.calculateCycleDay(from: start) else {
                print("❌ Could not determine cycle day for hydration scheduling")
                return
            }
            let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)
            NotificationManager.shared.scheduleHydrationNotifications(for: phase)
        }
    }
}
