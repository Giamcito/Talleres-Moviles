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
