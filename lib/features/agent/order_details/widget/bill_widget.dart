import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'send_bill_sheet.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';

class AgentBillWidget extends StatelessWidget {
  final AgentOrderDetailsCubit cubit;
  const AgentBillWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final item = cubit.order!;
    if (item.type == 'distribution' || item.price != 0) {
      return Container(
        width: context.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            _buildServiceRow(context, item.price),
            if (item.type == 'maintenance' || item.type == 'supply') 
              _buildRow(LocaleKeys.check_fee.tr(), item.checkFee, context).withPadding(start: 30.w),
            if (item.type != 'maintenance' && item.type != 'supply') 
              _buildRow(LocaleKeys.delivery_price.tr(), item.deliveryFee, context).withPadding(start: 43.w),
            _buildRow(LocaleKeys.tax.tr(), item.tax, context).withPadding(start: 43.w),
            _buildRow(LocaleKeys.total.tr(), item.totalPrice, context, isBold: true).withPadding(start: 43.w),
          ],
        ),
      );
    } else if (item.status == 'on_way') {
      return GestureDetector(
        onTap: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (c) => SendBillSheet(),
        ).then((v) {
          if (v != null) {
            cubit.bill = v;
            cubit.refreshOrder();
            cubit.sendBill();
          }
        }),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(8.r),
            color: context.primaryColor,
            padding: EdgeInsets.zero,
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: context.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/attachment.svg',
                    height: 20.h,
                    width: 20.w,
                    colorFilter: ColorFilter.mode(
                      context.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.attach_invoice_filling_invoice.tr(),
                    style: context.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ).center,
            ),
          ),
        ),
      );
    }
    return SizedBox();
  }
  
  Widget _buildServiceRow(BuildContext context, num value) {
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
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/pay.svg',
                  height: 20.h,
                  width: 20.w,
                  colorFilter: ColorFilter.mode(
                    context.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  LocaleKeys.service_price.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
              ],
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
              style: isBold 
                ? context.boldText.copyWith(fontSize: 14.sp)
                : context.mediumText.copyWith(fontSize: 14.sp),
            ),
          ),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: formattedValue,
                style: isBold 
                  ? context.boldText.copyWith(fontSize: 14.sp)
                  : context.mediumText.copyWith(fontSize: 14.sp),
              ),
              TextSpan(
                text: " ${LocaleKeys.sar.tr()}",
                style: isBold 
                  ? context.boldText.copyWith(fontSize: 14.sp)
                  : context.mediumText.copyWith(fontSize: 14.sp),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
