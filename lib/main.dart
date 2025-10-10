import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/joke.dart';
import 'views/detail_screen.dart';
import 'views/list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          name: 'home',
          path: '/',
          builder: (context, state) => const ListScreen(),
        ),
        GoRoute(
          name: 'detail',
          path: '/detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final extra = state.extra;
            Joke? joke;
            if (extra is Joke) {
              joke = extra;
              print('Main: navegando a Detail - id=$id extra disponible');
            } else {
              print('Main: navegando a Detail - id=$id no hay extra (se hará fetch en detalle si aplica)');
            }
            return DetailScreen(jokeId: id, initialJoke: joke);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Chuck Norris Jokes - Listado y Detalle',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}