# test_flutter_stripe_web

This is just a test project

Test card:
4242 4242 4242 4242
mm/yy 12/34
cvc 123
name test


Steps:
- Create Stripe customer with tchat id
- Check subscription status with tchat account id
- Pay for customer id with priceId (the price id of the premium product, configured in Stripe). Using either: Checkout or Elements

Note: Checkout is deprecated
https://github.com/flutter-stripe/flutter_stripe/issues/1776#issuecomment-2114822985
https://pub.dev/packages/stripe_checkout