import 'package:flutter/material.dart';

void main() => runApp(const TheProject());

class TheProject extends StatelessWidget {
  const TheProject({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Dashboard());
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCenter();
    });
  }

  void _scrollToCenter() {
    // Hitung posisi: (Lebar Card1) + (SizedBox width)
    // Dalam kasusmu: 800 + 10 = 810
    _scrollController.jumpTo(470);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The Project"),
        backgroundColor: Color.fromARGB(255, 80, 0, 178),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildCard('Card1', Color.fromARGB(255, 80, 0, 178)),
                  SizedBox(width: 10),
                  _buildCard('Card2', Color.fromARGB(255, 80, 0, 178)),
                  SizedBox(width: 10),
                  _buildCard('Card3', Color.fromARGB(255, 80, 0, 178)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Menu Utama",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap:
                    true, // PENTING: Agar GridView tidak mengambil semua space
                physics:
                    const NeverScrollableScrollPhysics(), // Biarkan SingleChildScrollView yang handle scroll-nya
                crossAxisCount: 4, // Jumlah kolom icon
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildMenuIcon(Icons.account_balance_wallet, "Dompet"),
                  _buildMenuIcon(Icons.send, "Transfer"),
                  _buildMenuIcon(Icons.history, "Riwayat"),
                  _buildMenuIcon(Icons.payment, "Tagihan"),
                  _buildMenuIcon(Icons.qr_code, "Scan QR"),
                  _buildMenuIcon(Icons.security, "Keamanan"),
                  _buildMenuIcon(Icons.help, "Bantuan"),
                  _buildMenuIcon(Icons.settings, "Lainnya"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Card Design
Widget _buildCard(String title, Color color) {
  return Container(
    width: 800,
    height: 250,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget _buildMenuIcon(IconData icon, String label) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 80, 0, 178),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color.fromARGB(255, 80, 0, 178)),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
  );
}
