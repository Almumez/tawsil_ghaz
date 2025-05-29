import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gasapp/core/widgets/custom_radius_icon.dart';
import '../../../gen/assets.gen.dart';

import '../../../../core/utils/extensions.dart';

import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../models/client.dart';
import 'package:url_launcher/url_launcher.dart';

void _callClient(String phoneCode, String phone) async {
  final Uri phoneUri = Uri(scheme: 'tel', path: '$phoneCode$phone');
  print(phoneUri);
  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    throw 'Could not launch $phoneUri';
  }
}

class AgentOrderClientItem extends StatelessWidget {
  const AgentOrderClientItem({
    super.key,
    required this.data,
  });

  final ClientModel data;

  @override
  Widget build(BuildContext context) {
    if (data.id == '') {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.client.tr(),
          style: context.mediumText.copyWith(fontSize: 20),
        ).withPadding(bottom: 10.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Color(0xfff5f5f5)),
          child: Row(
            children: [
              CustomImage(
                data.id == '' ? Assets.images.logo.path : data.image,
                height: 40.h,
                width: 40.h,
                borderRadius: BorderRadius.circular(20.h),
              ).withPadding(end: 8.w),
              Expanded(
                child: Text(
                  data.fullname,
                  style: context.mediumText.copyWith(fontSize: 14),
                ),
              ),
              CustomRadiusIcon(
                backgroundColor: '#f5f5f5'.color,
                child: Icon(Icons.call_outlined),
                onTap: () {
                  _callClient(data.phoneCode, data.phone);
                },
              )
            ],
          ),
        ).withPadding(bottom: 16.h),
      ],
    );
  }
}
