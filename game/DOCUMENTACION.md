# Práctica 2048 en Flutter - Documentación

**Nombre:** [tu nombre]   **Curso:** DAM2   **Repositorio:** [enlace a GitHub]

## 1. Modelo de datos

Base de datos `game2048.db` (SQLite con sqflite), versión 2.

```
usuarios                      partidas                        partida_guardada
-----------------------       ---------------------------     ---------------------------
id (PK, autoinc.)             id (PK, autoinc.)               id (PK, siempre 1)
usuario (UNIQUE)              usuario                         tablero (JSON, 16 valores)
fecha_registro (ISO 8601)     puntuacion                      puntuacion
email (UNIQUE)                ficha_maxima                    movimientos
contrasena ("sal:hash")       movimientos                     segundos_transcurridos
                              duracion_segundos
                              fecha (ISO 8601)
                              tamano_tablero (v2, def. 4)
```

Notas: la columna se llama `contrasena` (sin ñ) para evitar problemas con caracteres especiales.
`partidas.usuario` guarda el nombre del jugador como texto (no hemos normalizado el modelo con una
clave foránea; lo dejamos como mejora). Se activa `PRAGMA foreign_keys = ON` en `onConfigure`.

## 2. Arquitectura de la capa de datos

- **DatabaseHelper** (singleton): abre la base de datos con `openDatabase`, define la versión, crea las
  tablas en `onCreate` y gestiona la migración en `onUpgrade`.
- **Modelos** (`Usuario`, `Partida`, `PartidaGuardada`): clases con `toMap()` y `fromMap()`.
- **DAOs** (`UsuarioDao`, `PartidaDao`, `PartidaGuardadaDao`): contienen todo el SQL. Las pantallas nunca
  escriben SQL ni acceden a `Database`. Todas las consultas son parametrizadas (`?` y `whereArgs`).
- **Transacción:** `PartidaDao.finalizarPartida` inserta la partida en el historial y borra la partida en
  curso con `db.transaction`.
- **Contraseñas:** SHA-256 con sal aleatoria por usuario.
- **PreferenciasService** (shared_preferences): tema, paleta de fichas, último usuario y mejor puntuación,
  con las claves como constantes. **AjustesController** (`ChangeNotifier`) avisa a la app para que cambie el
  tema en tiempo real.
- Todo es asíncrono (`Future`, `async/await`) y los errores se controlan con `try/catch` en las pantallas.

## 3. Migración de la versión 1 a la 2

En la versión 1 la tabla `partidas` no tenía la columna `tamano_tablero`. En la versión 2 se añade con:

```sql
ALTER TABLE partidas ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4
```

Se ejecuta en `onUpgrade` cuando `versionAntigua < 2`. Las partidas que ya existían se conservan y
reciben el valor 4. En una instalación nueva, `onCreate` ya crea la tabla con la columna.
[Aquí cuenta cómo lo probaste: partidas antes y después de la migración.]

## 4. Navegación

```
Login ──(entrar OK: pushReplacement)──────────────► Home (NavigationBar)
  │                                                    ├─ Inicio
  └─(Crear cuenta)─► Registro ──pop(usuario)──► Login ├─ Historial ──(id de la partida)──► Detalle ──pop(true si se elimina)──► Historial (recarga)
                                                       ├─ Ranking ───(id de la partida)──► Detalle
                                                       └─ Ajustes ──(cerrar sesión)──► Login (borra la pila)
Inicio ──(continuar: true / nueva partida: false)──► Juego ──(fin de partida / salir)──► Inicio
```

Datos que se pasan: Historial/Ranking -> Detalle: el **id** (el Detalle consulta la BD); Inicio -> Juego:
un booleano `continuar`; Registro -> Login: el nombre de usuario; Detalle -> Historial: `true` si se ha eliminado.

Todas las rutas están en `routes.dart` (rutas con nombre y `onGenerateRoute`).

## 5. Gestos

| Gesto | Widget | Pantalla | Comportamiento |
|---|---|---|---|
| Deslizar (4 direcciones) | `GestureDetector` (`onPanStart/Update/End`) | Juego (tablero) | Mueve las fichas; umbral de 20 px y dirección dominante |
| Deslizar para descartar | `Dismissible` | Historial | Borra la partida y muestra SnackBar con "Deshacer" |
| Pulsación larga | `onLongPress` del `ListTile` | Historial | Menú con "Ver detalle" y "Eliminar" (con confirmación) |
| Pulsación simple | `onTap` del `ListTile` | Historial y Ranking | Abre el detalle |
| Arrastrar hacia abajo | `RefreshIndicator` | Historial y Ranking | Vuelve a consultar la BD |
| Doble toque | `GestureDetector` (`onDoubleTap`) | Juego (PUNTOS) | Muestra u oculta la ficha máxima |

Alternativa accesible: botones de flecha en pantalla. Ningún gesto destructivo funciona sin confirmación o "Deshacer".

## 6. Reutilización de widgets

| Widget | Dónde se usa |
|---|---|
| TileWidget | BoardWidget (Juego), Detalle, Ajustes (vista previa) |
| BoardWidget | Juego |
| ScoreCard | Juego, Inicio |
| StatCard | Ranking, Detalle |
| PartidaListItem | Historial, Ranking |
| ConfirmDialog | Historial, Detalle, Ajustes, Juego, Inicio |
| EmptyStateView | Historial, Ranking, Detalle |
| AsyncDataView | Historial, Ranking, Detalle |

## 7. Capturas

[Inserta aquí tus capturas]
- Login y registro
- Inicio (claro / oscuro)
- Juego (claro / oscuro) y una en horizontal
- Historial (claro / oscuro)
- Detalle (claro / oscuro)
- Ranking (claro / oscuro)
- Ajustes (claro / oscuro)

## 8. Decisiones de diseño

- **Navegación:** `NavigationBar` inferior (Material 3), porque hay cuatro destinos principales y es lo más
  cómodo en el móvil con una mano. Un Drawer esconde las opciones y un TabBar queda arriba, lejos del pulgar.
  El juego, el detalle, el login y el registro son pantallas aparte que se abren encima.
- **Gestor de estado:** `setState` en cada pantalla y un `ChangeNotifier` (`AjustesController`) solo para el
  tema y la paleta, que es lo único que afecta a toda la app. No hemos usado Provider para no añadir
  dependencias.
- **Estructura de carpetas:** `models/`, `data/`, `services/`, `widgets/` y `screens/`, más `routes.dart`,
  `app_theme.dart` y `main.dart`. Así separamos datos, interfaz y lógica del juego.
- **Colores de las fichas:** van en una `ThemeExtension` (`ColoresFicha`) dentro del tema, así cambian solos con
  el modo claro/oscuro y con la paleta elegida; el color de cada ficha se calcula mezclando dos colores según
  su valor y el texto se pone claro u oscuro según la luminosidad del fondo.
