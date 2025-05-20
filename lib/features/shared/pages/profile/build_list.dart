import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
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

class BuildProfileList {
  static List<ProfileItemModel> items = [
    ProfileItemModel(image: Assets.svg.ordersHistory, title: LocaleKeys.orders_history, onTap: () => push(NamedRoutes.clientOrdersHistory)),
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout()),
  ];

  static List<ProfileItemModel> agentItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout()),
  ];
  static List<ProfileItemModel> freeAgentItems = [
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.carInfoIcon, title: LocaleKeys.car_info, onTap: () => push(NamedRoutes.freeAgentCarInfo)),
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.profitsIcon, title: LocaleKeys.profits, onTap: () => push(NamedRoutes.profits)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout()),
  ];
  static List<ProfileItemModel> productAgentItems = [
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.ordersCountIcon, title: LocaleKeys.orders_count, onTap: () => push(NamedRoutes.ordersCount)),
    ProfileItemModel(image: Assets.svg.profitsIcon, title: LocaleKeys.profits, onTap: () => push(NamedRoutes.profits)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout()),
  ];
  static List<ProfileItemModel> technicianItems = [
    ProfileItemModel(image: Assets.svg.setting, title: LocaleKeys.settings, onTap: () => push(NamedRoutes.settings)),
    ProfileItemModel(image: Assets.svg.walletIcon, title: LocaleKeys.wallet, onTap: () => push(NamedRoutes.wallet)),
    ProfileItemModel(image: Assets.svg.logout, title: UserModel.i.isAuth ? LocaleKeys.logout : LocaleKeys.login, onTap: () => logout()),
  ];
}
