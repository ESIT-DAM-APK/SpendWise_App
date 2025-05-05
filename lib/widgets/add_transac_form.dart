import 'package:flutter/material.dart';
class AddTransacForm extends StatefulWidget {
  final String type;

  AddTransacForm({required this.type});

  @override
  _AddTransacFormState createState() => _AddTransacFormState();
}

class _AddTransacFormState extends State<AddTransacForm> {
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _dateController.dispose();
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
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIngreso = widget.type == 'Ingreso';
    final Color bgColor = isIngreso ? Colors.green : Colors.red;
    final Color btnColor = isIngreso ? Colors.red : Colors.green;
    final String btnText = isIngreso ? 'Gastos' : 'Ingresos';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor, // fondo verde o rojo
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

            // Cuadro blanco
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Monto'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
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
                    onPressed: () {
                      // Acción insertar
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
                    child: Text(btnText),
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
