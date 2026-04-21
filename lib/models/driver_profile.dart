class DriverProfile {
  String id;
  String name;
  String licenseName;
  String email;
  String phone;
  String gender;
  String dob;

  String? licenseFrontUrl;
  String? licenseBackUrl;
  String? idCardUrl;

  DriverProfile({
    required this.id,
    required this.name,
    required this.licenseName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    this.licenseFrontUrl,
    this.licenseBackUrl,
    this.idCardUrl,
  });

  factory DriverProfile.fromMap(Map<String, dynamic> data, String id) {
    return DriverProfile(
      id: id,
      name: data["name"] ?? "",
      licenseName: data["licenseName"] ?? "",
      email: data["email"] ?? "",
      phone: data["phone"] ?? "",
      gender: data["gender"] ?? "",
      dob: data["dob"] ?? "",
      licenseFrontUrl: data["licenseFront"],
      licenseBackUrl: data["licenseBack"],
      idCardUrl: data["idCard"],
    );
  }
}
