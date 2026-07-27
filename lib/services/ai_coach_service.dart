import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

/// Service qui génère les réponses du coach avatar.
///
/// Par défaut il fonctionne en mode "local" (règles + phrases variées),
/// sans clé API, pour que l'app tourne out-of-the-box.
///
/// Pour brancher une vraie IA (ex: Claude), passe `useRemoteApi = true`
/// et renseigne `apiUrl` + `apiKey` (à stocker côté backend idéalement,
/// jamais en clair dans l'app publiée sur le store).
class AiCoachService {
  final bool useRemoteApi;
  final String? apiUrl;
  final String? apiKey;

  AiCoachService({
    this.useRemoteApi = false,
    this.apiUrl,
    this.apiKey,
  });

  final _rand = Random();

  final List<String> _greetings = [
    "Hey {name} 👋 Prêt·e à avancer aujourd'hui ?",
    "Salut {name} ! On continue sur notre lancée ?",
    "Content de te revoir {name} 🙌",
  ];

  final List<String> _encouragements = [
    "Chaque petit pas compte, continue comme ça 💪",
    "Tu es sur une série de {streak} jours, ne casse pas ça !",
    "Je crois en toi. On y va, une étape à la fois.",
    "C'est normal d'avoir des jours plus durs. L'important c'est de revenir.",
    "Ton objectif '{goal}' est à portée de main, on continue.",
  ];

  final List<String> _celebrations = [
    "🎉 Bravo, tu viens de gagner des points !",
    "Niveau supérieur en vue, tu gères !",
    "Tu es en feu 🔥 continue comme ça !",
  ];

  /// Génère une réponse du coach à partir du message utilisateur et du profil.
  Future<String> respond(String userMessage, UserProfile profile) async {
    if (useRemoteApi && apiUrl != null) {
      try {
        return await _respondViaApi(userMessage, profile);
      } catch (_) {
        // fallback silencieux vers le mode local si l'API échoue
        return _localResponse(userMessage, profile);
      }
    }
    return _localResponse(userMessage, profile);
  }

  String greeting(UserProfile profile) {
    final template = _greetings[_rand.nextInt(_greetings.length)];
    return template.replaceAll('{name}', profile.name);
  }

  String _localResponse(String userMessage, UserProfile profile) {
    final msg = userMessage.toLowerCase();

    if (msg.contains('fatigue') || msg.contains('dur') || msg.contains('envie')) {
      return "Je comprends, ces jours existent. Tente juste 5 minutes aujourd'hui, "
          "pas plus. Souvent ça suffit à relancer la machine. Tu veux que je "
          "te propose un mini-défi de 5 min ?";
    }
    if (msg.contains('merci')) {
      return "Avec plaisir ${profile.name} ! C'est moi qui te remercie de rester motivé·e 🙏";
    }
    if (msg.contains('objectif')) {
      return "Ton objectif actuel est : \"${profile.goal}\". On le garde, ou tu "
          "veux qu'on le rende plus précis ensemble ?";
    }

    final template = _encouragements[_rand.nextInt(_encouragements.length)];
    return template
        .replaceAll('{streak}', profile.streakDays.toString())
        .replaceAll('{goal}', profile.goal);
  }

  String randomCelebration() =>
      _celebrations[_rand.nextInt(_celebrations.length)];

  /// Exemple d'appel à une vraie API IA (format générique, à adapter).
  Future<String> _respondViaApi(String userMessage, UserProfile profile) async {
    final response = await http.post(
      Uri.parse(apiUrl!),
      headers: {
        'Content-Type': 'application/json',
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'messages': [
          {
            'role': 'system',
            'content':
                'Tu es un coach personnel bienveillant et motivant, style Duolingo. '
                'Utilisateur: ${profile.name}, objectif: ${profile.goal}, '
                'streak actuel: ${profile.streakDays} jours.'
          },
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? _localResponse(userMessage, profile);
    }
    throw Exception('API error: ${response.statusCode}');
  }
}
