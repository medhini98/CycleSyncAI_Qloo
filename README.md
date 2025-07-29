# CycleSyncAI

## Overview
CycleSyncAI is an iOS app designed to provide personalized diet and workout recommendations tailored to a woman’s menstrual cycle phase. By integrating menstrual cycle data from the iOS Health app and optional user profile details (age, height, weight, medical conditions, dietary restrictions, fitness goals, activity level, and meal preferences), the app delivers expert-informed, dynamic plans that support better health, fitness, and wellness outcomes.

Unlike typical static wellness apps, CycleSyncAI integrates a large language model (LLM) through Perplexity’s Sonar Pro API to generate fully personalized recommendations, a daily grocery list, and motivational guidance in real time.

---

## Problem Statement
Women’s nutritional and fitness needs naturally fluctuate across different phases of the menstrual cycle, but most mainstream wellness apps provide generic, one-size-fits-all advice. This lack of personalization can leave many women feeling unsupported, frustrated, or unable to achieve their health goals.

**Why it matters:** Addressing these cyclical changes can help improve energy, reduce discomfort, support mental well-being, and enhance fitness results.

**How our app + API solve it:** CycleSyncAI bridges this gap by integrating Apple HealthKit menstrual cycle data with Perplexity’s Sonar Pro LLM to generate adaptive, expert-informed diet and workout recommendations — plus a daily grocery list to make following the plan easy. The result is a dynamic, cycle-aware wellness assistant that delivers timely, supportive, and motivating suggestions tailored to the user’s unique profile.

---

## Features
- Personalized diet and workout suggestions based on menstrual cycle phase and user profile.
- Optional input fields for more precise personalization (age, height, weight, medical conditions, dietary restrictions, fitness goals, activity level, meal preferences).
- Automatically generates a grocery list for the day based on the personalized diet plan, making it easy to shop and prepare meals.
- Seamless integration with Apple HealthKit to automatically detect the user’s menstrual cycle phase.
- Smooth, modern UI with gradient themes and soft animations.
- Uses Perplexity’s Sonar Pro API to generate AI-driven, expert-informed plans with motivational and supportive feedback.

---

## Positive Impact
This app empowers women to better align their nutrition and workouts with their body’s natural hormonal cycles, potentially improving energy levels, fitness outcomes, and overall well-being. By offering cycle-aware health suggestions, it promotes more mindful, personalized self-care, supports healthier body image, reduces decision fatigue by providing grocery lists aligned with the daily diet plan, and encourages positive motivation to eat well and stay active — including kind, supportive messages delivered directly in the app.

---

## Motivation
I wanted a tailored regime for myself and couldn’t find it all in one place — hence the idea for this app. Women’s fitness and nutrition needs fluctuate across their menstrual cycle, but most mainstream wellness apps ignore this. CycleSyncAI was built to fill this gap by providing evidence-informed, personalized recommendations for each phase.

---

## Repository Structure
- `CycleSyncAI.xcodeproj` — Xcode project file.
- `CycleSyncAI/` — Main app source code.
   - `EatPlanViewController.swift` — Generates and displays personalized diet plan; handles meal preference input; provides daily grocery list.
   - `WorkoutPlanViewController.swift` — Generates and displays personalized workout plan.
   - `HomepageViewController.swift` — Main navigation screen; connects to User Profile, Diet Plan, and Workout Plan pages; includes initial tagline shown on app start.
   - `UserProfileViewController.swift` — Handles user profile input and saves data locally.
   - `HealthManager.swift` — Interfaces with Apple HealthKit; provides menstrual cycle data for LLM prompts.
   - `UserProfile.swift` — Contains user profile data; feeds profile details into LLM prompts.
- `Main.storyboard` — App’s UI layout and navigation.
- `Assets.xcassets` — Images and app icon set.
- `Info.plist` — App configuration and permissions.

---

## Setup Instructions
1. Clone this repository.
2. Open the project in Xcode.
3. Ensure you have access to Apple HealthKit on your test device or simulator.
4. Build and run the app on an iOS device (recommended for HealthKit integration).
5. Set up any necessary API keys or tokens for accessing Perplexity’s Sonar Pro API.

---

## Perplexity API Usage
The app integrates with Perplexity’s Sonar Pro API by:
- Sending structured prompts containing menstrual cycle phase, age, weight, height, medical conditions, dietary restrictions, fitness goal, activity level, and meal preferences.
- Receiving AI-generated personalized diet and workout plans, a daily grocery list, plus motivational and supportive feedback.
- Parsing and presenting the results in a clean, user-friendly format.

---

## Demo Video
See demo video in the Devpost submission.

**Note:** The LLM takes approximately 30 seconds to 1 minute to generate each diet or workout plan. To stay within the 3-minute video time limit, we have cut out the waiting periods in the demo video while waiting for the API responses.

---

## Testing Instructions
- The app runs on iOS devices with HealthKit permissions.
- If needed, provide demo login credentials or additional setup instructions here.

---

## Repository Access
This is a private repository. Access has been granted to:
- james.liounis@perplexity.ai
- sathvik@perplexity.ai
- devrel@perplexity.ai
- testing@devpost.com