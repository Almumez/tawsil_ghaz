import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/forget_password_cubit.dart';
import '../controller/forget_password_states.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<ForgetPasswordCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: const AuthAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80.h),
              CustomImage(Assets.images.logo.path, height: 42.2.h),
              SizedBox(height: 45.h),
              Text(LocaleKeys.reset_password.tr(), style: context.boldText.copyWith(fontSize: 24)),
              SizedBox(height: 12.h),
              Text(
                LocaleKeys.please_enter_the_phone_number_below_to_reset_your_password.tr(),
                style: context.regularText.copyWith(fontSize: 14, color: context.hintColor),
              ),
              AppField(
                controller: cubit.phone,
                margin: EdgeInsets.symmetric(vertical: 24.h),
                keyboardType: TextInputType.phone,
                labelText: LocaleKeys.phone_number.tr(),
                onChangeCountry: (country) => cubit.country = country,
              ),
              SizedBox(height: 8.h),
              BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                bloc: cubit,
                listener: (context, state) {
                  if (state.requestState.isDone) {
                    push(NamedRoutes.verifyPhone, arg: {'type': VerifyType.resetPassword, 'phone': cubit.phone.text, 'phone_code': cubit.country!.phoneCode});
                  } else if (state.requestState.isError) {
                    FlashHelper.showToast(state.msg);
                  }
                },
                builder: (context, state) {
                  return AppBtn(
                    loading: state.requestState.isLoading,
                    onPressed: () => form.isValid ? cubit.forgotPassword() : null,
                    title: LocaleKeys.send.tr(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
