import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/enums.dart';

import '../../controller/upload_attachment/attachment_cubit.dart';
import '../../controller/upload_attachment/attachment_state.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/phoneix.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/change_password_sheet.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_radius_icon.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../core/widgets/pick_image.dart';
import '../../../../core/widgets/pin_code_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/user_model.dart';
import '../../components/appbar.dart';
import 'controller/edit_profile_cubit.dart';
import 'controller/edit_profile_state.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final cubit = sl<EditProfileCubit>();
  final attachmentCubit = sl<UploadAttachmentCubit>();
  final _buttonStream = StreamController<bool>();
  final _phoneStream = StreamController<bool>();

  @override
  void initState() {
    super.initState();
    cubit.name.addListener(() => _buttonStream.add(cubit.canUpdate));
    cubit.email.addListener(() => _buttonStream.add(cubit.canUpdate));
    cubit.phone.addListener(() => _phoneStream.add(cubit.canUpdatePhone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.edit_profile.tr()),
      bottomNavigationBar: SafeArea(
        child: StreamBuilder<bool>(
            stream: _buttonStream.stream,
            builder: (context, snapshot) {
              return BlocConsumer<EditProfileCubit, EditProfileState>(
                  bloc: cubit,
                  listener: (context, state) {
                    if (state.requestState.isDone) {
                      Phoenix.rebirth(context);
                      _buttonStream.add(cubit.canUpdate);
                      FlashHelper.showToast(state.msg, type: MessageType.success);
                    }
                  },
                  builder: (context, state) {
                    return AppBtn(
                      enable: snapshot.data ?? false,
                      title: LocaleKeys.confirm.tr(),
                      loading: state.requestState.isLoading,
                      onPressed: () {
                        cubit.updateProfile();
                      },
                    );
                  }).withPadding(horizontal: 16.w, bottom: 16.h);
            }),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            BlocConsumer<UploadAttachmentCubit, UploadAttachmentState>(
              bloc: attachmentCubit,
              listener: (context, state) {
                if (state.requestState.isDone) {
                  cubit.pickedImage = state.file!;
                  cubit.image = state.key;
                  _buttonStream.add(cubit.canUpdate);
                } else if (state.requestState.isError) {
                  FlashHelper.showToast(state.msg);
                }
              },
              builder: (context, state) {
                return InkWell(
                  onTap: () async {
                    if (!state.requestState.isLoading) {
                      final result = await showModalBottomSheet(
                        elevation: 0,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (context) => PickImage(
                          title: LocaleKeys.pick_image.tr(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          attachmentCubit.file = result;
                        });
                        attachmentCubit.uploadAttachment(model: 'User');
                      }
                    }
                  },
                  child: Badge(
                    label: CustomRadiusIcon(
                      size: 32.h,
                      backgroundColor: context.primaryColorDark,
                      child: state.requestState.isLoading
                          ? CustomProgress(size: 16.h, color: context.primaryColorLight)
                          : CustomImage(Assets.images.edit.path, color: context.primaryColorLight, height: 16.h),
                    ),
                    backgroundColor: Colors.transparent,
                    offset: Offset(context.locale.languageCode == 'en' ? -25.w : 80.w, 90.h),
                    child: CustomImage(
                      cubit.pickedImage?.path ?? UserModel.i.image,
                      border: Border.all(color: context.hoverColor),
                      height: 120.h,
                      isFile: true,
                      width: 120.h,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(60.r),
                    ),
                  ),
                );
              },
            ).center,
          
            SizedBox(height: 10.h),
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  elevation: 0,
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => ChangePasswordSheet(),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImage(Assets.images.keyIcon.path, height: 16.h).withPadding(end: 8.w),
                  Text(LocaleKeys.change_password.tr(), style: context.regularText),
                ],
              ).withPadding(bottom: 25.h),
            ),
            AppField(labelText: LocaleKeys.name.tr(), controller: cubit.name).withPadding(bottom: 16.h),
            if (UserModel.i.accountType != UserType.client)
              AppField(labelText: LocaleKeys.email.tr(), controller: cubit.email, isRequired: false).withPadding(bottom: 16.h),
            BlocConsumer<EditProfileCubit, EditProfileState>(
              bloc: cubit,
              listener: (context, state) {
                if (state.phoneState.isDone) {
                  showModalBottomSheet(
                    elevation: 0,
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    builder: (context) => PinCodeSheet(
                      phone: cubit.phone.text,
                      phoneCode: cubit.country!.phoneCode,
                      code: cubit.code.text,
                    ),
                  );
                } else if (state.phoneState.isError) {
                  FlashHelper.showToast(state.msg);
                }
              },
              builder: (context, state) {
                return AppField(
                  labelText: LocaleKeys.phone_number.tr(),
                  controller: cubit.phone,
                  initCountry: cubit.country,
                  onChangeCountry: (country) {
                    cubit.country = country;
                    _phoneStream.add(cubit.canUpdatePhone);
                  },
                  keyboardType: TextInputType.phone,
                  suffixIcon: SizedBox(
                    width: 60.w,
                    child: Center(
                      child: StreamBuilder<bool>(
                        stream: _phoneStream.stream,
                        builder: (context, sna) {
                          return InkWell(
                            onTap: () {
                              if (sna.data == true && cubit.phone.text.isNotEmpty) {
                                cubit.updatePhone();
                              }
                            },
                            child: Text(
                              LocaleKeys.confirm.tr(),
                              style: context.regularText.copyWith(color: sna.data == true ? context.primaryColorDark : context.hintColor),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
