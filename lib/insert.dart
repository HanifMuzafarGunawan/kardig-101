import 'dart:io';
import 'package:image_picker/image_picker.dart'; // 🛠️ TAMBAHAN: Impor ini wajib ada agar kamera berfungsi
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/card_model.dart';

class InsertPage extends StatefulWidget {
  final String? scannedCode;
  final String? scannedImagePath;

  const InsertPage({super.key, this.scannedCode, this.scannedImagePath});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstHourController = TextEditingController();
  final TextEditingController _afterFirstHourController =
      TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  String? _pathFotoTersimpan;

  @override
  void initState() {
    super.initState();
    if (widget.scannedCode != null) {
      _codeController.text = widget.scannedCode!;
    }
    if (widget.scannedImagePath != null) {
      _pathFotoTersimpan = widget.scannedImagePath!;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _firstHourController.dispose();
    _afterFirstHourController.dispose();
    _maxRateController.dispose();
    super.dispose();
  }

  Future<void> _ambilFotoKarcis() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality:
            70, // Kompres kualitas gambar agar hemat memori database HP
      );

      if (image != null) {
        setState(() {
          _pathFotoTersimpan = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka kamera: $e')));
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _formatDate() {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final day = _selectedDateTime.day.toString().padLeft(2, '0');
    final month = monthNames[_selectedDateTime.month - 1];
    final year = _selectedDateTime.year;
    return '$day $month $year';
  }

  String _formatTime() {
    final hour = _selectedDateTime.hour.toString().padLeft(2, '0');
    final minute = _selectedDateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final allCards = await DatabaseHelper().getAllCards();
        final colorIndex = allCards.length % 4;
        final colors = [
          0xFFE53935, // Merah
          0xFF1E88E5, // Biru
          0xFF43A047, // Hijau
          0xFFE0AD24, // Kuning
          0xFF9C27B0, // Ungu
          0xFF673AB7, // Indigo
          0xFFE91E63, // Pink
        ];

        final newCard = CardData(
          qrCode: _codeController.text,
          name: _nameController.text,
          date: _formatDate(),
          time: _formatTime(),
          firstHourRate: int.parse(_firstHourController.text),
          afterFirstHourRate: int.parse(_afterFirstHourController.text),
          maxRate: _maxRateController.text.isNotEmpty
              ? int.parse(_maxRateController.text)
              : null,
          color: colors[colorIndex],
          fotoKarcisFisik: _pathFotoTersimpan,
        );

        await DatabaseHelper().insertCard(newCard);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan')));
        Navigator.of(context).pop(true); // Return true untuk trigger refresh
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah ke Wallet'),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Lengkapi informasi berikut untuk menambahkan ke Wallet',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),

              // 1. Input Kode QR
              TextFormField(
                controller: _codeController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Kode QR',
                  filled: true,
                  fillColor: const Color(0xFF131314),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // 2. Input Nama
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  filled: true,
                  fillColor: const Color(0xFF1E1E20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. Pilihan Tanggal
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: _formatDate()),
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      filled: true,
                      fillColor: const Color(0xFF1E1E20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Pilihan Waktu
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(text: _formatTime()),
                    decoration: InputDecoration(
                      labelText: 'Waktu',
                      filled: true,
                      fillColor: const Color(0xFF1E1E20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. Input Tarif 1 Jam Pertama
              TextFormField(
                controller: _firstHourController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Tarif 1 jam pertama',
                  filled: true,
                  fillColor: const Color(0xFF1E1E20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tarif 1 jam pertama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 6. Input Tarif Jam Berikutnya
              TextFormField(
                controller: _afterFirstHourController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Tarif 1 jam setelahnya',
                  filled: true,
                  fillColor: const Color(0xFF1E1E20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tarif 1 jam setelahnya wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 7. Input Tarif Maksimal (Opsional)
              TextFormField(
                controller: _maxRateController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Tarif maksimal (opsional)',
                  filled: true,
                  fillColor: const Color(0xFF1E1E20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),

              // 📸 8. Tombol Kamera Manual
              GestureDetector(
                onTap: _ambilFotoKarcis,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E20),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _pathFotoTersimpan != null
                          ? Colors.green
                          : Colors.white24,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _pathFotoTersimpan != null
                            ? Icons.check_circle
                            : Icons.camera_alt,
                        color: _pathFotoTersimpan != null
                            ? Colors.green
                            : Colors.white70,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _pathFotoTersimpan != null
                            ? 'Foto Karcis Berhasil Disimpan'
                            : 'Ambil Foto Karcis Fisik (Opsional)',
                        style: TextStyle(
                          color: _pathFotoTersimpan != null
                              ? Colors.green
                              : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 🚀 9. Tombol Simpan Akhir
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
