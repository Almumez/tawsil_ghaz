import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/routes/routes.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';

class RequestGasWidget extends StatelessWidget {
  const RequestGasWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';
    
    return InkWell(
      onTap: () => push(NamedRoutes.clientChooseDistributingMethod),
      child: Container(
        height: 140.h,
        width: 353.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          image: DecorationImage(
            image: AssetImage(
              isEnglish 
                ? Assets.images.homeDistributionEn.path 
                : Assets.images.homeDistribution.path,
            ),
            fit: BoxFit.cover,
            opacity: .7
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.distribution.tr(),
              style: context.boldText.copyWith(
                fontSize: 28.sp,
                color: Colors.black, // Assuming text should be white on the image
              ),
            ).withPadding(bottom: 10.h),


          ],
        ).withPadding(start: 20.w),
      ),
    );
  }
}
