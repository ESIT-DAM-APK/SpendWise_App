import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/add_transac_form.dart';
import 'package:test_flutter/transac_item.dart';
import 'package:test_flutter/database/transac_database.dart'; // Ajusta el path

//void showAddIngresoModal(BuildContext context, {required void Function() refreshData}) {
void showAddIngresoModal(BuildContext context, {required VoidCallback refreshData}) {

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: AddTransacForm(
        type: 'Ingreso',
        onSaved: refreshData,
      ),
    ),
  );
}

void showAddGastoModal(BuildContext context, {required VoidCallback refreshData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: AddTransacForm(
        type: 'Gasto',
        onSaved: refreshData,
      ),
    ),
  );
}

void showEditModal(BuildContext context, TransacItem item, {required void Function() refreshData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: AddTransacForm(type: item.type, existingItem: item),
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
  if (parsedAmount == null || amount.isEmpty ) throw Exception('Monto inválido');
  if (description.isEmpty) throw Exception('Descripción inválida');
  if (date.isEmpty) throw Exception('Fecha inválida');

  final newTransac = TransacItem(
    type: type,
    amount: parsedAmount,
    date: date,
    description: description,
  );

  await TransacDatabase.instance.insertTransac(newTransac);
}