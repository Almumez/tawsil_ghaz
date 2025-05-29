import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'send_bill_sheet.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';

class AgentBillWidget extends StatelessWidget {
  final AgentOrderDetailsCubit cubit;
  const AgentBillWidget({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final item = cubit.order!;
    if (item.type == 'distribution' || item.price != 0) {
      return CustomImage(
        Assets.svg.bill,
        fit: BoxFit.fill,
        width: context.w,
        height: 270.h,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.service_price.tr(),
                    style: context.regularText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: "${item.price}", style: context.boldText.copyWith(fontSize: 16)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.regularText.copyWith(fontSize: 16)),
                  ]),
                )
              ],
            ),
            Row(children: List.generate(40, (i) => Expanded(child: Divider(height: 28.h, endIndent: 1.w, indent: 1.w)))),
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.tax.tr(),
                    style: context.regularText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: "${item.tax}", style: context.boldText.copyWith(fontSize: 16)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.regularText.copyWith(fontSize: 16)),
                  ]),
                ),
              ],
            ),
            Row(children: List.generate(40, (i) => Expanded(child: Divider(height: 28.h, endIndent: 1.w, indent: 1.w)))),
            Row(
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.delivery_price.tr(),
                    style: context.regularText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${item.deliveryFee}', style: context.boldText.copyWith(fontSize: 16)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.regularText.copyWith(fontSize: 16)),
                  ]),
                )
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${LocaleKeys.total.tr()} :',
                    style: context.boldText.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(text: '${item.totalPrice}', style: context.boldText.copyWith(fontSize: 16)),
                    TextSpan(text: LocaleKeys.sar.tr(), style: context.regularText.copyWith(fontSize: 16)),
                  ]),
                )
              ],
            ),
          ],
        ).withPadding(vertical: 22.h, horizontal: 16.w),
      );
    } else if (item.status == 'on_way') {
      return GestureDetector(
        onTap: () => showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (c) => SendBillSheet(),
        ).then((v) {
          if (v != null) {
            cubit.bill = v;
            cubit.refreshOrder();
            cubit.sendBill();
          }
        }),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(8.r),
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 48.h,
            child: Text(
              LocaleKeys.attach_invoice_filling_invoice.tr(),
              style: context.semiboldText.copyWith(fontSize: 16),
            ).center,
          ),
        ).withPadding(bottom: 16.h),
      );
    }
    return SizedBox();
  }
}
