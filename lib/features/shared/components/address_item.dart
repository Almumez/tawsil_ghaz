import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/extensions.dart';
import '../../../gen/locale_keys.g.dart';

class OrderDetailsAddressItem extends StatelessWidget {
  const OrderDetailsAddressItem({
    super.key,
    required this.title,
    required this.description,
    this.lable,
  });
  final String? lable;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${lable ?? LocaleKeys.address.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        Container(
          width: context.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.mediumText.copyWith(fontSize: 14)).withPadding(bottom: 5.h),
              Text(description, style: context.regularText.copyWith(fontSize: 12)).withPadding(bottom: 5.h),
            ],
          ),
        ).withPadding(bottom: 16),
      ],
    );
  }
}
