import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/custom_radius_icon.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../models/profile_item.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/utils/enums.dart';
import '../../../../gen/locale_keys.g.dart';
import 'build_list.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  List<ProfileItemModel> _buildItems() {
    if (UserModel.i.accountType == UserType.client) {
      return BuildProfileList.items;
    } else if (UserModel.i.accountType == UserType.agent) {
      return BuildProfileList.agentItems;
    } else if (UserModel.i.accountType == UserType.freeAgent) {
      return BuildProfileList.freeAgentItems;
    } else if (UserModel.i.accountType == UserType.productAgent) {
      return BuildProfileList.productAgentItems;
    } else if (UserModel.i.accountType == UserType.technician) {
      return BuildProfileList.technicianItems;
    } else {
      return BuildProfileList.items;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        title: Text(LocaleKeys.profile.tr()),
        centerTitle: true,
        backgroundColor: context.canvasColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (UserModel.i.isAuth)
              Row(
                children: [
                  CustomImage(
                    UserModel.i.image,
                    height: 72.h,
                    width: 72.h,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(36.h),
                  ).withPadding(end: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(UserModel.i.fullname, style: context.boldText.copyWith(fontSize: 16.sp)),
                        Text(
                          "+${UserModel.i.phoneCode}-${UserModel.i.phone}",
                          textDirection: TextDirection.ltr,
                          style: context.mediumText,
                        )
                      ],
                    ),
                  ),
                  CustomRadiusIcon(
                    onTap: () => push(NamedRoutes.editProfile),
                    size: 40.h,
                    child: CustomImage(
                      Assets.images.edit.path,
                      height: 20.h,
                      width: 20.h,
                      color: context.primaryColorDark,
                    ),
                  ),
                ],
              ),
            ...List.generate(
              _buildItems().length,
              (index) => InkWell(
                onTap: _buildItems()[index].onTap,
                child: Row(
                  children: [
                    CustomRadiusIcon(
                      size: 40.h,
                      backgroundColor: _buildItems()[index].isLogout ? context.errorColor.withValues(alpha: .1) : null,
                      child: CustomImage(
                        _buildItems()[index].image,
                        height: 20.h,
                        width: 20.h,
                        color: _buildItems()[index].isLogout ? context.errorColor : context.primaryColorDark,
                      ),
                    ).withPadding(end: 16.w),
                    Expanded(
                      child: Text(
                        _buildItems()[index].title.tr(),
                        style: context.mediumText.copyWith(fontSize: 16, color: _buildItems()[index].isLogout ? context.errorColor : null),
                      ),
                    ),
                    if (!_buildItems()[index].isLogout) Icon(Icons.arrow_forward_ios, size: 20.h, color: context.primaryColorDark),
                  ],
                ).withPadding(vertical: 16.h),
              ),
            )
          ],
        ).withPadding(horizontal: 16.w),
      ),
    );
  }
}
