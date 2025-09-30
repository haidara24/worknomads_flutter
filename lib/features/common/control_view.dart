import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:worknomads_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:worknomads_flutter/features/auth/presentation/login_screen.dart';
import 'package:worknomads_flutter/features/common/loading_indicator.dart';
import 'package:worknomads_flutter/features/uploads/presentation/home_screen.dart';

class ControlView extends StatefulWidget {
  const ControlView({Key? key}) : super(key: key);

  @override
  State<ControlView> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  DateTime? lastBackPressTime;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            print(state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            // جلب عدد المحادثات غير المقروءة عند فتح التطبيق

            return const HomeScreen();
          } else if (state is AuthInitial) {
            BlocProvider.of<AuthBloc>(context).add(AppStarted());
            return Scaffold(body: Center(child: LoadingIndicator()));
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
