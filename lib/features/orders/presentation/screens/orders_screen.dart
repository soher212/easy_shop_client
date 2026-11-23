import 'package:easy_shop_client/core/theme/app_dimensions.dart';
import 'package:easy_shop_client/core/widgets/empty_state.dart';
import 'package:easy_shop_client/core/widgets/error_view.dart';
import 'package:easy_shop_client/core/widgets/screen_title_bar.dart';
import 'package:easy_shop_client/features/orders/presentation/cubit/orders_cubit.dart';
import 'package:easy_shop_client/features/orders/presentation/widgets/order_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ScreenTitleBar(title: 'My Orders'),
        Expanded(
          child: BlocBuilder<OrdersCubit, OrdersState>(
            builder: (context, state) => switch (state) {
              OrdersLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              OrdersFailure(:final message) => ErrorView(
                message: message,
                onRetry: () => context.read<OrdersCubit>().load(),
              ),
              OrdersSuccess(:final orders) =>
                orders.isEmpty
                    ? const EmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No orders yet',
                        message: 'Your orders will appear here.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => context.read<OrdersCubit>().load(),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(
                            AppDimensions.screenPadding,
                          ),
                          itemCount: orders.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, index) =>
                              OrderCard(order: orders[index]),
                        ),
                      ),
            },
          ),
        ),
      ],
    );
  }
}
