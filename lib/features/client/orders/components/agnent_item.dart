import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/status_container.dart';

class ClientOrderAgentItem extends StatelessWidget {
  const ClientOrderAgentItem({
    super.key,
    required this.data,
  });

  final ClientOrderModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   "• ${data.type != 'maintenance' || data.type != 'supply' ? LocaleKeys.technician.tr() : LocaleKeys.agent.tr()}",
        //   style: context.semiboldText.copyWith(fontSize: 16),
        // ).withPadding(bottom: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg/delivry.svg',
                height: 20.h,
                width: 20.h,
                colorFilter: ColorFilter.mode(
                  context.primaryColor,
                  BlendMode.srcIn,
                ),
              ).withPadding(end: 10.w),
              Expanded(
                child: Text(
                  data.agent.id == '' ? "انتظار" : data.agent.fullname,
                  style: context.mediumText
                ),
              ),
              if (data.type != 'maintenance' && data.type != 'supply')
                StatusContainer(
                  title: data.statusTrans,
                  color: data.color,
                ).toEnd
            ],
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
