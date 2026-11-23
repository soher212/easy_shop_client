enum PaymentStatus { success, pending, failed, cancelled }

class PaymentResult {
  final PaymentStatus status;
  final String? transactionId;

  const PaymentResult({required this.status, this.transactionId});

  bool get isSuccess => status == PaymentStatus.success;
}

// Who is paying; Paymob asks for it on the checkout page.
class BillingData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  const BillingData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  // Splits "Ahmed Hassan Ali" into "Ahmed" and "Hassan Ali"; Paymob accepts
  // "NA" for anything we don't have.
  factory BillingData.fromProfile({
    required String name,
    required String email,
    required String phone,
  }) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final first = words.isEmpty ? 'NA' : words.first;
    final last = words.length > 1 ? words.skip(1).join(' ') : 'NA';
    // Paymob rejects a phone with spaces or longer than 15 characters.
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');
    return BillingData(
      firstName: first,
      lastName: last,
      email: email.isEmpty ? 'NA' : email,
      phoneNumber: cleanPhone.isEmpty || cleanPhone.length > 15
          ? 'NA'
          : cleanPhone,
    );
  }

  Map<String, dynamic> toJson() => {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone_number': phoneNumber,
  };
}
