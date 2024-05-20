import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../keys.dart';
import '../platforms/payment_element.dart'
    if (dart.library.js) '../platforms/payment_element_web.dart';
import 'loading_button.dart';

class ElementsPage extends StatefulWidget {
  const ElementsPage({super.key, required this.customerId});

  final String customerId;

  @override
  State<ElementsPage> createState() => _ElementsPageState();
}

class _ElementsPageState extends State<ElementsPage> {
  String? clientSecret;

  @override
  void initState() {
    getClientSecret();
    super.initState();
  }

  Future<void> getClientSecret() async {
    try {
      final client = await _createSubscription(widget.customerId);
      setState(() {
        clientSecret = client;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter App'),
      ),
      body: Column(
        children: [
          Container(
              child: clientSecret != null
                  ? PlatformPaymentElement(clientSecret)
                  : const Center(child: CircularProgressIndicator())),
          const LoadingButton(onPressed: pay, text: 'Pay'),
        ],
      ),
    );
  }
}

Future<String?> _createSubscription(String customerId) async {
  try {
    // final urlPort = getUrlPort();
    // final returnUrl = getReturnUrl();

    Map<String, dynamic> body = {
      'customer': customerId,
      'items[0][price]': StripeKeys.priceId,
      // 'items[0][quantity]': '1',
      'payment_behavior': 'default_incomplete',
      'payment_settings[save_default_payment_method]': 'on_subscription',
      'expand[]': 'latest_invoice.payment_intent',
    };

    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/subscriptions'),
      headers: {
        'Authorization': 'Bearer ${StripeKeys.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    final subscription = jsonDecode(response.body);
    print('create subscription body ->>> ${subscription.toString()}');

    final clientSecret =
        subscription['latest_invoice']['payment_intent']['client_secret'];

    return clientSecret;
  } catch (err) {
    print('err create subscription: ${err.toString()}');
  }
  return null;
}
