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

class RequestGasWidget extends StatelessWidget {
  const RequestGasWidget({
    super.key,
  });

  void _showDistributionOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.only(
            top: 20.h,
            right: 16.w,
            left: 16.w,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شريط سحب في أعلى البوتوم شيت
                Container(
                  width: 50.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ).center.withPadding(bottom: 25.h),
                
                // عنوان البوتوم شيت
                Text(
                  LocaleKeys.distribution.tr(),
                  style: context.boldText.copyWith(
                    fontSize: 24.sp,
                    color: "#090909".color,
                  ),
                ).withPadding(bottom: 24.h),
                
                // خيار شراء/إعادة تعبئة أسطوانة
                _buildBannerImage(
                  context: context,
                  image: context.locale.languageCode == 'en' 
                    ? Assets.images.buyCylinderEn.path 
                    : Assets.images.buyCylinder.path,
                  title: LocaleKeys.gas_exchange.tr(),
                  buttonText: LocaleKeys.buy_or_refill_gas.tr(),
                  onPressed: () {
                    Navigator.pop(context);
                    push(NamedRoutes.buyCylinder);
                  },
                ).withPadding(bottom: 16.h),
                
                // خيار بيع أسطوانة
                Row(children: [
                  _buildBannerImage(
                    context: context,
                    image: context.locale.languageCode == 'en'
                        ? Assets.images.sellCylinderEn.path
                        : Assets.images.sellCylinder.path,
                    title: LocaleKeys.sell_gas_to_companies.tr(),
                    buttonText: LocaleKeys.sell_gas.tr(),
                    onPressed: () {
                      // يمكن تعديل هذه الوظيفة لاحقاً
                      Navigator.pop(context);
                      _showComingSoonPopup(context, LocaleKeys.sell_gas.tr());
                    },
                  ).withPadding(bottom: 10.h),
                ],)

              ],
            ),
          ),
        );
      },
    );
  }

  // عرض نافذة "قريباً"
  void _showComingSoonPopup(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: "#BDBDD3".color.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: "#d68243".color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: "#d68243".color,
                    size: 35.r,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  "${LocaleKeys.coming_soon.tr()}",
                  style: context.boldText.copyWith(
                    fontSize: 20.sp,
                    color: "#090909".color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15.h),
                Text(
                  LocaleKeys.service_not_available.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 16.sp,
                    color: "#9E968F".color,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: "#090909".color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                  child: Text(
                    LocaleKeys.ok.tr(),
                    style: context.mediumText.copyWith(
                      fontSize: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // بناء صورة البانر مع النص والزر
  Widget _buildBannerImage({
    required BuildContext context,
    required String image,
    required String title,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return CustomImage(
      image,
      height: 156.h,
      width: double.infinity,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.all(Radius.circular(12.r)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 180.w,
            child: Text(
              title,
              style: context.mediumText.copyWith(fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ).withPadding(bottom: 10.h),
          AppBtn(
            title: buttonText,
            width: 100.w,
            height: 40.h,
            onPressed: onPressed,
          ),
        ],
      ).withPadding(end: 20.w).toEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.locale.languageCode == 'en';
    
    return InkWell(
      onTap: () => _showDistributionOptionsBottomSheet(context),
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
              style: context.mediumText.copyWith(
                fontSize: 28.sp,
                color: Colors.black, // Assuming text should be white on the image
              ),
            ).withPadding(bottom: 10.h, start: 30.w),
          ],
        ).withPadding(start: 20.w),
      ),
    );
  }
}
