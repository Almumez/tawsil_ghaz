import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/cubit.dart';

class ServicePriceWidget extends StatefulWidget {
  const ServicePriceWidget({
    super.key,
  });

  @override
  State<ServicePriceWidget> createState() => _ServicePriceWidgetState();
}

class _ServicePriceWidgetState extends State<ServicePriceWidget> {
  final cubit = sl<ClientDistributeGasCubit>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.service_value.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
          child: Column(
            children: [
              ServiceItem(title: LocaleKeys.service_price.tr(), price: cubit.state.orderPrices!.price.toString()),
              Divider(height: 30.h),
              ServiceItem(title: LocaleKeys.additional_services_fees.tr(), price: cubit.state.orderPrices!.additionalServicesFees.toString()),
              Divider(height: 30.h),
              ServiceItem(title: LocaleKeys.delivery_price.tr(), price: cubit.state.orderPrices!.deliveryFees.toString()),
              Divider(height: 30.h),
              ServiceItem(title: LocaleKeys.tax.tr(), price: double.parse(cubit.state.orderPrices!.tax.toString()).toStringAsFixed(2)),
              Divider(height: 30.h),
              ServiceItem(title: LocaleKeys.total.tr(), price: cubit.state.orderPrices!.totalPrice.toString()),
            ],
          ),
        ),
      ],
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String title, price;
  const ServiceItem({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: title == LocaleKeys.total.tr() ? context.boldText : context.regularText),
        Text.rich(
          TextSpan(
            text: price,
            style: context.boldText.copyWith(fontSize: 16),
            children: [
              TextSpan(text: ' ${LocaleKeys.currency.tr()}', style: context.regularText.copyWith(fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
// 
// 