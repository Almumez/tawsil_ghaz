import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';

class ClientBillWidget extends StatelessWidget {
  final ClientOrderModel data;

  const ClientBillWidget({super.key, required this.data});

  bool get isMaintenanceOrSupply => data.type == 'maintenance' || data.type == 'supply';

  @override
  Widget build(BuildContext context) {
    if (data.price == 0) return const SizedBox();

    return Container(
      width: context.w,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _buildRow("خدمة", data.price, context),
          if (isMaintenanceOrSupply) _buildRow(LocaleKeys.check_fee.tr(), data.checkFee, context),
          if (!isMaintenanceOrSupply) _buildRow("توصيل", data.deliveryFee, context),
          if (!isMaintenanceOrSupply) _buildRow("ضريبة", data.tax, context),
          if (isMaintenanceOrSupply) _buildRow("ضريبة", data.tax, context),
          SizedBox(height: 8.h),
          _buildRow("اجمالي", data.totalPrice, context),
        ],
      ),
    );
  }

  Widget _buildRow(String title, num value, BuildContext context, {bool isBold = false}) {
    // Format the number to remove decimal places if they're zeros
    String formattedValue = value.toStringAsFixed(2);
    if (formattedValue.endsWith('.00')) {
      formattedValue = value.toInt().toString();
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.mediumText.copyWith(
                fontSize: 14.sp,
              ),
            ),
          ),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: formattedValue,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                ),
              ),
              TextSpan(
                text: " ${LocaleKeys.sar.tr()}",
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
