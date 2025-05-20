import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
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
import '../controller/register_cubit.dart';
import '../controller/register_states.dart';

class RegisterView extends StatefulWidget {
  final UserType userType;
  const RegisterView({super.key, required this.userType});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<RegisterCubit>();

  @override
  void initState() {
    cubit.userType = widget.userType;
    print("user type is : ${cubit.userType}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 80.h),
              CustomImage(Assets.images.logo.path, height: 42.2.h),
              SizedBox(height: 17.h),
              Text(LocaleKeys.welcome_you.tr(), style: context.boldText.copyWith(fontSize: 24)),
              Text(
                LocaleKeys.please_enter_this_information_to_continue_registering_and_enjoy_our_services.tr(),
                style: context.regularText.copyWith(fontSize: 16, color: context.hintColor),
              ).withPadding(bottom: 19.h),
              AppField(
                controller: cubit.fullName,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                keyboardType: TextInputType.name,
                labelText: LocaleKeys.fullname.tr(),
              ),
              AppField(
                controller: cubit.phone,
                onChangeCountry: (country) => cubit.country = country,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                keyboardType: TextInputType.phone,
                labelText: LocaleKeys.phone_number.tr(),
              ),
              // AppField(
              //   controller: bloc.email,
              //   margin: EdgeInsets.symmetric(vertical: 8.h),
              //   keyboardType: TextInputType.emailAddress,
              //   labelText: LocaleKeys.email.tr(),
              // ),
              AppField(
                controller: cubit.password,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                keyboardType: TextInputType.visiblePassword,
                labelText: LocaleKeys.password.tr(),
              ),
              AppField(
                controller: cubit.confirmPassword,
                validator: (v) {
                  if (v != cubit.password.text) {
                    return LocaleKeys.passwords_do_not_match.tr();
                  } else {
                    return null;
                  }
                },
                margin: EdgeInsets.symmetric(vertical: 8.h),
                keyboardType: TextInputType.visiblePassword,
                labelText: LocaleKeys.confirm_password.tr(),
              ),
              SizedBox(height: 24.h),
              BlocConsumer<RegisterCubit, RegisterState>(
                bloc: cubit,
                listener: (context, state) {
                  if (state.requestState.isDone) {
                    replacement(NamedRoutes.verifyPhone, arg: {'type': VerifyType.register, 'phone': cubit.phone.text, 'phone_code': cubit.country!.phoneCode});
                  } else if (state.requestState.isError) {
                    FlashHelper.showToast(state.msg);
                  }
                },
                builder: (context, state) {
                  return AppBtn(
                    loading: state.requestState.isLoading,
                    onPressed: () => form.isValid ? cubit.register() : null,
                    title: LocaleKeys.create_account.tr(),
                  );
                },
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: LocaleKeys.have_account.tr(),
                      style: context.regularText.copyWith(fontSize: 14),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: LocaleKeys.login.tr(),
                      recognizer: TapGestureRecognizer()..onTap = () => replacement(NamedRoutes.login),
                      style: context.mediumText.copyWith(fontSize: 16, color: context.secondaryColor),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ).withPadding(vertical: 18.h),
            ],
          ),
        ),
      ),
    );
  }
}
