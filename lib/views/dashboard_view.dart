import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart'; // Ajusta el path
import 'package:test_flutter/helpers/modal_helpers.dart'; // Asegúrate de tener la función showAddIngresoModal y showAddGastoModal

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Función que se llama para actualizar la vista
  void _refreshData() {
    setState(() {}); // Llamamos a setState para que se recargue el FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido - Usuario'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _getTotalAmounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final totalIngresos = snapshot.data?['ingresos'] ?? 0.0;
            final totalGastos = snapshot.data?['gastos'] ?? 0.0;
            final saldo = totalIngresos - totalGastos;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '\$${saldo.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Saldo Disponible',
                          style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCard(
                    context,
                    title: 'Ingresos',
                    amount: totalIngresos,
                    color: Colors.green,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    context,
                    title: 'Gastos',
                    amount: totalGastos,
                    color: Colors.red,
                    onPressed: () {},
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavButton(
                        icon: Icons.arrow_upward,
                        color: Colors.green,
                        onPressed: () => showAddIngresoModal(
                          context,
                          refreshData: _refreshData, // Aquí pasamos la función
                        ),
                      ),
                      _buildNavButton(
                        icon: Icons.arrow_downward,
                        color: Colors.red,
                        onPressed: () => showAddGastoModal(
                          context,
                          refreshData: _refreshData, // Aquí también
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          return const Center(child: Text('No data available.'));
        },
      ),
    );
  }

  Future<Map<String, double>> _getTotalAmounts() async {
    final totalIngresos = await TransacDatabase.instance.getTotalAmount('Ingreso');
    final totalGastos = await TransacDatabase.instance.getTotalAmount('Gasto');

    return {
      'ingresos': totalIngresos,
      'gastos': totalGastos,
    };
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required double amount,
      required Color color,
      required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ver detalles',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
