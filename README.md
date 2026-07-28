# Mon Coach — App Flutter

Mini coach avatar façon Duolingo : points, streaks, niveaux, notifications
de motivation, et chat avec un coach (IA branchable).

## 🚀 Démarrage rapide

Prérequis : [Flutter SDK](https://docs.flutter.dev/get-started/install),
Python 3.10+, et un émulateur Android (ou un téléphone en mode debug USB).

### 1. Lancer l'app Flutter

```bash
flutter pub get
flutter run
```

La première fois, Android Studio / Flutter va générer automatiquement un
fichier `android/local.properties` avec les chemins vers ton SDK Android et
Flutter.

### 2. Lancer le backend IA (serveur Mistral)

Le dossier `AI/` contient un serveur Python FastAPI qui proxyie les appels
vers l'API Mistral AI. Sans lui, le coach répond en local sans IA.

**Installation des dépendances** (une seule fois) :
```bash
cd AI
python -m venv venv
```

Active l'environnement virtuel :
- **Sur Windows (cmd)** : `venv\Scripts\activate`
- **Sur Windows (PowerShell)** : `venv\Scripts\Activate.ps1`
- **Sur macOS / Linux** : `source venv/bin/activate`

Puis :
```
pip install -r requirements.txt
```

Configure ta clé API Mistral dans `AI/.env` :
```
MISTRAL_API_KEY=ta_cle_ici
```

**Démarrage du serveur** (à chaque fois que tu veux utiliser l'IA) :
```bash
cd AI
# active d'abord le venv (voir commande ci-dessus selon ton OS)
python server.py
```

Le serveur tourne sur `http://localhost:8000`. Laisse ce terminal ouvert
à côté de l'app Flutter.

### ⚠️ URL du backend selon ta plateforme

L'URL est configurée dans `lib/main.dart` :

```dart
final aiCoachService = AiCoachService(
  useRemoteApi: true,
  apiUrl: 'http://10.0.2.2:8000/coach', // Android emulator
  // apiUrl: 'http://localhost:8000/coach', // iOS simulator / web
);
```

- **Android emulateur** : `10.0.2.2:8000` (inchangé)
- **iOS simulateur** : `localhost:8000`
- **Vrai téléphone** : remplace par l'IP locale de ton PC (ex: `192.168.1.42:8000`)

### Générer un APK ou un App Bundle

```bash
flutter build apk --release        # APK unique, pratique pour tester
flutter build appbundle --release  # format requis pour le Play Store
```

### ⚠️ Avant de publier sur le Play Store

1. Change `applicationId` dans `android/app/build.gradle` (actuellement
   `com.example.coach_app`, à remplacer par ton propre identifiant,
   ex: `com.tonstudio.moncoach`) — et renomme le dossier
   `android/app/src/main/kotlin/com/example/coach_app/` en conséquence.
2. Configure une vraie clé de signature (`signingConfigs`) au lieu de la
   config debug utilisée par défaut dans `buildTypes.release`.
3. Remplace les icônes générées automatiquement (`mipmap-*/ic_launcher.png`)
   par ton propre design — idéalement via
   [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons).

### Permissions déjà configurées dans `AndroidManifest.xml`
- `POST_NOTIFICATIONS` (Android 13+, demandée au runtime automatiquement)
- `SCHEDULE_EXACT_ALARM` pour les rappels quotidiens à heure fixe
- `RECEIVE_BOOT_COMPLETED` pour que les rappels survivent à un redémarrage
- `INTERNET` pour le chat avec le coach (si tu branches une API distante)

Sur Android 12+, si l'utilisateur refuse ou révoque les alarmes exactes,
le système peut demander de l'activer manuellement dans
**Paramètres > Apps > Mon Coach > Alarmes et rappels**.

## 📁 Structure du projet

```
lib/
  main.dart                 # point d'entrée, thème, Provider
  models/
    user_profile.dart       # points, niveau, streak, badges
    coach_message.dart      # message du chat
    workout.dart            # modèles d'entraînement (sets, exercices)
  services/
    points_service.dart     # logique de gamification + persistance locale
    ai_coach_service.dart   # génération des réponses du coach (local + API)
    avatar_service.dart     # persistance de la config avatar
    notification_service.dart # notifications locales programmées
    workout_service.dart    # persistance et comparaison des entraînements
  widgets/
    avatar_widget.dart      # avatar animé avec humeurs
    mii_avatar_painter.dart # CustomPainter pour l'avatar Mii
    points_bar.dart         # barre streak / niveau / points
    speech_bubble.dart      # bulle de dialogue animée
    coach_reaction_dialog.dart # dialogue d'évaluation post-workout
  screens/
    home_screen.dart        # nav principale (4 onglets)
    chat_screen.dart        # conversation avec le coach
    progress_screen.dart    # stats et badges
    profile_screen.dart     # nom, objectif
    workout_log_screen.dart # logger ses séances d'entraînement
AI/
  server.py                 # serveur FastAPI (proxy Mistral AI)
  requirements.txt          # dépendances Python
  .env                      # clé API Mistral (ignoré par git)
```

## 🧠 Backend IA

Le dossier `AI/` contient un serveur Python FastAPI qui proxyie les appels
vers Mistral AI. La clé API se trouve dans `AI/.env` (ignoré par git).

Pour lancer le serveur :
```bash
cd AI
source venv/bin/activate
python server.py
```

L'app Flutter est déjà configurée pour l'utiliser via `AiCoachService` dans
`lib/main.dart`. Si le serveur est indisponible, le coach répond en mode
local (réponses basées sur des règles).

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
