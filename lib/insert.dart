import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstHourController = TextEditingController();
  final TextEditingController _afterFirstHourController =
      TextEditingController();
  final TextEditingController _maxRateController = TextEditingController();
  final TextEditingController _dateTimeController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateTimeController.text = _formatDateTime(_selectedDateTime);
  }

  // ✅ Fungsi format tanggal & waktu yang hilang
  String _formatDateTime(DateTime dateTime) {
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = monthNames[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  DateTime? _parseDateTime(String value) {
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final parts = value.split(',');
    if (parts.length != 2) return null;

    final dateParts = parts[0].trim().split(' ');
    if (dateParts.length != 3) return null;

    final day = int.tryParse(dateParts[0]);
    final monthName = dateParts[1].trim().toLowerCase();
    final year = int.tryParse(dateParts[2]);
    if (day == null || year == null) return null;

    final monthIndex = monthNames.indexWhere(
      (name) => name.toLowerCase() == monthName,
    );
    if (monthIndex < 0) return null;

    final timeParts = parts[1].trim().split(':');
    if (timeParts.length != 2) return null;

    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return DateTime(year, monthIndex + 1, day, hour, minute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstHourController.dispose();
    _afterFirstHourController.dispose();
    _maxRateController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    FocusScope.of(
      context,
    ).requestFocus(FocusNode()); // agar keyboard tidak muncul

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context), child: child!);
      },
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        _dateTimeController.text = _formatDateTime(_selectedDateTime);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah ke Wallet'),
        backgroundColor: const Color(0xFF131314),
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
              TextFormField(
                controller: _dateTimeController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[0-9A-Za-z,\s:]")),
                ],
                onTap: _pickDateTime,
                decoration: InputDecoration(
                  labelText: 'Tanggal & Waktu',
                  hintText: _formatDateTime(_selectedDateTime),
                  filled: true,
                  fillColor: const Color(0xFF1E1E20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range, color: Colors.white70),
                    onPressed: _pickDateTime,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tanggal & waktu wajib diisi';
                  }

                  final parsed = _parseDateTime(value.trim());
                  if (parsed == null) {
                    return 'Format harus: dd MMMM yyyy, HH:mm';
                  }

                  _selectedDateTime = parsed;
                  _dateTimeController.text = _formatDateTime(parsed);
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                  final num? parsed = num.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                  final num? parsed = num.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num? parsed = num.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return 'Masukkan angka yang valid';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
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
