import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:test_checkout_stripe/keys.dart';

import 'checkout/checkout.dart';
import 'elements/elements_page.dart';

void main() async {
  Stripe.publishableKey = StripeKeys.publicKey;
  // Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

  // for live mode
  // Stripe.merchantIdentifier = 'merchant.your_merchant_id';

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(
                  hintText: 'Enter customer id',
                ),
              ),
              TextButton(
                onPressed: () => _createCustomer(
                  customerId: idController.text,
                ),
                child: const Text('Create customer'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _checkSubscriptionStatus(
                  customerId: idController.text,
                ),
                child: const Text('Check subscription status'),
              ),
              const SizedBox(
                height: 100,
              ),
              TextButton(
                onPressed: () => checkout(
                  context,
                  customerId: idController.text,
                ),
                child: const Text('Checkout'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ElementsPage(
                        customerId: idController.text,
                      ),
                    ),
                  );
                },
                child: const Text('Elements'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_createCustomer({required String customerId}) async {
  try {
    Map<String, dynamic> body = {
      // the customer id already created, should be 'tchat account id'
      'id': customerId,
      'email': 'test@tchat.com',
    };

    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/customers'),
      headers: {
        'Authorization': 'Bearer ${StripeKeys.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );
    print('create customer response: ${response.body.toString()}');
  } catch (err) {
    print('err create customer: ${err.toString()}');
  }
}

_checkSubscriptionStatus({required String customerId}) async {
  try {
    // this only return non-cancelled subscription: https://docs.stripe.com/api/subscriptions/list#list_subscriptions-status
    var response = await http.get(
      Uri.parse('https://api.stripe.com/v1/subscriptions?customer=$customerId'),
      headers: {
        'Authorization': 'Bearer ${StripeKeys.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    print('check subscription status response: ${response.body.toString()}');
  } catch (err) {
    print('err check subscription status: ${err.toString()}');
  }
}
