import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAgentInfoCard(context),
          _buildSectionHeader(context, LocaleKeys.service_type.tr()),
          ...List.generate(
            data.orderServices.length,
            (index) {
              final service = data.orderServices[index];
              if (!service.isService) return SizedBox();
              return _buildServiceCard(context, service);
            },
          ),
          if (data.orderServices.any((e) => !e.isService)) ...[
            SizedBox(height: 16.h),
            _buildSectionHeader(context, LocaleKeys.additional_options.tr()),
            ...List.generate(
              data.orderServices.length,
              (index) {
                final service = data.orderServices[index];
                if (service.isService) return SizedBox();
                return _buildAdditionalServiceCard(context, service);
              },
            ),
          ],
          SizedBox(height: 16.h),
          _buildSectionHeader(context, LocaleKeys.site_address.tr()),
          _buildAddressCard(context),
          OrderPaymentItem(data: data),
          ClientBillWidget(data: data),
        ],
      ),
    );
  }
  
  Widget _buildAgentInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: context.borderColor.withOpacity(0.5)),
      ),
      child: ClientOrderAgentItem(data: data),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/svg/circle_check.svg',
            height: 20.h,
            width: 20.w,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            title,
            style: context.semiboldText.copyWith(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }
  
  Widget _buildServiceCard(BuildContext context, dynamic service) {
    return Container(
      width: context.w,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: context.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CustomRadiusIcon(
            size: 80.sp,
            borderRadius: BorderRadius.circular(8.r),
            backgroundColor: '#F0F0F5'.color,
            child: CustomImage(
              service.image,
              height: 64.sp,
              width: 64.sp,
            ),
          ).withPadding(end: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: context.semiboldText.copyWith(fontSize: 16.sp),
                ).withPadding(bottom: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    "${LocaleKeys.quantity.tr()} : ${service.count}",
                    style: context.mediumText.copyWith(
                      fontSize: 14.sp,
                      color: context.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdditionalServiceCard(BuildContext context, dynamic service) {
    return Container(
      width: context.w,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: context.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CustomRadiusIcon(
            size: 60.sp,
            borderRadius: BorderRadius.circular(8.r),
            backgroundColor: '#F0F0F5'.color,
            child: CustomImage(
              service.image,
              height: 48.sp,
              width: 48.sp,
            ),
          ).withPadding(end: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: context.semiboldText.copyWith(fontSize: 14.sp),
                ).withPadding(bottom: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "${service.price}${LocaleKeys.sar.tr()}",
                        style: context.mediumText.copyWith(
                          fontSize: 12.sp,
                          color: context.secondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: context.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "${LocaleKeys.quantity.tr()} : ${service.count}",
                        style: context.mediumText.copyWith(
                          fontSize: 12.sp,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: context.borderColor.withOpacity(0.3)),
      ),
      child: OrderDetailsAddressItem(
        lable: "",
        title: data.address.placeTitle,
        description: data.address.placeDescription,
      ),
    );
  }
}
