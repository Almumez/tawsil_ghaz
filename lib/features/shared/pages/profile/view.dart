import 'package:easy_localization/easy_localization.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
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

  Future<void> _refresh() async {
    // Actualizar los datos del usuario si es necesario
    setState(() {
      // Actualizar el estado si es necesario
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(LocaleKeys.profile.tr()),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: PullToRefresh(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (UserModel.i.isAuth)
                Row(
                  children: [
                    CustomRadiusIcon(
                      onTap: () => push(NamedRoutes.editProfile),
                      size: 40.h,
                      child: CustomImage(
                        Assets.images.edit.path,
                        height: 20.h,
                        width: 20.h,
                        color: context.primaryColorDark,
                      ),
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
                        backgroundColor: Colors.transparent,
                        child: CustomImage(
                          _buildItems()[index].image,
                          height: 20.h,
                          width: 20.h,
                          color: _buildItems()[index].isLogout ? context.errorColor : context.primaryColorDark,
                        ),
                      ).withPadding(end: 8.w),
                      Expanded(
                        child: Text(
                          _buildItems()[index].title.tr(),
                          style: context.mediumText.copyWith(fontSize: 16, color: _buildItems()[index].isLogout ? context.errorColor : null),
                        ),
                      ),
                    ],
                  ).withPadding(vertical: 3 .h),
                ),
              )
            ],
          ).withPadding(horizontal: 16.w),
        ),
      ),
    );
  }
}
