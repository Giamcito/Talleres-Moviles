import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

// Pantalla principal con navegación y paso de parámetros
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuración de rutas con go_router
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/detail/:value',
          builder: (context, state) {
            final value = state.pathParameters['value'] ?? '';
            return DetailScreen(value: value);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Demo Navegación y Ciclo de Vida',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}

// Pantalla principal con botones para navegar usando go, push y replace
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Ciclo de vida: initState
  @override
  void initState() {
    super.initState();
    print('HomeScreen: initState'); // Se ejecuta una vez al crear el widget
    _tabController = TabController(length: 3, vsync: this); // cambiado a 3 tabs
  }

  // Ciclo de vida: didChangeDependencies
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('HomeScreen: didChangeDependencies'); // Se ejecuta cuando cambian dependencias del contexto
  }

  // Ciclo de vida: build
  @override
  Widget build(BuildContext context) {
    print('HomeScreen: build'); // Se ejecuta cada vez que el widget se reconstruye
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Principal'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.cloud_download), text: 'Async'),
            Tab(icon: Icon(Icons.timer), text: 'Timer'),
            Tab(icon: Icon(Icons.memory), text: 'Isolate'),
          ],
        ),
      ),
      drawer: Drawer( // Widget adicional: Drawer
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('Drawer Header', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Configuración'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Nuevo tab: Async demo (Future / async-await)
          AsyncDemo(),
          // Nuevo tab: Timer / Cronómetro
          TimerDemo(),
          // Nuevo tab: Isolate demo (CPU-bound)
          IsolateDemo(),
        ],
      ),
    );
  }

  // Ciclo de vida: dispose
  @override
  void dispose() {
    print('HomeScreen: dispose'); // Se ejecuta al destruir el widget
    _tabController.dispose();
    super.dispose();
  }
}

// Pantalla secundaria que recibe y muestra un parámetro
class DetailScreen extends StatefulWidget {
  final String value;
  const DetailScreen({super.key, required this.value});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Ciclo de vida: initState
  @override
  void initState() {
    super.initState();
    print('DetailScreen: initState');
  }

  // Ciclo de vida: didChangeDependencies
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DetailScreen: didChangeDependencies');
  }

  // Ciclo de vida: build
  @override
  Widget build(BuildContext context) {
    print('DetailScreen: build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Valor recibido: ${widget.value}', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                print('DetailScreen: botón volver');
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  // Si no se puede hacer pop, navega a la pantalla principal
                  context.go('/');
                }
              },
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  // Ciclo de vida: dispose
  @override
  void dispose() {
    print('DetailScreen: dispose');
    super.dispose();
  }
}

// ----------------- Servicios y funciones top-level -----------------

// Simula una consulta asíncrona con retraso de 2-3s y posibilidad de error
Future<String> simulatedFetch() async {
  print('simulatedFetch: inicio (antes del delay)');
  await Future.delayed(Duration(seconds: 2 + Random().nextInt(2))); // 2-3s
  print('simulatedFetch: después del delay (antes de retornar)');
  // Simular éxito o error aleatorio
  if (Random().nextBool()) {
    print('simulatedFetch: éxito');
    return 'Datos simulados recibidos';
  } else {
    print('simulatedFetch: error simulado');
    throw Exception('Error simulado en la consulta');
  }
}

// Entrada para Isolate: recibe [SendPort, int n]
void heavyComputeEntry(dynamic message) {
  final SendPort sendPort = message[0] as SendPort;
  final int n = message[1] as int;
  print('Isolate: comenzando cómputo pesado (n=$n)');
  // Ejemplo CPU-bound: suma de 1..n
  BigInt sum = BigInt.zero;
  for (int i = 1; i <= n; i++) {
    sum += BigInt.from(i);
  }
  print('Isolate: cómputo finalizado, enviando resultado');
  sendPort.send(sum.toString());
}

// ----------------- Widgets demo -----------------

// AsyncDemo: muestra estados Cargando / Éxito / Error usando async/await
class AsyncDemo extends StatefulWidget {
  const AsyncDemo({super.key});

  @override
  _AsyncDemoState createState() => _AsyncDemoState();
}

class _AsyncDemoState extends State<AsyncDemo> {
  String? _result;
  String _status = 'Idle';

  Future<void> _loadData() async {
    setState(() {
      _status = 'Cargando…';
      _result = null;
    });
    print('AsyncDemo: antes de await simulatedFetch');
    try {
      final data = await simulatedFetch();
      print('AsyncDemo: después de await simulatedFetch');
      setState(() {
        _status = 'Éxito';
        _result = data;
      });
    } catch (e) {
      print('AsyncDemo: error capturado: $e');
      setState(() {
        _status = 'Error';
        _result = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado: $_status', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 12),
            if (_result != null) Text('Resultado: $_result'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Consultar (async)')),
          ],
        ),
      ),
    );
  }
}

// TimerDemo: cronómetro con Start / Pause / Resume / Reset
class TimerDemo extends StatefulWidget {
  const TimerDemo({super.key});

  @override
  _TimerDemoState createState() => _TimerDemoState();
}

class _TimerDemoState extends State<TimerDemo> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _running = false;
  DateTime? _lastTick;

  void _start() {
    if (_running) return;
    print('TimerDemo: iniciar');
    _lastTick = DateTime.now();
    _timer = Timer.periodic(Duration(milliseconds: 100), (t) {
      final now = DateTime.now();
      final diff = now.difference(_lastTick!);
      _lastTick = now;
      setState(() {
        _elapsed += diff;
      });
    });
    setState(() => _running = true);
  }

  void _pause() {
    if (!_running) return;
    print('TimerDemo: pausar');
    _timer?.cancel();
    _timer = null;
    setState(() => _running = false);
  }

  void _resume() {
    if (_running) return;
    print('TimerDemo: reanudar');
    _lastTick = DateTime.now();
    _timer = Timer.periodic(Duration(milliseconds: 100), (t) {
      final now = DateTime.now();
      final diff = now.difference(_lastTick!);
      _lastTick = now;
      setState(() {
        _elapsed += diff;
      });
    });
    setState(() => _running = true);
  }

  void _reset() {
    print('TimerDemo: reiniciar');
    _timer?.cancel();
    _timer = null;
    setState(() {
      _elapsed = Duration.zero;
      _running = false;
    });
  }

  @override
  void dispose() {
    print('TimerDemo: dispose - limpiar timer');
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hundreds = (d.inMilliseconds.remainder(1000) ~/ 100).toString();
    return '$minutes:$seconds.$hundreds';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_format(_elapsed), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(onPressed: _start, child: const Text('Iniciar')),
              ElevatedButton(onPressed: _pause, child: const Text('Pausar')),
              ElevatedButton(onPressed: _resume, child: const Text('Reanudar')),
              ElevatedButton(onPressed: _reset, child: const Text('Reiniciar')),
            ],
          ),
        ],
      ),
    );
  }
}

// IsolateDemo: ejecuta una tarea CPU-bound en un Isolate y muestra resultado
class IsolateDemo extends StatefulWidget {
  const IsolateDemo({super.key});

  @override
  _IsolateDemoState createState() => _IsolateDemoState();
}

class _IsolateDemoState extends State<IsolateDemo> {
  String _status = 'Idle';
  String? _result;
  bool _running = false;

  Future<void> _startIsolate() async {
    setState(() {
      _status = 'Iniciando isolate…';
      _result = null;
      _running = true;
    });
    print('IsolateDemo: creando ReceivePort y spawn');
    final receive = ReceivePort();
    final int n = 200000; // tamaño del trabajo (ajustable)
    await Isolate.spawn(heavyComputeEntry, [receive.sendPort, n]);
    print('IsolateDemo: esperando resultado desde el isolate');
    receive.listen((message) {
      print('IsolateDemo: mensaje recibido: (length ${message.toString().length})');
      setState(() {
        _status = 'Completado';
        _result = message.toString();
        _running = false;
      });
      receive.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Estado: $_status', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text('Resultado (texto): ${_result!.substring(0, min(200, _result!.length))}...'),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _running ? null : _startIsolate,
              child: const Text('Ejecutar en Isolate'),
            ),
          ],
        ),
      ),
    );
  }
}