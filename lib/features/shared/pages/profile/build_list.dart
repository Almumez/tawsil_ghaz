import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/logout_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/profile_item.dart';

logout() {
  if (!UserModel.i.isAuth) return push(NamedRoutes.login);

  showModalBottomSheet(
    context: navigator.currentContext!,
    builder: (context) => LogoutSheet(),
  );
}

// Function to switch between client and agent account types
void switchAccountType() {
  // This would be implemented with the proper API call to switch account types
  // For now, just show a dialog or navigate to a screen to handle this
  showDialog(
    context: navigator.currentContext!,
    builder: (context) => AlertDialog(
      title: Text(LocaleKeys.profile.tr()),
      content: Text('Switch account type functionality will be implemented here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

class BuildProfileList {
  static List<ProfileItemModel> items = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(
      image: 'assets/svg/information.svg', 
      title: LocaleKeys.information, 
      onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.about}),
    ),
    ProfileItemModel(
      image: 'assets/svg/receipt-disscount.svg', 
      title: LocaleKeys.offers, 
      onTap: () => push(NamedRoutes.notifications),
    ),
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.financial, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: 'assets/svg/user-add.svg', title: LocaleKeys.join, onTap: () => push(NamedRoutes.register)),
    if (UserModel.i.isAuth) ProfileItemModel(
      image: 'assets/svg/profile-2user.svg', 
      title: LocaleKeys.switch_account, 
      onTap: () => switchAccountType(),
    ),
    ProfileItemModel(image: Assets.svg.logout, title: LocaleKeys.exit, onTap: () => logout(),),
  ];

 
  static List<ProfileItemModel> freeAgentItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(
      image: 'assets/svg/information.svg', 
      title: LocaleKeys.information, 
      onTap: () => push(NamedRoutes.static, arg: {'type': StaticType.about}),
    ),
    ProfileItemModel(
      image: 'assets/svg/receipt-disscount.svg', 
      title: LocaleKeys.offers, 
      onTap: () => push(NamedRoutes.notifications),
    ),
    ProfileItemModel(image: 'assets/svg/user-add.svg', title: LocaleKeys.join, onTap: () => push(NamedRoutes.register)),
    ProfileItemModel(
      image: 'assets/svg/profile-2user.svg', 
      title: LocaleKeys.switch_account, 
      onTap: () => switchAccountType(),
    ),
    ProfileItemModel(image: Assets.svg.profitsIcon, title: LocaleKeys.profits, onTap: () => push(NamedRoutes.profits)),
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: "assets/svg/document.svg", title: LocaleKeys.car_info, onTap: () => push(NamedRoutes.freeAgentCarInfo)),
    ProfileItemModel(image: Assets.svg.logout, title: LocaleKeys.exit, onTap: () => logout(),),
  ];





 static List<ProfileItemModel> agentItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];
  
  static List<ProfileItemModel> productAgentItems = [
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.profitsIcon, title: LocaleKeys.profits, onTap: () => push(NamedRoutes.profits)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];
  static List<ProfileItemModel> technicianItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout(),),
  ];
}
