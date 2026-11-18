# 2048 en Flutter (sqflite + shared_preferences)

Este zip contiene solo lo importante del proyecto (`lib/` y `pubspec.yaml`).
Las carpetas de Android las genera Flutter, así que hay que crear el proyecto
y copiar encima estos archivos.

> **Importante:** este código se ha escrito sin poder compilarlo (no había Flutter
> instalado). Lo primero es ejecutar `flutter analyze` y arrancarlo en el emulador.
> Si sale algún error, copia el mensaje y se arregla.

## Cómo ponerlo en marcha

1. Instala Flutter y comprueba que `flutter doctor` está bien (con un emulador Android).
2. Crea el proyecto con el mismo nombre que usa el `pubspec.yaml`:
   ```
   flutter create game2048 --platforms=android
   ```
3. Copia estos archivos encima del proyecto creado:
   - `pubspec.yaml` (sustituye al que hay)
   - toda la carpeta `lib/` (sustituye a la que hay)
   - `.gitignore` (opcional), `README.md` y `DOCUMENTACION.md`
4. Borra el archivo `test/widget_test.dart` (hace referencia al `MyApp` de ejemplo y daría error).
5. Desde la carpeta del proyecto:
   ```
   flutter pub get
   flutter analyze
   flutter run
   ```
   Hay que usar un emulador o móvil Android (sqflite no funciona en web).

## Estructura

```
lib/
  main.dart                 arranque: carga los ajustes antes de runApp
  routes.dart               rutas con nombre (onGenerateRoute)
  app_theme.dart            colores, tamaños, espaciados, estilos y temas
  models/                   Usuario, Partida, PartidaGuardada, Juego2048 (lógica)
  data/                     DatabaseHelper (singleton) y los DAOs
  services/                 PreferenciasService, AjustesController, Sesion
  widgets/                  TileWidget, BoardWidget, ScoreCard, StatCard,
                            PartidaListItem, ConfirmDialog, EmptyStateView, AsyncDataView
  screens/                  login, registro, home, inicio, juego, historial,
                            detalle, ranking, ajustes
```

## Cómo probar cada requisito

- **Registro y login:** crea una cuenta (usuario ≥ 3 letras, email con @, contraseña ≥ 6) y entra.
- **Juego:** desliza el dedo (o ratón) sobre el tablero, o usa las flechas. Doble toque sobre PUNTOS muestra la ficha máxima.
- **Guardado:** juega unos movimientos y pulsa atrás (aparece el diálogo con 3 opciones). También se guarda al mandar la app a segundo plano.
- **Continuar:** en Inicio aparece "Continuar partida" solo si hay una guardada.
- **Fin de partida:** se registra en el historial con una transacción y sale el diálogo de resultado.
- **Historial:** tocar = detalle, mantener pulsado = menú, deslizar a la izquierda = borrar con "Deshacer", tirar hacia abajo = recargar, filtros por jugador y ficha mínima.
- **Detalle:** el botón de la papelera borra y vuelve al historial, que se actualiza.
- **Ajustes:** tema claro/oscuro/sistema y color de fichas (cambian al instante y se recuerdan al reabrir), borrar historial (con confirmación) y cerrar sesión.

## Probar la migración de la base de datos (versión 1 -> 2)

El código ya está en la versión 2 (con `onUpgrade`). Para enseñar que no se pierden datos:

1. En `data/database_helper.dart` pon `_version = 1` y quita la línea `tamano_tablero ...`
   del `CREATE TABLE partidas`.
2. Desinstala la app del emulador, ejecútala, registra un usuario y juega hasta terminar un par de partidas.
3. Vuelve a poner `_version = 2` y la columna `tamano_tablero INTEGER NOT NULL DEFAULT 4`
   en el `CREATE TABLE`.
4. Ejecuta de nuevo **sin desinstalar**: se lanza `onUpgrade`, las partidas siguen en el historial y el
   Detalle muestra "Tablero 4x4".

## Para la defensa (preguntas típicas)

- **¿Por qué `onPanStart/Update/End` y no `onHorizontalDragEnd` + `onVerticalDragEnd`?** Con pan
  se acumula el movimiento en los dos ejes y al soltar se elige el eje con más recorrido (dirección
  dominante). Con dos detectores separados compiten entre ellos.
- **¿Por qué hay un umbral de 20 px?** Para que un toque o un temblor del dedo no cuente como movimiento.
- **¿Por qué `Dismissible` + SnackBar con Deshacer?** Borrar al deslizar es fácil de hacer sin querer;
  "Deshacer" vuelve a insertar la misma partida con su mismo id.
- **¿Por qué una transacción al terminar la partida?** Para que se guarde en el historial y se borre la
  partida en curso a la vez, o ninguna de las dos cosas.
- **¿Cómo se guarda la contraseña?** SHA-256 con una sal aleatoria por usuario (`sal:hash`).
  Para una app real habría que usar un algoritmo pensado para contraseñas (bcrypt, Argon2).
- **¿Por qué se cargan los ajustes antes de `runApp`?** Para que no se vea un instante el tema equivocado.
- **¿Por qué no `IndexedStack` en las pestañas?** Así cada pestaña se vuelve a crear al entrar y recarga la base de datos.
- **¿Cómo se evita SQL injection?** Todas las consultas usan `?` y `whereArgs`; nunca se concatenan valores del usuario.

## Entrega

- Sube el proyecto a un repositorio de GitHub y haz **commits reales según vayas avanzando** (el enunciado
  pide commits repartidos a lo largo del mes). Por ejemplo: base de datos, modelos y DAOs, lógica del juego,
  pantallas, ajustes, gestos, migración, documentación.
- Completa `DOCUMENTACION.md` con tus capturas y expórtala a PDF (2 a 4 páginas de contenido según
  el enunciado, más las capturas).
- Antes de defenderlo, léete el código: tienes que poder explicar cada parte.
