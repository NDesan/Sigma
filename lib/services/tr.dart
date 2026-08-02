import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'translation_service.dart';

extension Tr on BuildContext {
  String tr(String key, [List<String>? args]) {
    return watch<TranslationService>().tr(key, args);
  }
}
