import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/add_transac_form.dart';

void showAddIngresoModal(BuildContext context) {
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

void showAddGastoModal(BuildContext context) {
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
