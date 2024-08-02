import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa la librería intl para el formato de fecha

class DailyReportsScreen extends StatelessWidget {
  final DateTime reportDate;
  final double totalSales;
  final double totalCost;
  final double totalProfit;
  final int totalProductsSold;
  final int totalSalesCount;
  final List<Map<String, dynamic>> salesDetails;

  const DailyReportsScreen({
    Key? key,
    required this.reportDate,
    required this.totalSales,
    required this.totalCost,
    required this.totalProfit,
    required this.totalProductsSold,
    required this.totalSalesCount,
    required this.salesDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formatear la fecha usando intl
    String formattedDate = DateFormat('dd/MM/yyyy').format(reportDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informe Diario'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Informe del Día: $formattedDate',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
                'Total Ventas:', '\$${totalSales.toStringAsFixed(2)}'),
            _buildInfoRow('Productos Vendidos:', '$totalProductsSold'),
            _buildInfoRow('Ventas Realizadas:', '$totalSalesCount'),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: salesDetails.length,
                itemBuilder: (context, index) {
                  final sale = salesDetails[index];
                  return Card(
                    child: ListTile(
                      title: Text(sale['productName']),
                      subtitle: Text(
                          'Precio: \$${sale['amount']} | Vendedor: ${sale['vendedor']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
