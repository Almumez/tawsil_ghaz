import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/country.dart';
import '../controller/verify_phone_bloc.dart';
import '../controller/verify_phone_states.dart';

class EditPhoneSheet extends StatefulWidget {
  final String phone;
  const EditPhoneSheet({super.key, required this.phone});

  @override
  State<EditPhoneSheet> createState() => _EditPhoneSheetState();
}

class _EditPhoneSheetState extends State<EditPhoneSheet> {
  late final newPhone = TextEditingController(text: widget.phone);
  CountryModel? country;
  final form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return CustomAppSheet(
      title: LocaleKeys.edit_phone.tr(),
      children: [
        Form(
          key: form,
          child: AppField(
            title: LocaleKeys.new_phone.tr(),
            controller: newPhone,
            keyboardType: TextInputType.phone,
            onChangeCountry: (country) => this.country = country,
          ),
        ),
        SizedBox(height: 10.h),
        BlocConsumer<VerifyPhoneCubit, VerifyPhoneState>(
          listenWhen: (previous, current) => previous.editEmailState != current.editEmailState,
          buildWhen: (previous, current) => previous.editEmailState != current.editEmailState,
          listener: (context, state) {
            if (state.editEmailState.isDone) {
              Navigator.pop(context, {'phone': newPhone.text});
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: AppBtn(
                loading: state.editEmailState.isLoading,
                title: LocaleKeys.confirm.tr(),
                onPressed: () => form.isValid ? context.read<VerifyPhoneCubit>().editEmail(country?.phoneCode ?? '', newPhone.text) : null,
              ),
            );
          },
        ),
        SizedBox(height: 10.h)
      ],
    );
  }
}
