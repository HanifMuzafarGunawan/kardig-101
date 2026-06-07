class CardData {
  final int? id;
  final String qrCode;
  final String name;
  final String date;
  final String time;
  final int firstHourRate;
  final int afterFirstHourRate;
  final int? maxRate;
  final int color;

  CardData({
    this.id,
    required this.qrCode,
    required this.name,
    required this.date,
    required this.time,
    required this.firstHourRate,
    required this.afterFirstHourRate,
    this.maxRate,
    required this.color,
  });

  // Convert object to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'qrCode': qrCode,
      'name': name,
      'date': date,
      'time': time,
      'firstHourRate': firstHourRate,
      'afterFirstHourRate': afterFirstHourRate,
      'maxRate': maxRate,
      'color': color,
    };
  }

  // Convert JSON to object
  factory CardData.fromMap(Map<String, dynamic> map) {
    return CardData(
      id: map['id'],
      qrCode: map['qrCode'],
      name: map['name'],
      date: map['date'],
      time: map['time'],
      firstHourRate: map['firstHourRate'],
      afterFirstHourRate: map['afterFirstHourRate'],
      maxRate: map['maxRate'],
      color: map['color'],
    );
  }
}
