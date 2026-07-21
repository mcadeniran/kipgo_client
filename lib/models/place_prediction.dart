class PlacePrediction {
  final String placeId;
  final String title;
  final String subtitle;

  const PlacePrediction({
    required this.placeId,
    required this.title,
    required this.subtitle,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final place = json["placePrediction"] ?? {};

    return PlacePrediction(
      placeId: place["placeId"] ?? "",
      title: place["text"]?["text"] ?? "",
      subtitle: place["structuredFormat"]?["secondaryText"]?["text"] ?? "",
    );
  }
}
