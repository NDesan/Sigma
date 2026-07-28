import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/avatar_config.dart';
import '../services/avatar_service.dart';
import '../widgets/avatar_widget.dart';

class AvatarCreatorScreen extends StatelessWidget {
  const AvatarCreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarService = context.watch<AvatarService>();
    final config = avatarService.config;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalise ton coach'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: AvatarWidget(config: config, size: 170),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: 'Peau',
                  child: _ColorRow(
                    colors: AvatarConfig.skinToneSwatches,
                    selected: config.skinTone,
                    onSelect: (c) => avatarService
                        .update((cfg) => cfg.skinTone = c),
                  ),
                ),
                _Section(
                  title: 'Coiffure',
                  child: _StyleRow<HairStyle>(
                    values: HairStyle.values,
                    selected: config.hairStyle,
                    labelBuilder: _hairStyleLabel,
                    onSelect: (v) =>
                        avatarService.update((cfg) => cfg.hairStyle = v),
                  ),
                ),
                _Section(
                  title: 'Couleur de cheveux',
                  child: _ColorRow(
                    colors: AvatarConfig.hairColorSwatches,
                    selected: config.hairColor,
                    onSelect: (c) =>
                        avatarService.update((cfg) => cfg.hairColor = c),
                  ),
                ),
                _Section(
                  title: 'Yeux',
                  child: _StyleRow<EyeStyle>(
                    values: EyeStyle.values,
                    selected: config.eyeStyle,
                    labelBuilder: _eyeStyleLabel,
                    onSelect: (v) =>
                        avatarService.update((cfg) => cfg.eyeStyle = v),
                  ),
                ),
                _Section(
                  title: 'Couleur des yeux',
                  child: _ColorRow(
                    colors: AvatarConfig.eyeColorSwatches,
                    selected: config.eyeColor,
                    onSelect: (c) =>
                        avatarService.update((cfg) => cfg.eyeColor = c),
                  ),
                ),
                _Section(
                  title: 'Bouche',
                  child: _StyleRow<MouthStyle>(
                    values: MouthStyle.values,
                    selected: config.mouthStyle,
                    labelBuilder: _mouthStyleLabel,
                    onSelect: (v) =>
                        avatarService.update((cfg) => cfg.mouthStyle = v),
                  ),
                ),
                _Section(
                  title: 'Accessoire',
                  child: _StyleRow<Accessory>(
                    values: Accessory.values,
                    selected: config.accessory,
                    labelBuilder: _accessoryLabel,
                    onSelect: (v) =>
                        avatarService.update((cfg) => cfg.accessory = v),
                  ),
                ),
                _Section(
                  title: 'Couleur de tenue',
                  child: _ColorRow(
                    colors: AvatarConfig.outfitSwatches,
                    selected: config.outfitColor,
                    onSelect: (c) =>
                        avatarService.update((cfg) => cfg.outfitColor = c),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _hairStyleLabel(HairStyle s) => switch (s) {
        HairStyle.bald => 'Chauve',
        HairStyle.short => 'Court',
        HairStyle.long => 'Long',
        HairStyle.spiky => 'Piquant',
        HairStyle.curly => 'Bouclé',
        HairStyle.cap => 'Casquette',
      };

  String _eyeStyleLabel(EyeStyle s) => switch (s) {
        EyeStyle.round => 'Ronds',
        EyeStyle.almond => 'Amande',
        EyeStyle.big => 'Grands',
        EyeStyle.sleepyLids => 'Mi-clos',
      };

  String _mouthStyleLabel(MouthStyle s) => switch (s) {
        MouthStyle.smile => 'Sourire',
        MouthStyle.grin => 'Grand sourire',
        MouthStyle.small => 'Discret',
        MouthStyle.neutral => 'Neutre',
      };

  String _accessoryLabel(Accessory a) => switch (a) {
        Accessory.none => 'Aucun',
        Accessory.glasses => 'Lunettes',
        Accessory.sunglasses => 'Lunettes de soleil',
        Accessory.headband => 'Bandeau',
      };
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelect;

  const _ColorRow({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((c) {
        final isSelected = c.value == selected.value;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black12,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _StyleRow<T> extends StatelessWidget {
  final List<T> values;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onSelect;

  const _StyleRow({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final isSelected = v == selected;
        return ChoiceChip(
          label: Text(labelBuilder(v)),
          selected: isSelected,
          onSelected: (_) => onSelect(v),
        );
      }).toList(),
    );
  }
}
