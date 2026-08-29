class RatingDistribution {
  late int one;
  late int two;
  late int three;
  late int four;
  late int five;
  RatingDistribution({
    required this.one,
    required this.two,
    required this.three,
    required this.four,
    required this.five,
  });

  factory RatingDistribution.fromFirestore(Map<String, dynamic> data) {
    return RatingDistribution(
      one: data['one'] ?? 0,
      two: data['two'] ?? 0,
      three: data['three'] ?? 0,
      four: data['four'] ?? 0,
      five: data['five'] ?? 0,
    );
  }

  int get total => one + two + three + four + five;

  int getCount(int rating) {
    switch (rating) {
      case 1:
        return one;
      case 2:
        return two;
      case 3:
        return three;
      case 4:
        return four;
      case 5:
        return five;
      default:
        return 0;
    }
  }
}
