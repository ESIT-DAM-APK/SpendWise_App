import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart'; // Asegúrate de tener el método getAllTransacs() correctamente implementado
import 'package:test_flutter/transac_item.dart';
import 'package:intl/intl.dart';

class HistoryTransac extends StatefulWidget {
  const HistoryTransac({super.key});

  @override
  State<HistoryTransac> createState() => _HistoryTransacState();
}

class _HistoryTransacState extends State<HistoryTransac> {
  late Future<List<TransacItem>> _transacList;
  String? selectedMonth;
  List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    
    // Inicializar selectedMonth con el mes actual o el primer mes de la lista si hay algún error
    selectedMonth = months.firstWhere(
      (month) => month.toLowerCase() == DateFormat('MMMM').format(DateTime.now()).toLowerCase(),
      orElse: () => months[4], // Si no se encuentra el mes, se asigna Mayo por defecto
    );

    _transacList = _getTransacsForMonth(selectedMonth!);
  }

  Future<List<TransacItem>> _getTransacsForMonth(String month) async {
    final transacs = await TransacDatabase.instance.getAllTransacs(); 
    final monthIndex = months.indexOf(month) + 1;
    final filteredTransacs = transacs.where((tx) {
      final txDate = DateTime.parse(tx.date); // Asegúrate de tener la fecha en formato ISO
      return txDate.month == monthIndex;
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedMonth,
              onChanged: (value) {
                if (value != null && months.contains(value)) {
                  setState(() {
                    selectedMonth = value;
                    _transacList = _getTransacsForMonth(selectedMonth!);
                  });
                }
              },
              items: months.map((month) {
                return DropdownMenuItem<String>(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TransacItem>>(
              future: _transacList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay transacciones para este mes.'));
                } else {
                  final transactions = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.builder(
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
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: isIngreso ? Colors.green : Colors.red,
                              child: Icon(
                                isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              '\$${txAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isIngreso ? Colors.green : Colors.red,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.description),
                                Text(formattedDate),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
