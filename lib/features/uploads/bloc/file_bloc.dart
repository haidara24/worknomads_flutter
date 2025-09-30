import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:worknomads_flutter/features/uploads/data/file_repository.dart';
import 'package:worknomads_flutter/features/uploads/domain/media_file.dart';

part 'file_event.dart';
part 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final FileRepository fileRepository;
  FileBloc({required this.fileRepository}) : super(FileInitial()) {
    on<FetchFilesEvent>((event, emit) async {
      emit(FileLoading());
      try {
        final files = await fileRepository.fetchFiles();
        emit(FileLoaded(files));
      } catch (e) {
        emit(FileFailure(e.toString()));
      }
    });

    on<UploadImageEvent>((event, emit) async {
      try {
        emit(FileUploadInProgress(0));
        await fileRepository.uploadImage(
          event.file,
          onProgress: (sent, total) {
            final p = total > 0 ? sent / total : 0.0;
            add(_ProgressEvent(p));
          },
        );
        add(FetchFilesEvent());
      } catch (e) {
        emit(FileFailure(e.toString()));
      }
    });

    on<UploadAudioEvent>((event, emit) async {
      try {
        emit(FileUploadInProgress(0));
        await fileRepository.uploadAudio(
          event.file,
          onProgress: (sent, total) {
            final p = total > 0 ? sent / total : 0.0;
            add(_ProgressEvent(p));
          },
        );
        add(FetchFilesEvent());
      } catch (e) {
        emit(FileFailure(e.toString()));
      }
    });

    on<_ProgressEvent>((event, emit) async {
      emit(FileUploadInProgress(event.progress));
    });
  }
}
