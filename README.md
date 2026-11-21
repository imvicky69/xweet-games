# Xweet Games 🎮

Modern, clean, and extensible Flutter mobile gaming platform built exclusively for **Android** (`in.xweet.games`).

---

## 📌 Project Overview

- **App Name**: Xweet Games
- **Package Name (Application ID)**: `in.xweet.games`
- **Target Platform**: Android Only (`--platforms android`)
- **Theme**: Cyberpunk / Dark Neon Game UI (`GoogleFonts.orbitron` + `rajdhani`)
- **Persistence**: High score tracking & game settings via `shared_preferences`
- **Audio / Haptics**: Built-in haptic feedback & audio cue pipeline

---

## 📂 Architecture & Directory Structure

```text
xweet_games/
├── android/                   # Android configuration (namespace & applicationId: in.xweet.games)
│   └── app/src/main/kotlin/in/xweet/games/MainActivity.kt
├── assets/                    # Assets for audio, icons, and textures
│   ├── audio/
│   ├── icons/
│   └── images/
├── lib/
│   ├── main.dart              # App bootstrap, storage & orientation initialization
│   ├── core/
│   │   ├── constants/         # App constants, game color palette
│   │   ├── services/          # StorageService, AudioService & Haptics
│   │   └── theme/             # Custom dark gaming theme & typography
│   ├── models/
│   │   └── game_model.dart    # Game metadata & category definitions
│   └── features/
│       ├── hub/               # Main Gaming Launchpad & player dashboard
│       │   ├── screens/       # GameHubScreen
│       │   └── widgets/       # GameCard, PlayerProfileHeader
│       ├── games/             # Game catalog
│       │   ├── reaction_tap/  # Playable mini-game: Cyber Reflex (countdown & speed tap)
│       │   └── game_template/ # Boilerplate screen ready for adding new games
│       └── settings/          # Sound, haptics & high score reset settings
└── test/                      # Unit and widget test suite
```

---

## 🚀 How to Add a New Game

Adding a new game to **Xweet Games** is modular:

1. **Create the game screen/canvas**:
   - Create a new directory under `lib/features/games/your_game_name/screens/`
   - You can copy or reference `lib/features/games/game_template/screens/game_template_screen.dart`
2. **Register the game in the Hub**:
   - Open `lib/features/hub/screens/game_hub_screen.dart`
   - Add your game to the `_games` list:
     ```dart
     GameModel(
       id: 'your_game_id',
       title: 'Your Game Title',
       tagline: 'Short thrilling tagline',
       description: 'Full game description',
       category: GameCategory.arcade,
       icon: Icons.gamepad_rounded,
       accentColor: GameColors.primaryNeon,
       builder: (context) => const YourGameScreen(),
     ),
     ```
3. **Record High Scores**:
   - Use `StorageService.instance.setHighScore('your_game_id', score)` to save records.

---

## 🛠️ Build & Run (Android)

Run debug build on connected Android device or emulator:
```bash
flutter run -d android
```

Build production APK:
```bash
flutter build apk --release
```

Build Google Play App Bundle:
```bash
flutter build appbundle --release
```
