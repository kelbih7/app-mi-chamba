import 'package:flutter/material.dart';

/// Constantes reutilizables de colores e íconos para los trabajos
class WorkConstants {
  static const Map<int, Map<String, dynamic>> coloresMap = {
    1: {'color': Colors.blue, 'nombre': 'Azul'},
    2: {'color': Colors.red, 'nombre': 'Rojo'},
    3: {'color': Colors.green, 'nombre': 'Verde'},
    4: {'color': Colors.orange, 'nombre': 'Naranja'},
    5: {'color': Colors.purple, 'nombre': 'Morado'},
    6: {'color': Colors.teal, 'nombre': 'Turquesa'},
    7: {'color': Colors.brown, 'nombre': 'Marrón'},
    8: {'color': Colors.cyan, 'nombre': 'Cyan'},
    9: {'color': Colors.amber, 'nombre': 'Ámbar'},
    10: {'color': Colors.pink, 'nombre': 'Rosa'},
  };

  static const Map<int, Map<String, dynamic>> iconosMap = {
    1: {'icono': Icons.local_shipping, 'nombre': 'Repartir'},
    3: {'icono': Icons.warehouse, 'nombre': 'Almacén'},
    2: {'icono': Icons.outbox, 'nombre': 'Cargar'},
    4: {'icono': Icons.attach_money, 'nombre': 'Cobrar'},
    5: {'icono': Icons.shopping_cart, 'nombre': 'Vender'},
    6: {'icono': Icons.point_of_sale, 'nombre': 'Cajero'},
    7: {'icono': Icons.support_agent, 'nombre': 'Atención al cliente'},
    8: {'icono': Icons.soup_kitchen, 'nombre': 'Cocina'},
    9: {'icono': Icons.build, 'nombre': 'Mantenimiento'},
    10: {'icono': Icons.edit_note, 'nombre': 'Registro'},
    11: {'icono': Icons.security, 'nombre': 'Seguridad'},
    12: {'icono': Icons.move_to_inbox, 'nombre': 'Descargar'},
    13: {'icono': Icons.inventory_2, 'nombre': 'Estibar'},
  };
}
