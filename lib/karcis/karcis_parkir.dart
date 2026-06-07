class KarcisParkir {
  final String id;
  final String qrData;
  final DateTime jamMasuk;
  final int hargaAwal;
  final int hargaBerikutnya;
  final int? tarifMaksimal;
  final String fotoKarcisFisik;

  KarcisParkir({
    required this.id,
    required this.qrData,
    required this.jamMasuk,
    required this.hargaAwal,
    required this.hargaBerikutnya,
    this.tarifMaksimal,
    required this.fotoKarcisFisik,
  });

  String get durasiParkirSaatIni {
    final durasi = DateTime.now().difference(jamMasuk);
    String jam = durasi.inHours.toString().padLeft(2, '0');
    String menit = durasi.inMinutes.remainder(60).toString().padLeft(2, '0');
    String detik = durasi.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    return '$jam:$menit:$detik';
  }
}