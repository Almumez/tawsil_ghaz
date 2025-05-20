import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/upload_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/complete_data_cubit.dart';
import '../controller/complete_data_states.dart';

class CompleteDataView extends StatefulWidget {
  final String phone, phoneCode;
  const CompleteDataView({super.key, required this.phone, required this.phoneCode});

  @override
  State<CompleteDataView> createState() => _CompleteDataViewState();
}

class _CompleteDataViewState extends State<CompleteDataView> {
  final form = GlobalKey<FormState>();
  final cubit = sl<CompleteDataCubit>();
  bool acceptTerms = false;
  @override
  void initState() {
    super.initState();
    cubit.phone = widget.phone;
    cubit.phoneCode = widget.phoneCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80.h),
            CustomImage(Assets.images.logo.path, height: 42.2.h),
            SizedBox(height: 17.h),
            Text(LocaleKeys.complete_registration.tr(), style: context.boldText.copyWith(fontSize: 24)),
            SizedBox(height: 12.h),
            Text(
              LocaleKeys.please_enter_this_information_to_continue_registering_and_enjoy_our_services.tr(),
              style: context.regularText.copyWith(fontSize: 16, color: context.hintColor),
            ).withPadding(bottom: 19.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 16.h,
                  children: [
                    UploadImage(
                      title: LocaleKeys.driving_license.tr(),
                      model: 'FreeAgent',
                      data: cubit.license,
                    ),
                    UploadImage(
                      title: LocaleKeys.vehicle_registration_form.tr(),
                      model: 'FreeAgent',
                      data: cubit.vehicleForm,
                    ),
                    // UploadImage(
                    //   title: LocaleKeys.health_certificate.tr(),
                    //   model: 'FreeAgent',
                    //   data: cubit.healthCertificate,
                    // ),
                    AppField(
                      controller: cubit.civilStatusNumber,
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      keyboardType: TextInputType.number,
                      labelText: LocaleKeys.civil_status_number.tr(),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: acceptTerms,
                          onChanged: (bool? val) {
                            setState(() {
                              acceptTerms = val!;
                            });
                          },
                        ),
                        Text(LocaleKeys.accept_terms.tr())
                      ],
                    ),
                    BlocConsumer<CompleteDataCubit, CompleteDataState>(
                      bloc: cubit,
                      listener: (context, state) {
                        if (state.requestState.isDone) {
                          pushAndRemoveUntil(NamedRoutes.successCompleteData);
                        } else if (state.requestState.isError) {
                          FlashHelper.showToast(state.msg);
                        }
                      },
                      builder: (context, state) {
                        return AppBtn(
                          loading: state.requestState.isLoading,
                          title: LocaleKeys.confirm.tr(),
                          onPressed: () {
                            if (cubit.validateSave && form.currentState!.validate() && acceptTerms) {
                              cubit.completeData();
                            } else if (!acceptTerms) {
                              FlashHelper.showToast(LocaleKeys.accept_terms.tr());
                            }
                          },
                        );
                      },
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            )
          ],
        ).withPadding(horizontal: 16.w),
      ),
    );
  }
}
