// Datos: contrato de la fuente de consumos. Habla como el dominio, no dice
// si detrás hay una lista, un archivo o una API.

import '../dominio/consumo.dart';

abstract class ConsumoRepository {
  // Guarda un consumo en la fuente de datos.
  Future<void> guardar(Consumo consumo);

  // Regresa todos los consumos guardados, en el orden en que llegaron.
  Future<List<Consumo>> todos();
}
