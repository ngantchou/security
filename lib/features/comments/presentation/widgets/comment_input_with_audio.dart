import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/widgets/audio_recorder_widget.dart';
import '../../../../core/services/storage_service.dart';

enum InputMode { text, audio }

class CommentInputWithAudio extends StatefulWidget {
  final Function(String?, String?) onSubmit; // textContent, audioUrl
  final String? replyToName;
  final VoidCallback? onCancelReply;
  final String userId;
  final String alertId;
  final StorageService storageService;

  const CommentInputWithAudio({
    super.key,
    required this.onSubmit,
    required this.userId,
    required this.alertId,
    required this.storageService,
    this.replyToName,
    this.onCancelReply,
  });

  @override
  State<CommentInputWithAudio> createState() => _CommentInputWithAudioState();
}

class _CommentInputWithAudioState extends State<CommentInputWithAudio> {
  final TextEditingController _controller = TextEditingController();
  InputMode _mode = InputMode.text;
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      widget.onSubmit(text, null);
      _controller.clear();
      if (widget.onCancelReply != null) {
        widget.onCancelReply!();
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _submitAudio(String audioPath) async {
    setState(() {
      _isSending = true;
    });

    try {
      // Upload audio to Firebase Storage
      final audioUrl = await widget.storageService.uploadAudioFile(
        filePath: audioPath,
        userId: widget.userId,
        alertId: widget.alertId,
      );

      // Delete local file
      await File(audioPath).delete();

      widget.onSubmit(null, audioUrl);

      if (widget.onCancelReply != null) {
        widget.onCancelReply!();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Reply indicator
        if (widget.replyToName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[200],
            child: Row(
              children: [
                Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Replying to ${widget.replyToName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: widget.onCancelReply,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Mode toggle and input
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              // Mode toggle buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.text_fields, size: 16),
                        SizedBox(width: 4),
                        Text('Text'),
                      ],
                    ),
                    selected: _mode == InputMode.text,
                    onSelected: (selected) {
                      if (selected && !_isSending) {
                        setState(() => _mode = InputMode.text);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic, size: 16),
                        SizedBox(width: 4),
                        Text('Audio'),
                      ],
                    ),
                    selected: _mode == InputMode.audio,
                    onSelected: (selected) {
                      if (selected && !_isSending) {
                        setState(() => _mode = InputMode.audio);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Input area
              if (_mode == InputMode.text)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isSending,
                        decoration: InputDecoration(
                          hintText: widget.replyToName != null
                              ? 'Write a reply...'
                              : 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitText(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      onPressed: _isSending ? null : _submitText,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                )
              else
                _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('Uploading audio...'),
                          ],
                        ),
                      )
                    : AudioRecorderWidget(
                        onRecordingComplete: _submitAudio,
                      ),
            ],
          ),
        ),
      ],
    );
  }
}
