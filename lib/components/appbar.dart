import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/widgets/custom_image.dart';
import '../gen/assets.gen.dart';

class LogoAppbar extends StatelessWidget implements PreferredSizeWidget {
  const LogoAppbar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CustomImage("assets/images/splash.png", height: 80.h),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 16.h);
}
