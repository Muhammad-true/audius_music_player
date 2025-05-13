# audius_music_player

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



📦 lib/
│
├── main.dart                            🟢 Стартовая точка
│
├── core/
│   ├── di/                              📦 get_it и инициализация зависимостей
│   └── services/
│       └── storage_service.dart         💾 Работа с SharedPreferences и локальными файлами
│
├── data/
│   ├── models/
│   │   └── track_model.dart             🎵 Модель трека
│   ├── repositories/
│   │   ├── audius_repository.dart       🌐 Онлайн-репозиторий
│   │   └── dummy_audius_repository.dart 📴 Оффлайн-репозиторий (работает через StorageService)
│
├── features/
│   ├── player/
│   │   ├── bloc/
│   │   │   └── player_bloc.dart         ▶️ Управление воспроизведением
│   │   └── view/
│   │       └── player_screen.dart       🎧 Полный плеер
│   │
│   ├── home/
│   │   ├── bloc/
│   │   │   └── home_bloc.dart           🧠 Загрузка топовых/загруженных треков
│   │   └── view/
│   │       └── home_screen.dart         🏠 Главная (таб)
│   │
│   ├── search/
│   │   ├── bloc/
│   │   │   └── search_bloc.dart         🔍 Поиск
│   │   └── view/
│   │       └── search_screen.dart       🧾 Экран поиска
│
│   └── favorites/
│       ├── bloc/
│       │   └── favorites_bloc.dart      ❤️ Избранное
│       └── view/
│           └── favorites_screen.dart
│
├── router/
│   └── app_router.dart                  🚦 AutoRoute маршруты
│
└── widgets/
    └── mini_player.dart                🔻 Мини-плеер внизу

