import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/widgets/custom_image.dart';
import '../../../../../core/widgets/custom_radius_icon.dart';
import '../agnent_item.dart';
import '../payment_item.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/address_item.dart';
import '../bill_widget.dart';

class ClientDistributionOrderDetails extends StatelessWidget {
  const ClientDistributionOrderDetails({
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
        return LocaleKeys.while_waiting_for_the_application_to_be_accepted.tr();
      case 'accepted':
        return LocaleKeys.while_waiting_for_the_application_to_be_accepted.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClientOrderAgentItem(data: data),
          Text("• ${LocaleKeys.service_type.tr()}", style: context.semiboldText.copyWith(fontSize: 16)),
          SizedBox(height: 5.h),
          ...List.generate(
            data.orderServices.length,
            (index) {
              final service = data.orderServices[index];
              if (!service.isService) return SizedBox();
              return Container(
                width: context.w,
                margin: EdgeInsets.symmetric(vertical: 5.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                child: Row(
                  children: [
                    CustomRadiusIcon(
                      size: 80.sp,
                      borderRadius: BorderRadius.circular(4.r),
                      backgroundColor: '#F0F0F5'.color,
                      child: CustomImage(
                        service.image,
                        height: 64.sp,
                        width: 64.sp,
                      ),
                    ).withPadding(end: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.title, style: context.mediumText.copyWith(fontSize: 16)).withPadding(bottom: 8.h),
                          Text(
                            "${LocaleKeys.quantity.tr()} : ${service.count}",
                            style: context.mediumText.copyWith(fontSize: 16, color: context.secondaryColor),
                          ).withPadding(bottom: 5.h),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (data.orderServices.any((e) => !e.isService)) ...[
            SizedBox(height: 10.h),
            Text("• ${LocaleKeys.additional_options.tr()}", style: context.semiboldText.copyWith(fontSize: 16)),
            SizedBox(height: 5.h),
            ...List.generate(
              data.orderServices.length,
              (index) {
                final service = data.orderServices[index];
                if (service.isService) return SizedBox();
                return Container(
                  width: context.w,
                  margin: EdgeInsets.symmetric(vertical: 5.h),
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: '#E5E6E1'.color)),
                  child: Row(
                    children: [
                      CustomRadiusIcon(
                        size: 60.sp,
                        borderRadius: BorderRadius.circular(4.r),
                        backgroundColor: '#F0F0F5'.color,
                        child: CustomImage(
                          service.image,
                        ),
                      ).withPadding(end: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "${service.price}${LocaleKeys.sar.tr()} ",
                                    style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryColor),
                                  ).withPadding(bottom: 5.h),
                                ),
                                Text(
                                  "${LocaleKeys.quantity.tr()} : ${service.count}",
                                  style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryColor),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          OrderDetailsAddressItem(
            lable: LocaleKeys.site_address.tr(),
            title: data.address.placeTitle,
            description: data.address.placeDescription,
          ),
          OrderPaymentItem(data: data),
          ClientBillWidget(data: data),
        ],
      ),
    );
  }
}
