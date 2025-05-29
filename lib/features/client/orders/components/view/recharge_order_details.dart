import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../core/widgets/custom_image.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/status_container.dart';
import '../../../../shared/components/address_item.dart';
import '../bill_widget.dart';
import '../payment_item.dart';

class ClientRechargeOrderDetails extends StatelessWidget {
  const ClientRechargeOrderDetails({
    super.key,
    required this.data,
  });

  final ClientOrderModel data;

  Color get color {
    switch (data.status) {
      case 'pending':
        return "#CE6518".color;
      case 'accepted':
        return "#168836".color;
      default:
        return "#CE6518".color;
    }
  }

  String get title {
    switch (data.status) {
      case 'pending':
        return LocaleKeys.wait_for_agent_to_take_cylinder_and_refill.tr();
      case 'accepted':
        return LocaleKeys.refilling_a_small_cylinder_now_see_cost.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != '')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Color(0xfff5f5f5)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20.h, color: color).withPadding(end: 10.w),
                  Expanded(child: Text(title, style: context.mediumText.copyWith(fontSize: 14.sp, color: color))),
                ],
              ),
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          if (title != '')
            Container(
              height: 10.h,
              color: context.canvasColor,
            ).withPadding(bottom: 16.h),
          Text("• ${LocaleKeys.agent.tr()}", style: context.mediumText.copyWith(fontSize: 20.sp)).withPadding(horizontal: 16.w, bottom: 10.h),
          Container(
            width: context.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Color(0xfff5f5f5),
            ),
            child: Row(
              children: [
                if (data.agent.id != '')
                  CustomImage(data.agent.image, height: 40.h, width: 40.h, borderRadius: BorderRadius.circular(20.h)).withPadding(end: 10.w),
                Expanded(
                  child: Text(
                    data.agent.id == '' ? LocaleKeys.waiting_for_the_request_to_be_accepted_by_the_nearest_representative.tr() : data.agent.fullname,
                    style: context.mediumText.copyWith(fontSize: 14.sp),
                  ),
                ),
                StatusContainer(
                  title: data.statusTrans,
                  color: data.color,
                ).toEnd
              ],
            ),
          ).withPadding(horizontal: 16.w, bottom: 16.h),
          Text("• ${LocaleKeys.service_type.tr()}", style: context.mediumText.copyWith(fontSize: 20.sp)).withPadding(horizontal: 16.w, bottom: 10.h),
          Container(
            width: context.w,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Color(0xfff5f5f5)),
            child: Row(
              children: [
                CustomImage(Assets.svg.clientRefill, height: 50.h).withPadding(end: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocaleKeys.refilling_a_small_cylinder.tr(), style: context.mediumText.copyWith(fontSize: 20.sp)).withPadding(bottom: 8.h),
                      Text(
                        "${LocaleKeys.quantity.tr()} : ${data.daforaCount}",
                        style: context.mediumText.copyWith(fontSize: 14.sp, color: context.secondaryColor),
                      ).withPadding(bottom: 5.h),
                    ],
                  ),
                ),
              ],
            ),
          ).withPadding(horizontal: 16.w, bottom: 16.h),
          OrderDetailsAddressItem(
            title: data.address.placeTitle,
            description: data.address.placeDescription,
          ).withPadding(horizontal: 16.w),
          OrderPaymentItem(data: data).withPadding(horizontal: 16.w),
          ClientBillWidget(data: data).withPadding(horizontal: 16.w),
        ],
      ),
    );
  }
}
