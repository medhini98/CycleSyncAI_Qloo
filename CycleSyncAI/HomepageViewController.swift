import UIKit

class HomepageViewController: UIViewController {

    let splashLabel = UILabel()
    let headerCardView = UIView()
    let headerLabel = UILabel()
    let guideLabel = UILabel()
    let arrowImageView = UIImageView()
    let creditsLabel = UILabel()
    let eatButton = UIButton(type: .system)
    let moveButton = UIButton(type: .system)
    let historyButton = UIButton(type: .system)
    let curatedButton = UIButton(type: .system)
    let profileButton = UIButton(type: .system)
    let settingsButton = UIButton(type: .system)
    let buttonStack = UIStackView()
    let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ HomepageViewController loaded")

        setupGradientBackground()
        setupSplashLabel()
        setupHomepageButtons()
        setupHeaderCard()
        setupFloatingProfileButton()
        setupFloatingSettingsButton()
        setupArrowImage()
        setupGuideLabel()
        setupCreditsLabel()
        showSplashAnimation()
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

    func setupSplashLabel() {
        splashLabel.translatesAutoresizingMaskIntoConstraints = false
        splashLabel.text = "Eat. Move. Thrive. \nWith your Cycle."
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

    func setupHeaderCard() {
        headerCardView.translatesAutoresizingMaskIntoConstraints = false
        headerCardView.layer.cornerRadius = 20
        headerCardView.clipsToBounds = true
        headerCardView.layer.shadowOpacity = 0.1 // reduced shadow

        let cardGradient = CAGradientLayer()
        cardGradient.colors = [
            UIColor(red: 255/255, green: 240/255, blue: 245/255, alpha: 1).cgColor,
            UIColor(red: 240/255, green: 235/255, blue: 255/255, alpha: 1).cgColor
        ]
        cardGradient.startPoint = CGPoint(x: 0, y: 0)
        cardGradient.endPoint = CGPoint(x: 1, y: 1)
        cardGradient.frame = CGRect(x: 0, y: 0, width: 300, height: 80)
        headerCardView.layer.insertSublayer(cardGradient, at: 0)

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "Tap below to explore your journey - your personalized plans await! 🦉✨"
        headerLabel.numberOfLines = 0
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont(name: "Avenir", size: 16)
        headerLabel.textColor = UIColor(red: 230/255, green: 100/255, blue: 140/255, alpha: 1)
        headerCardView.addSubview(headerLabel)

        view.addSubview(headerCardView)

        NSLayoutConstraint.activate([
            headerCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerCardView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -40),
            headerCardView.widthAnchor.constraint(equalToConstant: 300),
            headerCardView.heightAnchor.constraint(equalToConstant: 80),

            headerLabel.centerXAnchor.constraint(equalTo: headerCardView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerCardView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerCardView.leadingAnchor, constant: 10),
            headerLabel.trailingAnchor.constraint(equalTo: headerCardView.trailingAnchor, constant: -10)
        ])

        headerCardView.alpha = 0
        UIView.animate(withDuration: 1.5, delay: 2.5, options: [.autoreverse, .repeat], animations: {
            self.headerCardView.alpha = 0.9
        }, completion: nil)
    }

    func setupHomepageButtons() {
        configureButton(eatButton, title: "What to Eat Today 🍽️", colors: [
            UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1),  // #FFC3B9
            UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1) // #FEB2DC
        ])
        eatButton.addTarget(self, action: #selector(goToEatPlan), for: .touchUpInside)
        
        configureButton(moveButton, title: "How to Move Today 🏋️‍♀️", colors: [
            //UIColor(red: 0.8, green: 0.757, blue: 0.969, alpha: 1),  // #CCC1F7
            UIColor(red: 0.75, green: 0.76, blue: 0.95, alpha: 1),
            //UIColor(red: 0.663, green: 0.776, blue: 1.0, alpha: 1)   // #A9C6FF
            UIColor(red: 0.68, green: 0.85, blue: 1.0, alpha: 1)
        ])
        moveButton.addTarget(self, action: #selector(goToWorkoutPlan), for: .touchUpInside)
        
        configureButton(historyButton, title: "View My History 📖", colors: [
            UIColor(red: 165/255, green: 196/255, blue: 229/255, alpha: 1),
            UIColor(red: 188/255, green: 160/255, blue: 232/255, alpha: 1)
        ])
        historyButton.addTarget(self, action: #selector(goToHistory), for: .touchUpInside)
        
        configureButton(curatedButton, title: "Curated for You 🌟", colors: [
            UIColor(red: 224/255, green: 176/255, blue: 255/255, alpha: 1),
            UIColor(red: 195/255, green: 139/255, blue: 255/255, alpha: 1)
        ])
        curatedButton.addTarget(self, action: #selector(goToRecommendations), for: .touchUpInside)

        buttonStack.axis = .vertical
        buttonStack.spacing = 30
        buttonStack.alignment = .center
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        buttonStack.addArrangedSubview(eatButton)
        buttonStack.addArrangedSubview(moveButton)
        buttonStack.addArrangedSubview(historyButton)
        buttonStack.addArrangedSubview(curatedButton)

        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            eatButton.widthAnchor.constraint(equalToConstant: 280),
            eatButton.heightAnchor.constraint(equalToConstant: 60),
            moveButton.widthAnchor.constraint(equalToConstant: 280),
            moveButton.heightAnchor.constraint(equalToConstant: 60),
            historyButton.widthAnchor.constraint(equalToConstant: 280),
            historyButton.heightAnchor.constraint(equalToConstant: 60),
            curatedButton.widthAnchor.constraint(equalToConstant: 280),
            curatedButton.heightAnchor.constraint(equalToConstant: 60),

            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20)
        ])

        buttonStack.alpha = 0
        buttonStack.transform = CGAffineTransform(translationX: 0, y: 30)
    }

    func configureButton(_ button: UIButton, title: String, colors: [UIColor]) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 280, height: 60)
        gradientLayer.cornerRadius = 12
        button.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupFloatingSettingsButton() {
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.tintColor = .white
        settingsButton.backgroundColor = UIColor(red: 0.667, green: 0.776, blue: 1.0, alpha: 1)
        settingsButton.layer.cornerRadius = 30
        settingsButton.clipsToBounds = true
        settingsButton.layer.shadowColor = UIColor.black.cgColor
        settingsButton.layer.shadowOpacity = 0.2
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        settingsButton.layer.shadowRadius = 6
        settingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)

        view.addSubview(settingsButton)
        
        settingsButton.alpha = 0
        settingsButton.transform = CGAffineTransform(translationX: -30, y: 0)

        NSLayoutConstraint.activate([
            settingsButton.widthAnchor.constraint(equalToConstant: 60),
            settingsButton.heightAnchor.constraint(equalToConstant: 60),
            settingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    func setupFloatingProfileButton() {
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.setImage(UIImage(systemName: "person.circle.fill"), for: .normal)
        profileButton.tintColor = .white
        profileButton.backgroundColor = UIColor(red: 0.667, green: 0.776, blue: 1.0, alpha: 1) // #AAC6FF
        profileButton.layer.cornerRadius = 30
        profileButton.clipsToBounds = true
        profileButton.layer.shadowColor = UIColor.black.cgColor
        profileButton.layer.shadowOpacity = 0.2
        profileButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        profileButton.layer.shadowRadius = 6
        profileButton.addTarget(self, action: #selector(goToProfile), for: .touchUpInside)

        view.addSubview(profileButton)

        NSLayoutConstraint.activate([
            profileButton.widthAnchor.constraint(equalToConstant: 60),
            profileButton.heightAnchor.constraint(equalToConstant: 60),
            profileButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        profileButton.alpha = 0
        profileButton.transform = CGAffineTransform(translationX: 30, y: 0)
    }

    func setupArrowImage() {
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.image = UIImage(named: "homepage_arrow-removebg-preview")
        arrowImageView.contentMode = .scaleAspectFit
        view.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -10),
            arrowImageView.bottomAnchor.constraint(equalTo: profileButton.topAnchor, constant: 10),
            arrowImageView.widthAnchor.constraint(equalToConstant: 80),
            arrowImageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        arrowImageView.alpha = 0
        arrowImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    func setupGuideLabel() {
            guideLabel.translatesAutoresizingMaskIntoConstraints = false
            guideLabel.text = "Click here to personalize \nyour journey! ✨"
            guideLabel.numberOfLines = 0
            guideLabel.textAlignment = .center
            guideLabel.font = UIFont(name: "Avenir", size: 14)
            guideLabel.textColor = UIColor(red: 230/255, green: 100/255, blue: 140/255, alpha: 1)
            view.addSubview(guideLabel)

        NSLayoutConstraint.activate([
            guideLabel.centerXAnchor.constraint(equalTo: profileButton.centerXAnchor, constant: -20),  // shifted left
            guideLabel.bottomAnchor.constraint(equalTo: arrowImageView.topAnchor, constant: -15),      // shifted down
            guideLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 120)
        ])

            guideLabel.alpha = 0
        }

    func setupCreditsLabel() {
        creditsLabel.translatesAutoresizingMaskIntoConstraints = false
        creditsLabel.text = "v1.0 | Powered by Perplexity's Sonar"
        creditsLabel.font = UIFont.systemFont(ofSize: 12)
        creditsLabel.textColor = .gray
        creditsLabel.textAlignment = .center
        view.addSubview(creditsLabel)

        NSLayoutConstraint.activate([
            creditsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            creditsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        creditsLabel.alpha = 0
    }

    func showSplashAnimation() {
        UIView.animate(withDuration: 2.0, delay: 1.5, options: [], animations: {
            self.splashLabel.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 1.0) {
                self.buttonStack.alpha = 1
                self.headerCardView.alpha = 1
                self.creditsLabel.alpha = 1
                self.profileButton.alpha = 1
                self.settingsButton.alpha = 1
                self.guideLabel.alpha = 1
                self.arrowImageView.alpha = 1

                self.buttonStack.transform = .identity
                self.profileButton.transform = .identity
                self.settingsButton.transform = .identity
                self.arrowImageView.transform = .identity

                UIView.animate(withDuration: 1.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                    self.headerCardView.alpha = 0.9
                }, completion: nil)
            }
        })
    }
    
    @objc func goToSettings() {
        let settingsVC = SettingsViewController()
        navigateTo(viewController: settingsVC)
    }

    @objc func goToProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
            navigateTo(viewController: userProfileVC)
        }
    }

    @objc func goToEatPlan() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let eatPlanVC = storyboard.instantiateViewController(withIdentifier: "EatPlanViewController") as? EatPlanViewController {

            // Load profile data from UserDefaults
            let defaults = UserDefaults.standard
            let profile = UserProfile(
                name: defaults.string(forKey: "name") ?? "",
                ageGroup: defaults.string(forKey: "age") ?? "",
                height: defaults.string(forKey: "height") ?? "",
                weight: defaults.string(forKey: "weight") ?? "",
                country: defaults.string(forKey: "country") ?? "",
                medicalConditions: (defaults.array(forKey: "medical") as? [String])?.joined(separator: ", ") ?? "",
                dietaryRestrictions: (defaults.array(forKey: "dietary") as? [String])?.joined(separator: ", ") ?? "",
                preferredCuisines: (defaults.array(forKey: "preferredCuisines") as? [String])?.joined(separator: ", ") ?? "",
                preferredMusicGenres: (defaults.array(forKey: "preferredMusicGenres") as? [String])?.joined(separator: ", ") ?? "",
                goal: defaults.string(forKey: "goal") ?? "",
                activityLevel: defaults.string(forKey: "activity") ?? ""
            )

            // Pass the profile object into EatPlanViewController
            eatPlanVC.userProfileData = profile

            // Navigate to EatPlanViewController
            navigateTo(viewController: eatPlanVC)
        }
    }

    @objc func goToWorkoutPlan() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let workoutPlanVC = storyboard.instantiateViewController(withIdentifier: "WorkoutPlanViewController") as? WorkoutPlanViewController {

            // Load profile data from UserDefaults
            let defaults = UserDefaults.standard
            let profile = UserProfile(
                name: defaults.string(forKey: "name") ?? "",
                ageGroup: defaults.string(forKey: "age") ?? "",
                height: defaults.string(forKey: "height") ?? "",
                weight: defaults.string(forKey: "weight") ?? "",
                country: defaults.string(forKey: "country") ?? "",
                medicalConditions: (defaults.array(forKey: "medical") as? [String])?.joined(separator: ", ") ?? "",
                dietaryRestrictions: (defaults.array(forKey: "dietary") as? [String])?.joined(separator: ", ") ?? "",
                preferredCuisines: (defaults.array(forKey: "preferredCuisines") as? [String])?.joined(separator: ", ") ?? "",
                preferredMusicGenres: (defaults.array(forKey: "preferredMusicGenres") as? [String])?.joined(separator: ", ") ?? "",
                goal: defaults.string(forKey: "goal") ?? "",
                activityLevel: defaults.string(forKey: "activity") ?? ""
            )

            // Pass the profile object into WorkoutPlanViewController
            workoutPlanVC.userProfileData = profile

            // Navigate to WorkoutPlanViewController
            navigateTo(viewController: workoutPlanVC)
        }
    }
    
    @objc func goToHistory() {
        let historyVC = HistoryViewController()
        let navController = UINavigationController(rootViewController: historyVC)
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        present(navController, animated: true, completion: nil)
    }
    
    @objc func goToRecommendations() {
            let recVC = RecommendationsViewController()
            recVC.modalPresentationStyle = .fullScreen
            present(recVC, animated: true, completion: nil)
        }

    func navigateTo(viewController: UIViewController) {
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
}
