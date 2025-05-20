import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/routes/app_routes_fun.dart';
import '../../core/routes/routes.dart';
import '../../core/widgets/app_btn.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/custom_image.dart';
import '../../gen/assets.gen.dart';
import '../../gen/locale_keys.g.dart';

import '../../components/appbar.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int currentIndex = 0;

  final PageController _controller = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: LogoAppbar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(LocaleKeys.welcome_you.tr(), style: context.boldText.copyWith(fontSize: 24)).withPadding(bottom: 10.h).center,
          Text(LocaleKeys.don_t_miss_out_on_trying_the_app_with_its_many_diverse_features.tr(),
                  style: context.regularText.copyWith(fontSize: 20, height: 1.2), textAlign: TextAlign.center)
              .withPadding(bottom: 56.h),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children: [
                OnboardingItem(image: Assets.svg.intro1, title: LocaleKeys.live_tracking.tr()),
                OnboardingItem(image: Assets.svg.intro2, title: LocaleKeys.cover_all_cities.tr()),
                OnboardingItem(image: Assets.svg.intro3, title: LocaleKeys.verify_all_distributors.tr()),
                OnboardingItem(image: Assets.svg.intro5, title: LocaleKeys.varied_and_secure_payment.tr()),
                OnboardingItem(image: Assets.svg.intro4, title: LocaleKeys.instant_support.tr()),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => currentIndex == index
                  ? Container(
                      height: 8.h,
                      width: 24.w,
                      margin: EdgeInsetsDirectional.only(end: 2.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: context.primaryColor,
                      ),
                    ).withPadding(horizontal: 2.w)
                  : Container(
                      height: 8.h,
                      width: 8.w,
                      margin: EdgeInsetsDirectional.only(end: 2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.primaryColor.withValues(alpha: .4),
                      ),
                    ).withPadding(horizontal: 2.w),
            ),
          ).center.withPadding(bottom: 52.h),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBtn(
            saveArea: false,
            title: LocaleKeys.star_now.tr(),
            onPressed: () => replacement(NamedRoutes.login),
          ),
          AppBtn(
            title: LocaleKeys.login_as_guest.tr(),
            backgroundColor: context.scaffoldBackgroundColor,
            textColor: context.primaryColor,
            onPressed: () => pushAndRemoveUntil(NamedRoutes.navbar),
          ).withPadding(top: 10.h),
        ],
      ).withPadding(bottom: 24.h, horizontal: 24.w),
    );
  }
}

class OnboardingItem extends StatelessWidget {
  final String title, image;
  const OnboardingItem({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 6.w),
          height: 236.h,
          width: context.w,
          child: CustomImage(image, fit: BoxFit.fill).center,
        ).withPadding(bottom: 10.h),
        Text(title, style: context.boldText.copyWith(fontSize: 24)).center,
      ],
    );
  }
}
