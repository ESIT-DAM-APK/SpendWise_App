import 'package:flutter/material.dart';
import 'package:test_flutter/widgets/add_transac_form.dart';
import 'package:test_flutter/transac_item.dart';
import 'package:test_flutter/database/transac_database.dart'; // Ajusta el path
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

void showAddIngresoModal(BuildContext context, {required VoidCallback refreshData, required int userId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite que el modal se ajuste al contenido
    backgroundColor: Colors.transparent,
    builder: (_) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Cierra el teclado si se toca fuera del campo
        child: Wrap(
          children: [
            AnimatedPadding(
              padding: EdgeInsets.only(
                top: 32.0, // Ajuste superior
                bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste dinámico con el teclado
              ),
              duration: Duration(milliseconds: 300), // Animación suave
              child: SingleChildScrollView( // Usamos SingleChildScrollView para permitir desplazamiento
                child: KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                    // Aquí puedes hacer ajustes según si el teclado está visible
                    return AddTransacForm(
                      type: 'Ingreso',
                      onSaved: refreshData,
                      userId: userId, // Añadido
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showAddGastoModal(BuildContext context, {required VoidCallback refreshData, required int userId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite que el modal se ajuste al contenido
    backgroundColor: Colors.transparent,
    builder: (_) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Cierra el teclado si se toca fuera del campo
        child: Wrap(
          children: [
            AnimatedPadding(
              padding: EdgeInsets.only(
                top: 32.0, // Ajuste superior
                bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste dinámico con el teclado
              ),
              duration: Duration(milliseconds: 300), // Animación suave
              child: SingleChildScrollView( // Usamos SingleChildScrollView para permitir desplazamiento
                child: KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                    // Aquí puedes hacer ajustes según si el teclado está visible
                    return AddTransacForm(
                      type: 'Gasto',
                      onSaved: refreshData,
                      userId: userId, // Añadido
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Peticiones a la base de datos
Future<void> saveTransaction({
  required String type,
  required String amount,
  required String description,
  required String date,
  required int userId, // Añadido
}) async {
  final parsedAmount = double.tryParse(amount);
  if (parsedAmount == null || amount.isEmpty) throw Exception('Monto inválido');
  if (description.isEmpty) throw Exception('Descripción inválida');
  if (date.isEmpty) throw Exception('Fecha inválida');

  final newTransac = TransacItem(
    type: type,
    amount: parsedAmount,
    date: date,
    description: description,
    userId: userId, // Añadido
  );

  await TransacDatabase.instance.insertTransac(newTransac);
}

Future<void> updateTransaction({
  required int id,
  required String type,
  required String amount,
  required String description,
  required String date,
  required int userId, // Añadido
}) async {
  final parsedAmount = double.tryParse(amount);
  if (parsedAmount == null || amount.isEmpty) throw Exception('Monto inválido');
  if (description.isEmpty) throw Exception('Descripción inválida');
  if (date.isEmpty) throw Exception('Fecha inválida');

  final updatedTransac = TransacItem(
    id: id,
    type: type,
    amount: parsedAmount,
    date: date,
    description: description,
    userId: userId // Añadido
  );

  await TransacDatabase.instance.updateTransac(updatedTransac);
}
