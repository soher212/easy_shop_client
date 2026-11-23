import 'package:easy_shop_client/core/helpers/format.dart';
import 'package:easy_shop_client/core/theme/app_colors.dart';
import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/theme/app_text_styles.dart';
import 'package:easy_shop_client/core/widgets/app_button.dart';
import 'package:easy_shop_client/core/widgets/app_snack_bar.dart';
import 'package:easy_shop_client/features/cart/domain/entities/cart_item_entity.dart';
import 'package:easy_shop_client/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:easy_shop_client/features/checkout/presentation/cubit/checkout_cubit.dart';
import 'package:easy_shop_client/features/checkout/presentation/screens/payment_success_screen.dart';
import 'package:easy_shop_client/features/checkout/presentation/widgets/delivery_map_preview.dart';
import 'package:easy_shop_client/features/checkout/presentation/widgets/payment_option.dart';
import 'package:easy_shop_client/features/maps/presentation/pick_location_on_map.dart';
import 'package:easy_shop_client/features/orders/domain/entities/order_entity.dart';
import 'package:easy_shop_client/features/payment/domain/entities/payment_models.dart';
import 'package:easy_shop_client/features/payment/presentation/paymob_webview_screen.dart';
import 'package:easy_shop_client/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop_client/features/products/presentation/widgets/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemEntity> items;
  final String initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;
  final VoidCallback onViewOrders;
  final VoidCallback onContinueShopping;
  final String billingName;
  final String billingEmail;
  final String billingPhone;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.onViewOrders,
    required this.onContinueShopping,
    this.initialAddress = '',
    this.initialLatitude,
    this.initialLongitude,
    this.billingName = '',
    this.billingEmail = '',
    this.billingPhone = '',
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late String _address = widget.initialAddress;
  late double? _latitude = widget.initialLatitude;
  late double? _longitude = widget.initialLongitude;
  PaymentMethod _payment = PaymentMethod.cash;

  double get _total =>
      widget.items.fold(0, (sum, item) => sum + item.lineTotal);

  // The order is delivered, so it needs a point on the map, not just text.
  bool get _hasLocation => _latitude != null && _longitude != null;
  bool get _canPlaceOrder => _hasLocation && _address.trim().isNotEmpty;

  Future<void> _changeLocation() async {
    final picked = await pickLocationOnMap(
      context,
      latitude: _latitude,
      longitude: _longitude,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _latitude = picked.latitude;
      _longitude = picked.longitude;
      _address =
          picked.label ??
          '${picked.latitude.toStringAsFixed(4)}, '
              '${picked.longitude.toStringAsFixed(4)}';
    });
  }

  // Cash is paid at the door, so the courier needs to know where to go: if
  // there is no point on the map yet, open it straight away.
  void _chooseCash() {
    setState(() => _payment = PaymentMethod.cash);
    if (!_hasLocation) _changeLocation();
  }

  void _placeOrder() {
    context.read<CheckoutCubit>().placeOrder(
      PlaceOrderData(
        items: widget.items,
        address: _address,
        latitude: _latitude,
        longitude: _longitude,
        paymentMethod: _payment,
      ),
      BillingData.fromProfile(
        name: widget.billingName,
        email: widget.billingEmail,
        phone: widget.billingPhone,
      ),
    );
  }

  void _refreshCartAndOrders() {
    context.read<CartCubit>().load();
    context.read<OrdersCubit>().load();
  }

  Future<void> _openPayment(Uri checkoutUri) async {
    final redirectUrl = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymobWebViewScreen(checkoutUri: checkoutUri),
      ),
    );
    if (mounted) context.read<CheckoutCubit>().finishPayment(redirectUrl);
  }

  Future<void> _showPaymentFailed(CheckoutState state) async {
    _refreshCartAndOrders();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Payment not completed'),
        content: Text(
          '${state.message ?? 'The payment did not go through.'}\n\n'
          'Your order #${state.orderCode} was saved as pending.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
              widget.onViewOrders();
            },
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
  }

  void _onState(BuildContext context, CheckoutState state) {
    switch (state.status) {
      case CheckoutStatus.placed:
        _refreshCartAndOrders();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentSuccessScreen(
              orderCode: state.orderCode!,
              onViewOrders: widget.onViewOrders,
              onContinueShopping: widget.onContinueShopping,
            ),
          ),
        );
      case CheckoutStatus.awaitingPayment:
        _openPayment(state.checkoutUri!);
      case CheckoutStatus.paymentFailed:
        _showPaymentFailed(state);
      case CheckoutStatus.failure:
        showAppSnackBar(
          context,
          state.message ?? 'Could not place your order',
          isError: true,
        );
      case CheckoutStatus.idle || CheckoutStatus.submitting:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: _onState,
        builder: (context, state) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                children: [
                  _Card(
                    title: 'Delivery Address',
                    child: _AddressBlock(
                      address: _address,
                      latitude: _latitude,
                      longitude: _longitude,
                      onChange: _changeLocation,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Card(
                    title: 'Order Items',
                    child: Column(
                      children: [
                        for (final item in widget.items) _ItemRow(item: item),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Card(
                    title: 'Payment Method',
                    child: Column(
                      children: [
                        PaymentOption(
                          icon: Icons.payments_outlined,
                          iconColor: AppColors.successBright,
                          label: 'Cash on Delivery',
                          isSelected: _payment == PaymentMethod.cash,
                          onTap: _chooseCash,
                        ),
                        const SizedBox(height: 10),
                        PaymentOption(
                          icon: Icons.credit_card_outlined,
                          iconColor: AppColors.info,
                          label: 'Credit / Debit Card',
                          isSelected: _payment == PaymentMethod.card,
                          onTap: () =>
                              setState(() => _payment = PaymentMethod.card),
                        ),
                        if (_payment == PaymentMethod.card) ...[
                          const SizedBox(height: 10),
                          Text(
                            'You will enter your card details securely on '
                            "Paymob's page right after placing the order.",
                            style: AppTextStyles.caption.copyWith(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Card(
                    title: 'Order Summary',
                    child: _SummaryBlock(
                      itemsCount: widget.items.length,
                      total: _total,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: SafeArea(
                top: false,
                child: AppButton(
                  label: 'Place Order',
                  isLoading:
                      state.status == CheckoutStatus.submitting ||
                      state.status == CheckoutStatus.awaitingPayment,
                  onPressed: _canPlaceOrder ? _placeOrder : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final String address;
  final double? latitude;
  final double? longitude;
  final VoidCallback onChange;

  const _AddressBlock({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onChange,
  });

  bool get hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address.isEmpty ? 'Add a delivery address' : address,
                style: address.isEmpty
                    ? AppTextStyles.caption.copyWith(fontSize: 14)
                    : AppTextStyles.body,
              ),
            ),
          ],
        ),
        if (!hasLocation) ...[
          const SizedBox(height: 8),
          Text(
            'Pick your delivery location on the map to place the order.',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: 12),
        DeliveryMapPreview(
          latitude: latitude,
          longitude: longitude,
          onTap: onChange,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onChange,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                address.isEmpty ? 'Pick Location' : 'Change Location',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  final CartItemEntity item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          ProductImage(
            product: item.product,
            height: 46,
            width: 46,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatEgp(item.lineTotal),
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  final int itemsCount;
  final double total;

  const _SummaryBlock({required this.itemsCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Items ($itemsCount)',
              style: AppTextStyles.caption.copyWith(fontSize: 14),
            ),
            Text(
              formatEgp(total),
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const Divider(height: 22, color: AppColors.border),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: AppTextStyles.subtitle.copyWith(fontSize: 17)),
            Text(
              formatEgp(total),
              style: AppTextStyles.title.copyWith(
                color: AppColors.primary,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
