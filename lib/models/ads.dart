import 'package:cloud_firestore/cloud_firestore.dart';

class AdsModel {
  final String id;
  final String bannerUrl;
  final DateTime createdAt;
  final String description;
  final DateTime endDate;
  final bool isActive;
  final String linkUrl;
  final DateTime startDate;
  final String title;
  final DateTime updatedAt;

  AdsModel({
    required this.id,
    required this.bannerUrl,
    required this.createdAt,
    required this.description,
    required this.endDate,
    required this.isActive,
    required this.linkUrl,
    required this.startDate,
    required this.title,
    required this.updatedAt,
  });

  /// Convert Firestore snapshot → AdsModel
  factory AdsModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdsModel(
      id: doc.id,
      bannerUrl: data['bannerUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
      linkUrl: data['linkUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      title: data['title'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert AdsModel → Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bannerUrl': bannerUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
      'linkUrl': linkUrl,
      'startDate': Timestamp.fromDate(startDate),
      'title': title,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
