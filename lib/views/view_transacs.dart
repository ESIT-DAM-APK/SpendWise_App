import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart';
import 'package:test_flutter/transac_item.dart';

class ViewTransacs extends StatefulWidget {
  const ViewTransacs({super.key});

  @override
  State<ViewTransacs> createState() => _ViewTransacsState();
}

class _ViewTransacsState extends State<ViewTransacs> {
  late Future<List<TransacItem>> _transacList;

  @override
  void initState() {
    super.initState();
    _transacList = TransacDatabase.instance.getAllTransacs(); // método que crearás abajo
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TransacItem>>(
      future: _transacList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay transacciones.'));
        } else {
          final transactions = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: transactions.map((tx) {
                final isIngreso = tx.type == 'Ingreso';
                return Container(
                  decoration: BoxDecoration(
                    color: isIngreso ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tx.type,
                        style: TextStyle(
                          color: isIngreso ? Colors.green[800] : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('\$${tx.amount.toStringAsFixed(2)}'),
                      Text(tx.description),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
