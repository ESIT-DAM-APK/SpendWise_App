import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart'; // Ajusta el path
import '../models/transac_item.dart'; 

class FormTransac extends StatefulWidget {
  final VoidCallback? onSaved;
  final int userId; // Añade este parámetro


  const FormTransac({
    super.key, 
    this.onSaved,
    required this.userId, // Hazlo requerido
  });

  @override
  State<FormTransac> createState() => _FormTransacState();
}

class _FormTransacState extends State<FormTransac> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Gasto';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    final newTransac = TransacItem(
      type: _type,
      amount: double.parse(_amountController.text),
      date: DateTime.now().toIso8601String(),
      description: _descriptionController.text,
      userId: widget.userId, // Añadido

    );

    await TransacDatabase.instance.insertTransac(newTransac);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transacción guardada')),
    );

    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _type = 'Gasto';
    });

    widget.onSaved?.call(); // si usas este callback para recargar la vista
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector tipo
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Tipo de movimiento'),
                items: const [
                  DropdownMenuItem(value: 'Gasto', child: Text('Gasto')),
                  DropdownMenuItem(value: 'Ingreso', child: Text('Ingreso')),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 16),

              // Monto
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un monto';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción / Comentario
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Comentario'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un comentario';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón guardar
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
