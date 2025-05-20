import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/address_item.dart';
import '../agnent_item.dart';
import '../bill_widget.dart';
import '../payment_item.dart';
import '../product_service_type.dart';

class ClientProductOrderDetails extends StatelessWidget {
  const ClientProductOrderDetails({super.key, required this.data});

  final ClientOrderModel data;
  Color get color {
    switch (data.status) {
      case 'pending':
        return "#CE6518".color;
      case 'accepted':
        return "#168836".color;
      default:
        return "#CE6518".color;
    }
  }

  String get title {
    switch (data.status) {
      case 'pending':
        return LocaleKeys.wait_for_agent_to_take_cylinder_and_refill.tr();
      case 'accepted':
        return LocaleKeys.refilling_a_small_cylinder_now_see_cost.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClientOrderAgentItem(data: data).withPadding(bottom: 16.w),
          ProductServiceType(data: data).withPadding(bottom: 16.w),
          OrderDetailsAddressItem(
            title: data.address.placeTitle,
            description: data.address.placeDescription,
          ).withPadding(bottom: 16.w),
          OrderPaymentItem(data: data).withPadding(bottom: 16.w),
          ClientBillWidget(data: data),
        ],
      ),
    );
  }
}
