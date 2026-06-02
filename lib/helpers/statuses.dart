class BookingStatuses {
  static const pending = 'pending';

  static const paymentSubmitted = 'payment_submitted';

  static const reserved = 'reserved';

  static const approved = 'approved';

  static const ongoing = 'ongoing';

  static const completed = 'completed';

  static const cancelled = 'cancelled';

  static const rejected = 'rejected';

  static const expired = 'expired';
}

class PaymentMethods {
  static const crypto = 'crypto';

  static const payOnPickup = 'payOnPickup';
}

class PaymentStatuses {
  static const unpaid = 'unpaid';

  static const pending = 'pending';

  static const awaitingVerification = 'awaiting_verification';

  static const paid = 'paid';

  static const failed = 'failed';

  static const expired = 'expired';
}
