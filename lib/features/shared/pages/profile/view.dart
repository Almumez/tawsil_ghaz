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
import '../../../../core/services/location_tracking_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/enums.dart';
import '../../../../gen/locale_keys.g.dart';
import 'build_list.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLocationTracking = false;

  @override
  void initState() {
    super.initState();
    _checkLocationTrackingStatus();
  }

  void _checkLocationTrackingStatus() {
    if (UserModel.i.accountType == UserType.freeAgent) {
      _isLocationTracking = sl<LocationTrackingService>().isTracking;
      setState(() {});
    }
  }

  Future<void> _toggleLocationTracking() async {
    final service = sl<LocationTrackingService>();
    
    if (_isLocationTracking) {
      service.stopTracking();
    } else {
      await service.checkAndStart();
    }
    
    _isLocationTracking = service.isTracking;
    setState(() {});
    
    if (_isLocationTracking) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تشغيل خدمة تتبع الموقع'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إيقاف خدمة تتبع الموقع'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

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
    _checkLocationTrackingStatus();
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
                
              // زر التحكم في خدمة تتبع الموقع للمندوب الحر
              if (UserModel.i.isAuth && UserModel.i.accountType == UserType.freeAgent)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: _isLocationTracking ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _isLocationTracking ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _isLocationTracking ? Icons.location_on : Icons.location_off,
                      color: _isLocationTracking ? Colors.green : Colors.orange,
                    ),
                    title: Text(
                      _isLocationTracking ? 'خدمة تتبع الموقع قيد التشغيل' : 'خدمة تتبع الموقع متوقفة',
                      style: context.mediumText.copyWith(
                        color: _isLocationTracking ? Colors.green : Colors.orange,
                      ),
                    ),
                    subtitle: Text(
                      _isLocationTracking 
                          ? 'يتم إرسال موقعك إلى النظام كل 5 ثواني' 
                          : 'اضغط للتشغيل',
                      style: context.regularText.copyWith(fontSize: 12.sp),
                    ),
                    trailing: Switch(
                      value: _isLocationTracking,
                      onChanged: (value) => _toggleLocationTracking(),
                      activeColor: Colors.green,
                    ),
                    onTap: _toggleLocationTracking,
                  ),
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
