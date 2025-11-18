# To-Do Offline-First (Flutter)

Aplicación de lista de tareas con arquitectura limpia, gestión de estado con Riverpod, persistencia local (SQLite) y sincronización contra API REST.

## Objetivo
Demostrar un flujo Offline-First: leer desde base local al abrir, permitir operaciones CRUD sin conexión y sincronizar automáticamente cuando vuelve la conectividad.

# Api local recursiva
Se usa una api en la misma carpeta del projecto ("cd Talleres-Moviles/api")
luego ejecuta npm install y npm start para iniciar api

## Tecnologías
- Flutter 3.x
- Riverpod (`flutter_riverpod`) para gestión de estado.
- SQLite (`sqflite`) para almacenamiento local.
- `connectivity_plus` para detectar conexión.
- `http` para consumir API REST.
- `uuid` para generar identificadores.

## Estructura de Carpetas
```
lib/
  domain/entities/        # Modelos de dominio (Task, QueueOperation)
  data/local/             # SQLite: database y DAOs
  data/remote/            # Llamadas HTTP a la API
  data/repositories/      # Lógica Offline-First y cola de operaciones
  core/connectivity/      # Servicio de conectividad
  core/sync/              # Servicio de sincronización periódica
  presentation/providers/ # Riverpod providers (lista, filtros)
  presentation/pages/     # UI (TaskListPage, EditTaskPage)
  main.dart               # Arranque y wiring de providers
```

## Modelo de Datos (SQLite)
```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL,
  deleted INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE queue_operations (
  id TEXT PRIMARY KEY,
  entity TEXT,
  entity_id TEXT,
  op TEXT,              -- CREATE | UPDATE | DELETE
  payload TEXT,
  created_at INTEGER,
  attempt_count INTEGER,
  last_error TEXT
);
```

## Flujo Offline-First
1. Apertura app -> se cargan tareas locales inmediatamente.
2. En segundo plano se intenta refrescar remoto (si hay conexión).
3. Operaciones (crear, editar, completar, eliminar):
   - Se aplican localmente (inmediato en UI).
   - Se encolan en `queue_operations`.
4. Servicio de sincronización:
   - Se ejecuta cada 20s y al recuperar conectividad.
   - Procesa cola: envía operaciones a API.
   - Si éxito: elimina operación y refresca listado remoto.
   - Si falla: incrementa `attempt_count` y guarda `last_error` (backoff simple por reintentos repetidos manual/política futura).
5. Resolución de conflictos: estrategia LWW (Last Write Wins) usando `updatedAt`.

## Endpoints Esperados
```
GET    /tasks
POST   /tasks
GET    /tasks/{id}
PUT    /tasks/{id}
DELETE /tasks/{id}
```
Formato JSON mínimo: `{ id, title, completed, updatedAt }`.

## Configuración API
La URL base se injecta mediante `--dart-define=API_BASE_URL=http://localhost:3000` (por defecto localhost:3000).

Ejemplo de ejecución de mock con json-server:
```bash
json-server --watch tasks.json --port 3000
```
Contenido inicial `tasks.json`:
```json
{ "tasks": [] }
```

## Instalación y Ejecución
```bash
flutter clean
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```

## API Mock (Node)
Se incluye carpeta `api/` con un servidor Express en memoria.

### Instalar y ejecutar (Windows CMD)
```cmd
cd api
npm install
npm run start
```
El servidor expone endpoints en `http://localhost:3000`.

### Sembrar datos de ejemplo
```cmd
curl -X POST http://localhost:3000/seed
```

### Endpoints
```
GET    /tasks
POST   /tasks       (body: {id,title,completed,updatedAt})
GET    /tasks/:id
PUT    /tasks/:id   (body: {title?,completed?,updatedAt})
DELETE /tasks/:id
```
Implementa política LWW comparando `updatedAt`.

## Generar APK Release
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://tu-servidor
```
APK generado: `build/app/outputs/flutter-apk/app-release.apk`.

## Probar Modo Offline
1. Ejecutar app con API activa.
2. Crear/editar varias tareas.
3. Apagar conexión (modo avión) y seguir operando.
4. Encender conexión -> observar icono nube verde y sincronización (operaciones desaparecen de cola y se refleja en servidor).

## Próximas Mejoras (opcionales)
- Backoff exponencial real (delay según `attempt_count`).
- Campo `syncedAt` en tasks para auditoría.
- Manejo de conflictos interactivo.
- Tests unitarios para repositorio y sincronización.

## Notas
El código previo del proyecto ha sido reemplazado para cumplir los requerimientos del reto To-Do Offline-First.

## Dudas / Contacto
Agregar en este archivo cualquier inquietud o anotación futura.
