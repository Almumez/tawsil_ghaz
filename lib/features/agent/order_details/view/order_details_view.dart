import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widget/bill_widget.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/method.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_radius_icon.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/agent_order_client_item.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/status_container.dart';
import '../cubit/order_details_cubit.dart';
import '../cubit/order_details_state.dart';
import '../widget/agent_order_actions.dart';

class OrderDetailsView extends StatefulWidget {
  final String id;
  final String type;
  const OrderDetailsView({super.key, required this.id, required this.type});

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final cubit = sl<AgentOrderDetailsCubit>();
  @override
  void initState() {
    super.initState();
    cubit.getOrderDetails(widget.id, widget.type);
  }

  Future<void> _handleRefresh() async {
    cubit.getOrderDetails(widget.id, widget.type);
  }

  // Build status section similar to client
  Widget _buildOrderStatusSection(context, item) {
    final Map<String, Color> statusColors = {
      'pending': "#CE6518".color,
      'accepted': "#168836".color,
      'completed': "#168836".color,
      'canceled': "#E53935".color,
      'on_way': "#168836".color,
      'checked': "#168836".color,
    };
    
    final Map<String, String> statusIcons = {
      'pending': 'assets/svg/time.svg',
      'accepted': 'assets/svg/check_circle.svg',
      'completed': 'assets/svg/check_circle.svg',
      'canceled': 'assets/svg/cancel.svg',
      'on_way': 'assets/svg/delivery.svg',
      'checked': 'assets/svg/check_circle.svg',
    };
    
    final Map<String, String> statusMessages = {
      'pending': LocaleKeys.waiting_for_approval.tr(),
      'accepted': LocaleKeys.order_accepted.tr(),
      'completed': LocaleKeys.service_completed.tr(),
      'canceled': LocaleKeys.order_cancelled.tr(),
      'on_way': LocaleKeys.tracking_delivery.tr(),
      'checked': LocaleKeys.check_now.tr(),
    };
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: statusColors[item.status]?.withOpacity(0.1) ?? Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: statusColors[item.status] ?? Colors.grey, width: 1),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            statusIcons[item.status] ?? 'assets/svg/time.svg',
            height: 24.h,
            width: 24.w,
            colorFilter: ColorFilter.mode(
              statusColors[item.status] ?? Colors.grey,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              statusMessages[item.status] ?? '',
              style: context.mediumText.copyWith(
                fontSize: 14.sp,
                color: statusColors[item.status] ?? Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.order_details.tr()),
      bottomNavigationBar: AgentOrderActions(cubit: cubit),
      body: BlocBuilder<AgentOrderDetailsCubit, AgentOrderDetailsState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.getOrderState != current.getOrderState,
        builder: (context, state) {
          if (cubit.order != null) {
            var item = cubit.order!;
            return PullToRefresh(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID and Status
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${LocaleKeys.order_number.tr()} : ${cubit.order!.id}", 
                            style: context.mediumText.copyWith(fontSize: 14)
                          ),
                          StatusContainer(
                            title: cubit.order!.statusTrans,
                            color: cubit.order!.color,
                          )
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Status section
                    _buildOrderStatusSection(context, item),
                    
                    // Service Type
                    Container(
                      width: context.w,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/services.svg',
                                height: 20.h,
                                width: 20.w,
                                colorFilter: ColorFilter.mode(
                                  context.primaryColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                LocaleKeys.service_type.tr(), 
                                style: context.mediumText.copyWith(fontSize: 16)
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ...List.generate(
                            item.details.length,
                            (index) {
                              final service = item.details[index];
                              if (!service.isService) return SizedBox();
                              return Container(
                                width: context.w,
                                margin: EdgeInsets.only(bottom: 8.h),
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r), 
                                  border: Border.all(color: '#f5f5f5'.color)
                                ),
                                child: Row(
                                  children: [
                                    CustomRadiusIcon(
                                      size: 80.sp,
                                      borderRadius: BorderRadius.circular(8.r),
                                      backgroundColor: '#f5f5f5'.color,
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
                                          Text(service.title, style: context.mediumText.copyWith(fontSize: 14)).withPadding(bottom: 8.h),
                                          Text(
                                            "${LocaleKeys.quantity.tr()} : ${service.count}",
                                            style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryColor),
                                          ).withPadding(bottom: 5.h),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    // Additional Options
                    if (item.details.any((e) => !e.isService)) 
                      Container(
                        width: context.w,
                        padding: EdgeInsets.all(16.w),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/options.svg',
                                  height: 20.h,
                                  width: 20.w,
                                  colorFilter: ColorFilter.mode(
                                    context.primaryColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  LocaleKeys.additional_options.tr(), 
                                  style: context.mediumText.copyWith(fontSize: 16)
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ...List.generate(
                              item.details.length,
                              (index) {
                                final service = item.details[index];
                                if (service.isService) return SizedBox();
                                return Container(
                                  width: context.w,
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r), 
                                    border: Border.all(color: '#f5f5f5'.color)
                                  ),
                                  child: Row(
                                    children: [
                                      CustomRadiusIcon(
                                        size: 60.sp,
                                        borderRadius: BorderRadius.circular(8.r),
                                        backgroundColor: '#f5f5f5'.color,
                                        child: CustomImage(
                                          service.image,
                                        ),
                                      ).withPadding(end: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(service.title, style: context.mediumText.copyWith(fontSize: 14)).withPadding(bottom: 8.h),
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
                        ),
                      ),
                    
                    // Client info
                    Container(
                      width: context.w,
                      padding: EdgeInsets.all(16.w),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/user.svg',
                                height: 20.h,
                                width: 20.w,
                                colorFilter: ColorFilter.mode(
                                  context.primaryColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                LocaleKeys.client_details.tr(), 
                                style: context.mediumText.copyWith(fontSize: 16)
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          AgentOrderClientItem(data: item.client),
                        ],
                      ),
                    ),
                    
                    // Addresses
                    Container(
                      width: context.w,
                      padding: EdgeInsets.all(16.w),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/location.svg',
                                height: 20.h,
                                width: 20.w,
                                colorFilter: ColorFilter.mode(
                                  context.primaryColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                LocaleKeys.addresses.tr(), 
                                style: context.mediumText.copyWith(fontSize: 16)
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          
                          // Client location
                          Text(
                            LocaleKeys.client_location.tr(),
                            style: context.mediumText.copyWith(fontSize: 14),
                          ).withPadding(bottom: 8.h),
                          
                          Row(
                            children: [
                              CustomImage(
                                Assets.svg.location,
                                height: 20.h,
                                width: 20.h,
                              ).withPadding(end: 4.w),
                              Expanded(child: Text(item.address.placeDescription, style: context.mediumText.copyWith(fontSize: 14)).withPadding(bottom: 5.h)),
                            ],
                          ),
                          
                          GestureDetector(
                            onTap: () => launchGoogleMaps(item.address.lat, item.address.lng),
                            child: Container(
                              margin: EdgeInsets.only(top: 8.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: context.primaryColor.withOpacity(0.1),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/eye.svg',
                                    height: 20.h,
                                    width: 20.w,
                                    colorFilter: ColorFilter.mode(
                                      context.primaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ).withPadding(end: 8.w),
                                  Text(
                                    LocaleKeys.address_view.tr(),
                                    style: context.mediumText.copyWith(fontSize: 14),
                                  )
                                ],
                              ),
                            ),
                          ),
                          
                          // Merchant address if exists
                          if (item.merchentAddress.hasData) ...[
                            Divider(height: 32.h),
                            Text(
                              LocaleKeys.store_address.tr(),
                              style: context.mediumText.copyWith(fontSize: 16),
                            ).withPadding(bottom: 8.h),
                            
                            Row(
                              children: [
                                CustomImage(
                                  Assets.svg.location,
                                  height: 20.h,
                                  width: 20.h,
                                ).withPadding(end: 4.w),
                                Expanded(
                                  child: Text(
                                    item.merchentAddress.placeDescription, 
                                    style: context.regularText.copyWith(fontSize: 12)
                                  ).withPadding(bottom: 5.h)
                                ),
                              ],
                            ),
                            
                            GestureDetector(
                              onTap: () => launchGoogleMaps(item.merchentAddress.lat, item.merchentAddress.lng),
                              child: Container(
                                margin: EdgeInsets.only(top: 8.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: context.primaryColor.withOpacity(0.1),
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/svg/eye.svg',
                                      height: 20.h,
                                      width: 20.w,
                                      colorFilter: ColorFilter.mode(
                                        context.primaryColor,
                                        BlendMode.srcIn,
                                      ),
                                    ).withPadding(end: 8.w),
                                    Text(
                                      LocaleKeys.address_view.tr(),
                                      style: context.mediumText.copyWith(fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    
                    // Bill widget
                    AgentBillWidget(cubit: cubit),
                  ],
                ),
              ),
            );
          } else if (state.getOrderState.isError) {
            return CustomErrorWidget(title: state.msg, onTap: () => cubit.getOrderDetails(widget.id, widget.type));
          }
          return LoadingApp();
        },
      ),
    );
  }
}
