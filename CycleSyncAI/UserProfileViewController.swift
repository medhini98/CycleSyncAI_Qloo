import UIKit

class UserProfileViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let scrollView = UIScrollView()
    let contentView = UIView()

    let headingLabel = UILabel()
    let basicInfoLabel = UILabel()
    let nameField = UITextField()
    let nameLabel = UILabel()
    let ageLabel = UILabel()
    let agePicker = UIPickerView()
    let heightLabel = UILabel()
    let heightUnitSegment = UISegmentedControl(items: ["cm", "ft/in"])
    let weightLabel = UILabel()
    let weightUnitSegment = UISegmentedControl(items: ["kg", "lbs"])
    let heightCmField = UITextField()
    let heightFtField = UITextField()
    let heightInField = UITextField()
    let heightContainerView = UIView()
    let weightField = UITextField()
    let countryLabel = UILabel()
    let countryField = UITextField()
    let medicalLabel = UILabel()
    let dietaryLabel = UILabel()
    let medicalOtherButton = UIButton(type: .system)
    let medicalNoneButton = UIButton(type: .system)
    let dietaryOtherButton = UIButton(type: .system)
    let dietaryNoneButton = UIButton(type: .system)
    let medicalOtherField = UITextField()
    let dietaryOtherField = UITextField()
    let cuisineLabel = UILabel()
    let cuisineOtherButton = UIButton(type: .system)
    let cuisineNoneButton = UIButton(type: .system)
    let cuisineOtherField = UITextField()
    let musicLabel = UILabel()
    let musicOtherButton = UIButton(type: .system)
    let musicNoneButton = UIButton(type: .system)
    let musicOtherField = UITextField()
    let goalLabel = UILabel()
    let activityLabel = UILabel()
    let saveButton = UIButton(type: .system)
    let resetButton = UIButton(type: .system)
    let backButton = UIButton(type: .system)
    
    let selectedColor = UIColor(red: 150/255, green: 140/255, blue: 235/255, alpha: 1)  // deeper lavender #968CEB
    let unselectedColor = UIColor(red: 193/255, green: 194/255, blue: 249/255, alpha: 1)  // #C1C2F9
    
    let ageBuckets = ["Below 18", "18–30", "31–40", "41–50", "51+"]
    let medicalOptions = ["Diabetes", "PCOS", "Thyroid", "Hypertension", "Cardiovascular"]
    let dietaryOptions = ["Vegetarian", "Vegan", "Pescatarian", "Gluten-free", "Dairy-free", "Nut-free", "Keto", "Paleo"]
    let cuisineOptions = ["Indian", "Italian", "Mexican", "Japanese", "Mediterranean", "Thai", "American", "Chinese"]
    let musicOptions = ["Pop", "Rock", "Hip-Hop", "Jazz", "Classical", "EDM", "R&B", "Folk", "Ambient"]
    let goalOptions = ["Weight loss", "Weight gain", "Maintenance", "Improve endurance", "Build muscle", "Improve flexibility"]
    let activityOptions = ["No activity", "1–2 times a week", "3–4 times a week", "5+ times a week"]
    
    let userDefaults = UserDefaults.standard

    var medicalButtons: [UIButton] = []
    var dietaryButtons: [UIButton] = []
    var cuisineButtons: [UIButton] = []
    var musicButtons: [UIButton] = []
    var goalButtons: [UIButton] = []
    var selectedGoals: [String] = []
    var activityButtons: [UIButton] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupScrollView()
        setupStyledBasicInfo()
        setupHeightAndWeightFields()
        setupCountryField()
        setupTapToDismiss()
        setupMedicalAndDietarySections()
        setupGoalSection()
        setupActivitySection()
        setupCuisineSection()
        setupMusicSection()
        setupActionButtons()
        loadProfile()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let textFields = [heightCmField, heightFtField, heightInField, weightField, medicalOtherField, dietaryOtherField, cuisineOtherField, musicOtherField]
            for field in textFields {
                field.layer.cornerRadius = 10
                field.layer.masksToBounds = true
                field.layer.borderWidth = 1
                field.layer.borderColor = UIColor(white: 0.85, alpha: 1).cgColor  // light gray border
            }
        
        let defaults = UserDefaults.standard
            if let savedGoals = defaults.array(forKey: "selectedGoals") as? [String] {
                selectedGoals = savedGoals

                // Update button visuals
                for button in goalButtons {
                    if let title = button.title(for: .normal) {
                        if selectedGoals.contains(title) {
                            button.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.9, alpha: 1)
                        } else {
                            button.backgroundColor = UIColor(red: 193/255, green: 194/255, blue: 249/255, alpha: 1) // unselected color
                        }
                    }
                }
            }

            // Apply rounded corners to segmented controls
            let segments = [heightUnitSegment, weightUnitSegment]
            for segment in segments {
                segment.layer.cornerRadius = 10
                segment.layer.masksToBounds = true
            }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleActionButton(saveButton, type: "save")
        styleActionButton(resetButton, type: "reset")
        styleActionButton(backButton, type: "back")
    }
    
    func setupTapToDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // so buttons still work
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }

    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }

    func styleTextField(_ textField: UITextField) {
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 12
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        textField.backgroundColor = UIColor(white: 1, alpha: 0.9)
        textField.font = UIFont(name: "Avenir", size: 16)
    }

    func styleLabel(_ label: UILabel, size: CGFloat, heavy: Bool = false) {
        label.font = UIFont(name: heavy ? "Avenir-Heavy" : "Avenir", size: size)
        label.textColor = UIColor(red: 155/255, green: 107/255, blue: 175/255, alpha: 1)
    }
    
    func styleActionButton(_ button: UIButton, type: String) {
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4

        // Check if gradient layer already exists; if not, add it
        let gradientLayer: CAGradientLayer
        if let existingGradient = button.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer = existingGradient
        } else {
            gradientLayer = CAGradientLayer()
            gradientLayer.cornerRadius = 12
            button.layer.insertSublayer(gradientLayer, at: 0)
        }

        // Apply colors based on type
        if type == "save" {
            gradientLayer.colors = [
                UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1).cgColor,    // #FFC3B9
                UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1).cgColor   // #FEB2DC
            ]
        } else if type == "reset" || type == "back" {
            gradientLayer.colors = [
                UIColor(red: 0.8, green: 0.757, blue: 0.969, alpha: 1).cgColor,    // #CCC1F7
                UIColor(red: 0.663, green: 0.776, blue: 1.0, alpha: 1).cgColor     // #A9C6FF
            ]
        } else {
            gradientLayer.colors = [
                UIColor(red: 193/255, green: 194/255, blue: 249/255, alpha: 1).cgColor
            ]
        }

        // Always update the gradient frame to match the button bounds
        gradientLayer.frame = button.bounds
    }
    
    @objc func toggleHeightFields() {
        if heightUnitSegment.selectedSegmentIndex == 0 {
            heightCmField.isHidden = false
            heightFtField.isHidden = true
            heightInField.isHidden = true
        } else {
            heightCmField.isHidden = true
            heightFtField.isHidden = false
            heightInField.isHidden = false
        }
    }
    
    @objc func toggleButtonSelection(_ sender: UIButton) {
        if medicalButtons.contains(sender) {
            medicalNoneButton.isSelected = false
            medicalNoneButton.backgroundColor = unselectedColor
        }
        if dietaryButtons.contains(sender) {
            dietaryNoneButton.isSelected = false
            dietaryNoneButton.backgroundColor = unselectedColor
        }
        if cuisineButtons.contains(sender) {
            cuisineNoneButton.isSelected = false
            cuisineNoneButton.backgroundColor = unselectedColor
        }
        if musicButtons.contains(sender) {
            musicNoneButton.isSelected = false
            musicNoneButton.backgroundColor = unselectedColor
        }

        if sender.isSelected {
            sender.isSelected = false
            sender.backgroundColor = unselectedColor
        } else {
            sender.isSelected = true
            sender.backgroundColor = selectedColor
        }
    }
    
    @objc func toggleMedicalOtherField() {
        medicalOtherField.isHidden.toggle()
    }

    
    @objc func toggleDietaryOtherField() {
        dietaryOtherField.isHidden.toggle()
    }

    @objc func toggleCuisineOtherField() {
        cuisineOtherField.isHidden.toggle()
    }

    @objc func toggleMusicOtherField() {
        musicOtherField.isHidden.toggle()
    }
    
    @objc func clearMedicalSelections() {
        for button in medicalButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        medicalNoneButton.isSelected = true
        medicalNoneButton.backgroundColor = selectedColor
        medicalOtherField.text = ""
        medicalOtherField.isHidden = true
    }

    @objc func clearDietarySelections() {
        for button in dietaryButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        dietaryNoneButton.isSelected = true
        dietaryNoneButton.backgroundColor = selectedColor
        dietaryOtherField.text = ""
        dietaryOtherField.isHidden = true
    }

    @objc func clearCuisineSelections() {
        for button in cuisineButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        cuisineNoneButton.isSelected = true
        cuisineNoneButton.backgroundColor = selectedColor
        cuisineOtherField.text = ""
        cuisineOtherField.isHidden = true
    }

    @objc func clearMusicSelections() {
        for button in musicButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        musicNoneButton.isSelected = true
        musicNoneButton.backgroundColor = selectedColor
        musicOtherField.text = ""
        musicOtherField.isHidden = true
    }
    
    @objc func handleGoalButtonTapped(_ sender: UIButton) {
        guard let title = sender.title(for: .normal) else { return }

        let exclusiveGoals = ["Weight loss", "Weight gain", "Maintenance"]

        if exclusiveGoals.contains(title) {
            // Deselect all exclusive goals
            for button in goalButtons where exclusiveGoals.contains(button.title(for: .normal) ?? "") {
                button.isSelected = false
                button.backgroundColor = unselectedColor
            }
            selectedGoals.removeAll(where: { exclusiveGoals.contains($0) })

            // Toggle tapped exclusive goal
            if sender.isSelected {
                sender.isSelected = false
                selectedGoals.removeAll(where: { $0 == title })
                sender.backgroundColor = unselectedColor
            } else {
                sender.isSelected = true
                selectedGoals.append(title)
                sender.backgroundColor = selectedColor
            }
        } else {
            // Non-exclusive: toggle on/off
            if sender.isSelected {
                sender.isSelected = false
                selectedGoals.removeAll(where: { $0 == title })
                sender.backgroundColor = unselectedColor
            } else {
                sender.isSelected = true
                selectedGoals.append(title)
                sender.backgroundColor = selectedColor
            }
        }

        let defaults = UserDefaults.standard
        defaults.set(selectedGoals, forKey: "selectedGoals")

        print("Current selected goals: \(selectedGoals)")
    }
    
    @objc func toggleActivitySelection(_ sender: UIButton) {
        for button in activityButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        sender.isSelected = true
        sender.backgroundColor = selectedColor
    }
    
    @objc func handleSave() {
        let name = nameField.text ?? ""
        
        let selectedAge = ageBuckets[agePicker.selectedRow(inComponent: 0)]
        
        let height = heightUnitSegment.selectedSegmentIndex == 0 ? heightCmField.text ?? "" : "\(heightFtField.text ?? "") ft \(heightInField.text ?? "") in"
        
        let weight = weightField.text ?? ""
        let weightUnit = weightUnitSegment.selectedSegmentIndex == 0 ? "kg" : "lbs"
        let fullWeight = "\(weight) \(weightUnit)"
        
        let country = countryField.text ?? ""
        
        var selectedMedical = medicalButtons.filter { $0.isSelected }.map { $0.title(for: .normal) ?? "" }
        if !medicalOtherField.isHidden, !medicalOtherField.text!.isEmpty {
            selectedMedical.append(medicalOtherField.text!)
        }
        if medicalNoneButton.isSelected {
            selectedMedical = ["None"]
        }

        var selectedDietary = dietaryButtons.filter { $0.isSelected }.map { $0.title(for: .normal) ?? "" }
        if !dietaryOtherField.isHidden, !dietaryOtherField.text!.isEmpty {
            selectedDietary.append(dietaryOtherField.text!)
        }
        if dietaryNoneButton.isSelected {
            selectedDietary = ["None"]
        }

        var selectedCuisines = cuisineButtons.filter { $0.isSelected }.map { $0.title(for: .normal) ?? "" }
        if !cuisineOtherField.isHidden, !cuisineOtherField.text!.isEmpty {
            selectedCuisines.append(cuisineOtherField.text!)
        }
        if cuisineNoneButton.isSelected {
            selectedCuisines = ["None"]
        }

        var selectedMusic = musicButtons.filter { $0.isSelected }.map { $0.title(for: .normal) ?? "" }
        if !musicOtherField.isHidden, !musicOtherField.text!.isEmpty {
            selectedMusic.append(musicOtherField.text!)
        }
        if musicNoneButton.isSelected {
            selectedMusic = ["None"]
        }

        let selectedGoal = goalButtons.filter { $0.isSelected }.map { $0.title(for: .normal) ?? "" }
        let selectedActivity = activityButtons.first(where: { $0.isSelected })?.title(for: .normal) ?? "None"
        
        print("SAVED:")
        print("Name: \(name)")
        print("Age: \(selectedAge)")
        print("Height: \(height)")
        print("Weight: \(weight)")
        print("Medical: \(selectedMedical)")
        print("Dietary: \(selectedDietary)")
        print("Preferred Cuisines: \(selectedCuisines)")
        print("Preferred Music: \(selectedMusic)")
        print("Goal: \(selectedGoal)")
        print("Activity Level: \(selectedActivity)")
        
        let alert = UIAlertController(title: "Saved", message: "Your profile has been saved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        userDefaults.set(name, forKey: "name")
        userDefaults.set(selectedAge, forKey: "age")
        userDefaults.set(height, forKey: "height")
        userDefaults.set(fullWeight, forKey: "weight")
        userDefaults.set(country, forKey: "country")
        userDefaults.set(selectedMedical, forKey: "medical")
        userDefaults.set(selectedDietary, forKey: "dietary")
        userDefaults.set(medicalOtherField.text ?? "", forKey: "medicalOther")
        userDefaults.set(dietaryOtherField.text ?? "", forKey: "dietaryOther")
        userDefaults.set(selectedCuisines, forKey: "preferredCuisines")
        userDefaults.set(selectedMusic, forKey: "preferredMusicGenres")
        userDefaults.set(cuisineOtherField.text ?? "", forKey: "otherCuisine")
        userDefaults.set(musicOtherField.text ?? "", forKey: "otherMusicGenre")
        userDefaults.set(selectedGoal, forKey: "selectedGoals")
        userDefaults.set(selectedActivity, forKey: "activity")
    }
    
    @objc func handleReset() {
        nameField.text = ""
        heightCmField.text = ""
        heightFtField.text = ""
        heightInField.text = ""
        weightField.text = ""
        countryField.text = ""
        agePicker.selectRow(0, inComponent: 0, animated: true)
        clearMedicalSelections()
        clearDietarySelections()
        clearCuisineSelections()
        clearMusicSelections()
        
        for button in medicalButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        medicalNoneButton.isSelected = false
        medicalNoneButton.backgroundColor = unselectedColor
        
        for button in dietaryButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        dietaryNoneButton.isSelected = false
        dietaryNoneButton.backgroundColor = unselectedColor

        for button in cuisineButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        cuisineNoneButton.isSelected = false
        cuisineNoneButton.backgroundColor = unselectedColor

        for button in musicButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        musicNoneButton.isSelected = false
        musicNoneButton.backgroundColor = unselectedColor

        for button in goalButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }

        for button in activityButtons {
            button.isSelected = false
            button.backgroundColor = unselectedColor
        }
        
        userDefaults.removeObject(forKey: "name")
        userDefaults.removeObject(forKey: "age")
        userDefaults.removeObject(forKey: "height")
        userDefaults.removeObject(forKey: "weight")
        userDefaults.removeObject(forKey: "country")
        userDefaults.removeObject(forKey: "medical")
        userDefaults.removeObject(forKey: "dietary")
        userDefaults.removeObject(forKey: "medicalOther")
        userDefaults.removeObject(forKey: "dietaryOther")
        userDefaults.removeObject(forKey: "preferredCuisines")
        userDefaults.removeObject(forKey: "preferredMusicGenres")
        userDefaults.removeObject(forKey: "otherCuisine")
        userDefaults.removeObject(forKey: "otherMusicGenre")
        userDefaults.removeObject(forKey: "selectedGoals")
        userDefaults.removeObject(forKey: "activity")
        
        heightUnitSegment.selectedSegmentIndex = 0
        weightUnitSegment.selectedSegmentIndex = 0
        toggleHeightFields()
    }
    
    
    @objc func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let bottomInset = keyboardFrame.height + 20  // Add padding
        scrollView.contentInset.bottom = bottomInset
        scrollView.verticalScrollIndicatorInsets.bottom = bottomInset
    }

    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    func setupStyledBasicInfo() {
        headingLabel.text = "User Profile"
        headingLabel.textAlignment = .center
        styleLabel(headingLabel, size: 26, heavy: true)
        headingLabel.translatesAutoresizingMaskIntoConstraints = false

        basicInfoLabel.text = "Basic Information"
        styleLabel(basicInfoLabel, size: 20, heavy: true)
        basicInfoLabel.translatesAutoresizingMaskIntoConstraints = false

        nameField.placeholder = "Name (optional)"
        nameField.translatesAutoresizingMaskIntoConstraints = false
        styleTextField(nameField)
        
        nameLabel.text = "Name"
        styleLabel(nameLabel, size: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        ageLabel.text = "Age"
        styleLabel(ageLabel, size: 16)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false

        agePicker.delegate = self
        agePicker.dataSource = self
        agePicker.translatesAutoresizingMaskIntoConstraints = false

        heightLabel.text = "Height"
        styleLabel(heightLabel, size: 16)
        heightLabel.translatesAutoresizingMaskIntoConstraints = false

        heightUnitSegment.selectedSegmentIndex = 0
        heightUnitSegment.translatesAutoresizingMaskIntoConstraints = false

        weightLabel.text = "Weight"
        styleLabel(weightLabel, size: 16)
        weightLabel.translatesAutoresizingMaskIntoConstraints = false

        weightUnitSegment.selectedSegmentIndex = 0
        weightUnitSegment.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(headingLabel)
        contentView.addSubview(basicInfoLabel)
        contentView.addSubview(nameField)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ageLabel)
        contentView.addSubview(agePicker)
        contentView.addSubview(heightLabel)
        contentView.addSubview(heightUnitSegment)
        contentView.addSubview(weightLabel)
        contentView.addSubview(weightUnitSegment)

        NSLayoutConstraint.activate([
            headingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headingLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            basicInfoLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 20),
            basicInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: basicInfoLabel.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            nameField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            ageLabel.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 10),
            ageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            agePicker.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 10),
            agePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            agePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            agePicker.heightAnchor.constraint(equalToConstant: 100),

            heightLabel.topAnchor.constraint(equalTo: agePicker.bottomAnchor, constant: 20),
            heightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            heightUnitSegment.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 10),
            heightUnitSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    func setupHeightAndWeightFields() {
        // Add height container
        heightContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heightContainerView)

        // Height (cm)
        heightCmField.placeholder = "Height (cm)"
        styleTextField(heightCmField)
        heightCmField.keyboardType = .decimalPad
        heightCmField.translatesAutoresizingMaskIntoConstraints = false
        heightContainerView.addSubview(heightCmField)

        // Height (ft)
        heightFtField.placeholder = "ft"
        styleTextField(heightFtField)
        heightFtField.keyboardType = .numberPad
        heightFtField.translatesAutoresizingMaskIntoConstraints = false
        heightFtField.isHidden = true
        heightContainerView.addSubview(heightFtField)

        // Height (in)
        heightInField.placeholder = "in"
        styleTextField(heightInField)
        heightInField.keyboardType = .numberPad
        heightInField.translatesAutoresizingMaskIntoConstraints = false
        heightInField.isHidden = true
        heightContainerView.addSubview(heightInField)

        // Weight
        weightField.placeholder = "Weight"
        styleTextField(weightField)
        weightField.keyboardType = .decimalPad
        weightField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weightField)
        
        weightLabel.text = "Weight"
        styleLabel(weightLabel, size: 16)
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(weightLabel)

        heightUnitSegment.addTarget(self, action: #selector(toggleHeightFields), for: .valueChanged)
        toggleHeightFields() // Ensure initial state

        NSLayoutConstraint.activate([
            // height container under height unit segment
            heightContainerView.topAnchor.constraint(equalTo: heightUnitSegment.bottomAnchor, constant: 10),
            heightContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            heightContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            heightContainerView.heightAnchor.constraint(equalToConstant: 40),

            // cm field (single)
            heightCmField.leadingAnchor.constraint(equalTo: heightContainerView.leadingAnchor),
            heightCmField.trailingAnchor.constraint(equalTo: heightContainerView.trailingAnchor),
            heightCmField.topAnchor.constraint(equalTo: heightContainerView.topAnchor),
            heightCmField.bottomAnchor.constraint(equalTo: heightContainerView.bottomAnchor),

            // ft field
            heightFtField.leadingAnchor.constraint(equalTo: heightContainerView.leadingAnchor),
            heightFtField.widthAnchor.constraint(equalToConstant: 60),
            heightFtField.topAnchor.constraint(equalTo: heightContainerView.topAnchor),
            heightFtField.bottomAnchor.constraint(equalTo: heightContainerView.bottomAnchor),

            // in field next to ft
            heightInField.leadingAnchor.constraint(equalTo: heightFtField.trailingAnchor, constant: 10),
            heightInField.widthAnchor.constraint(equalToConstant: 60),
            heightInField.topAnchor.constraint(equalTo: heightContainerView.topAnchor),
            heightInField.bottomAnchor.constraint(equalTo: heightContainerView.bottomAnchor),

            // weight field next to unit segment
            // Weight Label
                weightLabel.topAnchor.constraint(equalTo: heightContainerView.bottomAnchor, constant: 20),
                weightLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

                // weight unit segment below label
                weightUnitSegment.topAnchor.constraint(equalTo: weightLabel.bottomAnchor, constant: 10),
                weightUnitSegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

                // weight field next to unit segment
                weightField.centerYAnchor.constraint(equalTo: weightUnitSegment.centerYAnchor),
                weightField.leadingAnchor.constraint(equalTo: weightUnitSegment.trailingAnchor, constant: 10),
                weightField.widthAnchor.constraint(equalToConstant: 100),
                weightField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func setupCountryField() {
        // Label
        countryLabel.text = "Country"
        styleLabel(countryLabel, size: 16)
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countryLabel)

        // Field
        countryField.placeholder = "Enter your country"
        countryField.translatesAutoresizingMaskIntoConstraints = false
        styleTextField(countryField)
        contentView.addSubview(countryField)

        NSLayoutConstraint.activate([
            countryLabel.topAnchor.constraint(equalTo: weightField.bottomAnchor, constant: 20),
            countryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            countryField.topAnchor.constraint(equalTo: countryLabel.bottomAnchor, constant: 10),
            countryField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            countryField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            countryField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupMedicalAndDietarySections() {
        // Medical Complications Section
        
        medicalLabel.text = "Medical Complications"
        styleLabel(medicalLabel, size: 20, heavy: true)
        medicalLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(medicalLabel)


        NSLayoutConstraint.activate([
            medicalLabel.topAnchor.constraint(equalTo: countryField.bottomAnchor, constant: 30),
            medicalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
        
        // Medical None Button
        medicalNoneButton.setTitle("None", for: .normal)
        styleSelectableButton(medicalNoneButton)
        medicalNoneButton.addTarget(self, action: #selector(clearMedicalSelections), for: .touchUpInside)
        contentView.addSubview(medicalNoneButton)

        medicalNoneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            medicalNoneButton.topAnchor.constraint(equalTo: medicalLabel.bottomAnchor, constant: 10),
            medicalNoneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicalNoneButton.widthAnchor.constraint(equalToConstant: 150),
            medicalNoneButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        var previousMedicalButton: UIButton? = medicalNoneButton  // update to start below 'None'

        for option in medicalOptions {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            styleSelectableButton(button)
            button.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
            contentView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousMedicalButton?.bottomAnchor ?? medicalLabel.bottomAnchor, constant: 10),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.widthAnchor.constraint(equalToConstant: 150),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])

            previousMedicalButton = button
            medicalButtons.append(button)
        }

        // Medical Other Button + Field
        medicalOtherButton.setTitle("Other", for: .normal)
        styleSelectableButton(medicalOtherButton)
        medicalOtherButton.addTarget(self, action: #selector(toggleMedicalOtherField), for: .touchUpInside)
        contentView.addSubview(medicalOtherButton)

        
        medicalOtherField.placeholder = "Specify other medical condition"
        styleTextField(medicalOtherField)
        medicalOtherField.isHidden = true
        contentView.addSubview(medicalOtherField)

        medicalOtherButton.translatesAutoresizingMaskIntoConstraints = false
        medicalOtherField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            medicalOtherButton.topAnchor.constraint(equalTo: previousMedicalButton?.bottomAnchor ?? medicalLabel.bottomAnchor, constant: 10),
            medicalOtherButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicalOtherButton.widthAnchor.constraint(equalToConstant: 150),
            medicalOtherButton.heightAnchor.constraint(equalToConstant: 40),

            medicalOtherField.topAnchor.constraint(equalTo: medicalOtherButton.bottomAnchor, constant: 10),
            medicalOtherField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            medicalOtherField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])

        // Dietary Restrictions Section
        dietaryLabel.text = "Dietary Restrictions"
        styleLabel(dietaryLabel, size: 20, heavy: true)
        dietaryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dietaryLabel)
        
        dietaryNoneButton.setTitle("None", for: .normal)
        styleSelectableButton(dietaryNoneButton)
        dietaryNoneButton.addTarget(self, action: #selector(clearDietarySelections), for: .touchUpInside)
        contentView.addSubview(dietaryNoneButton)

        dietaryNoneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dietaryLabel.topAnchor.constraint(equalTo: medicalOtherField.bottomAnchor, constant: 30),
            dietaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            dietaryNoneButton.topAnchor.constraint(equalTo: dietaryLabel.bottomAnchor, constant: 10),
            dietaryNoneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dietaryNoneButton.widthAnchor.constraint(equalToConstant: 150),
            dietaryNoneButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        var previousDietaryButton: UIButton? = dietaryNoneButton

        for option in dietaryOptions {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            styleSelectableButton(button)
            button.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
            contentView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousDietaryButton?.bottomAnchor ?? dietaryLabel.bottomAnchor, constant: 10),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.widthAnchor.constraint(equalToConstant: 150),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])

            previousDietaryButton = button
            dietaryButtons.append(button)
        }

        // Dietary Other Button + Field
        
        dietaryOtherButton.setTitle("Other", for: .normal)
        styleSelectableButton(dietaryOtherButton)
        dietaryOtherButton.addTarget(self, action: #selector(toggleDietaryOtherField), for: .touchUpInside)
        contentView.addSubview(dietaryOtherButton)

        dietaryOtherField.placeholder = "Specify other dietary restriction"
        styleTextField(dietaryOtherField)
        dietaryOtherField.isHidden = true
        contentView.addSubview(dietaryOtherField)

        dietaryOtherButton.translatesAutoresizingMaskIntoConstraints = false
        dietaryOtherField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dietaryOtherButton.topAnchor.constraint(equalTo: previousDietaryButton?.bottomAnchor ?? dietaryLabel.bottomAnchor, constant: 10),
            dietaryOtherButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dietaryOtherButton.widthAnchor.constraint(equalToConstant: 150),
            dietaryOtherButton.heightAnchor.constraint(equalToConstant: 40),

            dietaryOtherField.topAnchor.constraint(equalTo: dietaryOtherButton.bottomAnchor, constant: 10),
            dietaryOtherField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dietaryOtherField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func setupGoalSection() {
        goalLabel.text = "Goal"
        styleLabel(goalLabel, size: 20, heavy: true)
        goalLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(goalLabel)

        NSLayoutConstraint.activate([
            goalLabel.topAnchor.constraint(equalTo: dietaryOtherField.bottomAnchor, constant: 30),
            goalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        var previousGoalButton: UIButton? = nil

        for option in goalOptions {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            styleSelectableButton(button)
            button.addTarget(self, action: #selector(handleGoalButtonTapped(_:)), for: .touchUpInside)
            contentView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousGoalButton?.bottomAnchor ?? goalLabel.bottomAnchor, constant: 10),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])

            previousGoalButton = button
            goalButtons.append(button)
        }
    }
    
    func setupActivitySection() {
        activityLabel.text = "Activity Level"
        styleLabel(activityLabel, size: 20, heavy: true)
        activityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(activityLabel)

        NSLayoutConstraint.activate([
            activityLabel.topAnchor.constraint(equalTo: goalButtons.last?.bottomAnchor ?? goalLabel.bottomAnchor, constant: 30),
            activityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        var previousActivityButton: UIButton? = nil

        for option in activityOptions {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            styleSelectableButton(button)
            button.addTarget(self, action: #selector(toggleActivitySelection(_:)), for: .touchUpInside)
            contentView.addSubview(button)

            button.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousActivityButton?.bottomAnchor ?? activityLabel.bottomAnchor, constant: 10),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.widthAnchor.constraint(equalToConstant: 200),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])

            previousActivityButton = button
            activityButtons.append(button)
        }
    }

    func setupCuisineSection() {
        cuisineLabel.text = "Preferred Cuisines"
        styleLabel(cuisineLabel, size: 20, heavy: true)
        cuisineLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cuisineLabel)

        NSLayoutConstraint.activate([
            cuisineLabel.topAnchor.constraint(equalTo: activityButtons.last?.bottomAnchor ?? activityLabel.bottomAnchor, constant: 30),
            cuisineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        cuisineNoneButton.setTitle("None", for: .normal)
        styleSelectableButton(cuisineNoneButton)
        cuisineNoneButton.addTarget(self, action: #selector(clearCuisineSelections), for: .touchUpInside)
        contentView.addSubview(cuisineNoneButton)
        cuisineNoneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cuisineNoneButton.topAnchor.constraint(equalTo: cuisineLabel.bottomAnchor, constant: 10),
            cuisineNoneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cuisineNoneButton.widthAnchor.constraint(equalToConstant: 150),
            cuisineNoneButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        var previousCuisineButton: UIButton? = cuisineNoneButton
        for option in cuisineOptions {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            styleSelectableButton(button)
            button.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousCuisineButton?.bottomAnchor ?? cuisineLabel.bottomAnchor, constant: 10),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.widthAnchor.constraint(equalToConstant: 150),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
            previousCuisineButton = button
            cuisineButtons.append(button)
        }

        cuisineOtherButton.setTitle("Other", for: .normal)
        styleSelectableButton(cuisineOtherButton)
        cuisineOtherButton.addTarget(self, action: #selector(toggleCuisineOtherField), for: .touchUpInside)
        contentView.addSubview(cuisineOtherButton)

        cuisineOtherField.placeholder = "Specify other cuisine"
        styleTextField(cuisineOtherField)
        cuisineOtherField.isHidden = true
        contentView.addSubview(cuisineOtherField)

        cuisineOtherButton.translatesAutoresizingMaskIntoConstraints = false
        cuisineOtherField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cuisineOtherButton.topAnchor.constraint(equalTo: previousCuisineButton?.bottomAnchor ?? cuisineLabel.bottomAnchor, constant: 10),
            cuisineOtherButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cuisineOtherButton.widthAnchor.constraint(equalToConstant: 150),
            cuisineOtherButton.heightAnchor.constraint(equalToConstant: 40),

            cuisineOtherField.topAnchor.constraint(equalTo: cuisineOtherButton.bottomAnchor, constant: 10),
            cuisineOtherField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cuisineOtherField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    func setupMusicSection() {
        musicLabel.text = "Preferred Music Genres"
        styleLabel(musicLabel, size: 20, heavy: true)
        musicLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(musicLabel)

        NSLayoutConstraint.activate([
            musicLabel.topAnchor.constraint(equalTo: cuisineOtherField.bottomAnchor, constant: 30),
            musicLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        musicNoneButton.setTitle("None", for: .normal)
        styleSelectableButton(musicNoneButton)
        musicNoneButton.addTarget(self, action: #selector(clearMusicSelections), for: .touchUpInside)
        contentView.addSubview(musicNoneButton)
        musicNoneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            musicNoneButton.topAnchor.constraint(equalTo: musicLabel.bottomAnchor, constant: 10),
            musicNoneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            musicNoneButton.widthAnchor.constraint(equalToConstant: 150),
            musicNoneButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        var previousMusicButton: UIButton? = musicNoneButton
        for option in musicOptions {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            styleSelectableButton(button)
            button.addTarget(self, action: #selector(toggleButtonSelection(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: previousMusicButton?.bottomAnchor ?? musicLabel.bottomAnchor, constant: 10),
                button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                button.widthAnchor.constraint(equalToConstant: 150),
                button.heightAnchor.constraint(equalToConstant: 40)
            ])
            previousMusicButton = button
            musicButtons.append(button)
        }

        musicOtherButton.setTitle("Other", for: .normal)
        styleSelectableButton(musicOtherButton)
        musicOtherButton.addTarget(self, action: #selector(toggleMusicOtherField), for: .touchUpInside)
        contentView.addSubview(musicOtherButton)

        musicOtherField.placeholder = "Specify other genre"
        styleTextField(musicOtherField)
        musicOtherField.isHidden = true
        contentView.addSubview(musicOtherField)

        musicOtherButton.translatesAutoresizingMaskIntoConstraints = false
        musicOtherField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            musicOtherButton.topAnchor.constraint(equalTo: previousMusicButton?.bottomAnchor ?? musicLabel.bottomAnchor, constant: 10),
            musicOtherButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            musicOtherButton.widthAnchor.constraint(equalToConstant: 150),
            musicOtherButton.heightAnchor.constraint(equalToConstant: 40),

            musicOtherField.topAnchor.constraint(equalTo: musicOtherButton.bottomAnchor, constant: 10),
            musicOtherField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            musicOtherField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func setupActionButtons() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        contentView.addSubview(saveButton)
        styleActionButton(saveButton, type: "save")

        saveButton.translatesAutoresizingMaskIntoConstraints = false

        // Reset Button
        resetButton.setTitle("Reset", for: .normal)
        resetButton.addTarget(self, action: #selector(handleReset), for: .touchUpInside)
        contentView.addSubview(resetButton)
        styleActionButton(resetButton, type: "reset")

        resetButton.translatesAutoresizingMaskIntoConstraints = false

        // Back Button
        backButton.setTitle("Back", for: .normal)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        contentView.addSubview(backButton)
        styleActionButton(backButton, type: "back")

        backButton.translatesAutoresizingMaskIntoConstraints = false

        // Stack the buttons horizontally
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: musicOtherField.bottomAnchor, constant: 40),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.widthAnchor.constraint(equalToConstant: 100),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            resetButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            resetButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 100),
            resetButton.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 44),
            
            contentView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 40)
        ])
    }
    
    func styleSelectableButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        button.backgroundColor = unselectedColor
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4

        // ✅ Ensure button uses full background (remove system tint)
        button.tintColor = .clear

        // ✅ Add a subtle border so background is visibly consistent
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.clear.cgColor
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { ageBuckets.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { ageBuckets[row] }
    
    func loadProfile() {
        nameField.text = userDefaults.string(forKey: "name")
        
        if let savedAge = userDefaults.string(forKey: "age"),
           let index = ageBuckets.firstIndex(of: savedAge) {
            agePicker.selectRow(index, inComponent: 0, animated: false)
        }
        
        heightCmField.text = userDefaults.string(forKey: "height")
        weightField.text = userDefaults.string(forKey: "weight")
        
        countryField.text = userDefaults.string(forKey: "country")

        if let savedMedical = userDefaults.array(forKey: "medical") as? [String] {
            for button in medicalButtons {
                if savedMedical.contains(button.title(for: .normal) ?? "") {
                    button.isSelected = true
                    button.backgroundColor = selectedColor
                }
            }
            if savedMedical.contains("None") {
                medicalNoneButton.isSelected = true
                medicalNoneButton.backgroundColor = selectedColor
            }
        }

        if let savedDietary = userDefaults.array(forKey: "dietary") as? [String] {
            for button in dietaryButtons {
                if savedDietary.contains(button.title(for: .normal) ?? "") {
                    button.isSelected = true
                    button.backgroundColor = selectedColor
                }
            }
            if savedDietary.contains("None") {
                dietaryNoneButton.isSelected = true
                dietaryNoneButton.backgroundColor = selectedColor
            }
        }

        if let savedCuisines = userDefaults.array(forKey: "preferredCuisines") as? [String] {
            for button in cuisineButtons {
                if savedCuisines.contains(button.title(for: .normal) ?? "") {
                    button.isSelected = true
                    button.backgroundColor = selectedColor
                }
            }
            if savedCuisines.contains("None") {
                cuisineNoneButton.isSelected = true
                cuisineNoneButton.backgroundColor = selectedColor
            }
        }

        if let savedMusic = userDefaults.array(forKey: "preferredMusicGenres") as? [String] {
            for button in musicButtons {
                if savedMusic.contains(button.title(for: .normal) ?? "") {
                    button.isSelected = true
                    button.backgroundColor = selectedColor
                }
            }
            if savedMusic.contains("None") {
                musicNoneButton.isSelected = true
                musicNoneButton.backgroundColor = selectedColor
            }
        }

        if let savedGoals = userDefaults.array(forKey: "selectedGoals") as? [String] {
            for button in goalButtons {
                if savedGoals.contains(button.title(for: .normal) ?? "") {
                    button.isSelected = true
                    button.backgroundColor = selectedColor
                }
            }
        }
        

        if let savedActivity = userDefaults.string(forKey: "activity") {
            for button in activityButtons {
                if button.title(for: .normal) == savedActivity {
                    button.isSelected = true
                    button.backgroundColor = selectedColor
                }
            }
        }

        // Load 'Other' fields
        medicalOtherField.text = userDefaults.string(forKey: "medicalOther")
        dietaryOtherField.text = userDefaults.string(forKey: "dietaryOther")
        cuisineOtherField.text = userDefaults.string(forKey: "otherCuisine")
        musicOtherField.text = userDefaults.string(forKey: "otherMusicGenre")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
