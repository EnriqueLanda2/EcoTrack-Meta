// Arranque de la variante A. Junto con main.dart, es el único lugar que
// conoce la implementación en memoria.
//   flutter run -t lib/main_change_notifier.dart

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/a_change_notifier.dart';

void main() {
  runApp(AppChangeNotifier(repositorio: MemoriaConsumoRepository()));
}
