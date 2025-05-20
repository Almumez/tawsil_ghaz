import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';

class SuccessCompleteDataView extends StatefulWidget {
  const SuccessCompleteDataView({super.key});

  @override
  State<SuccessCompleteDataView> createState() => _SuccessCompleteDataViewState();
}

class _SuccessCompleteDataViewState extends State<SuccessCompleteDataView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: AppBtn(
          title: LocaleKeys.confirm.tr(),
          onPressed: () {
            replacement(NamedRoutes.login);
          },
        ),
      ).withPadding(horizontal: 24.w, bottom: 16.h),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleKeys.request_to_create_an_account.tr(), style: context.boldText.copyWith(fontSize: 24)).center.withPadding(bottom: 10.h),
          Text(
            LocaleKeys.request_to_create_an_account_pending_admin_approval.tr(),
            style: context.regularText.copyWith(fontSize: 16, color: context.hintColor),
            textAlign: TextAlign.center,
          ).center,
        ],
      ).withPadding(horizontal: 24.w),
    );
  }
}
