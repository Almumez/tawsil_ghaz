import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/utils/extensions.dart';

class StatusContainer extends StatelessWidget {
  const StatusContainer({
    super.key,
    required this.title,
    required this.color,
  });

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 8.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.r), color: color.withValues(alpha: .1)),
      child: Text(title, style: context.mediumText.copyWith(fontSize: 14, color: color)),
    );
  }
}