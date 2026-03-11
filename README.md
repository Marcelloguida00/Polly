# 🤖 Polly

**Polly** is an iOS app that raises awareness about **Data Pollution** — the hidden environmental cost of storing unnecessary digital data — through an interactive virtual robot companion.

---

## 🌱 About the Project

Polly is a tamagotchi-style eco-companion. Her mood and stats reflect your engagement with sustainability: feed her with good habits, keep her educated, and chat with her to learn how your digital footprint impacts the planet. The more you interact, the more you learn about the environmental cost of data.

---

## ✨ Key Features

- 🤖 **Virtual companion** — Polly has moods (happy, hungry, tired, curious, bored, chatting) that change dynamically based on her stats and your activity
- 📊 **Live stats** — track Hunger, Education, and Fun as progress bars that decay over time and require your attention
- 💬 **AI-powered chat** — talk to Polly using Apple's on-device `FoundationModels` framework; she answers in character as an eco-conscious guide on data pollution
- 📚 **Education quizzes** — a rotating set of multiple-choice questions about digital carbon footprints, data centers, dark data, and AI environmental impact
- 🍎 **Hunger mini-game** — feed Polly to keep her hunger stat up
- 🔔 **Push notifications** — Polly reminds you to come back when her stats drop below 50%
- ⏱️ **Screen time awareness** — after 5 minutes of use, Polly warns you about overuse and drains her energy stat
- 🎬 **Splash screen & onboarding** — animated intro and a multi-slide onboarding explaining the concept of Data Pollution
- ♿ **Accessibility** — full VoiceOver support with labels and hints throughout the app

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| AI Chat | Apple FoundationModels (on-device LLM) |
| State Management | ObservableObject + Combine |
| Notifications | UserNotifications framework |
| Graphics | SVG rendering via WKWebView |
| Persistence | AppStorage (UserDefaults) |

---

## 📋 Requirements

- iOS 18.0+
- Xcode 16+
- Device with Apple Intelligence support (for AI chat via FoundationModels)

> ⚠️ The AI chat feature uses `FoundationModels`, Apple's on-device language model framework introduced in iOS 18. On unsupported devices the chat will gracefully fall back.

---

## 🚀 Setup & Installation

### 1. Clone the repository

```bash
git clone https://github.com/your-username/Polly.git
cd Polly
```

### 2. Open the project in Xcode

```bash
open Polly.xcodeproj
```

### 3. Build and run

Select a physical device or simulator running iOS 18+ and hit `Product → Run`.

> No external dependencies or API keys are required — everything runs on-device.

---

## 📁 Project Structure

```
Polly/
├── Polly/
│   ├── PollyApp.swift              # App entry point
│   ├── ContentView.swift           # Root navigation and screen routing
│   ├── GameManager.swift           # Core state: stats, mood, decay timer, notifications
│   ├── HomeView.swift              # Main screen with Polly and stat cards
│   ├── ChatView.swift              # AI chat powered by FoundationModels
│   ├── EducationView.swift         # Quiz section on data pollution
│   ├── HungerView.swift            # Feeding mini-game
│   ├── Rob8View.swift              # Polly's animated SVG robot character
│   ├── SVGWebView.swift            # WKWebView wrapper for SVG rendering
│   ├── OnboardingView.swift        # Multi-slide onboarding flow
│   ├── SplashView.swift            # Animated splash screen
│   └── InfoView.swift              # About / info sheet
└── Polly.xcodeproj
```

---

## 🧠 How the AI Chat Works

Polly's chat uses **Apple's FoundationModels** framework to run a language model entirely on-device. The model is given a system prompt that defines Polly's personality and injects a knowledge base about:

- Data pollution and digital carbon footprints
- Model collapse and AI-generated data risks
- Data poisoning and adversarial attacks
- The environmental impact of data centers

Polly always responds in the language the user writes in, keeps answers short and friendly, and never breaks character.

---

## 📊 Stats & Mood System

Polly has four stats that decay every 5 minutes:

| Stat | Restored by |
|---|---|
| 🍎 Hunger | Hunger mini-game |
| 📚 Education | Completing quizzes |
| 💬 Fun | Chatting with Polly |

Her mood is determined by the lowest stat:

| Mood | Condition |
|---|---|
| 😊 Happy | All stats above 60% |
| 🍎 Hungry | Hunger is lowest |
| 😴 Tired | Energy is lowest |
| 🤔 Curious | Education is lowest |
| 😐 Bored | Fun is lowest |
| 💬 Chatting | Chat is open |

---

## 📄 License

Distributed under the **MIT** License. See [`LICENSE`](LICENSE) for details.

---

## 🤝 Contributing

Pull requests and issues are welcome! For major changes, please open an issue first to discuss what you'd like to change.

---

*Polly — because every byte you ignore has a cost.* 🌍
