import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:worknomads_flutter/features/uploads/domain/media_file.dart';

import '../bloc/file_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import 'preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FileBloc _fileBloc;

  @override
  void initState() {
    super.initState();
    _fileBloc = context.read<FileBloc>();
    _fileBloc.add(FetchFilesEvent());
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      _fileBloc.add(UploadImageEvent(File(picked.path)));
    }
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      _fileBloc.add(UploadAudioEvent(File(result.files.single.path!)));
    }
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void _openPreview(UploadedFileModel file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(file: file)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: BlocConsumer<FileBloc, FileState>(
        listener: (context, state) {
          if (state is FileFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is FileLoading || state is FileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FileUploadInProgress) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Uploading..."),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: state.progress),
                ],
              ),
            );
          } else if (state is FileLoaded) {
            final files = state.files;
            if (files.isEmpty) {
              return const Center(child: Text("No files uploaded yet."));
            }
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(
                    file.fileType == "image" ? Icons.image : Icons.audiotrack,
                  ),
                  title: Text(file.filename),
                  subtitle: Text(file.ownerUsername),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _openPreview(file),
                );
              },
            );
          } else if (state is FileFailure) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "imageBtn",
            onPressed: _pickImage,
            tooltip: "Upload Image",
            child: const Icon(Icons.image),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "audioBtn",
            onPressed: _pickAudio,
            tooltip: "Upload Audio",
            child: const Icon(Icons.audiotrack),
          ),
        ],
      ),
    );
  }
}
