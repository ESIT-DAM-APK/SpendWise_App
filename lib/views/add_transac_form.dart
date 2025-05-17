import 'package:flutter/material.dart';
import '../helpers/modal_helpers.dart';
import 'package:test_flutter/models/transac_item.dart';
import 'package:test_flutter/database/transac_database.dart';

class AddTransacForm extends StatefulWidget {
  final String type;
  final TransacItem? existingItem;
  final void Function()? onSaved;
  final int userId; // Añadido

  const AddTransacForm({
    super.key,
    required this.type,
    this.existingItem,
    this.onSaved,
    required this.userId, // Añadido
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
    // Inicializa los controladores con los valores existentes si hay un item
    _dateController = TextEditingController(
      text: widget.existingItem?.date ?? ''
    );
    _amountController = TextEditingController(
      text: widget.existingItem?.amount.toString() ?? ''
    );
    _descriptionController = TextEditingController(
      text: widget.existingItem?.description ?? ''
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveOrUpdateTransaction() async {
    final amount = _amountController.text.trim();
    final description = _descriptionController.text.trim();
    final date = _dateController.text.isEmpty
        ? DateTime.now().toIso8601String()
        : _dateController.text;

    try {
      if (widget.existingItem != null) {
        // Actualizar transacción existente
        final updatedItem = TransacItem(
          id: widget.existingItem!.id,
          type: widget.type,
          amount: double.tryParse(amount) ?? 0,
          date: date,
          description: description,
          userId: widget.userId, // Añadido
        );
        await TransacDatabase.instance.updateTransac(updatedItem);
      } else {
        // Crear nueva transacción
        await saveTransaction(
          type: widget.type,
          amount: amount,
          description: description,
          date: date,
          userId: widget.userId, // Añadido
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.existingItem != null 
            ? 'Transacción actualizada' 
            : 'Transacción guardada')),
      );

      widget.onSaved?.call();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
        _dateController.text = pickedDate.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIngreso = widget.type == 'Ingreso';
    final Color bgColor = isIngreso ? Colors.green : Colors.red;
    final Color btnColor = isIngreso ? Colors.red : Colors.red;
    final String btnText = isIngreso ? 'Ingreso' : 'Gasto';
    final Color btnTextColor = Colors.white;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingItem != null ? 'Editar ${widget.type}' : 'Agregar ${widget.type}',
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
                mainAxisSize: MainAxisSize.min,
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
                  Center( // Envolvemos los botones en Center para controlar su ancho
                    child: SizedBox( // Definimos un ancho específico para los botones
                      width: 200, // Ajusta este valor según necesites
                      child: ElevatedButton(
                        onPressed: _saveOrUpdateTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(widget.existingItem != null ? 'Actualizar' : 'Confirmar'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: SizedBox(
                      width: 200, // Mismo ancho que el botón anterior
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: btnColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Cancelar $btnText',
                          style: TextStyle(color: btnTextColor),
                        ),
                      ),
                    ),
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