import UIKit

class LaunchViewController: UIViewController {
    let splashLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        splashLabel.translatesAutoresizingMaskIntoConstraints = false
        splashLabel.text = "Eat. Move. Thrive. With your Cycle.\nPowered by Perplexity’s Sonar."
        splashLabel.numberOfLines = 2
        splashLabel.textAlignment = .center
        splashLabel.font = UIFont(name: "Avenir-Heavy", size: 20)
        splashLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)
        view.addSubview(splashLabel)

        NSLayoutConstraint.activate([
            splashLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.requestHealthPermission()
        }
    }

    private func requestHealthPermission() {
        if !UserDefaults.standard.bool(forKey: "healthPermissionAsked") {
            HealthManager.shared.requestAuthorization { _, _ in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "healthPermissionAsked")
                    self.requestNotificationPermission()
                }
            }
        } else {
            requestNotificationPermission()
        }
    }

    private func requestNotificationPermission() {
        if !UserDefaults.standard.bool(forKey: "notificationPermissionAsked") {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                DispatchQueue.main.async {
                    UserDefaults.standard.set(true, forKey: "notificationPermissionAsked")
                    self.goToHome()
                }
            }
        } else {
            goToHome()
        }
    }

    private func goToHome() {
        let homepage = HomepageViewController()
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = homepage
            window.makeKeyAndVisible()
        } else {
            self.present(homepage, animated: true)
            let homepage = HomepageViewController()
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                window.rootViewController = homepage
                window.makeKeyAndVisible()
            } else {
                self.present(homepage, animated: true)
            }
        }
    }
}
