import 'package:flutter/material.dart';
import 'camera.dart';
import 'insert.dart';
import 'update.dart';
import 'database/database_helper.dart';
import 'models/card_model.dart';
import 'karcis/ticket.dart';
import 'karcis/karcis_parkir.dart';

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
  // Data kartu dimuat dari database
  List<Map<String, dynamic>> _cards = [];
  bool _isLoading = true;

  // Warna-warna untuk kartu bergantian
  static const List<int> _cardColors = [
    0xFFE53935, // Merah
    0xFF1E88E5, // Biru
    0xFF43A047, // Hijau
    0xFFFDD835, // Kuning
  ];

  double _swipeOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadCardsFromDatabase();
  }

  Future<void> _loadCardsFromDatabase() async {
    try {
      final List<CardData> cardDataList = await DatabaseHelper().getAllCards();

      setState(() {
        _cards = cardDataList.asMap().entries.map((entry) {
          int index = entry.key;
          CardData card = entry.value;
          return {
            'id': card.id,
            'title': card.name,
            'color': Color(card.color),
            'qrCode': card.qrCode,
            'date': card.date,
            'time': card.time,
            'firstHourRate': card.firstHourRate,
            'afterFirstHourRate': card.afterFirstHourRate,
            'maxRate': card.maxRate,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading cards: $e')));
    }
  }

  void _shuffleCard() {
    setState(() {
      // Mengambil kartu paling depan (indeks terakhir) lalu ditaruh ke belakang (indeks 0)
      final topCard = _cards.removeLast();
      _cards.insert(0, topCard);
      _swipeOffset = 0.0;
      _isDragging = false;
    });
  }

  Future<void> _deleteCard(int cardId) async {
    try {
      await DatabaseHelper().deleteCard(cardId);
      _loadCardsFromDatabase();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kartu berhasil dihapus')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _editCard(int? cardId) async {
    if (cardId == null) return;
    try {
      final card = await DatabaseHelper().getCardById(cardId);
      if (card == null) return;

      final result = await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => UpdatePage(existingCard: card)));

      if (result == true) {
        _loadCardsFromDatabase();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mencari tahu kartu apa yang sekarang berada di posisi paling depan
    int activeIndex = _cards.isNotEmpty ? _cards.length - 1 : 0;

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.card_giftcard,
                    size: 64,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada kartu',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Area Tumpukan Kartu di Tengah Layar
                Container(
                  height: 520,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: _cards.asMap().entries.map((entry) {
                      int index = entry.key;
                      var cardData = entry.value;

                      bool isTopCard = index == _cards.length - 1;

                      // Efek tumpukan berlapis: kartu belakang dibuat agak bergeser ke atas
                      double baseTopPosition =
                          (_cards.length - 1 - index) * -16.0;  

                      // Efek skala perspektif untuk memberikan kedalaman visual 3D
                      double scale = 1.0 - ((_cards.length - 1 - index) * 0.05);

                      // Menggunakan Transform.translate untuk menggeser kartu teratas saat di-drag
                      Widget cardWidget = AnimatedContainer(
                        duration: Duration(milliseconds: _isDragging ? 0 : 300),
                        transform: Matrix4.identity()
                          ..translate(
                            0.0, //posisi X
                            baseTopPosition +
                                (isTopCard ? _swipeOffset : 0.0), //posisi Y
                            baseTopPosition,
                          ),
                        child: Transform.scale(
                          scale: scale + (_isDragging ? 0.3 : 0.3),
                          child: _buildVerticalCard(
                            cardData['title'],
                            cardData['color'],
                            cardData['qrCode'],
                            cardData['id'],
                          ),
                        ),
                      );

                      // Logika khusus untuk kartu teratas agar bisa di-shuffle secara horizontal
                      if (isTopCard) {
                        return GestureDetector(
                          onTap: () {
                            final karcisDariDatabase = KarcisParkir(
                              id: cardData['id'].toString(),
                              qrData: cardData['qrCode'] ?? 'Data Kosong',
                              jamMasuk:
                                  DateTime.tryParse(
                                    '${cardData['date']} ${cardData['time']}',
                                  ) ??
                                  DateTime.now(),
                              hargaAwal: cardData['firstHourRate'] ?? 0,
                              hargaBerikutnya:
                                  cardData['afterFirstHourRate'] ?? 0,
                              tarifMaksimal: cardData['maxRate'],
                              fotoKarcisFisik:
                                  '', // Dikosongkan sementara karena DB belum punya foto
                            );

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TicketDetailPage(
                                  warnaKartu: cardData['color'],
                                  karcis: karcisDariDatabase,
                                ),
                              ),
                            );
                          },
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
                  children: List.generate(_cards.length, (index) {
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
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const Camera()));
          if (result == true) {
            _loadCardsFromDatabase();
          }
        },
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3), width: 1),
        ),
        icon: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
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

Widget _buildVerticalCard(
  String title,
  Color color,
  String qrCode,
  int? cardId,
) {
  return Builder(
    builder: (context) => Container(
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
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (value) {
                      final state = context
                          .findAncestorStateOfType<_DashboardState>();
                      if (value == 'Edit') {
                        state?._editCard(cardId);
                      } else if (value == 'Hapus' && cardId != null) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Hapus Kartu'),
                            content: const Text(
                              'Apakah Anda yakin ingin menghapus kartu ini?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  state?._deleteCard(cardId);
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        const <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'Edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'Hapus',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_forever,
                                  size: 18,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
            ],
          ),

          // Bagian Bawah - Card Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                qrCode,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  letterSpacing: 1,
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

          // Bagian Tengah: QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 160,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
