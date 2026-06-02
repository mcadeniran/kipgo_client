import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double> convertToUsdt(
  double amount,
  String currency,
  double networkFee,
) async {
  String currencyUpper = currency.toUpperCase();
  final response = await http.get(
    // Uri.parse(
    //   'https://api.binance.com/api/v3/ticker/price?symbol=USDT$currencyUpper',
    // ),
    Uri.parse(
      'https://v6.exchangerate-api.com/v6/91a000317b66194ac515ccdc/pair/USD/$currencyUpper',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    // Example:
    // { "symbol": "USDTNGN", "price": "1550.45" }

    // final rate = double.parse(data['conversion_rate']);
    final rate = data['conversion_rate'].toDouble();
    // final rate = double.parse(data['price']);

    final usdtAmount = amount / rate;

    return usdtAmount + networkFee;
  } else {
    throw Exception('Failed to fetch USDT rate');
  }
}
