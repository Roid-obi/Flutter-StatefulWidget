import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF468A9A),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF468A9A)),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      home: const CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // New flow: two text inputs + operator selector + result dialog
  final TextEditingController _firstController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  String? _selectedOperator; // '+', '-', '×', '÷'

  // (old helpers removed) - new flow uses text fields

  void _clearAll() {
    setState(() {
      _firstController.clear();
      _secondController.clear();
      _selectedOperator = null;
    });
  }

  String _formatNumber(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  // not used in new flow

  double _compute(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0) return double.nan;
        return a / b;
      default:
        return b;
    }
  }

  // calculation handled by computeAndShowDialog

  void computeAndShowDialog() {
    final a = double.tryParse(_firstController.text.replaceAll(',', '.'));
    final b = double.tryParse(_secondController.text.replaceAll(',', '.'));
    if (a == null || b == null) {
      _showResultDialog(
        'Input tidak valid. Masukkan angka pada baris 1 dan 2.',
      );
      return;
    }
    if (_selectedOperator == null) {
      _showResultDialog('Pilih operasi di baris 3 (Tambah/Kurang/Kali/Bagi).');
      return;
    }
    final res = _compute(a, b, _selectedOperator!);
    final left = _formatNumber(a);
    final right = _formatNumber(b);
    if (res.isNaN || res.isInfinite) {
      // show expression and error
      final expr = '$left ${_selectedOperator!} $right = Error';
      _showResultDialog(expr);
    } else {
      final resultStr = _formatNumber(res);
      final expr = '$left ${_selectedOperator!} $right = $resultStr';
      _showResultDialog(expr);
    }
  }

  void _showResultDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hasil Operasi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Buttons are built inline in the new flow

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF468A9A);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Calculator',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row 1: first value input
              const Text(
                'Nilai Pertama',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _firstController,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan angka pertama',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Row 2: second value input
              const Text(
                'Nilai Kedua',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _secondController,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Masukkan angka kedua',
                  filled: true,
                  fillColor: const Color(0xFFF7F7F7),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // Row 3: operator selection
              const Text(
                'Pilih Operasi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedOperator = '+'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _selectedOperator == '+'
                              ? base
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: _selectedOperator == '+'
                            ? base
                            : Colors.white,
                        foregroundColor: _selectedOperator == '+'
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedOperator = '-'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _selectedOperator == '-'
                              ? base
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: _selectedOperator == '-'
                            ? base
                            : Colors.white,
                        foregroundColor: _selectedOperator == '-'
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kurang'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedOperator = '×'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _selectedOperator == '×'
                              ? base
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: _selectedOperator == '×'
                            ? base
                            : Colors.white,
                        foregroundColor: _selectedOperator == '×'
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Kali'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedOperator = '÷'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: _selectedOperator == '÷'
                              ? base
                              : Colors.grey.shade300,
                        ),
                        backgroundColor: _selectedOperator == '÷'
                            ? base
                            : Colors.white,
                        foregroundColor: _selectedOperator == '÷'
                            ? Colors.white
                            : Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Bagi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Row 4: compute button and result dialog
              OutlinedButton(
                onPressed: _clearAll,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Bersihkan',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: computeAndShowDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: base,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Hitung',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
