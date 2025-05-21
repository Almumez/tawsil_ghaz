import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/phoneix.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/widgets/delete_account_sheet.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../core/widgets/select_item_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/profile_item.dart';
import '../../components/appbar.dart';
import 'controller/cubit.dart';
import 'controller/state.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final cubit = sl<SettingsCubit>();

  String getLangUrl(Locale locale) {
    return locale.languageCode == 'en' ? 'general/profile/locale/en' : 'general/profile/locale/ar';
  }

  List<ProfileItemModel> items = [
    ProfileItemModel(image: Assets.svg.contactUs, title: LocaleKeys.contact_us, onTap: () => push(NamedRoutes.contactUs)),
    ProfileItemModel(image: Assets.svg.aboutUs, title: LocaleKeys.about_us, onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.about})),
    ProfileItemModel(image: Assets.svg.terms, title: LocaleKeys.terms_and_conditions, onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.terms})),
    ProfileItemModel(image: Assets.svg.policy, title: LocaleKeys.privacy_policy, onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.privacy})),
    ProfileItemModel(image: Assets.svg.faq, title: LocaleKeys.faq, onTap: () => push(NamedRoutes.faq)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppbar(title: LocaleKeys.settings.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 32.h,
          children: [
            BlocConsumer<SettingsCubit, SettingsState>(
              bloc: cubit,
              listener: (context, state) {
                if (state.changeLanguageState.isDone) {
                  navigator.currentContext!.setLocale(state.locale!);
                  Phoenix.rebirth(context);
                } else if (state.changeLanguageState.isError) {
                  FlashHelper.showToast(state.msg);
                }
              },
              builder: (context, state) {
                return Row(
                  children: [
                    CustomImage(
                      Assets.svg.languageIcon,
                      height: 24.h,
                      width: 24.h,
                      color: context.primaryColorDark,
                    ).withPadding(end: 16.w),
                    Expanded(child: Text(LocaleKeys.language.tr(), style: context.mediumText)),
                    InkWell(
                      onTap: () async {
                        final localeResult = await showModalBottomSheet<SelectModel?>(
                          context: context,
                          builder: (context) => SelectItemSheet(
                            title: LocaleKeys.choose.tr(args: [LocaleKeys.language.tr()]),
                            items: const [
                              SelectModel(id: Locale('en', 'US'), name: 'English'),
                              SelectModel(id: Locale('ar', 'SA'), name: 'العربية'),
                            ],
                            initItem: SelectModel(
                              id: context.locale,
                              name: context.locale.languageCode == 'en' ? "English" : "العربية",
                            ),
                          ),
                        );
                        if (context.mounted) {
                          cubit.locale = localeResult!.id;
                          cubit.changeLanguage(getLangUrl(localeResult.id));
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            context.locale.languageCode == 'en' ? LocaleKeys.english.tr() : LocaleKeys.arabic.tr(),
                            style: context.mediumText,
                          ).withPadding(end: 6.w),
                          state.changeLanguageState.isLoading ? CustomProgress(size: 16.h) : Icon(Icons.keyboard_arrow_down),
                        ],
                      ),
                    )
                  ],
                );
              },
            ).withPadding(bottom: 0.h),
            Row(
              children: [
                CustomImage(
                  Assets.svg.notificationsOut,
                  height: 24.h,
                  width: 24.h,
                  color: context.primaryColorDark,
                ).withPadding(end: 16.w),
                Expanded(child: Text(LocaleKeys.notifications.tr(), style: context.mediumText)),
                BlocConsumer<SettingsCubit, SettingsState>(
                  bloc: cubit,
                  listener: (context, state) {
                    if (state.allowNotificationsState.isDone) {
                      Phoenix.rebirth(context);
                    } else if (state.allowNotificationsState.isError) {
                      FlashHelper.showToast(state.msg);
                    }
                  },
                  builder: (context, state) {
                    return Switch(
                      activeColor: context.primaryColorLight.withValues(alpha: state.allowNotificationsState.isLoading ? .5 : 1),
                      activeTrackColor: context.primaryColorDark.withValues(alpha: state.allowNotificationsState.isLoading ? .5 : 1),
                      inactiveThumbColor: context.primaryColorLight.withValues(alpha: state.allowNotificationsState.isLoading ? .5 : 1),
                      inactiveTrackColor: context.shadowColor.withValues(alpha: state.allowNotificationsState.isLoading ? .5 : 1),
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                      value: UserModel.i.isNotified,
                      onChanged: (value) {
                        cubit.allowNotifications();
                      },
                    );
                  },
                ),
              ],
            ).withPadding(bottom: 12.h),
            ...List.generate(
              items.length,
              (index) => InkWell(
                onTap: items[index].onTap,
                child: Row(
                  children: [
                    CustomImage(
                      items[index].image,
                      height: 24.h,
                      width: 24.h,
                      color: items[index].isLogout ? context.errorColor : context.primaryColorDark,
                    ).withPadding(end: 16.w),
                    Expanded(
                      child: Text(
                        items[index].title.tr(),
                        style: context.mediumText.copyWith(fontSize: 16, color: items[index].isLogout ? context.errorColor : null),
                      ),
                    ),
                  ],
                ),
              ).withPadding(bottom: 12.h),
            ),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => DeleteAccountSheet(),
                );
              },
              child: Row(
                children: [
                  CustomImage(
                    Assets.svg.deleteIcon,
                    height: 24.h,
                    width: 24.h,
                    color: context.errorColor,
                  ).withPadding(end: 16.w),
                  Expanded(child: Text(LocaleKeys.delete_account.tr(), style: context.mediumText.copyWith(color: context.errorColor))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
