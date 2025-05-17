import 'package:flutter/material.dart';
import 'package:test_flutter/database/transac_database.dart';
import 'package:test_flutter/models/transac_item.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/views/add_transac_form.dart';

class HistoryTransac extends StatefulWidget {
  final String? filtroTipo;
  final VoidCallback? onNavBarTap; // Añade este parámetro
  final int userId; // Añadido



  const HistoryTransac({
    super.key,
    this.filtroTipo,
    this.onNavBarTap, // Inclúyelo en el constructor
    required this.userId, // Añadido
     });

  @override
  State<HistoryTransac> createState() => _HistoryTransacState();
}

class _HistoryTransacState extends State<HistoryTransac> {
  late Future<List<TransacItem>> _transacList;
  String? selectedMonth;
  int? selectedYear;

  List<String> months = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio',
    'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  
  List<int> years = List.generate(10, (index) => DateTime.now().year - index);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavBarTap?.call();
    });
    _loadInitialData();
  }

  void _loadInitialData() {
    selectedMonth = months[DateTime.now().month - 1];
    selectedYear = DateTime.now().year;
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _transacList = _getTransacsForMonthAndYear(selectedMonth!, selectedYear!);
    });
  }

  @override
  void didUpdateWidget(HistoryTransac oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filtroTipo != oldWidget.filtroTipo) {
      _refreshData();
    }
  }

  Future<List<TransacItem>> _getTransacsForMonthAndYear(String month, int year) async {
    final transacs = await TransacDatabase.instance.getTransacsByUser(widget.userId);
    final monthIndex = months.indexOf(month) + 1;

    print('Filtrando con: month=$monthIndex, year=$year, tipo=${widget.filtroTipo}');

    final filteredTransacs = transacs.where((tx) {
      final txDate = DateTime.parse(tx.date);
      final bool matchesDate = txDate.month == monthIndex && txDate.year == year;
      final bool matchesType = widget.filtroTipo == null || 
                            tx.type.toLowerCase() == widget.filtroTipo!.toLowerCase();
      
      print('Transacción: ${tx.type} - Filtro: ${widget.filtroTipo} - Match: $matchesType');
      
      return matchesDate && matchesType;
    }).toList();

    print('Transacciones filtradas: ${filteredTransacs.length}');
    
    filteredTransacs.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    
    return filteredTransacs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transacciones', 
               style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildFiltersRow(),
          const SizedBox(height: 16),
          if (widget.filtroTipo != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Filtrado por: ${widget.filtroTipo}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMonthDropdown(),
        _buildYearDropdown(),
      ],
    );
  }

  Widget _buildMonthDropdown() {
    return _buildDropdown(
      value: selectedMonth!,
      items: months,
      onChanged: (value) {
        selectedMonth = value;
        _refreshData();
      },
    );
  }

  Widget _buildYearDropdown() {
    return _buildDropdown(
      value: selectedYear.toString(),
      items: years.map((year) => year.toString()).toList(),
      onChanged: (value) {
        selectedYear = int.parse(value!);
        _refreshData();
      },
    );
  }

  Widget _buildTransactionsList() {
    return FutureBuilder<List<TransacItem>>(
      future: _transacList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No hay transacciones para este período.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildTransactionCard(snapshot.data![index]);
            },
          );
        }
      },
    );
  }

  Widget _buildTransactionCard(TransacItem tx) {
    final isIngreso = tx.type == 'Ingreso';
    final txAmount = isIngreso ? tx.amount : -tx.amount;
    final formattedDate = _formatDate(tx.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isIngreso ? Colors.green : Colors.red,
              child: Icon(
                isIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
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
            _buildActionButtons(tx),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(TransacItem tx) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blueGrey),
          onPressed: () => _showEditForm(context, tx),
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(context, tx.id!),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final txDate = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(txDate);
    } catch (e) {
      print('Error formateando fecha: $e');
      return dateString;
    }
  }

  void _showEditForm(BuildContext context, TransacItem tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: const EdgeInsets.only(top: 32.0),
        child: AddTransacForm(
          type: tx.type,
          existingItem: tx,
          onSaved: _refreshData,
          userId: tx.userId, // Pasa el userId desde la transacción existente
        ),
      ),
    );
  }

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
        isExpanded: false,
        underline: const SizedBox(),
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

  void _confirmDelete(BuildContext context, int transacId) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Estás seguro?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Esta acción eliminará la transacción permanentemente.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await TransacDatabase.instance.deleteTransac(transacId);
              _refreshData();
            },
          ),
        ],
      ),
    );
  }
}