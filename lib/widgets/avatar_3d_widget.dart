import 'package:flutter/material.dart';
import 'package:model_viewer_pro/model_viewer_pro.dart';
import '../models/avatar_config.dart';

/// Renders the avatar as a 3D model using [ModelViewerProViewer].
///
/// Maps [AvatarConfig] properties to mesh visibility and color operations
/// at runtime. All meshes should be present in a single .glb file
/// (see [Avatar3DMeshConfig] for naming conventions).
class Avatar3DWidget extends StatefulWidget {
  final AvatarConfig config;
  final AvatarMood mood;
  final double size;
  final bool animate;

  const Avatar3DWidget({
    super.key,
    required this.config,
    this.mood = AvatarMood.neutral,
    this.size = 140,
    this.animate = true,
  });

  @override
  State<Avatar3DWidget> createState() => _Avatar3DWidgetState();
}

class _Avatar3DWidgetState extends State<Avatar3DWidget> {
  final _controller = ModelViewerProController();
  bool _loaded = false;

  void _onLoad(List<String> meshes) {
    _loaded = true;
    debugPrint('Avatar3D: loaded meshes — $meshes');
    _applyAll();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(Avatar3DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_configChanged(oldWidget)) {
      _applyAll();
    } else if (widget.mood != oldWidget.mood) {
      _applyMood();
    }
  }

  bool _configChanged(Avatar3DWidget old) {
    final c = widget.config;
    final o = old.config;
    return c.skinTone != o.skinTone ||
        c.hairStyle != o.hairStyle ||
        c.hairColor != o.hairColor ||
        c.eyeStyle != o.eyeStyle ||
        c.eyeColor != o.eyeColor ||
        c.mouthStyle != o.mouthStyle ||
        c.accessory != o.accessory ||
        c.outfitColor != o.outfitColor;
  }

  Future<void> _applyAll() async {
    if (!_loaded) return;
    final c = widget.config;
    final mc = c.meshConfig;

    await _controller.setTextureColor(mc.skinMesh, _colorToHex(c.skinTone));

    await _applyExclusiveGroup(
      mc.hairStyleMeshes.values.where((n) => n.isNotEmpty).toList(),
      mc.hairStyleMeshes[c.hairStyle] ?? '',
    );
    await _controller.setTextureColor(mc.hairMesh, _colorToHex(c.hairColor));

    await _applyExclusiveGroup(
      mc.eyeStyleMeshes.values.where((n) => n.isNotEmpty).toList(),
      mc.eyeStyleMeshes[c.eyeStyle] ?? '',
    );
    await _applyExclusiveGroup(
      mc.mouthStyleMeshes.values.where((n) => n.isNotEmpty).toList(),
      mc.mouthStyleMeshes[c.mouthStyle] ?? '',
    );
    await _applyExclusiveGroup(
      mc.accessoryMeshes.values.where((n) => n.isNotEmpty).toList(),
      mc.accessoryMeshes[c.accessory] ?? '',
    );

    await _controller.setTextureColor(mc.outfitMesh, _colorToHex(c.outfitColor));

    await _applyMood();
  }

  Future<void> _applyExclusiveGroup(List<String> allMeshes, String selected) async {
    if (allMeshes.isEmpty) return;
    if (selected.isEmpty) {
      for (final m in allMeshes) {
        await _controller.setVisibility(m, false);
      }
    } else {
      await _controller.setExclusiveMesh(allMeshes, selected);
    }
  }

  Future<void> _applyMood() async {
    if (!_loaded) return;
    if (widget.mood == AvatarMood.sleepy) {
      await _controller.pauseAnimation();
    } else {
      await _controller.playAnimation();
    }
  }

  String _colorToHex(Color c) {
    return '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  List<String> _visibleMeshes() {
    final mc = widget.config.meshConfig;
    final meshes = <String>[
      mc.skinMesh,
      mc.hairMesh,
      mc.outfitMesh,
    ];
    final hair = mc.hairStyleMeshes[widget.config.hairStyle] ?? '';
    if (hair.isNotEmpty) meshes.add(hair);
    final eye = mc.eyeStyleMeshes[widget.config.eyeStyle] ?? '';
    if (eye.isNotEmpty) meshes.add(eye);
    final mouth = mc.mouthStyleMeshes[widget.config.mouthStyle] ?? '';
    if (mouth.isNotEmpty) meshes.add(mouth);
    final acc = mc.accessoryMeshes[widget.config.accessory] ?? '';
    if (acc.isNotEmpty) meshes.add(acc);
    return meshes;
  }

  @override
  Widget build(BuildContext context) {
    final mc = widget.config.meshConfig;

    return SizedBox(
      width: widget.size,
      height: widget.size * 1.15,
      child: ModelViewerProViewer(
        src: mc.modelSrc,
        controller: _controller,
        cameraControls: true,
        disablePan: true,
        cameraOrbit: '0deg 55deg 2m',
        cameraTarget: '0m 0.5m 0m',
        autoRotate: widget.animate,
        autoPlay: widget.animate,
        backgroundColor: Colors.transparent,
        onLoad: _onLoad,
        loading: Loading.eager,
        reveal: Reveal.auto,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
