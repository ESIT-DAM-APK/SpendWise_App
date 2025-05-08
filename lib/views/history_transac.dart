import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart';
import 'package:test_flutter/transac_item.dart';
import 'package:intl/intl.dart';
// Asegúrate de tener la función showEditModal
import 'package:test_flutter/widgets/add_transac_form.dart';
class HistoryTransac extends StatefulWidget {
  const HistoryTransac({super.key});

  @override
  State<HistoryTransac> createState() => _HistoryTransacState();
}

class _HistoryTransacState extends State<HistoryTransac> {
  late Future<List<TransacItem>> _transacList;
  String? selectedMonth;
  int? selectedYear;

  List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  List<int> years = List.generate(10, (index) => DateTime.now().year - index); // Últimos 10 años

  @override
  void initState() {
    super.initState();

    // Asegúrate de que los valores iniciales estén correctamente configurados
    selectedMonth = months[DateTime.now().month - 1]; // Mes actual
    selectedYear = DateTime.now().year; // Año actual

    _transacList = _getTransacsForMonthAndYear(selectedMonth!, selectedYear!); // Inicializamos las transacciones
  }

  Future<List<TransacItem>> _getTransacsForMonthAndYear(String month, int year) async {
    final transacs = await TransacDatabase.instance.getAllTransacs(); 
    final monthIndex = months.indexOf(month) + 1;
    
    final filteredTransacs = transacs.where((tx) {
      final txDate = DateTime.parse(tx.date); // Asegúrate de tener la fecha en formato ISO
      return txDate.month == monthIndex && txDate.year == year;
    }).toList();
    
    // Ordena las transacciones por fecha descendente
    filteredTransacs.sort((a, b) {
      final dateA = DateTime.parse(a.date);
      final dateB = DateTime.parse(b.date);
      return dateB.compareTo(dateA); // Orden descendente
    });

    return filteredTransacs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transacciones'),
        centerTitle: true,
        elevation: 0, // Sin sombra para diseño minimalista
        backgroundColor: Colors.transparent, // Fondo transparente para un diseño limpio
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filtro de mes y año
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDropdown(
                  value: selectedMonth!,
                  items: months,
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value;
                      _transacList = _getTransacsForMonthAndYear(selectedMonth!, selectedYear!);
                    });
                  },
                ),
                _buildDropdown(
                  value: selectedYear.toString(),
                  items: years.map((year) => year.toString()).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedYear = int.parse(value!);
                      _transacList = _getTransacsForMonthAndYear(selectedMonth!, selectedYear!);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de transacciones
            Expanded(
              child: FutureBuilder<List<TransacItem>>(
                future: _transacList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay transacciones para este filtro.'));
                  } else {
                    final transactions = snapshot.data!;
                    return ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isIngreso = tx.type == 'Ingreso';
                        final txAmount = isIngreso ? tx.amount : -tx.amount; // Los gastos como valores negativos
                        final txDate = DateTime.parse(tx.date);
                        final formattedDate = DateFormat('dd/MM/yyyy').format(txDate);

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3, // Menos sombra para un diseño más limpio
                          // child: ListTile(
                          //   contentPadding: const EdgeInsets.all(16),
                          //   leading: CircleAvatar(
                          //     backgroundColor: isIngreso ? Colors.green : Colors.red,
                          //     child: Icon(
                          //       isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          //   title: Text(
                          //     '\$${txAmount.toStringAsFixed(2)}',
                          //     style: TextStyle(
                          //       fontSize: 20,
                          //       fontWeight: FontWeight.bold,
                          //       color: isIngreso ? Colors.green : Colors.red,
                          //     ),
                          //   ),
                          //   subtitle: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(tx.description),
                          //       Text(formattedDate),
                          //     ],
                          //   ),
                          // ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ícono tipo de transacción
                                CircleAvatar(
                                  backgroundColor: isIngreso ? Colors.green : Colors.red,
                                  child: Icon(
                                    isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Detalles de la transacción
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '\$${txAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isIngreso ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      Text(tx.description),
                                      Text(formattedDate),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botones de acción
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => Padding(
                                            padding: const EdgeInsets.only(top: 32.0),
                                            child: AddTransacForm(
                                              type: tx.type,
                                              existingItem: tx,
                                              onSaved: () {
                                                setState(() {
                                                  _transacList = _getTransacsForMonthAndYear(selectedMonth!, selectedYear!);
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await TransacDatabase.instance.deleteTransac(tx.id!);
                                        setState(() {
                                          _transacList = _getTransacsForMonthAndYear(selectedMonth!, selectedYear!);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Widget para crear los Dropdowns de mes y año
      Widget _buildDropdown({
        required String value,
        required List<String> items,
        required ValueChanged<String?> onChanged,
      }) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        isExpanded: false, // No expandir para hacerlo más minimalista
        underline: const SizedBox(), // Eliminar la línea por debajo
        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }
}
