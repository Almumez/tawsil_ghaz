import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/extensions.dart';

import '../../../../gen/locale_keys.g.dart';

class InvoiceRow extends StatelessWidget {
  final BuildContext context;
  final String title;
  final double price;
  final bool? isDiscount;
  const InvoiceRow({super.key, required this.title, required this.price, this.isDiscount = false, required this.context});

  Color get discountColor => isDiscount! ? Colors.red : context.primaryColorDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: title == LocaleKeys.total.tr() ? context.boldText : context.regularText.copyWith(color: discountColor))),
        Text.rich(
          TextSpan(text: price.toString(), style: context.boldText.copyWith(fontSize: 16, color: discountColor), children: [
            TextSpan(text: ' ${LocaleKeys.currency.tr()}', style: context.regularText.copyWith(color: discountColor)),
          ]),
        )
      ],
    );
  }
}
