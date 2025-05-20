import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_radius_icon.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/status_container.dart';

class ClientOrderCard extends StatelessWidget {
  final Function() onBack;
  final ClientOrderModel data;
  const ClientOrderCard({super.key, required this.data, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print(data.type);
        push(NamedRoutes.orderDetails, arg: {"id": data.id, "type": data.type}).then((context) => onBack());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: context.borderColor),
          color: context.hoverColor,
        ),
        child: Column(
          spacing: 10.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                CustomRadiusIcon(
                  size: 40.h,
                  backgroundColor: context.primaryColorLight,
                  child: CustomImage(
                    data.agent.id != '' ? data.agent.image : Assets.images.logo.path,
                    height: 36.h,
                    width: 36.h,
                    borderRadius: BorderRadius.circular(40.h),
                  ),
                ).withPadding(end: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.agent.id != '' ? data.agent.fullname : LocaleKeys.no_agent.tr(),
                        style: context.mediumText.copyWith(fontSize: 14),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          CustomImage(
                            Assets.svg.location,
                            height: 16.sp,
                            width: 16.sp,
                          ).withPadding(end: 4.w),
                          Expanded(
                            child: Text(
                              data.address.placeDescription,
                              style: context.regularText.copyWith(fontSize: 12, color: context.hintColor),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                StatusContainer(
                  title: data.statusTrans,
                  color: data.color,
                ).toEnd
              ],
            ),
            Text.rich(
              TextSpan(
                text: LocaleKeys.the_service.tr(),
                style: context.regularText.copyWith(color: context.hintColor),
                children: [
                  TextSpan(
                    text: data.typeTrans,
                    style: context.boldText,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                CustomImage(
                  Assets.svg.calender,
                  height: 16.sp,
                  width: 16.sp,
                  color: context.hintColor,
                ).withPadding(end: 5.w),
                Text(
                  DateFormat('dd MMM yyyy', context.locale.languageCode).format(data.createdAt),
                  style: context.regularText.copyWith(
                    fontSize: 12,
                    color: context.hintColor,
                  ),
                ),
                CustomImage(
                  Assets.svg.clock,
                  height: 16.sp,
                  width: 16.sp,
                  color: context.hintColor,
                ).withPadding(start: 12.w, end: 5.w),
                Text(
                  DateFormat('hh:mm a', context.locale.languageCode).format(data.createdAt),
                  style: context.regularText.copyWith(
                    fontSize: 12,
                    color: context.hintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
