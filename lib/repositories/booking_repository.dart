import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kipgo/models/booking_model.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookingModel>> streamUserBookings(String userId) {
    return _firestore
        .collection("bookings")
        .where("userId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList();
        });
  }
}
