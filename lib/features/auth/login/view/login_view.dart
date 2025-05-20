import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/select_item_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../../../models/country.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import '../controller/login_cubit.dart';
import '../controller/login_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<LoginCubit>();
  List<UserTypeModel> userTypes = [
    UserTypeModel(name: LocaleKeys.client.tr(), userType: UserType.client),
    UserTypeModel(
        name: LocaleKeys.free_agent.tr(), userType: UserType.freeAgent),
  ];
  @override
  void initState() {
    super.initState();
    // تعيين رمز الدولة الافتراضي للسعودية (+966)
    cubit.country = CountryModel.fromJson({
      'name': 'Saudi Arabia',
      'phone_code': '966',
      'flag': '',
      'short_name': 'SA',
      'phone_limit': 9
    });
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
              Center(
                child: CustomImage("assets/images/splash.png", height: 60.h),
              ),
              SizedBox(height: 16.h),
              Text(
                "تسجيل الدخول",
                textAlign: TextAlign.center,
                style: context.semiboldText.copyWith(fontSize: 22),
              ),
              SizedBox(height: 45.h),
              AppField(
                controller: cubit.phone,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                keyboardType: TextInputType.phone,
                labelText: "الهاتف",
                onChangeCountry: null,
                prefixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 14.h),
                      child: Text(
                        "+966",
                        style: context.regularText.copyWith(fontSize: 14),
                      ),
                    ),
                    Container(
                      height: 25.h,
                      width: 1,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              AppField(
                controller: cubit.password,
                margin: EdgeInsets.symmetric(vertical: 8.h),
                keyboardType: TextInputType.visiblePassword,
                labelText: "الرمز",
              ),
              Text.rich(
                TextSpan(
                  text: "نسيت الرمز",
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => push(NamedRoutes.forgetPassword),
                ),
                style: context.regularText.copyWith(fontSize: 14),
              ).withPadding(vertical: 8.h),
              SizedBox(height: 24.h),
              BlocConsumer<LoginCubit, LoginState>(
                bloc: cubit,
                listener: (context, state) {
                  switch (state.requestState) {
                    case RequestState.done:
                      _navigateUserBasedOnType();
                      break;

                    case RequestState.error:
                      FlashHelper.showToast(state.msg);
                      break;

                    default:
                      break;
                  }
                },
                builder: (context, state) {
                  return AppBtn(
                    loading: state.requestState == RequestState.loading,
                    onPressed: () => form.isValid ? cubit.login() : null,
                    title: LocaleKeys.confirm.tr(),
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    radius: 30.r,
                  );
                },
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "انشاء حساب",
                      style: context.regularText.copyWith(fontSize: 14),
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: "تسجيل",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          showModalBottomSheet<UserTypeModel?>(
                            context: context,
                            builder: (context) => SelectItemSheet(
                              title: LocaleKeys.select_val
                                  .tr(args: [LocaleKeys.user_type.tr()]),
                              items: userTypes,
                            ),
                          ).then((value) {
                            if (value != null) {
                              push(NamedRoutes.register,
                                  arg: {"type": value.userType});
                            }
                          });
                        },
                      style: context.mediumText.copyWith(
                          fontSize: 16, color: context.secondaryColor),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ).withPadding(vertical: 18.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: Colors.black),
          ),
          child: AppBtn(
            title: LocaleKeys.login_as_guest.tr(),
            backgroundColor: Colors.transparent,
            textColor: Colors.black,
            onPressed: () => pushAndRemoveUntil(NamedRoutes.navbar),
            radius: 30.r,
          ),
        ),
      ),
    );
  }

  void _navigateUserBasedOnType() {
    final user = UserModel.i;

    if (user.accountType == UserType.client) {
      _handleClientNavigation(user);
      return;
    }

    if (user.accountType == UserType.freeAgent ||
        user.accountType == UserType.agent ||
        user.accountType == UserType.productAgent ||
        user.accountType == UserType.technician) {
      _handleAgentNavigation(user);
      return;
    }

    _navigateToHome();
  }

  void _handleClientNavigation(UserModel user) {
    if (user.isActive) {
      _navigateToHome();
    } else {
      _navigateToVerifyPhone();
    }
  }

  void _handleAgentNavigation(UserModel user) {
    if (!user.isActive) {
      _navigateToVerifyPhone();
    } else if (user.accountType == UserType.freeAgent) {
      if (!user.completeRegistration) {
        _navigateToCompleteData();
      } else if (!user.adminApproved) {
        push(NamedRoutes.successCompleteData);
      } else {
        _navigateToHome();
      }
    } else {
      _navigateToHome();
    }
  }

  void _navigateToVerifyPhone() {
    push(
      NamedRoutes.verifyPhone,
      arg: {
        'type': VerifyType.register,
        'phone': cubit.phone.text,
        'phone_code': cubit.country!.phoneCode,
      },
    );
  }

  void _navigateToCompleteData() {
    push(
      NamedRoutes.completeData,
      arg: {
        'phone': cubit.phone.text,
        'phone_code': cubit.country!.phoneCode,
      },
    );
  }

  void _navigateToHome() {
    sl<NavbarCubit>().changeTap(0);
    pushAndRemoveUntil(NamedRoutes.navbar);
  }
}

class UserTypeModel {
  final String name;
  final UserType userType;

  UserTypeModel({required this.name, required this.userType});
}
