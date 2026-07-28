import 'package:flutter/material.dart';

enum HairStyle { bald, short, long, spiky, curly, cap }

enum EyeStyle { round, almond, big, sleepyLids }

enum MouthStyle { smile, grin, small, neutral }

enum Accessory { none, glasses, sunglasses, headband }

/// Toute la configuration visuelle de l'avatar du coach.
/// Persisté en local, façon création de Mii sur Wii.
class AvatarConfig {
  Color skinTone;
  HairStyle hairStyle;
  Color hairColor;
  EyeStyle eyeStyle;
  Color eyeColor;
  MouthStyle mouthStyle;
  Accessory accessory;
  Color outfitColor;

  AvatarConfig({
    Color? skinTone,
    this.hairStyle = HairStyle.short,
    Color? hairColor,
    this.eyeStyle = EyeStyle.round,
    Color? eyeColor,
    this.mouthStyle = MouthStyle.smile,
    this.accessory = Accessory.none,
    Color? outfitColor,
  })  : skinTone = skinTone ?? skinToneSwatches[1],
        hairColor = hairColor ?? hairColorSwatches[0],
        eyeColor = eyeColor ?? const Color(0xFF3E2723),
        outfitColor = outfitColor ?? outfitSwatches[0];

  AvatarConfig copy() => AvatarConfig(
        skinTone: skinTone,
        hairStyle: hairStyle,
        hairColor: hairColor,
        eyeStyle: eyeStyle,
        eyeColor: eyeColor,
        mouthStyle: mouthStyle,
        accessory: accessory,
        outfitColor: outfitColor,
      );

  Map<String, dynamic> toJson() => {
        'skinTone': skinTone.value,
        'hairStyle': hairStyle.index,
        'hairColor': hairColor.value,
        'eyeStyle': eyeStyle.index,
        'eyeColor': eyeColor.value,
        'mouthStyle': mouthStyle.index,
        'accessory': accessory.index,
        'outfitColor': outfitColor.value,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
        skinTone: Color(json['skinTone'] ?? skinToneSwatches[1].value),
        hairStyle: HairStyle.values[json['hairStyle'] ?? 1],
        hairColor: Color(json['hairColor'] ?? hairColorSwatches[0].value),
        eyeStyle: EyeStyle.values[json['eyeStyle'] ?? 0],
        eyeColor: Color(json['eyeColor'] ?? 0xFF3E2723),
        mouthStyle: MouthStyle.values[json['mouthStyle'] ?? 0],
        accessory: Accessory.values[json['accessory'] ?? 0],
        outfitColor: Color(json['outfitColor'] ?? outfitSwatches[0].value),
      );

  // --- Palettes disponibles dans le créateur d'avatar ---

  static const List<Color> skinToneSwatches = [
    Color(0xFFFFE0BD),
    Color(0xFFF1C27D),
    Color(0xFFE0AC69),
    Color(0xFFC68642),
    Color(0xFF8D5524),
    Color(0xFF5C3A21),
  ];

  static const List<Color> hairColorSwatches = [
    Color(0xFF2C1B10), // noir
    Color(0xFF4E342E), // châtain
    Color(0xFF8D6E63), // brun clair
    Color(0xFFD7A86E), // blond
    Color(0xFFE0E0E0), // gris/argent
    Color(0xFFB71C1C), // roux
    Color(0xFF7C4DFF), // violet fun
    Color(0xFF29B6F6), // bleu fun
  ];

  static const List<Color> outfitSwatches = [
    Color(0xFF7C4DFF),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
    Color(0xFF616161),
  ];

  static const List<Color> eyeColorSwatches = [
    Color(0xFF3E2723),
    Color(0xFF1565C0),
    Color(0xFF2E7D32),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
  ];
}
