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
          
          ...List.generate(
            data.orderServices.length,
            (index) {
              final service = data.orderServices[index];
              if (!service.isService) return SizedBox();
              return _buildServiceCard(context, service, isFirst: index == 0);
            },
          ),
          if (data.orderServices.any((e) => !e.isService)) ...[
            ...List.generate(
              data.orderServices.length,
              (index) {
                final service = data.orderServices[index];
                if (service.isService) return SizedBox();
                return _buildAdditionalServiceCard(context, service);
              },
            ),
          ],
          
          _buildAddressCard(context),

          OrderPaymentItem(data: data).withPadding(start: 16.w, end: 16.w, bottom: 16.h),
          ClientBillWidget(data: data),
         
        ],
      ),
    );
  }



  Widget _buildVerticalInstructionItem({
    required BuildContext context, 
    required String svgAsset, 
    required String text
  }) {
    List<String> words = text.split(' ');
    
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgAsset,
            height: 24.h,
            width: 24.h,
            colorFilter: ColorFilter.mode(
              context.primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: 8.h),
          Column(
            children: words.map((word) => 
              Text(
                word,
                textAlign: TextAlign.center,
                style: context.mediumText.copyWith(
                  fontSize: 14.sp,
                  height: 1.4,
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgentInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
     
      padding: EdgeInsets.symmetric( horizontal: 16.w),
    
      child: ClientOrderAgentItem(data: data),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title, String svgAsset) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            height: 24.h,
            width: 24.w,
            alignment: Alignment.center,
            child: SvgPicture.asset(
              svgAsset,
              height: 20.h,
              width: 20.w,
              colorFilter: ColorFilter.mode(
                context.primaryColor,
                BlendMode.srcIn,
              ),
            ),
          ).withPadding(start: 25.w),

        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, dynamic service, {bool isFirst = false}) {
    return Container(
      width: context.w,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          if (isFirst)
            SvgPicture.asset(
              'assets/svg/orders_out.svg',
              height: 24.h,
              width: 24.w,
              colorFilter: ColorFilter.mode(
                context.primaryColor,
                BlendMode.srcIn,
              ),
            ).withPadding(end: 8.w),
          CustomImage(
            service.image,
            height: 45.sp,
            width: 45.sp,
            borderRadius: BorderRadius.circular(8.r),
          ).withPadding(end: 16.w,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service.title,
                      style: context.semiboldText.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "(${service.count}x)",
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ).withPadding(start: isFirst ? 15.w : 45.w),
    );
  }
  
  Widget _buildAdditionalServiceCard(BuildContext context, dynamic service) {
    return Container(
      width: context.w,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CustomImage(
            service.image,
            height: 48.sp,
            width: 48.sp,
            borderRadius: BorderRadius.circular(8.r),
          ).withPadding(end: 16.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      service.title,
                      style: context.semiboldText.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "(${service.count}x)",
                      style: context.mediumText.copyWith(
                        fontSize: 14.sp,
                        color: context.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).withPadding(start: 45.w);
  }
  
  Widget _buildAddressCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: OrderDetailsAddressItem(
        lable: "",
        title: data.address.placeTitle,
        description: data.address.placeDescription,
      ),
    );
  }
  
  Widget _buildComponentCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }
}
