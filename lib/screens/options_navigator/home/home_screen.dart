import 'package:flutter/material.dart';
import '../../../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;
  bool _isCajaAbierta = false;
  List<Map<String, dynamic>> _productosVendidos = [];
  double _totalSales = 0;
  int _totalProductsSold = 0;
  int _totalSalesCount = 0;

  @override
  void initState() {
    super.initState();
    _checkCajaStatus();
    _fetchProductosVendidos();
  }

  Future<void> _showOpenCajaDialog() async {
    bool? shouldOpenCaja = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_open,
                  size: 60,
                  color: Colors.teal,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Abrir Caja',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '¿Deseas abrir la caja para comenzar a vender?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Sí'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldOpenCaja == true) {
      await _toggleCaja(); // Abre la caja si el usuario lo desea
    }
  }

  Future<void> _showCloseCajaDialog() async {
    bool? shouldCloseCaja = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock,
                  size: 60,
                  color: Colors.teal,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cerrar Caja',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '¿Estás seguro de que deseas cerrar la caja?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text('Sí'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldCloseCaja == true) {
      await _toggleCaja(); // Cierra la caja si el usuario lo desea
    }
  }

  Future<void> _checkCajaStatus() async {
    setState(() {
      _isLoading = true;
    });

    _isCajaAbierta = await _databaseService.getCajaStatus();

    setState(() {
      _isLoading = false;
    });

    if (!_isCajaAbierta) {
      _showOpenCajaDialog();
    } else {
      _fetchProductosVendidos(); // Solo cargar productos si la caja está abierta
    }
  }

  Future<void> _toggleCaja() async {
    setState(() {
      _isLoading = true;
    });

    if (_isCajaAbierta) {
      await _databaseService.closeCaja();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caja cerrada exitosamente.'),
        ),
      );
    } else {
      await _databaseService.openCaja();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caja abierta exitosamente.'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
      _isCajaAbierta = !_isCajaAbierta;
    });

    if (_isCajaAbierta) {
      _fetchProductosVendidos(); // Cargar productos después de abrir la caja
    }
  }

  Future<void> _fetchProductosVendidos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var data = await _databaseService.getProductosVendidosDelDia();
      if (data != null) {
        setState(() {
          _productosVendidos = data['productosVendidos'];
          _totalSales = data['totalSales'];
          _totalProductsSold = data['totalProductsSold'];
          _totalSalesCount = data['totalSalesCount'];
        });
      } else {
        setState(() {
          _productosVendidos = [];
          _totalSales = 0;
          _totalProductsSold = 0;
          _totalSalesCount = 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener productos vendidos: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: _fetchProductosVendidos,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50), // Espacio para ajustar la altura
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Icon(
                            Icons.analytics,
                            size: 80,
                            color: Colors.teal[800],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              if (_isCajaAbierta) {
                                await _showCloseCajaDialog();
                              } else {
                                await _showOpenCajaDialog();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 50,
                              width: 150,
                              decoration: BoxDecoration(
                                color: _isCajaAbierta
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 3,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: _isCajaAbierta
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Icon(
                                        _isCajaAbierta
                                            ? Icons.nights_stay
                                            : Icons.wb_sunny,
                                        color: _isCajaAbierta
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      _isCajaAbierta
                                          ? '    CERRAR CAJA'
                                          : 'ABRIR CAJA   ',
                                      style: TextStyle(
                                        color: _isCajaAbierta
                                            ? Colors.white
                                            : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: SizedBox(
                            width: 80,
                            child: Divider(
                              thickness: 2,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Resumen del Día',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildResumenCard(
                          icon: Icons.attach_money,
                          title: 'Total de Ventas',
                          value: '\$${_totalSales.toStringAsFixed(2)}',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 10),
                        _buildResumenCard(
                          icon: Icons.shopping_cart,
                          title: 'Productos Vendidos',
                          value: '$_totalProductsSold',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 10),
                        _buildResumenCard(
                          icon: Icons.receipt,
                          title: 'Ventas Realizadas',
                          value: '$_totalSalesCount',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Productos Vendidos',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _productosVendidos.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _productosVendidos.length,
                                itemBuilder: (context, index) {
                                  final sale = _productosVendidos[index];
                                  return Card(
                                    child: ListTile(
                                      leading: Icon(Icons.check_circle,
                                          color: Colors.teal),
                                      title: Text(sale['productName']),
                                      subtitle: Text(
                                          'Precio: \$${sale['salePrice'].toStringAsFixed(2)} '),
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                child: Text(
                                  'Abra la caja para comenzar a vender.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
