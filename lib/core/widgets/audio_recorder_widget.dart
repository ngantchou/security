import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class AudioRecorderWidget extends StatefulWidget {
  final Function(String audioPath) onRecordingComplete;
  final int maxDurationSeconds;

  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.maxDurationSeconds = 120, // 2 minutes default
  });

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required for recording'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Check if device has microphone
      if (!await _audioRecorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No microphone permission'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
        return;
      }

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: '${DateTime.now().millisecondsSinceEpoch}.m4a',
      );

      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
        });

        // Auto-stop at max duration
        if (_recordDuration >= widget.maxDurationSeconds) {
          _stopRecording();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _pauseRecording() async {
    try {
      await _audioRecorder.pause();
      _timer?.cancel();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pause recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _resumeRecording() async {
    try {
      await _audioRecorder.resume();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
        });

        if (_recordDuration >= widget.maxDurationSeconds) {
          _stopRecording();
        }
      });
      setState(() {
        _isPaused = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resume recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _audioPath = path;
      });

      if (path != null) {
        widget.onRecordingComplete(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _recordDuration = 0;
        _audioPath = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel recording: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_audioPath != null) {
      // Recording complete
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.accentColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.accentColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Audio recorded',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Duration: ${_formatDuration(_recordDuration)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _audioPath = null;
                  _recordDuration = 0;
                });
              },
              icon: const Icon(Icons.delete_outline),
              color: AppTheme.errorColor,
              tooltip: 'Delete recording',
            ),
          ],
        ),
      );
    }

    if (!_isRecording) {
      // Start recording button
      return ElevatedButton.icon(
        onPressed: _startRecording,
        icon: const Icon(Icons.mic),
        label: const Text('Record Audio'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      );
    }

    // Recording in progress
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Recording indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _isPaused ? AppTheme.warningColor : AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPaused ? 'Recording paused' : 'Recording...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDuration(_recordDuration),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isPaused
                            ? AppTheme.warningColor
                            : AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDuration(widget.maxDurationSeconds),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          LinearProgressIndicator(
            value: _recordDuration / widget.maxDurationSeconds,
            backgroundColor: AppTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation(
              _isPaused ? AppTheme.warningColor : AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: 16),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cancel
              OutlinedButton.icon(
                onPressed: _cancelRecording,
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
              ),
              // Pause/Resume
              if (!_isPaused)
                ElevatedButton.icon(
                  onPressed: _pauseRecording,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningColor,
                    foregroundColor: Colors.white,
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _resumeRecording,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Resume'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              // Stop
              ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('Done'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
