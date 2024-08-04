import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyReportsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dailyReports; // Lista de informes diarios para el día especificado

  const DailyReportsScreen({
    Key? key,
    required this.dailyReports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informe Diario'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
          itemCount: dailyReports.length,
          itemBuilder: (context, index) {
            final report = dailyReports[index];
            String formattedOpenTime = DateFormat('HH:mm').format(report['openTime']);
            String formattedCloseTime = DateFormat('HH:mm').format(report['closeTime']);
            String duration = _calculateDuration(report['openTime'], report['closeTime']);
            String date = DateFormat('dd/MM/yyyy').format(report['openTime']);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Caja abierta el: $date',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Duración: $formattedOpenTime - $formattedCloseTime ($duration)',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildInfoRow('Total Ventas:', '\$${report['totalVentas'].toStringAsFixed(2)}'),
                _buildInfoRow('Productos Vendidos:', '${report['cantidadProductosVendidos']}'),
                _buildInfoRow('Ventas Realizadas:', '${report['cantidadVentasRealizadas']}'),
                const SizedBox(height: 20),
                const Text(
                  'Detalles de Ventas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                ...report['detallesVentas'].map<Widget>((sale) {
                  return Card(
                    child: ListTile(
                      title: Text(sale['productName']),
                      subtitle: Text(
                        'Precio: \$${sale['amount']} | Vendedor: ${sale['vendedor']}',
                      ),
                    ),
                  );
                }).toList(),
                const Divider(),
              ],
            );
          },
        ),
      ),
    );
  }

  String _calculateDuration(DateTime openTime, DateTime closeTime) {
    Duration duration = closeTime.difference(openTime);
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
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
