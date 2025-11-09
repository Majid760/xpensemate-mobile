# xpensemate 💰

**xpensemate** is a modern, feature-rich expense tracking application built with Flutter. It helps users manage their personal finances by providing intuitive tools for tracking expenses, setting budgets, and analyzing spending patterns.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)

<p align="center">
  <img src="assets/images/logo.png" alt="xpensemate Logo" width="200">
</p>

## 🌟 Key Features

### 🔐 Authentication
- Secure user registration and login
- Email/password authentication
- Social login (Google, Apple)
- Email verification flow
- Password recovery
dpcrop enc
### 💳 Expense Management
- Add, edit, and delete expenses with detailed information
- Categorize expenses for better organization
- Attach images to expense entries
- Search and filter expenses by date, category, or amount

### 📊 Budget Tracking
- Create and manage budget goals
- Set spending limits for different categories
- Visualize budget progress with intuitive charts
- Receive alerts when approaching budget limits

### 📈 Financial Insights
- Weekly, monthly, and yearly spending analysis
- Interactive charts and graphs
- Spending pattern recognition
- Financial overview dashboard

### 🌍 Localization
- Multi-language support (English, Arabic, and more)
- RTL (Right-to-Left) language support
- Currency localization

### 🎨 Modern UI/UX
- Clean, intuitive Material Design 3 interface
- Light and dark theme support
- Smooth animations and transitions
- Responsive design for all device sizes

## 🏗️ Architecture

xpensemate follows a **Clean Architecture** pattern with a feature-driven approach:

```
lib/
├── core/                    # Shared infrastructure
│   ├── error/              # Error handling
│   ├── localization/       # Multi-language support
│   ├── network/            # Network clients
│   ├── route/              # Navigation
│   ├── service/            # Shared services
│   ├── theme/              # UI theming
│   ├── usecase/            # Business logic abstractions
│   ├── utils/              # Helper functions
│   └── widget/             # Reusable UI components
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── budget/             # Budget management
│   ├── dashboard/          # Main dashboard
│   ├── expense/            # Expense tracking
│   ├── home/               # Home navigation
│   └── profile/            # User profile
└── main.dart               # App entry point
```

### Key Architectural Patterns:
- **BLoC/Cubit** for state management
- **Dependency Injection** using GetIt
- **Repository Pattern** for data abstraction
- **Clean Architecture** principles
- **Feature-first** organization

## 🛠️ Technologies & Dependencies

### Core Technologies
- **Flutter** - Cross-platform UI toolkit
- **Dart** - Programming language
- **Firebase** - Backend services (Auth, Firestore, Storage)
- **GoRouter** - Navigation and routing

### Key Packages
- **flutter_bloc** - State management
- **get_it** - Dependency injection
- **dio** - HTTP client
- **firebase_auth** - Authentication
- **cloud_firestore** - Database
- **flutter_secure_storage** - Secure data storage
- **fl_chart** - Charting and data visualization
- **intl** - Internationalization
- **shared_preferences** - Local data persistence
- **image_picker** - Media handling

## 📱 Screenshots

<p align="center">
  <img src="assets/images/dashboard_light.png" alt="Dashboard Light" width="200">
  <img src="assets/images/dashboard_dark.png" alt="Dashboard Dark" width="200">
  <img src="assets/images/expense_list.png" alt="Expense List" width="200">
  <img src="assets/images/budget_creation.png" alt="Budget Creation" width="200">
</p>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.5.0 or higher)
- Dart SDK (3.5.0 or higher)
- Android Studio or VS Code
- Firebase account

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/xpensemate.git
   cd xpensemate
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase:**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android and iOS apps to your Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🧪 Testing

The project includes unit and widget tests:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## 📦 Build & Deployment

### Android
```bash
# Build APK
flutter build apk

# Build App Bundle
flutter build appbundle
```

### iOS
```bash
# Build for iOS
flutter build ios
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure your code follows the project's coding standards and includes appropriate tests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to all the open-source packages that made this project possible
- Inspired by modern personal finance management apps
- Built with ❤️ using Flutter

## 📞 Contact

For support or inquiries, please open an issue on GitHub or contact the development team.

---

<p align="center">
  Made with 🚀 using Flutter and Firebase
</p>
</parameter_content>