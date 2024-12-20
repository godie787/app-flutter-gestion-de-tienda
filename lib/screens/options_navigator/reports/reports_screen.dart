import 'package:flutter/material.dart';
import 'package:re_fashion/screens/options_navigator/reports/daily_reports.dart';
import 'package:re_fashion/services/database_service.dart';

class ReportsScreen extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Generar Informes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
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
                DateTime today = DateTime.now();
                List<Map<String, dynamic>> dailyReports =
                    await _databaseService.getDailyReportsByDay(today);

                if (dailyReports.isNotEmpty) {
                  // Navega a la vista de informes diarios, pasando la lista de informes del día
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DailyReportsScreen(
                        dailyReports: dailyReports, // Pasa los informes diarios
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'No hay informes disponibles para las cajas cerradas de hoy.'),
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
