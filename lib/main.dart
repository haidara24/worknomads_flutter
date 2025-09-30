import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:worknomads_flutter/core/api/api_client.dart';
import 'package:worknomads_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:worknomads_flutter/features/auth/data/auth_repository.dart';
import 'package:worknomads_flutter/features/common/control_view.dart';
import 'package:worknomads_flutter/features/uploads/bloc/file_bloc.dart';
import 'package:worknomads_flutter/features/uploads/data/file_api.dart';
import 'package:worknomads_flutter/features/uploads/data/file_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final authApiClient = ApiClient(
    baseUrl: const String.fromEnvironment(
      'AUTH_BASE_URL',
      defaultValue: 'http://10.0.2.2:8000',
    ),
  );

  final fileApiClient = ApiClient(
    baseUrl: const String.fromEnvironment(
      'AUTH_BASE_URL',
      defaultValue: 'http://10.0.2.2:8001',
    ),
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(apiClient: authApiClient),
        ),
        RepositoryProvider(
          create: (context) =>
              FileRepository(api: FileApi(client: fileApiClient)),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => FileBloc(
              fileRepository: RepositoryProvider.of<FileRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'WorkNomads',
          theme: ThemeData(primarySwatch: Colors.deepOrange),
          debugShowCheckedModeBanner: false,
          home: const ControlView(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? Container(),
            );
          },
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
