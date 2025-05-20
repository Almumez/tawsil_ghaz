import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${LocaleKeys.order_number.tr()} : ${cubit.order!.id}", style: context.semiboldText),
                        StatusContainer(
                          title: cubit.order!.statusTrans,
                          color: cubit.order!.color,
                        )
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text("• ${LocaleKeys.service_type.tr()}", style: context.semiboldText.copyWith(fontSize: 16)),
                    SizedBox(height: 5.h),
                    ...List.generate(
                      item.details.length,
                      (index) {
                        final service = item.details[index];
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
                    if (item.details.any((e) => !e.isService)) ...[
                      SizedBox(height: 10.h),
                      Text("• ${LocaleKeys.additional_options.tr()}", style: context.semiboldText.copyWith(fontSize: 16)),
                      SizedBox(height: 5.h),
                      ...List.generate(
                        item.details.length,
                        (index) {
                          final service = item.details[index];
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
                    AgentOrderClientItem(data: item.client).withPadding(top: 8.h),
                    SizedBox(height: 5.h),
                    Text(
                      "• ${LocaleKeys.addresses.tr()}",
                      style: context.semiboldText.copyWith(fontSize: 16),
                    ).withPadding(bottom: 10.h),
                    Container(
                      width: context.w,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.client_location.tr(),
                            style: context.mediumText.copyWith(fontSize: 16),
                          ).withPadding(bottom: 8.h),
                          Row(
                            children: [
                              CustomImage(
                                Assets.svg.location,
                                height: 20.h,
                                width: 20.h,
                              ).withPadding(end: 4.w),
                              Expanded(child: Text(item.address.placeDescription, style: context.regularText.copyWith(fontSize: 12)).withPadding(bottom: 5.h)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => launchGoogleMaps(item.address.lat, item.address.lng),
                            child: Container(
                              margin: EdgeInsets.only(top: 8.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: '#0404041A'.color.withValues(alpha: .1),
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomImage(
                                    Assets.svg.eye,
                                    height: 20.h,
                                    width: 20.h,
                                    color: context.primaryColorDark,
                                  ).withPadding(end: 4.w),
                                  Text(
                                    LocaleKeys.address_view.tr(),
                                    style: context.mediumText.copyWith(fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
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
                                    child: Text(item.merchentAddress.placeDescription, style: context.regularText.copyWith(fontSize: 12))
                                        .withPadding(bottom: 5.h)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => launchGoogleMaps(item.merchentAddress.lat, item.merchentAddress.lng),
                              child: Container(
                                margin: EdgeInsets.only(top: 8.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: '#0404041A'.color.withValues(alpha: .1),
                                ),
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomImage(
                                      Assets.svg.eye,
                                      height: 20.h,
                                      width: 20.h,
                                      color: context.primaryColorDark,
                                    ).withPadding(end: 4.w),
                                    Text(
                                      LocaleKeys.address_view.tr(),
                                      style: context.mediumText.copyWith(fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ).withPadding(bottom: 16),
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
