import 'package:flutter/material.dart';
import '../options_drawer/chistes.dart';
import 'dart:math';

class ChistesFomesScreen extends StatefulWidget {
  const ChistesFomesScreen({Key? key}) : super(key: key);

  @override
  _ChistesFomesScreenState createState() => _ChistesFomesScreenState();
}

class _ChistesFomesScreenState extends State<ChistesFomesScreen> {
  String _chisteFome = '';

  void _mostrarChisteFome() {
    final random = Random();
    final chiste = chistesFomes[random.nextInt(chistesFomes.length)];
    setState(() {
      _chisteFome = chiste;
    });

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.orange, Colors.yellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_emotions,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),
                Text(
                  _chisteFome,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chistes Fomes'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan, Colors.pinkAccent, Colors.amber],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Monitas noches 🐒 disfruta de unos buenos chistes :)',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _mostrarChisteFome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text(
                'Crear un chiste fome al azar',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 40),
            if (_chisteFome.isNotEmpty)
              Card(
                color: Colors.white.withOpacity(0.8),
                margin: const EdgeInsets.symmetric(vertical: 20.0),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    _chisteFome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
