import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _title = "Hola, Flutter";

  void _toggleTitle() {
    setState(() {
      _title = _title == "Hola, Flutter" ? "¡Titulo cambiado!" : "Hola, Flutter";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Titulo actualizado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: const Color.fromARGB(255, 212, 69, 193),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 167, 252, 255),
                border: Border.all(color: const Color.fromARGB(255, 71, 188, 218)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Nombre: Juan Camilo Giraldo Amaya",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ImageRow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(
                  'https://db.pokemongohub.net/_next/image?url=%2Fimages%2Fofficial%2Ffull%2F134.webp&w=640&q=75',
                  width: 80,
                  height: 80,
                ),
                Image.network(
                  'https://img.pokemondb.net/artwork/large/jolteon.jpg',
                  width: 80,
                  height: 80,
                ),
                Image.network(
                  'https://db.pokemongohub.net/_next/image?url=%2Fimages%2Fofficial%2Ffull%2F136.webp&w=640&q=75',
                  width: 80,
                  height: 80,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // AssetImageRow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/images/sylveon.jpg',
                  width: 80,
                  height: 80,
                ),
                Image.asset(
                  'assets/images/sylveon.jpg',
                  width: 80,
                  height: 80,
                ),
                Image.asset(
                  'assets/images/sylveon.jpg',
                  width: 80,
                  height: 80,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _toggleTitle,
              child: const Text("Cambiar título"),
            ),
            const SizedBox(height: 12),
            // SimpleList
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Estrella'),
                  ),
                  ListTile(
                    leading: Icon(Icons.face),
                    title: Text('Cara'),
                  ),
                  ListTile(
                    leading: Icon(Icons.favorite),
                    title: Text('Corazon'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ImageStack
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Image.network(
                      'https://db.pokemongohub.net/_next/image?url=%2Fimages%2Fofficial%2Ffull%2F134.webp&w=640&q=75',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Positioned(
                    left: 40,
                    child: Image.network(
                      'https://img.pokemondb.net/artwork/large/jolteon.jpg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    child: Image.network(
                      'https://db.pokemongohub.net/_next/image?url=%2Fimages%2Fofficial%2Ffull%2F136.webp&w=640&q=75',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}