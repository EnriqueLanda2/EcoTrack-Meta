# Gestión de estado — EcoTrack Meta

**Equipo:** Enrique Landa (20233TN174)
**Fecha:** 27/10/2026

## Tipos de estado en nuestro código

| Dato | Tipo (efímero, compartido, derivado, persistido) | Dónde vive |
|---|---|---|
| Pestaña activa | Efímero: solo le importa a la barra inferior y se cambia con `setState`. | `_PantallasEcoTrackState._pestana` en `lib/presentacion/vistas.dart`. |
| Texto del campo de litros | Efímero: es del formulario mientras se escribe, junto con el laboratorio elegido. | `_FormularioRegistroState._litros` (`TextEditingController`, liberado en `dispose()`) y `_laboratorio` en `lib/presentacion/vistas.dart`. |
| consumos y meta | Compartido: las tres pestañas los leen y un solo dueño los cambia. | Campos `consumos` y `meta` de `ConsumosViewModel` en `lib/presentacion/consumos_view_model.dart`; lo prueba "Dato compartido" en `etapa4_change_notifier_test.dart` y `etapa5_provider_test.dart`. |
| total y metaSuperada | Derivado: se calculan de `consumos` y `meta` en cada lectura, no se guardan. | Getters `ConsumosViewModel.total` y `.metaSuperada`; lo prueba "total, avance y metaSuperada se derivan de consumos y meta" en `etapa3_viewmodel_test.dart` y el punto 3 de `verificar_estado.sh`. |
| Lo que regresa todos() | Persistido: es la fuente de verdad; el ViewModel solo guarda una copia. | Lista privada `_consumos` de `MemoriaConsumoRepository`, entregada con `List.unmodifiable`; lo prueba "todos() no deja modificar la lista interna" en `etapa2_datos_test.dart`. |

## Criterios

| Criterio | A · ChangeNotifier puro | B · provider |
|---|---|---|
| Dato compartido | Un solo `_vm` creado en `_AppChangeNotifierState` se pasa a `RegistroCN`, `HistorialCN` y `MetaCN`; pasa "Dato compartido" en `etapa4_change_notifier_test.dart`. | Un solo `ConsumosViewModel` colgado con `ChangeNotifierProvider<ConsumosViewModel>` arriba de `MaterialApp` en `AppProvider`; pasa "Dato compartido" en `etapa5_provider_test.dart`. |
| Capas | `a_change_notifier.dart` solo importa el ViewModel, `vistas.dart` y el contrato `ConsumoRepository`; pasa "Capas" en etapa 4 y los puntos 2 a 5 de `verificar_estado.sh`. | `b_provider.dart` importa lo mismo más `package:provider`; las vistas siguen sin conocer provider; pasa "Capas" en etapa 5 y los puntos 4 y 6 de `verificar_estado.sh`. |
| Encaje con el diagrama | Encaja: vista tonta ← adaptador `*CN` con `ListenableBuilder` ← `ConsumosViewModel` ← contrato `ConsumoRepository`. | Encaja igual: solo cambia el adaptador (`*Provider` con `context.watch`/`context.read`); `git diff e98c3e3 25f1d4c` muestra que solo cambiaron `b_provider.dart` y `main.dart`, ni una línea del ViewModel ni de `vistas.dart`. |
| Constructores que reciben vm | 3 (`RegistroCN`, `HistorialCN`, `MetaCN` con `required this.vm`); con una subpantalla de detalle en Meta serían 4 y `MetaCN` tendría que reenviarlo. | 0: los adaptadores son `const` y piden el ViewModel al árbol; lo prueba "Los adaptadores piden el ViewModel al árbol, no al constructor". |
| Quién libera el ViewModel | Quien lo crea: `_AppChangeNotifierState.dispose()` llama a `_vm.dispose()`; ningún adaptador lo libera. | El `ChangeNotifierProvider`: lo crea en `create` y lo libera solo cuando se desmonta; no escribimos ningún `dispose()`. |
| Costo de adoptarla ahora | Cero dependencias (solo `ChangeNotifier` y `ListenableBuilder` de Flutter), pero exige un `StatefulWidget` para crear/liberar a mano y pasar `vm` por cada constructor (`a_change_notifier.dart`: 103 líneas). | Una dependencia (`provider` en `pubspec.yaml`) y aprender `watch` para mostrar y `read` para actuar; a cambio el cableado es más corto (`b_provider.dart`: 76 líneas). |
| Sustitución de la fuente de datos | `AppChangeNotifier(repositorio: RepositorioEspia(...))` funciona sin tocar pantallas; pasa "Sustitución" en etapa 4. Solo `main_change_notifier.dart` elige `MemoriaConsumoRepository`. | `AppProvider(repositorio: espia)` funciona sin tocar pantallas; pasa "Sustitución" en etapa 5. Solo `main.dart` elige `MemoriaConsumoRepository` (punto 8 de `verificar_estado.sh`). |

## Elección

Elegimos: B · provider, porque deja en 0 los constructores que reciben `vm`, libera el ViewModel solo y escala mejor si llega otra pantalla; por eso `lib/main.dart` arranca `AppProvider`.
Se mantiene esta pieza del diagrama: `ConsumosViewModel` (con el dominio y el contrato `ConsumoRepository` debajo), que no cambió una sola línea entre la variante A y la B.
Esta pieza es la que podría sustituirse después: la fuente de datos `MemoriaConsumoRepository`, por una de disco o red que implemente `ConsumoRepository`, cambiando solo `main.dart`.

## Preguntas de control

- **¿`laboratoriosUtez` es estado? ¿Y `metaInicial`?** No: son constantes (`const`) en `lib/dominio/`; nunca cambian. `metaInicial` solo es el valor con el que arranca el estado `meta` del ViewModel.
- **¿Quién es la fuente de verdad: el repositorio o el ViewModel?** El repositorio. Después de guardar, `ConsumosViewModel.guardar` reasigna `consumos = await _repositorio.todos()` en lugar de hacer `consumos.add(...)`.
- **¿Qué pasa si olvidamos el último `notifyListeners()` de `guardar`?** `guardando` se queda en `true` para las pantallas: el botón Guardar sigue desactivado y Historial no se entera del consumo nuevo. Lo detecta "guardar avisa \"guardando\" y luego \"listo\"" en `etapa3_viewmodel_test.dart`.
- **¿Por qué `total` es un getter y no un campo?** Porque se deriva de `consumos`; como getter nunca puede quedar desincronizado. `verificar_estado.sh` (punto 3) revisa que no sea un campo.
- **Entre A y B, ¿qué archivos cambiaron?** Solo `lib/variantes/b_provider.dart` (nuevo) y `lib/main.dart`. El ViewModel y `vistas.dart` no cambiaron.
- **¿Quién hace el `dispose()` en B?** `ChangeNotifierProvider`, al desmontarse.
