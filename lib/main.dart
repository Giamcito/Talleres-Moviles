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
    final GoRouter _router = GoRouter(
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
      routerConfig: _router,
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
    _tabController = TabController(length: 2, vsync: this);
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
            Tab(icon: Icon(Icons.grid_on), text: 'Grid'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
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
          // Primer tab: GridView
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  print('HomeScreen: setState (Grid item tapped)');
                  setState(() {}); // Evidencia de setState
                  // Navegación con go, push y replace
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Navegación'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // go: reemplaza la ruta actual
                              context.go('/detail/${index + 1}');
                            },
                            child: const Text('Ir con go (reemplaza)'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // push: agrega una nueva ruta encima
                              context.push('/detail/${index + 1}');
                            },
                            child: const Text('Ir con push (apila)'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // replace: reemplaza la ruta actual
                              context.replace('/detail/${index + 1}');
                            },
                            child: const Text('Ir con replace (reemplaza)'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  color: Colors.deepPurple[100 * ((index % 8) + 1)],
                  child: Center(
                    child: Text('Item ${index + 1}'),
                  ),
                ),
              );
            },
          ),
          // Segundo tab: Información
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Este es el segundo tab.'),
                SizedBox(height: 16),
                Icon(Icons.info, size: 48),
              ],
            ),
          ),
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