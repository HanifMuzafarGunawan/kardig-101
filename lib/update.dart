import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/card_model.dart';

class UpdatePage extends StatefulWidget {
  final CardData existingCard;

  const UpdatePage({super.key, required this.existingCard});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _firstHourController;
  late TextEditingController _afterFirstHourController;
  late TextEditingController _maxRateController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.existingCard.qrCode);
    _nameController = TextEditingController(text: widget.existingCard.name);
    _firstHourController = TextEditingController(
      text: widget.existingCard.firstHourRate.toString(),
    );
    _afterFirstHourController = TextEditingController(
      text: widget.existingCard.afterFirstHourRate.toString(),
    );
    _maxRateController = TextEditingController(
      text: widget.existingCard.maxRate != null
          ? widget.existingCard.maxRate.toString()
          : '',
    );

    // parsing date & time
    try {
      final partsDate = widget.existingCard.date.split(' ');
      final partsTime = widget.existingCard.time.split(':');
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
      final monthIndex = monthNames.indexOf(partsDate[1]) + 1;
      _selectedDateTime = DateTime(
        int.parse(partsDate[2]),
        monthIndex,
        int.parse(partsDate[0]),
        int.parse(partsTime[0]),
        int.parse(partsTime[1]),
      );
    } catch (_) {
      _selectedDateTime = DateTime.now();
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

  void _updateCard() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final updatedCard = CardData(
          id: widget.existingCard.id,
          qrCode: _codeController.text,
          name: _nameController.text,
          date: _formatDate(),
          time: _formatTime(),
          firstHourRate: int.parse(_firstHourController.text),
          afterFirstHourRate: int.parse(_afterFirstHourController.text),
          maxRate: _maxRateController.text.isNotEmpty
              ? int.parse(_maxRateController.text)
              : null,
          color: widget.existingCard.color,
        );

        await DatabaseHelper().updateCard(updatedCard);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil diperbarui')),
        );
        Navigator.of(context).pop(true);
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
        title: const Text('Edit Kartu'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 20),
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Tarif 1 jam pertama wajib diisi'
                    : null,
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
                validator: (value) => value == null || value.isEmpty
                    ? 'Tarif 1 jam setelahnya wajib diisi'
                    : null,
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
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _updateCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Update',
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
