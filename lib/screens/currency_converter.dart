import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends State<CurrencyConverterScreen> {
  final amountController =
      TextEditingController();

  String fromCurrency = "IDR";
  String toCurrency = "USD";

  double result = 0;

  /// rate sederhana (manual)
  final Map<String, double> rates = {
    "IDR": 1,
    "USD": 16000,
    "SGD": 12000,
    "EUR": 17500,
    "JPY": 110,
    "KRW": 12,
  };

  void convertCurrency() {
    double amount =
        double.tryParse(
              amountController.text,
            ) ??
            0;

    double inIdr =
        amount * rates[fromCurrency]!;

    double converted =
        inIdr / rates[toCurrency]!;

    setState(() {
      result = converted;
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F2FA),
      appBar: AppBar(
        title:
            const Text("Currency Converter"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              "Convert Your Budget",
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Convert travel budget easily",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            /// amount input
            TextField(
              controller:
                  amountController,
              keyboardType:
                  TextInputType.number,
              decoration: InputDecoration(
                labelText:
                    "Enter Amount",
                hintText:
                    "Example: 1000000",
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// from currency
            DropdownButtonFormField<String>(
              value: fromCurrency,
              decoration:
                  InputDecoration(
                labelText: "From",
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
              items: rates.keys
                  .map(
                    (currency) =>
                        DropdownMenuItem(
                      value: currency,
                      child:
                          Text(currency),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  fromCurrency =
                      value!;
                });
              },
            ),

            const SizedBox(height: 20),

            /// to currency
            DropdownButtonFormField<String>(
              value: toCurrency,
              decoration:
                  InputDecoration(
                labelText: "To",
                filled: true,
                fillColor:
                    Colors.white,
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                          18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
              items: rates.keys
                  .map(
                    (currency) =>
                        DropdownMenuItem(
                      value: currency,
                      child:
                          Text(currency),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  toCurrency =
                      value!;
                });
              },
            ),

            const SizedBox(height: 30),

            /// convert button
            SizedBox(
              width:
                  double.infinity,
              child:
                  ElevatedButton(
                onPressed:
                    convertCurrency,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.purple,
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                            18),
                  ),
                ),
                child: const Text(
                  "Convert",
                  style: TextStyle(
                    color:
                        Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// result card
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                      20),
              decoration:
                  BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                        22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(
                            0.05),
                    blurRadius: 10,
                    offset:
                        const Offset(
                            0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Converted Result",
                    style: TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                  const SizedBox(
                      height: 10),
                  Text(
                    result
                        .toStringAsFixed(
                            2),
                    style:
                        const TextStyle(
                      fontSize: 28,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  const SizedBox(
                      height: 6),
                  Text(
                    toCurrency,
                    style:
                        const TextStyle(
                      color:
                          Colors.purple,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}