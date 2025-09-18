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

---
