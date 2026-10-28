// Dominio: entidad Consumo y su regla de validación. Dart puro, sin Flutter.

// Laboratorios donde se registra consumo. Es constante: no es estado.
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

// Tope de litros que acepta un solo registro.
const _topeLitros = 10000;

// Un registro de agua consumida en un laboratorio.
class Consumo {
  const Consumo({required this.laboratorio, required this.litros});

  final String laboratorio;
  final double litros;
}

// Regresa el mensaje de error, o null si los litros son válidos.
// El orden importa: no es número, menor o igual a cero, mayor al tope.
String? validarLitros(double? litros) {
  if (litros == null) return 'Escribe los litros con número';
  if (litros <= 0) return 'Los litros deben ser mayores que cero';
  if (litros > _topeLitros) return 'Los litros superan el tope de $_topeLitros';
  return null;
}
