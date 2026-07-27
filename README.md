# Mon Coach — App Flutter

Mini coach avatar façon Duolingo : points, streaks, niveaux, notifications
de motivation, et chat avec un coach (IA branchable).

## 🚀 Démarrage rapide

Prérequis : [Flutter SDK](https://docs.flutter.dev/get-started/install) installé,
un émulateur Android ou un téléphone en mode debug USB.

```bash
flutter pub get
flutter run
```

Si tu n'as pas encore de projet Android généré (dossier `android/` absent),
lance d'abord :

```bash
flutter create .
```
à la racine de `coach_app` — cela régénère les dossiers `android/`, `ios/`,
etc. sans toucher au code Dart déjà présent dans `lib/`.

## 📁 Structure du projet

```
lib/
  main.dart                 # point d'entrée, thème, Provider
  models/
    user_profile.dart       # points, niveau, streak, badges
    coach_message.dart      # message du chat
  services/
    points_service.dart     # logique de gamification + persistance locale
    ai_coach_service.dart   # génération des réponses du coach (local + API)
    notification_service.dart # notifications locales programmées
  widgets/
    avatar_widget.dart      # avatar animé avec humeurs
    points_bar.dart         # barre streak / niveau / points
  screens/
    home_screen.dart        # nav principale (4 onglets)
    chat_screen.dart        # conversation avec le coach
    progress_screen.dart    # stats et badges
    profile_screen.dart     # nom, objectif
```

## 🧠 Brancher une vraie IA

Le fichier `lib/services/ai_coach_service.dart` fonctionne en mode "local"
par défaut (réponses variées basées sur des règles), donc l'app tourne
sans configuration. Pour brancher une vraie IA :

1. Crée un petit backend (Cloudflare Worker, Vercel function, etc.) qui
   reçoit `{ messages: [...] }` et appelle l'API Claude côté serveur
   (ne mets **jamais** ta clé API directement dans l'app mobile).
2. Dans `main.dart` ou `chat_screen.dart`, instancie le service ainsi :

```dart
final _aiService = AiCoachService(
  useRemoteApi: true,
  apiUrl: 'https://ton-backend.example.com/coach',
);
```

## 🔔 Notifications

Le package `flutter_local_notifications` est déjà configuré pour Android.
Pour Android 13+, l'app demande automatiquement la permission au premier
lancement (via `NotificationService.init()`).

Si tu veux des notifications **poussées depuis un serveur** (et pas
seulement programmées localement), il faudra ajouter Firebase Cloud
Messaging — dis-le moi et je peux l'intégrer.

## 🎨 Avatar

L'avatar est actuellement une forme géométrique animée en pur Flutter
(aucun asset requis, donc ça marche immédiatement). Le package `lottie`
est déjà inclus dans `pubspec.yaml` : dès que tu as un fichier `.json`
d'animation Lottie (ex: depuis LottieFiles ou fait par un designer),
remplace le contenu de `avatar_widget.dart` par un widget `Lottie.asset(...)`.

## 🗺️ Prochaines étapes suggérées

- [ ] Ajouter Firebase Auth + Firestore pour synchroniser les données multi-appareils
- [ ] Notifications push serveur (Firebase Cloud Messaging)
- [ ] Vrai avatar animé (Lottie ou Rive)
- [ ] Système de "quêtes" quotidiennes/hebdomadaires
- [ ] Classement entre amis (leaderboard)
- [ ] Sons/haptics pour les récompenses
