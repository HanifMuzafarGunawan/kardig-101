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
  // Prediksi harga
  int get prediksiHarga {
    final durasi = DateTime.now().difference(jamMasuk);
    int totalMenit = durasi.inMinutes;

    // Kalau baru masuk (kurang dari 1 menit), bayar tarif awal
    if (totalMenit <= 0) return hargaAwal;

    //1-60 menit = 1 jam, 61-120 menit = 2 jam, dst.
    int totalJam = (totalMenit / 60).ceil();
    if (totalJam == 0) totalJam = 1;

    int harga = hargaAwal;
    if (totalJam > 1) {
      harga += (totalJam - 1) * hargaBerikutnya;
    }

    // Cek apakah melebihi tarif maksimal 
    if (tarifMaksimal != null && tarifMaksimal! > 0) {
      if (harga > tarifMaksimal!) {
        harga = tarifMaksimal!;
      }
    }
    return harga;
  }
}