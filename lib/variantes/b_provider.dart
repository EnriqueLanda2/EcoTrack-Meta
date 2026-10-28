// Variante B: provider sobre el MISMO ViewModel. Se cuelga en el árbol con
// ChangeNotifierProvider; los adaptadores lo piden al contexto.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../datos/consumo_repository.dart';
import '../presentacion/consumos_view_model.dart';
import '../presentacion/vistas.dart';

class AppProvider extends StatelessWidget {
  const AppProvider({super.key, required this.repositorio});

  final ConsumoRepository repositorio;

  @override
  Widget build(BuildContext context) {
    // create corre una sola vez; el provider libera el ViewModel al salir.
    return ChangeNotifierProvider<ConsumosViewModel>(
      create: (_) => ConsumosViewModel(repositorio)..cargar(),
      child: MaterialApp(
        title: 'EcoTrack Meta',
        theme: temaEcoTrack,
        home: const PantallasEcoTrack(
          titulo: 'B · provider',
          registro: RegistroProvider(),
          historial: HistorialProvider(),
          meta: MetaProvider(),
        ),
      ),
    );
  }
}

// watch para mostrar, read para actuar.
class RegistroProvider extends StatelessWidget {
  const RegistroProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return FormularioRegistro(
      alGuardar: (laboratorio, litros) =>
          context.read<ConsumosViewModel>().guardar(laboratorio, litros),
      error: vm.error,
      guardando: vm.guardando,
    );
  }
}

class HistorialProvider extends StatelessWidget {
  const HistorialProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return ListaHistorial(consumos: vm.consumos, total: vm.total);
  }
}

class MetaProvider extends StatelessWidget {
  const MetaProvider({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConsumosViewModel>();
    return PanelMeta(
      usado: vm.total,
      meta: vm.meta,
      avance: vm.avance,
      superada: vm.metaSuperada,
      alSubir: () => context.read<ConsumosViewModel>().subirMeta(),
      alBajar: () => context.read<ConsumosViewModel>().bajarMeta(),
    );
  }
}
