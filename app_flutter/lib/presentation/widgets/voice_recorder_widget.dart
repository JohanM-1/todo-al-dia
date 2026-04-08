// lib/presentation/widgets/voice_recorder_widget.dart
import 'dart:async';

import 'package:flutter/material.dart';
import '../../services/voice_service.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final ValueChanged<VoiceResult> onVoiceResult;
  final VoidCallback? onError;
  final bool showTextFallback;

  const VoiceRecorderWidget({
    super.key,
    required this.onVoiceResult,
    this.onError,
    this.showTextFallback = true,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget>
    with SingleTickerProviderStateMixin {
  final VoiceService _voiceService = VoiceService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isListening = false;
  bool _isAvailable = false;
  String _currentText = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    unawaited(_initializeVoice());
  }

  Future<void> _initializeVoice() async {
    final available = await _voiceService.initialize();
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    unawaited(_voiceService.stopListening());
    super.dispose();
  }

  Future<void> _toggleListening() async {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    if (_isListening) {
      await _voiceService.stopListening();
      if (mounted) {
        setState(() {
          _isListening = false;
          _pulseController.stop();
        });
      }
    } else {
      setState(() {
        _error = null;
        _currentText = '';
      });

      await _voiceService.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _currentText = text;
            });
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isListening = false;
              _pulseController.stop();
            });
            if (_currentText.isNotEmpty) {
              final result = _voiceService.parseTranscription(_currentText);
              widget.onVoiceResult(result);
            }
          }
        },
        onError: () {
          if (mounted) {
            setState(() {
              _isListening = false;
              _pulseController.stop();
              _error = 'Error al reconocer voz';
            });
            widget.onError?.call();
          }
        },
      );

      if (mounted) {
        setState(() {
          _isListening = true;
        });
        if (!disableAnimations) {
          _pulseController.repeat(reverse: true); // ignore: unawaited_futures
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_isAvailable && !_isListening) {
      return _buildUnavailableState(theme);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.hearing,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  _currentText,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening
                                ? theme.colorScheme.error
                                : theme.colorScheme.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: theme.colorScheme.onPrimary,
                    size: 36,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isListening ? 'Escuchando...' : 'Toca para hablar',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (widget.showTextFallback && !_isListening)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              key: const ValueKey('voice_keyboard_fallback'),
              onPressed: () => widget.onVoiceResult(
                const VoiceResult(
                  transcription: '',
                  intent: VoiceIntent.unknown,
                  slots: VoiceSlot(),
                  confidence: 0,
                ),
              ),
              child: const Text('Usar teclado'),
            ),
          ),
      ],
    );
  }

  Widget _buildUnavailableState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mic_off,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Voz no disponible',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Puedes usar el teclado para registrar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => widget.onVoiceResult(
              const VoiceResult(
                transcription: '',
                intent: VoiceIntent.unknown,
                slots: VoiceSlot(),
                confidence: 0,
              ),
            ),
            icon: const Icon(Icons.keyboard),
            label: const Text('Usar teclado'),
          ),
        ],
      ),
    );
  }
}
