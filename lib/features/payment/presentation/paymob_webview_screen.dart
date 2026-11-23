import 'package:easy_shop_client/features/payment/data/paymob_service.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Paymob's card page. It closes by itself, returning the redirect URL, when
// Paymob sends the customer back to our redirection URL.
class PaymobWebViewScreen extends StatefulWidget {
  final Uri checkoutUri;

  const PaymobWebViewScreen({super.key, required this.checkoutUri});

  @override
  State<PaymobWebViewScreen> createState() => _PaymobWebViewScreenState();
}

class _PaymobWebViewScreenState extends State<PaymobWebViewScreen> {
  late final WebViewController _controller;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onUrlChange: (change) => _checkUrl(change.url)),
      )
      ..loadRequest(widget.checkoutUri);
  }

  void _checkUrl(String? url) {
    if (url == null || _finished) return;
    if (!url.startsWith(PaymobService.redirectionUrl)) return;
    _finished = true;
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
