import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';

class RequestGasWidget extends StatelessWidget {
  const RequestGasWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => push(NamedRoutes.clientChooseDistributingMethod),
      child: CustomImage(
        context.locale.languageCode == 'en' ? Assets.images.homeDistributionEn.path : Assets.images.homeDistribution.path,
        height: 140.h,
        width: 353.w,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleKeys.distribution.tr(), style: context.boldText.copyWith(fontSize: 23)).withPadding(bottom: 10.h),
            Text(LocaleKeys.request_gas_now.tr(), style: context.regularText.copyWith(fontSize: 15)),
          ],
        ).toStart.withPadding(start: 20.w),
      ),
    );
  }
}
