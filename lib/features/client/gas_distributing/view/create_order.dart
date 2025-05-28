import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/successfully_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/pages/navbar/cubit/navbar_cubit.dart';
import '../../addresses/components/my_addresses.dart';
// import '../components/additional_services.dart';
import '../../../shared/components/payment_methods.dart';
import '../components/service_price.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class ClientDistributingCreateOrderView extends StatefulWidget {
  const ClientDistributingCreateOrderView({super.key});

  @override
  State<ClientDistributingCreateOrderView> createState() => _ClientDistributingCreateOrderViewState();
}

class _ClientDistributingCreateOrderViewState extends State<ClientDistributingCreateOrderView> {
  final cubit = sl<ClientDistributeGasCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "تفاصيل"),
      bottomNavigationBar: BlocConsumer<ClientDistributeGasCubit, ClientDistributeGasState>(
        bloc: cubit,
        buildWhen: (previous, current) => previous.createOrderState != current.createOrderState,
        listener: (context, state) {
          if (state.createOrderState.isDone) {
            showModalBottomSheet(
              elevation: 0,
              context: context,
              enableDrag: false,
              isScrollControlled: true,
              isDismissible: true,
              builder: (context) => SuccessfullySheet(
                title: LocaleKeys.order_created_successfully.tr(),
                onLottieFinish: () {
                  sl<NavbarCubit>().changeTap(1);
                  Navigator.popUntil(context, (s) => s.isFirst);
                },
              ),
            );
          } else if (state.createOrderState.isError) {
            FlashHelper.showToast(state.msg);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: AppBtn(
              loading: state.createOrderState.isLoading,
              title: "طلب",
              onPressed: () {
                if (cubit.addressId == '') {
                  FlashHelper.showToast(LocaleKeys.choose_address_first.tr());
                } else if (cubit.paymentMethod == '') {
                  FlashHelper.showToast(LocaleKeys.choose_payment_method_first.tr());
                } else {
                  cubit.completeOrder();
                }
              },
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم التعليمات في البداية
            _buildInstructionsSection(context).withPadding(bottom: 15.h),
            
            MyAddressWidgets(
              callback: (val) {
                setState(() {
                  cubit.addressId = val;
                });
              },
            ).withPadding(bottom: 10.h),
            ServicePriceWidget().withPadding(bottom: 15.h),
            PaymentMethodsView(
              callback: (v) {
                cubit.paymentMethod = v;
              },
            ).withPadding(bottom: 15.h),
          ],
        ),
      ),
    );
  }
  
  // دالة لإنشاء قسم التعليمات
  Widget _buildInstructionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // قائمة التعليمات
        _buildInstructionItem(
          context: context,
          icon: Icons.check_circle_outline,
          text: "اسطوانة نظيفة",
        ),
        SizedBox(height: 10.h),
        _buildInstructionItem(
          context: context,
          icon: Icons.local_shipping_outlined,
          text: "توصل للباب",
        ),
        SizedBox(height: 10.h),
        _buildInstructionItem(
          context: context,
          icon: Icons.handshake_outlined,
          text: "استلامك مسوؤليتك",
        ),
      ],
    );
  }
  
  // دالة لإنشاء عنصر تعليمة واحدة
  Widget _buildInstructionItem({
    required BuildContext context, 
    required IconData icon, 
    required String text
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.h,
          color: context.primaryColor,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: context.regularText.copyWith(
              fontSize: 13.sp,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
