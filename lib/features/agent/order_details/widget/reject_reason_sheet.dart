import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../cubit/order_details_cubit.dart';

class RejectReasonSheet extends StatefulWidget {
  final AgentOrderDetailsCubit cubit;
  const RejectReasonSheet({super.key, required this.cubit});

  @override
  State<RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<RejectReasonSheet> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/cancel.svg',
                    height: 24.h,
                    width: 24.w,
                    colorFilter: ColorFilter.mode(
                      context.errorColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.reject_order.tr(),
                    style: context.semiboldText.copyWith(fontSize: 18),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: context.hintColor),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.reject_reason.tr(),
            style: context.mediumText.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: context.borderColor),
              color: Colors.grey[50],
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 4,
              style: context.regularText,
              decoration: InputDecoration(
                hintText: LocaleKeys.enter_reject_reason.tr(),
                hintStyle: context.regularText.copyWith(color: context.hintColor),
                contentPadding: EdgeInsets.all(12.w),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          AbsorbPointer(
            absorbing: _isSubmitting,
            child: Opacity(
              opacity: _isSubmitting ? 0.7 : 1.0,
              child: Row(
                children: [
                  Expanded(
                    child: AppBtn(
                      onPressed: () => Navigator.pop(context),
                      textColor: context.primaryColor,
                      backgroundColor: context.primaryColor.withOpacity(0.1),
                      title: LocaleKeys.cancel.tr(),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: AppBtn(
                      onPressed: () {
                        setState(() => _isSubmitting = true);
                        widget.cubit.rejectOrder(_reasonController.text).then((_) {
                          setState(() => _isSubmitting = false);
                        });
                      },
                      textColor: Colors.white,
                      backgroundColor: context.errorColor,
                      loading: _isSubmitting,
                      title: LocaleKeys.reject.tr(),
                      prefix: SvgPicture.asset(
                        'assets/svg/cancel.svg',
                        height: 20.h,
                        width: 20.w,
                        colorFilter: ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
} 