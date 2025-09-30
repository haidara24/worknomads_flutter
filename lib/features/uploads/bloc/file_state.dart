part of 'file_bloc.dart';

sealed class FileState extends Equatable {
  const FileState();

  @override
  List<Object> get props => [];
}

class FileInitial extends FileState {}

class FileLoading extends FileState {}

class FileUploadInProgress extends FileState {
  final double progress; // 0..1
  FileUploadInProgress(this.progress);
}

class FileLoaded extends FileState {
  final List<UploadedFileModel> files;
  FileLoaded(this.files);
}

class FileFailure extends FileState {
  final String message;
  FileFailure(this.message);
}
