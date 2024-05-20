import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_checkout/stripe_checkout.dart';

import '../keys.dart';
import '../platforms/url_helper_mock.dart'
    if (dart.library.js) '../platforms/url_helper_web.dart';

checkout(BuildContext context, {required String customerId}) async {
  final sessionId = await _createCheckoutSession(customerId);
  if (sessionId == null) {
    return;
  }

  final result = await redirectToCheckout(
    context: context,
    sessionId: sessionId,
    publishableKey: StripeKeys.publicKey,
    successUrl: 'https://checkout.stripe.dev/success',
    canceledUrl: 'https://checkout.stripe.dev/cancel',
  );

  final text = result.when(
    success: () => 'Paid succesfully',
    canceled: () => 'Checkout canceled',
    error: (e) => 'Error $e',
    redirected: () => 'Redirected succesfully',
  );
  print('finish checkout $text');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text ?? '')),
  );
}

Future<String?> _createCheckoutSession(String customerId) async {
  try {
    final returnUrl = getReturnUrl();
    final urlPort = getUrlPort();

    Map<String, dynamic> body = {
      // the customer id already created, should be 'tchat account id'
      'customer': customerId,

      'line_items[0][price]': StripeKeys.priceId,
      'line_items[0][quantity]': '1',
      'mode': 'subscription',
      'success_url': '${returnUrl}success',
      'cancel_url': '${returnUrl}cancel',
    };

    var response = await http.post(
      Uri.parse('https://api.stripe.com/v1/checkout/sessions'),
      headers: {
        'Authorization': 'Bearer ${StripeKeys.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );

    final session = jsonDecode(response.body);
    print('create checkout session body ->>> ${session.toString()}');

    return session['id'];
  } catch (err) {
    print('err checkout session: ${err.toString()}');
    return null;
  }
}
