class ServiceAreaResolver {
  static const Map<String, String> _zones = {
    // Girne Region
    "Girne": "Girne",
    "Kyrenia": "Girne",
    "Karaoğlanoğlu": "Girne",
    "Alsancak": "Girne",
    "Lapta": "Girne",
    "Bellapais": "Girne",
    "Çatalköy": "Girne",
    "Ozanköy": "Girne",

    // Lefkoşa Region
    "Lefkoşa": "Lefkoşa",
    "Nicosia": "Lefkoşa",
    "Gönyeli": "Lefkoşa",
    "Hamitköy": "Lefkoşa",
    "Metehan": "Lefkoşa",

    // Gazimağusa Region
    "Gazimağusa": "Gazimağusa",
    "Famagusta": "Gazimağusa",
    "Sakarya": "Gazimağusa",
    "Yeni Boğaziçi": "Gazimağusa",

    // İskele
    "İskele": "İskele",
    "Iskele": "İskele",

    // Güzelyurt
    "Güzelyurt": "Güzelyurt",
    "Morphou": "Güzelyurt",

    // Lefke
    "Lefke": "Lefke",

    // Airport
    "Ercan": "Ercan Airport",
    "Ercan Havalimanı": "Ercan Airport",
  };

  static String resolve({required String city, String? district}) {
    if (district != null && _zones.containsKey(district)) {
      return _zones[district]!;
    }

    return _zones[city] ?? city;
  }
}
