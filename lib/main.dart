import 'package:flutter/material.dart';
import 'camera.dart';

void main() => runApp(const TheProject());

class TheProject extends StatelessWidget {
  const TheProject({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Data kartu utama (urutan dari belakang ke depan di dalam Stack)
  final List<Map<String, dynamic>> _cards = [
    {'title': 'Belanja', 'color': const Color.fromARGB(255, 99, 78, 169)},
    {'title': 'minum', 'color': const Color(0xFF34A853)},
    {'title': 'Sekunder', 'color': const Color(0xFF1A73E8)},
  ];

  // List cadangan asli untuk mengetahui urutan halaman/titik indikator yang aktif
  final List<String> _originalOrder = ['Belanja', 'minum', 'Sekunder'];

  double _swipeOffset = 0.0;
  bool _isDragging = false;

  void _shuffleCard() {
    setState(() {
      // Mengambil kartu paling depan (indeks terakhir) lalu ditaruh ke belakang (indeks 0)
      final topCard = _cards.removeLast();
      _cards.insert(0, topCard);
      _swipeOffset = 0.0;
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mencari tahu kartu apa yang sekarang berada di posisi paling depan
    String currentTopTitle = _cards.last['title'];
    int activeIndex = _originalOrder.indexOf(currentTopTitle);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Kardig Wallet",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Area Tumpukan Kartu di Tengah Layar
          Container(
            height: 520,
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment
                  .center, // Memastikan semua elemen default berada di tengah
              children: _cards.asMap().entries.map((entry) {
                int index = entry.key;
                var cardData = entry.value;

                bool isTopCard = index == _cards.length - 1;

                // Efek tumpukan berlapis: kartu belakang dibuat agak bergeser ke atas
                double baseTopPosition = (_cards.length - 1 - index) * -16.0;

                // Efek skala perspektif untuk memberikan kedalaman visual 3D
                double scale = 1.0 - ((_cards.length - 1 - index) * 0.05);

                // Menggunakan Transform.translate untuk menggeser kartu teratas saat di-drag
                // Ini menggantikan penggunaan 'left' agar tidak merusak posisi center awal
                Widget cardWidget = AnimatedContainer(
                  duration: Duration(milliseconds: _isDragging ? 0 : 300),
                  transform: Matrix4.identity()
                    ..translate(
                      0.0, //posisi X
                      baseTopPosition + (isTopCard ? _swipeOffset : 0.0), //posisi Y
                      baseTopPosition,
                    ),
                  child: Transform.scale(
                    scale: scale + (_isDragging ? 0.3 : 0.3),
                    child: _buildVerticalCard(
                      cardData['title'],
                      cardData['color'],
                    ),
                  ),
                );

                // Logika khusus untuk kartu teratas agar bisa di-shuffle secara horizontal
                if (isTopCard) {
                  return GestureDetector(
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _isDragging = true;
                        _swipeOffset += details.primaryDelta ?? 0;
                      });
                    },
                    onVerticalDragEnd: (details) {
                      // Jika digeser ke kanan atau kiri lebih dari 120 piksel, shuffle kartu
                      if (_swipeOffset.abs() > 120) {
                        _shuffleCard();
                      } else {
                        setState(() {
                          _isDragging = false;
                          _swipeOffset = 0.0;
                        });
                      }
                    },
                    child: cardWidget,
                  );
                }

                // Untuk kartu belakang, langsung return widget tanpa GestureDetector
                return cardWidget;
              }).toList(),
            ),
          ),

          const SizedBox(height: 32),

          // 2. Titik-titik Indikator Jumlah Kartu (Page Indicator)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_originalOrder.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: activeIndex == index
                    ? 24
                    : 8, // Titik aktif dibuat lebih panjang melonjong
                height: 8,
                decoration: BoxDecoration(
                  color: activeIndex == index
                      ? const Color(0xFFA8C7FA)
                      : Colors.grey.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),

      // 3. Tombol Tambah di Posisi Center Bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context,
          ).push(MaterialPageRoute(builder: (_) => const Camera()));
        },
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Warna gelap minimalis kontras
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        ),
        icon: const Icon(Icons.add, color: Color(0xFFA8C7FA)),
        label: const Text(
          "Tambah karcis",
          style: TextStyle(
            color: Color(0xFFE3E2E6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Widget Desain Kartu Vertikal dengan QR Code di Tengah
Widget _buildVerticalCard(String title, Color color) {
  return Container(
    width: 240,
    height: 360,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // Bagian Atas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const Icon(Icons.contactless, color: Colors.white, size: 28),

          ],
        ),

        // Bagian Bawah
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1234 5678 - 1234 5678",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),

        // Bagian Bawah
        // Bagian Tengah: QR Code
        Center(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.qr_code_2, size: 160, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}
