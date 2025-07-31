# CycleSyncAI

## Overview

CycleSyncAI is a native iOS app that delivers personalized, cycle-aware diet and fitness plans, along with a ready-to-use grocery list — to help women align their wellness routines with their body’s natural rhythms.

It integrates:
- Menstrual cycle data from Apple HealthKit  
- User profile inputs (age, weight, height, dietary restrictions, medical conditions, fitness goals, activity level, and meal preferences)  
- Perplexity’s Sonar Pro API to generate evidence-informed diet and workout plans  
- Qloo’s Taste AI™ API to provide culturally relevant wellness recommendations based on user behavior and taste

The result is a highly adaptive health assistant that merges biological, behavioral, and cultural context into one personalized wellness experience.

---

## Problem Statement

Most wellness apps offer generic recommendations, ignoring the natural hormonal fluctuations that affect women’s nutritional and fitness needs throughout their menstrual cycle. This often leads to frustration, low motivation, and poor adherence.

CycleSyncAI fills this gap by providing timely, personalized, and culturally sensitive suggestions, empowering users to follow a wellness plan that evolves with their body and preferences.

---

## Features

- Personalized, phase-specific diet and workout plans using LLMs - for a single day or a custom date range  
- Customized grocery lists aligned with each day’s meals, consolidated for weekly planning  
- Adherence-aware tracking system: Users mark completed tasks, and future plans adapt based on tracker insights  
- Motivational and supportive messages integrated into plan delivery  
- Smart notifications for hydration, menstrual phase changes, and task follow-ups  
- “Curated For You” page powered by Qloo, surfacing food and wellness suggestions tailored to the user’s taste and behavior  
- User profile system that stores and updates personal and health-related information  
- History & Progress View: view previous plans, track consistency, and celebrate progress  
- Clean and engaging UI with gradient backgrounds, custom cards, and modern UX elements

---

## Positive Impact

CycleSyncAI empowers women to take charge of their wellness in a personalized, inclusive, and culturally intelligent way.  
It promotes:
- Smarter food and workout decisions  
- Better adherence through feedback and tracking  
- Culturally relevant wellness engagement using Qloo  
- Positive body awareness and mental well-being  
- Reduced decision fatigue with ready-to-use plans and grocery lists

---

## Motivation

I created CycleSyncAI to address a personal need for more meaningful, science-based, and personalized wellness planning - something that adapts to both biology and behavior. With Qloo’s Taste AI, the app now goes a step further by embedding cultural context into wellness, recognizing that personalization is not just about health data, but about what resonates with who we are.

---

## Technologies Used

**Languages:** Swift, Python  
**Frameworks:** UIKit, HealthKit, UserNotifications  
**Platforms:** iOS, Xcode  
**APIs:** Perplexity Sonar Pro API, Qloo Taste AI API  
**Storage:** UserDefaults (local), WKWebView (HTML rendering)  
**Version Control:** Git, GitHub

---

## Repository Structure

- `CycleSyncAI.xcodeproj` — Xcode project file  
- `CycleSyncAI/` — Main app source code  
- `EatPlanViewController.swift` — Diet plan generator, grocery list builder  
- `WorkoutPlanViewController.swift` — Workout plan generator  
- `CuratedForYouViewController.swift` — Qloo-powered Taste AI interface  
- `PlanDetailViewController.swift` — Tracks completion for each component of a saved plan  
- `UserProfileViewController.swift` — Manages user inputs  
- `TrackerManager.swift` — Stores and analyzes adherence data  
- `HealthManager.swift` — Interfaces with HealthKit for menstrual data  
- `Main.storyboard` — UI layout and navigation  
- `Assets.xcassets` — Image and icon assets  
- `Info.plist` — App configuration and HealthKit permissions

---

## Setup Instructions

1. Clone the repository  
2. Open `CycleSyncAI.xcodeproj` in Xcode  
3. Set up API keys for:  
   - Perplexity Sonar Pro  
   - Qloo Taste AI™  
4. Build and run the app on an iOS device (HealthKit access required)  
5. Navigate to User Profile to input initial details before generating plans

---

## Perplexity API Usage

- Sends structured prompts combining cycle phase, goals, restrictions, and preferences  
- Receives HTML-formatted personalized diet/workout plans and motivational feedback  
- Parses and displays output using WKWebView  
- Supports both single-day and multi-day planning

---

## Qloo API Usage

- Queries Taste AI with user context to fetch culturally relevant food and wellness suggestions  
- Powers the “Curated For You” section  
- Adapts to user tastes and behavior to improve over time

---

## Demo Video

A 3-minute video demonstrating the app’s main features and Qloo integration is available in the Devpost submission.

**Note:** API response delays have been edited out in the video for smoother viewing. Typical plan generation time ranges from 30 seconds to 1 minute.

---

## What’s Next

- Add a chatbot assistant so users can ask follow-up questions like:  
  - “Can you give me the recipe for this meal?”  
  - “Why was this workout recommended?”  
  - “Can you suggest something similar but vegan?”  
- Expand Qloo integration to dynamically respond to tracker data and seasonal/taste changes  
- Release on Android  
- Add wearable support for fitness data  
- Enable multilingual support to reach a global audience

---

## License

This repository is open to the public for the purpose of the Qloo Hackathon. Attribution required if reused beyond this context.
