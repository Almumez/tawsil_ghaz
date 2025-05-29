import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../gen/locale_keys.g.dart';

class SendBillSheet extends StatefulWidget {
  final String? amount;
  const SendBillSheet({super.key, this.amount});

  @override
  State<SendBillSheet> createState() => _SendBillSheetState();
}

class _SendBillSheetState extends State<SendBillSheet> {
  late final textCtr = TextEditingController(text: widget.amount ?? '');
  final form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: CustomAppSheet(
        title: LocaleKeys.attach_invoice.tr(),
        titleWidget: Row(
          children: [
            SvgPicture.asset(
              'assets/svg/invoice.svg',
              height: 24.h,
              width: 24.w,
              colorFilter: ColorFilter.mode(
                context.primaryColor,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              LocaleKeys.attach_invoice.tr(),
              style: context.semiboldText.copyWith(fontSize: 18),
            ),
          ],
        ),
        children: [
          SizedBox(height: 8.h),
          Text(
            LocaleKeys.amount.tr(),
            style: context.mediumText.copyWith(fontSize: 14.sp),
          ).withPadding(bottom: 8.h),
          AppField(
            controller: textCtr,
            keyboardType: TextInputType.number,
            hintText: LocaleKeys.enter_amount.tr(),
            validator: (v) {
              final amount = double.tryParse('$v');
              if (amount == null) {
                return LocaleKeys.invalid_value.tr();
              } else if (amount == 0) {
                return LocaleKeys.insufficient_balance.tr();
              }
              return null;
            },
            suffixIcon: SizedBox(
              width: 100.w,
              child: Container(
                decoration: BoxDecoration(
                  color: context.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r)
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Text(
                  LocaleKeys.sar.tr(),
                  style: context.mediumText.copyWith(
                    fontSize: 14,
                    color: context.primaryColor,
                  ),
                ),
              ).center,
            ),
          ),
          SizedBox(height: 24.h),
          AppBtn(
            onPressed: () {
              if (form.isValid) {
                Navigator.pop(context, textCtr.text);
              }
            },
            title: LocaleKeys.confirm.tr(),
            prefix: SvgPicture.asset(
              'assets/svg/check_circle.svg',
              height: 20.h,
              width: 20.w,
              colorFilter: ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
