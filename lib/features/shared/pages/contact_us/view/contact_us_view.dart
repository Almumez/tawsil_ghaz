import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/widgets/app_btn.dart';

import '../../../../../core/services/service_locator.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/widgets/app_field.dart';
import '../../../../../core/widgets/custom_radius_icon.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../components/appbar.dart';
import '../controller/contact_us_cubit.dart';
import '../controller/contact_us_state.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  final cubit = sl<ContactUsCubit>()..getContacts();
  final form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: LocaleKeys.contact_us.tr()),
      bottomNavigationBar: SafeArea(
        child: BlocConsumer<ContactUsCubit, ContactUsState>(
          bloc: cubit,
          buildWhen: (previous, current) => previous.sendContactsState != current.sendContactsState,
          listenWhen: (previous, current) => previous.sendContactsState != current.sendContactsState,
          listener: (context, state) {
            if (state.sendContactsState.isDone) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            return AppBtn(
              loading: state.sendContactsState.isLoading,
              title: LocaleKeys.send.tr(),
              onPressed: () {
                if (form.currentState!.validate()) {
                  cubit.send();
                }
              },
            );
          },
        ).withPadding(horizontal: 24.w, bottom: 16.h),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<ContactUsCubit, ContactUsState>(
                bloc: cubit,
                builder: (context, state) {
                  if (cubit.contactsPhone != null) {
                    return Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(color: context.canvasColor, borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(LocaleKeys.contact_us.tr(), style: context.mediumText).withPadding(bottom: 8.h),
                                Text('${cubit.contactsPhone}', style: context.regularText, textDirection: TextDirection.ltr),
                              ],
                            ),
                          ),
                          CustomRadiusIcon(
                            onTap: () => launchUrl(Uri.parse('https://wa.me/${cubit.contactsPhone}')),
                            size: 40.h,
                            backgroundColor: context.primaryColorDark,
                            child: Icon(CupertinoIcons.phone, color: context.primaryColorLight, size: 24.h),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              Text(LocaleKeys.please_enter_the_information.tr(), style: context.boldText).withPadding(top: 32.h, bottom: 20.h),
              AppField(labelText: LocaleKeys.name.tr(), controller: cubit.name).withPadding(bottom: 20.h),
              AppField(labelText: LocaleKeys.email.tr(), controller: cubit.email, isRequired: false).withPadding(bottom: 20.h),
              AppField(
                  labelText: LocaleKeys.phone.tr(),
                  controller: cubit.phone,
                  keyboardType: TextInputType.phone,
                  onChangeCountry: (country) => cubit.country = country).withPadding(bottom: 20.h),
              AppField(
                labelText: LocaleKeys.your_message.tr(),
                controller: cubit.msg,
                maxLines: 4,
              ).withPadding(bottom: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
