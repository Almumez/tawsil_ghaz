import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/extensions.dart';
import '../../../core/widgets/custom_image.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/locale_keys.g.dart';

class PaymentMethodsView extends StatefulWidget {
  final Function(String) callback;

  const PaymentMethodsView({super.key, required this.callback});

  @override
  State<PaymentMethodsView> createState() => _PaymentMethodsViewState();
}

class _PaymentMethodsViewState extends State<PaymentMethodsView> {
  String paymentMethod = '';

  List<PaymentMethods> methods = [
    PaymentMethods(image: Assets.images.creditCard.path, title: LocaleKeys.online_payment.tr(), key: "visa"),
    // PaymentMethods(image: Assets.images.mada.path, title: LocaleKeys.mada.tr(), key: "mada"),
    PaymentMethods(image: Assets.images.cash.path, title: LocaleKeys.cash.tr(), key: "cash"),
    // PaymentMethods(image: Assets.images.applePay.path, title: LocaleKeys.apple_pay.tr(), key: "applePay"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("• ${LocaleKeys.choose_payment_method.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  paymentMethod = methods[index].key;
                  widget.callback(paymentMethod);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                child: Row(
                  children: [
                    CustomImage(methods[index].image, height: 30.h, width: 30.h),
                    Expanded(child: Text(methods[index].title, style: context.mediumText.copyWith(fontSize: 16)).withPadding(start: 8.w)),
                    Radio(
                      value: methods[index].key,
                      groupValue: paymentMethod,
                      onChanged: (value) {
                        setState(() {
                          paymentMethod = methods[index].key;
                          widget.callback(paymentMethod);
                        });
                      },
                    )
                  ],
                ),
              ).withPadding(bottom: 10.h),
            );
          },
        )
      ],
    );
  }
}

class PaymentMethods {
  final String title, image, key;

  PaymentMethods({required this.title, required this.image, required this.key});
}
