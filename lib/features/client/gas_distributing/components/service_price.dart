import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        Row(
          children: [
            SvgPicture.asset(
              'assets/svg/orders_out.svg',
              height: 22.h,
              width: 22.w,
              color: Colors.black,
            ),
            SizedBox(width: 8.w),
            Text("قيمة", 
              style: context.semiboldText.copyWith(fontSize: 16)
            ),
          ],
        ).withPadding(bottom: 10.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
          child: Column(
            children: [
              ServiceItem(title: "خدمة", price: double.parse(cubit.state.orderPrices!.price.toString()).toStringAsFixed(2)),
              Divider(height: 30.h),
              ServiceItem(title: "اضافات", price: double.parse(cubit.state.orderPrices!.additionalServicesFees.toString()).toStringAsFixed(2)),
              Divider(height: 30.h),
              ServiceItem(title: "توصيل", price: double.parse(cubit.state.orderPrices!.deliveryFees.toString()).toStringAsFixed(2)),
              Divider(height: 30.h),
              ServiceItem(title: "ضريبة", price: double.parse(cubit.state.orderPrices!.tax.toString()).toStringAsFixed(2)),
              Divider(height: 30.h),
              ServiceItem(title: "اجمالي", price: double.parse(cubit.state.orderPrices!.totalPrice.toString()).toStringAsFixed(2)),
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