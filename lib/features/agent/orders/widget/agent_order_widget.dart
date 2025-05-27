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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(" ${item.id} #", style: context.semiboldText),
              ],
            ).withPadding(bottom: 4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.clientName,
                  style: context.mediumText,
                ),
                
                if (item.price != 0)
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: LocaleKeys.sar.tr(),
                        style: context.regularText.copyWith(fontSize: 14),
                      ),
                      TextSpan(
                        text: "${item.price}",
                        style: context.regularText.copyWith(fontSize: 16),
                      ),
                    ]),
                  )
              ],
            ),
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
                    style: context.mediumText.copyWith(fontSize: 12),
                  ).withPadding(horizontal: 4.w),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                text: "${LocaleKeys.service_type.tr()} : ",
                style: context.regularText.copyWith(color: context.hintColor),
                children: [
                  TextSpan(text: item.typeTrans, style: context.mediumText.copyWith(fontSize: 16)),
                ],
              ),
            ).withPadding(top: 8.h),
            Row(
              children: [
                Icon(Icons.access_time, color: context.primaryColor, size: 20.h).withPadding(end: 3.w),
                Text(item.createdAt, style: context.regularText),
              ],
            ).withPadding(top: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                StatusContainer(
                  title: item.statusTrans,
                  color: item.color,
                )
              ],
            ).withPadding(top: 10.h, bottom: 5.h),

            if (item.status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
              )
          ],
        ),
      ),
    );
  }
}
