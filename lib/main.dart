import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'views/login_view.dart';
import 'views/evidence_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Módulo JWT - Evidencia',
            theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
            routes: {
              '/login': (_) => const LoginView(),
              '/evidence': (_) => const EvidenceView(),
            },
            home: !_ensureInit(auth)
                ? const _Splash()
                : (auth.status == AuthStatus.authenticated
                    ? const EvidenceView()
                    : const LoginView()),
          );
        },
      ),
    );
  }

  bool _ensureInit(AuthProvider auth) => auth.initialized;
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}