# Talleres-Moviles

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Taller Flutter: Navegación, Widgets y Ciclo de Vida

## Arquitectura y Navegación

- Se utiliza `go_router` para la navegación entre pantallas.
- Rutas definidas:
  - `/` : Pantalla principal (`HomeScreen`)
  - `/detail/:value` : Pantalla secundaria (`DetailScreen`) que recibe el parámetro `value`.
- El parámetro se envía desde la pantalla principal al seleccionar un elemento del GridView.
- Se demuestra la diferencia entre `go`, `push` y `replace`:
  - `go`: Reemplaza la ruta actual (no permite volver atrás).
  - `push`: Apila una nueva ruta (permite volver atrás).
  - `replace`: Reemplaza la ruta actual (similar a `go`).

## Widgets Usados

- **GridView**: Para mostrar una lista de elementos interactivos.
- **TabBar y TabBarView**: Para manejar diferentes secciones dentro de la pantalla principal.
- **Drawer**: Widget adicional para navegación lateral.
- **AlertDialog**: Para mostrar opciones de navegación.
- **ElevatedButton**: Para acciones de usuario.

## Ciclo de Vida

- Se registran en consola los métodos del ciclo de vida de los widgets principales:
  - `initState()`: Inicialización del estado.
  - `didChangeDependencies()`: Cambios en dependencias del contexto.
  - `build()`: Construcción del widget.
  - `setState()`: Actualización del estado.
  - `dispose()`: Liberación de recursos.

## Razón de elección de widgets

- **GridView**: Permite mostrar elementos en formato de cuadrícula, ideal para listas visuales.
- **TabBar**: Facilita la organización de contenido en secciones.
- **Drawer**: Añade navegación adicional y mejora la experiencia de usuario.

# Talleres-Moviles - Async, Timer e Isolate

## Qué incluye
- Demo de Future + async/await (simulación con Future.delayed).
- Cronómetro con Timer (Iniciar / Pausar / Reanudar / Reiniciar).
- Tarea CPU-bound ejecutada en un Isolate y comunicación por mensajes.

## Cuándo usar cada cosa
- Future / async/await:
  - Para operaciones asíncronas que no bloquean la UI (I/O, consultas, delays).
  - Usar cuando quieres escribir código secuencial sin bloquear el hilo principal.
- Timer:
  - Para tareas periódicas o temporizadores (cronómetro, refresco cada X ms).
  - Cancelar el Timer al pausar o en dispose para liberar recursos.
- Isolate:
  - Para tareas CPU-bound que bloquearían la UI si se ejecutan en el hilo principal.
  - Crear un Isolate y comunicar mediante SendPort/ReceivePort.

## Pantallas / flujo
- Pantalla principal (Tab bar):
  - Async: botón "Consultar (async)". Muestra estados: Idle → Cargando… → Éxito / Error.
    - Logs: antes del await, durante delay, después del await.
  - Timer: cronómetro actualizado cada 100 ms. Botones: Iniciar / Pausar / Reanudar / Reiniciar.
    - Cancela el Timer en pause y en dispose.
  - Isolate: botón para ejecutar la tarea pesada (suma grande). Se crea un Isolate, se envía N, se recibe resultado por ReceivePort y se muestra en UI.

## Notas de implementación
- simulatedFetch usa Future.delayed(2–3s) y lanza error aleatorio para poder ver estado Error.
- heavyComputeEntry es función top-level usada por Isolate.spawn.
- Se imprimen trazas en consola mostrando el orden de ejecución para cada demo.

## Flujo de uso recomendado
1. Usar Future/async para operaciones I/O y UX fluidas.
2. Usar Timer para mecánicas de tiempo controladas.
3. Usar Isolate para offload de cómputo pesado; pasar resultados por SendPort.

# Proyecto: Listado y Detalle usando api.chucknorris.io

API usada
- Endpoint principal para listado (búsqueda):
  GET https://api.chucknorris.io/jokes/search?query={query}
- Endpoint para detalle por id:
  GET https://api.chucknorris.io/jokes/{id}

Ejemplo de respuesta (search -> body.result[]):
{
  "categories": [],
  "created_at": "2020-01-05 13:42:23.484083",
  "icon_url": "https://assets.chucknorris.host/img/avatar/chuck-norris.png",
  "id": "abc123",
  "updated_at": "2020-01-05 13:42:23.484083",
  "url": "https://api.chucknorris.io/jokes/abc123",
  "value": "Chuck Norris joke text..."
}

Arquitectura mínima propuesta (carpetas)
- lib/models/    -> Joke model (fromJson)
- lib/services/  -> ChuckService (HTTP, manejo de statusCode y errores)
- lib/views/     -> ListScreen (listado) y DetailScreen (detalle)
- lib/main.dart  -> Configuración de rutas con go_router y arranque

Rutas definidas (go_router)
- name: home, path: '/' -> ListScreen (no params)
- name: detail, path: '/detail/:id' -> DetailScreen
  Parámetros enviados:
    - path param 'id' (obligatorio)
    - extra: objeto Joke (opcional, si se tiene desde la lista)

Buenas prácticas aplicadas
- No se realizan peticiones en build(); se usan initState() y servicios.
- Manejo de estados: cargando / éxito / error con mensajes y Snackbar.
- Validación de statusCode y rethrow para mostrar errores amigables.

Notas
- Añadir dependencia HTTP en pubspec.yaml si no existe:
  dependencies:
    http: ^0.13.0
- Capturas/GIFs: generar localmente (Listado, Detalle, estado de carga/ error).
