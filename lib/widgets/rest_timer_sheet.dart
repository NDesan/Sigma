import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RestTimerSheet extends StatefulWidget {
  final int initialDuration;
  final bool autoStart;

  const RestTimerSheet({
    super.key,
    this.initialDuration = 60,
    this.autoStart = false,
  });

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet> {
  final List<int> _durations = [30, 60, 90, 120, 180];
  late int _selectedDuration;
  int _remaining = 0;
  bool _isRunning = false;
  bool _isComplete = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _selectedDuration = _durations.contains(widget.initialDuration)
        ? widget.initialDuration
        : 60;
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startTimer());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _remaining = _selectedDuration;
      _isRunning = true;
      _isComplete = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        HapticFeedback.heavyImpact();
        if (mounted) {
          setState(() {
            _isRunning = false;
            _isComplete = true;
            _remaining = 0;
          });
        }
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _remaining = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "REST TIMER",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          if (!_isRunning)
            Wrap(
              spacing: 8,
              children: _durations.map((dur) {
                final selected = _selectedDuration == dur;
                return ChoiceChip(
                  label: Text("${dur}s"),
                  selected: selected,
                  selectedColor: Colors.deepPurpleAccent,
                  backgroundColor: Colors.black26,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedDuration = dur);
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _isRunning
                      ? (_remaining / _selectedDuration)
                      : (_isComplete ? 1.0 : 0.0),
                  strokeWidth: 12,
                  backgroundColor: Colors.white10,
                  color: _isComplete ? Colors.green : Colors.deepPurpleAccent,
                ),
                Text(
                  _isComplete
                      ? "DONE!"
                      : (_isRunning ? "${_remaining}s" : "${_selectedDuration}s"),
                  style: TextStyle(
                    color: _isComplete ? Colors.green : Colors.white,
                    fontSize: _isComplete ? 22 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRunning ? Colors.redAccent : Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isRunning ? _stopTimer : _startTimer,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(
                _isRunning
                    ? "STOP"
                    : (_isComplete ? "RESTART" : "START"),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
