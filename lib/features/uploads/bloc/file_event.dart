part of 'file_bloc.dart';

sealed class FileEvent extends Equatable {
  const FileEvent();

  @override
  List<Object> get props => [];
}

class FetchFilesEvent extends FileEvent {}

class UploadImageEvent extends FileEvent {
  final File file;
  UploadImageEvent(this.file);
}

class UploadAudioEvent extends FileEvent {
  final File file;
  UploadAudioEvent(this.file);
}

class _ProgressEvent extends FileEvent {
  final double progress;
  _ProgressEvent(this.progress);
}
