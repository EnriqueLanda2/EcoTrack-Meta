// Presentación: único dueño del estado compartido de las tres pestañas.
// Avisa con notifyListeners(); no dibuja ni sabe de dónde salen los datos.

import 'package:flutter/foundation.dart';

import '../datos/consumo_repository.dart';
import '../dominio/consumo.dart';
import '../dominio/meta.dart';

class ConsumosViewModel extends ChangeNotifier {
  // Recibe el contrato: nunca crea un repositorio ni sabe cuál es.
  ConsumosViewModel(ConsumoRepository repositorio) : _repositorio = repositorio;

  final ConsumoRepository _repositorio;

  // Estado compartido.
  List<Consumo> consumos = const [];
  String? error;
  bool guardando = false;
  double meta = metaInicial;

  // Estado derivado: se calcula cada vez, no se guarda.
  double get total => consumos.fold(0, (suma, c) => suma + c.litros);
  double get avance => avanceDeMeta(total: total, meta: meta);
  bool get metaSuperada => total > meta;

  // Lee lo que ya tiene la fuente de verdad y avisa.
  Future<void> cargar() async {
    consumos = await _repositorio.todos();
    notifyListeners();
  }

  // Valida con el dominio y guarda. Regresa true si se guardó.
  Future<bool> guardar(String laboratorio, String litrosTexto) async {
    final litros = double.tryParse(litrosTexto.trim().replaceAll(',', '.'));

    final mensaje = validarLitros(litros);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    await _repositorio.guardar(
      Consumo(laboratorio: laboratorio, litros: litros!),
    );
    // Se reasigna con lo que regresa la fuente, no se agrega a mano.
    consumos = await _repositorio.todos();

    guardando = false;
    notifyListeners();
    return true;
  }

  // El mínimo lo decide ajustarMeta, no el ViewModel.
  void subirMeta() {
    meta = ajustarMeta(meta, pasoMeta);
    notifyListeners();
  }

  void bajarMeta() {
    meta = ajustarMeta(meta, -pasoMeta);
    notifyListeners();
  }
}
