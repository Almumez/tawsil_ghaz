import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../models/user_model.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../addresses/controller/cubit.dart';
import '../components/appbar.dart';
import '../components/request_gas.dart';
import '../components/slider.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class HomeClientView extends StatefulWidget {
  const HomeClientView({super.key});

  @override
  State<HomeClientView> createState() => _HomeClientViewState();
}

class _HomeClientViewState extends State<HomeClientView> {
  final cubit = sl<ClientHomeCubit>()..getHome();
  final addressesCubit = sl<AddressesCubit>();

  @override
  void initState() {
    if (UserModel.i.isAuth) {
      if (addressesCubit.addresses.isEmpty) {
        addressesCubit.getAddresses();
      }
    }
    super.initState();
  }

  List<HomeItemModel> items = [
    HomeItemModel(
      title: LocaleKeys.factory.tr(),
      image: Assets.images.homeFactory.path,
      onTap: () => push(NamedRoutes.clientFactoryAccessory, arg: {"type": FactoryServiceType.factory}),
    ),
    HomeItemModel(
      title: LocaleKeys.suppliers.tr(),
      image: Assets.images.homeProvide.path,
      onTap: () => push(NamedRoutes.clientMaintenanceCompanies, arg: {"type": CompanyServiceType.supply}),
    ),
    HomeItemModel(
      title: LocaleKeys.maintenance.tr(),
      image: Assets.images.homeMaintenance.path,
      onTap: () => push(NamedRoutes.clientMaintenanceCompanies, arg: {"type": CompanyServiceType.maintenance}),
    ),
    HomeItemModel(
      title: LocaleKeys.accessories.tr(),
      image: Assets.images.homeAccessories.path,
      onTap: () => push(NamedRoutes.clientFactoryAccessory, arg: {"type": FactoryServiceType.accessory}),
    ),
    HomeItemModel(
      title: LocaleKeys.fill.tr(),
      image: Assets.images.homeFill.path,

      onTap: () => push(NamedRoutes.centralGasFilling),
    ),
    HomeItemModel(
      title: LocaleKeys.reset.tr(),
      image: Assets.images.homeRecycle.path,
      onTap: () => push(NamedRoutes.clientRefill),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientHomeCubit, ClientHomeState>(
      bloc: cubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.scaffoldBackgroundColor,
          appBar: HomeAppbar(),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SliderWidget(cubit: cubit),
                Text(LocaleKeys.services.tr(), style: context.boldText.copyWith(fontSize: 20)).withPadding(horizontal: 20.w, bottom: 16.h),
                RequestGasWidget().withPadding(bottom: 16.h).center,
                Wrap(
                  children: List.generate(
                    items.length,
                    (index) => InkWell(
                      onTap: items[index].onTap,
                      child: Column(
                        children: [
                          CustomImage(

                            items[index].image,
                            backgroundColor: Color(0xfff5f5f5),
                            height: 115.h,
                            width: 112.w, 
                            fit: BoxFit.fill,
                            borderRadius: BorderRadius.circular(25), // إضافة radius للصور
                            border: Border.all(width: 0, color: Colors.transparent), // إزالة البوردر
                          ),
                          Text(items[index].title, style: context.mediumText.copyWith(fontSize: 20)),
                        ],
                      ).withPadding(bottom: 16.h, horizontal: 4.w),
                    ),
                  ),
                ).center
              ],
            ),
          ),
        );
      },
    );
  }
}

class HomeItemModel {
  final String title, image;
  final Function()? onTap;

  HomeItemModel({required this.title, required this.image, required this.onTap});
}
