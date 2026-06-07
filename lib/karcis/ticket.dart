import 'dart:io';
import 'dart:async'; // <-- Tambahan untuk Timer
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'karcis_parkir.dart';

// 1. StatefulWidget
class TicketDetailPage extends StatefulWidget {
  final KarcisParkir karcis;
  final Color warnaKartu;

  const TicketDetailPage({
    super.key,
    required this.karcis,
    required this.warnaKartu,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  Timer? _timer;
  bool _isFavorite = false;

  // Real Time
  @override
  void initState() {
    super.initState();
    // Timer berdetak setiap 1 detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tampilkanQRFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            elevation: 4,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Scan QR",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          body: Center(
            child: QrImageView(
              data: widget.karcis.qrData,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 1. Icon Favorite
          // IconButton(
          //   icon: Icon(
          //     _isFavorite ? Icons.star : Icons.star_border,
          //     color: _isFavorite ? Colors.yellow : Colors.white,
          //   ),
          //   onPressed: () {
          //     setState(() {
          //       _isFavorite = !_isFavorite;
          //     });

          //     // pop up notifikasi
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text(
          //           _isFavorite
          //               ? 'Ditambahkan ke Favorit'
          //               : 'Dihapus dari Favorit',
          //           style: const TextStyle(color: Colors.white),
          //         ),
          //         duration: const Duration(seconds: 1),
          //         backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          //       ),
          //     );
          //   },
          // ),
          // const SizedBox(width: 8),

          // 2. Tombol Titik Tiga (hapus)
          PopupMenuButton<String>(
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 255, 0, 0)),
            color: const Color.fromARGB(
              255,
              255,
              0,
              0,
            ), // Background popup gelap
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (String pilihan) {
              if (pilihan == 'Hapus') {
                // Aksi Hapus: Menutup halaman karcis dan kembali ke menu awal
                Navigator.pop(context);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Hapus',
                child: Text('Hapus', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCardUtama(context),
            const SizedBox(height: 16),
            _buildViewPhotosButton(context),
            const SizedBox(height: 24),
            const Text(
              "Karcis ini hanya duplikasi. Untuk memverifikasi detail karcis, hubungi penyedia layanan parkir.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardUtama(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: widget.warnaKartu,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.local_parking, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Karcis",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "parkir tiket",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          Center(
            child: GestureDetector(
              onTap: () => _tampilkanQRFullScreen(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: widget.karcis.qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Memanggil data menggunakan 'widget.karcis'
          _buildDetailRow("Waktu Parkir", widget.karcis.durasiParkirSaatIni),
          _buildDetailRow(
            "Jam Masuk",
            "${widget.karcis.jamMasuk.hour.toString().padLeft(2, '0')}:${widget.karcis.jamMasuk.minute.toString().padLeft(2, '0')}",
          ),
          _buildDetailRow(
            "Harga 1 Jam Pertama",
            "Rp ${widget.karcis.hargaAwal}",
          ),
          _buildDetailRow(
            "Jam Berikutnya",
            "Rp ${widget.karcis.hargaBerikutnya} / jam",
          ),
          if (widget.karcis.tarifMaksimal != null)
            _buildDetailRow(
              "Tarif Maksimal",
              "Rp ${widget.karcis.tarifMaksimal}",
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewPhotosButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Foto Karcis Fisik",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),

                  // child: 

                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Lihat Foto Karcis",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                color: Colors.grey,
                child: const Icon(
                  Icons.qr_code,
                  size: 20,
                  color: Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
