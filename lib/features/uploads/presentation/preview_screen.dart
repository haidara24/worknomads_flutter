import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:worknomads_flutter/features/uploads/domain/media_file.dart';

class PreviewScreen extends StatefulWidget {
  final UploadedFileModel file;
  const PreviewScreen({super.key, required this.file});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.file.fileType == "audio") {
      _audioPlayer = AudioPlayer();
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_audioPlayer == null) return;
    if (_isPlaying) {
      await _audioPlayer!.pause();
    } else {
      await _audioPlayer!.play(UrlSource(widget.file.fileUrl));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.file.filename)),
      body: Center(
        child: widget.file.fileType == "image"
            ? Image.network(widget.file.fileUrl)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.audiotrack, size: 80),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _toggleAudio,
                    child: Text(_isPlaying ? "Pause" : "Play"),
                  ),
                ],
              ),
      ),
    );
  }
}
