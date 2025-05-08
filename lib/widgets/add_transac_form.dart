import 'package:flutter/material.dart';
import '../helpers/modal_helpers.dart'; // Asegúrate de tener ahí la función saveTransaction()
import 'package:test_flutter/transac_item.dart';



class AddTransacForm extends StatefulWidget {
  final String type;
  final TransacItem? existingItem;
  final void Function()? onSaved;

  const AddTransacForm({
    super.key,
    required this.type,
    this.existingItem,
    this.onSaved,
  });

  @override
  State<AddTransacForm> createState() => _AddTransacFormState();
}

class _AddTransacFormState extends State<AddTransacForm> {
  late TextEditingController _dateController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toIso8601String(); // formato ISO
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIngreso = widget.type == 'Ingreso';
    final Color bgColor = isIngreso ? Colors.green : Colors.red;
    final Color btnColor = isIngreso ? Colors.red : Colors.red;
    final String btnText = isIngreso ? 'Ingreso' : 'Gasto';
    // color de fuente btnText blanco
    final Color btnTextColor = Colors.white;
    final Color textColor = isIngreso ? Colors.white : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Agregar ${widget.type}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Monto'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Selecciona el día'),
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      final amount = _amountController.text.trim();
                      final description = _descriptionController.text.trim();
                      final date = _dateController.text.isEmpty
                          ? DateTime.now().toIso8601String()
                          : _dateController.text;

                      try {
                        await saveTransaction(
                          type: widget.type,
                          amount: amount, // Aquí como String
                          description: description,
                          date: date,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Guardado: $amount | $description | $date')),
                        );

                        // Recarga los datos y actualiza la vista (en lugar de pop)
                        widget.onSaved?.call();

                        // Cierra el modal después de guardar la transacción
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al guardar: ${e.toString()}')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirmar'),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnColor,
                    ),
                    //color de fuente btnText blanco
                    child: Text(
                      'Cancelar'' $btnText',
                      style: TextStyle(color: btnTextColor),
                    ),
                    //child: Text('Cancelar'+' $btnText'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
