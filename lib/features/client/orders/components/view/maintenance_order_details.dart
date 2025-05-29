import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/extensions.dart';
import '../../../../../gen/locale_keys.g.dart';
import '../../../../../models/client_order.dart';
import '../../../../shared/components/address_item.dart';
import '../agnent_item.dart';
import '../bill_widget.dart';
import '../maintenance_company.dart';
import '../maintenance_service_type.dart';
import '../payment_item.dart';

class ClientMaintenanceOrderDetails extends StatelessWidget {
  const ClientMaintenanceOrderDetails({
    super.key,
    required this.data,
  });

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
        return LocaleKeys.while_waiting_for_the_application_to_be_accepted.tr();
      case 'accepted':
        return LocaleKeys.while_waiting_for_the_application_to_be_accepted.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != '')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20.h, color: color).withPadding(end: 10.w),
                  Expanded(child: Text(title, style: context.regularText.copyWith(fontSize: 12, color: color))),
                ],
              ),
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          if (title != '')
            Container(
              height: 10.h,
              color: context.canvasColor,
            ).withPadding(bottom: 16.h),
          MaintenanceCompanyItem(data: data).withPadding(horizontal: 16.w),
          ClientOrderAgentItem(data: data).withPadding(horizontal: 16.w),
          MaintenanceServiceType(data: data).withPadding(horizontal: 16.w),
          OrderDetailsAddressItem(
            title: data.address.placeTitle,
            description: data.address.placeDescription,
          ).withPadding(horizontal: 16.w),
          OrderPaymentItem(data: data).withPadding(horizontal: 16.w),
          ClientBillWidget(data: data).withPadding(horizontal: 16.w),
        ],
      ),
    );
  }
}
