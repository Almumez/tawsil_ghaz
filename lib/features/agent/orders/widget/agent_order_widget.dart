import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/agent_order.dart';
import '../../../shared/components/status_container.dart';

class AgentOrderWidget extends StatelessWidget {
  final AgentOrderModel item;
  final Function() onBack;
  const AgentOrderWidget({super.key, required this.item, required this.onBack});

  onTap() {
    push(NamedRoutes.agentShowOrder, arg: {"id": item.id, "type": item.type}).then((_) => onBack());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.w),
          color: Color(0xFFF5F5F5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.clientName,
                        style: context.mediumText.copyWith(color: Colors.black),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          CustomImage(
                            Assets.svg.location,
                            height: 20.sp,
                            width: 20.sp,
                          ),
                          Expanded(
                            child: Text(
                              item.address.placeDescription,
                              style: context.mediumText.copyWith(fontSize: 12, color: Colors.black),
                            ).withPadding(horizontal: 4.w),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(" ${item.id} #", style: context.semiboldText.copyWith(color: Colors.black)),
                    SizedBox(height: 8.h),
                    if (item.price != 0)
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: LocaleKeys.sar.tr(),
                            style: context.regularText.copyWith(fontSize: 14, color: Colors.black),
                          ),
                          TextSpan(
                            text: "${item.price}",
                            style: context.regularText.copyWith(fontSize: 16, color: Colors.black),
                          ),
                        ]),
                      ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.typeTrans,
                            style: context.mediumText.copyWith(fontSize: 16, color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          CustomImage(
                            Assets.svg.calender,
                            height: 16.sp,
                            width: 16.sp,
                            color: Colors.black,
                          ).withPadding(end: 5.w),
                          Text(
                            item.createdAt.split(' - ')[0],
                            style: context.regularText.copyWith(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          CustomImage(
                            Assets.svg.clock,
                            height: 16.sp,
                            width: 16.sp,
                            color: Colors.black,
                          ).withPadding(start: 12.w, end: 5.w),
                          Text(
                            item.createdAt.split(' - ').length > 1 ? item.createdAt.split(' - ')[1] : item.createdAt,
                            style: context.regularText.copyWith(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusContainer(
                      title: item.statusTrans,
                      color: item.color,
                    ),
                    SizedBox(height: 8.h),
                    if (item.status == 'pending')
                      Container(
                        width: 105.w,
                        height: 30.h,
                        child: AppBtn(
                          onPressed: onTap,
                          height: 30.h,
                          saveArea: false,
                          title: LocaleKeys.accept.tr(),
                          radius: 4.r,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
