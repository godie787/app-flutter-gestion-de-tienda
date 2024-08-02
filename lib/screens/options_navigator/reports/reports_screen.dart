import 'package:flutter/material.dart';
import '../reports/daily_reports.dart';
import '../../../services/database_service.dart';

class ReportsScreen extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Fondo similar a las otras vistas
      appBar: AppBar(
        title: const Text('Informes'),
        backgroundColor: Colors.teal, // Mantén la consistencia con otras pantallas
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Generar Informes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildReportOption(
              context,
              icon: Icons.calendar_today,
              title: 'Informe Diario',
              description: 'Genera un resumen de las ventas diarias.',
              color: Colors.blueAccent,
              onTap: () async {
                // Generar el informe diario y obtener los datos
                Map<String, dynamic>? reportData = await _databaseService.generateDailyReport();

                if (reportData != null) {
                  DateTime reportDate = reportData['date'];
                  double totalSales = reportData['totalVentas'];
                  int totalProductsSold = reportData['cantidadProductosVendidos'];

                  // Navegar a la vista del informe diario
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyReportsScreen(
                        reportDate: reportDate,
                        totalSales: totalSales,
                        totalProductsSold: totalProductsSold,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No se pudo generar el informe diario.'),
                    ),
                  );
                }
              },
            ),
            _buildReportOption(
              context,
              icon: Icons.calendar_view_week,
              title: 'Informe Semanal',
              description: 'Genera un resumen de las ventas semanales.',
              color: Colors.orangeAccent,
              onTap: () {
                // Acción para el Informe Semanal
              },
            ),
            _buildReportOption(
              context,
              icon: Icons.calendar_view_month,
              title: 'Informe Mensual',
              description: 'Genera un resumen de las ventas mensuales.',
              color: Colors.greenAccent,
              onTap: () {
                // Acción para el Informe Mensual
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportOption(BuildContext context,
      {required IconData icon,
      required String title,
      required String description,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}
