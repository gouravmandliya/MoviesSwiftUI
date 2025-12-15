# 🎬 Movies iOS App

A modern iOS application that showcases popular movies using The Movie Database (TMDB) API with offline support and clean architecture.

## 📱 Screenshots

iphone
<table>
  <tr>
    <td><img width="250" height="2532" alt="Simulator Screenshot - iPhone 16e - 2025-12-13 at 14 51 53" src="https://github.com/user-attachments/assets/a7b64c31-48a3-4316-94fb-c42cf2deca45" />
</td>
    <td><img width="250" height="2532" alt="Simulator Screenshot - iPhone 16e - 2025-12-13 at 14 52 00" src="https://github.com/user-attachments/assets/a5fbbcb2-dca1-4f8a-8af2-af7e9d61e2f6" />
</td>
  </tr>
  <tr>
    <td align="center"><b>Movie List</b></td>
    <td align="center"><b>Movie Detail</b></td>
  </tr>
</table>
iPad
<table>
  <tr>
    <td><img width="400" height="2360" alt="Simulator Screenshot - iPad Air 11-inch (M3) - 2025-12-13 at 14 50 37" src="https://github.com/user-attachments/assets/4c488802-8188-4c9d-8b12-b29b718400d1" />
</td>
    <td><img width="400" height="2360" alt="Simulator Screenshot - iPad Air 11-inch (M3) - 2025-12-13 at 14 46 09" src="https://github.com/user-attachments/assets/6d780497-7a6d-43b1-845c-33894e3cd6ee" /></td>
  </tr>
  <tr>
    <td align="center"><b>Movie List</b></td>
    <td align="center"><b>Movie Detail</b></td>
  </tr>
</table>

## ✨ Features

- Browse popular movies with infinite scroll
- View detailed movie information
- Offline support with Core Data
- Pull-to-refresh functionality
- Universal app (iPhone & iPad)
- Comprehensive error handling
- 80%+ test coverage

## 🏗️ Architecture

**MVVM + Repository Pattern**

```
Views → ViewModels → Repository → Network/Persistence
```

### Key Patterns

- **MVVM**: Separation of UI and business logic
- **Repository Pattern**: Single source of truth for data
- **Dependency Injection**: Testable, loosely coupled components
- **Protocol-Oriented**: Abstraction through protocols
- **Generic Programming**: Reusable, type-safe code

## 🛠️ Technologies

- **SwiftUI**: Declarative UI framework
- **Async/Await**: Modern concurrency
- **Core Data**: Local persistence
- **Combine**: Reactive data binding
- **URLSession**: Network requests

## 📂 Project Structure

```
MovieBrowser/
├── App/                    # Entry point & DI container
├── Common/                # Shared enums & views
├── Core/
│   ├── Network/           # API client & endpoints
│   ├── Persistence/       # Core Data manager
│   └── TMDBConfig/            # Configuration
├── Features/
│   ├── MovieList/         # List feature
│   └── MovieDetail/       # Detail feature
├── Repositories/          # Data abstraction
└── Tests/                 # Unit tests (40+ cases)
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 15.0+

### Installation

1. Clone the repository
```bash
git clone https://github.com/gouravmandliya/MoviesSwiftUI.git
```

2. Add your TMDB API key in `TMDBConfig.swift`

3. Build and run (`⌘ + R`)

## 🎯 Key Implementations

### Network Layer
- Generic HTTP client with async/await
- Custom error types
- Automatic JSON decoding

### Persistence
- Core Data with async operations
- Offline-first architecture
- Automatic cache fallback

## 🧪 Testing

40+ unit tests covering:
- Initial states
- Success scenarios
- Error handling
- Edge cases

Mock repository pattern enables isolated ViewModel testing.

## 🎓 Demonstrates

**Architecture**: MVVM, Repository, DI, Protocol-Oriented Design  
**iOS Skills**: SwiftUI, Async/Await, Core Data, Combine  
**Best Practices**: Error handling, offline support
**Quality**: Unit testing, 80%+ coverage, clean code


