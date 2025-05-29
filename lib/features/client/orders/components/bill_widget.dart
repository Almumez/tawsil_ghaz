import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';

class ClientBillWidget extends StatelessWidget {
  final ClientOrderModel data;

  const ClientBillWidget({super.key, required this.data});

  bool get isMaintenanceOrSupply => data.type == 'maintenance' || data.type == 'supply';

  @override
  Widget build(BuildContext context) {
    if (data.price == 0) return const SizedBox();

    return CustomImage(
      Assets.svg.bill,
      fit: BoxFit.fill,
      width: context.w,
      height: context.h / 2.6,
      child: Column(
        children: [
          _buildRow(LocaleKeys.service_price.tr(), data.price, context),
          _buildDivider(),
          if (isMaintenanceOrSupply) _buildRow(LocaleKeys.check_fee.tr(), data.checkFee, context),
          if (!isMaintenanceOrSupply) _buildRow(LocaleKeys.tax.tr(), data.tax, context),
          _buildDivider(),
          if (isMaintenanceOrSupply) _buildRow(LocaleKeys.tax.tr(), data.tax, context),
          if (!isMaintenanceOrSupply) _buildRow(LocaleKeys.delivery_price.tr(), data.deliveryFee, context),
          const Spacer(),
          _buildRow('${LocaleKeys.total.tr()} :', data.totalPrice, context, isBold: true),
        ],
      ).withPadding(vertical: 22.h, horizontal: 16.w),
    );
  }

  Widget _buildRow(String title, num value, BuildContext context, {bool isBold = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: isBold ? context.mediumText.copyWith(fontSize: 20.sp) : context.mediumText.copyWith(fontSize: 14.sp),
          ),
        ),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: "$value", style: context.mediumText.copyWith(fontSize: 20.sp)),
            TextSpan(text: LocaleKeys.sar.tr(), style: context.mediumText.copyWith(fontSize: 14.sp)),
          ]),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: List.generate(
        40,
        (i) => const Expanded(child: Divider(height: 28, endIndent: 1, indent: 1)),
      ),
    );
  }
}
