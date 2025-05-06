import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/add_transac_form.dart';
import 'package:test_flutter/transac_item.dart';
import 'package:test_flutter/database/transac_database.dart'; // Ajusta el path

void showAddIngresoModal(BuildContext context, {required void Function() refreshData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: AddTransacForm(type: 'Ingreso'),
    ),
  );
}

void showAddGastoModal(BuildContext context, {required void Function() refreshData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: AddTransacForm(type: 'Gasto'),
    ),
  );
}


// Peticiones a la base de datos

Future<void> saveTransaction({
  required String type,
  required String amount,
  required String description,
  required String date, // Lo recibimos como string por simplicidad
}) async {
  final parsedAmount = double.tryParse(amount);
  if (parsedAmount == null) throw Exception('Monto inválido');

  final newTransac = TransacItem(
    type: type,
    amount: parsedAmount,
    date: date,
    description: description,
  );

  await TransacDatabase.instance.insertTransac(newTransac);
}