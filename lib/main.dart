// Arranque de la variante B. Junto con main_change_notifier.dart, es el único
// lugar que conoce la implementación en memoria.
//   flutter run

import 'package:flutter/material.dart';

import 'datos/memoria_consumo_repository.dart';
import 'variantes/b_provider.dart';

void main() {
  runApp(AppProvider(repositorio: MemoriaConsumoRepository()));
}
