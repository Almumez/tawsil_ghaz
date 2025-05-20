import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../core/widgets/custom_image.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/flash_helper.dart';
import '../../../../core/widgets/loading.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/buy_cylinder.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/components/increment_widget.dart';
import '../controller/cubit.dart';
import '../controller/states.dart';

class BuyCylinderView extends StatefulWidget {
  const BuyCylinderView({super.key});

  @override
  State<BuyCylinderView> createState() => _BuyCylinderViewState();
}

class _BuyCylinderViewState extends State<BuyCylinderView> {
  late final ClientDistributeGasCubit cubit;

  @override
  void initState() {
    sl.resetLazySingleton<ClientDistributeGasCubit>();
    cubit = sl<ClientDistributeGasCubit>();
    cubit.fetchServices();
    super.initState();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar(title: LocaleKeys.buy_or_refill_gas.tr()),
        bottomNavigationBar: BlocConsumer<ClientDistributeGasCubit, ClientDistributeGasState>(
          bloc: cubit,
          listenWhen: (previous, current) => previous.calculationsState != current.calculationsState,
          listener: (context, state) {
            if (state.calculationsState.isDone) {
              push(NamedRoutes.clientDistributingCreateOrder);
            } else if (state.calculationsState.isError) {
              FlashHelper.showToast(state.msg);
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: AppBtn(
                loading: state.calculationsState.isLoading,
                enable: state.serviceChosen!,
                title: LocaleKeys.order_now.tr(),
                onPressed: () => cubit.calculateOrder(),
              ).withPadding(horizontal: 16.w, bottom: 16.h),
            );
          },
        ),
        body: BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
            bloc: cubit,
            builder: (context, state) {
              if (state.requestState.isError) {
                return CustomErrorWidget(title: state.msg);
              } else if (state.requestState.isDone) {
                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  separatorBuilder: (context, index) => Container(
                    width: context.w,
                    height: 10.h,
                    color: context.mainBorderColor.withValues(alpha: .5),
                  ).withPadding(bottom: 15.h),
                  itemCount: cubit.services.length,
                  itemBuilder: (context, index) => BuyOrRefillWidget(cubit: cubit, i: index).withPadding(bottom: 16.h, horizontal: 4.w),
                );
              } else {
                return Center(child: CustomProgress(size: 30.w));
              }
            }));
  }
}

class BuyOrRefillWidget extends StatelessWidget {
  final int i;
  final ClientDistributeGasCubit cubit;
  const BuyOrRefillWidget({
    super.key,
    required this.cubit,
    required this.i,
  });

  @override
  Widget build(BuildContext context) {
    BuyCylinderServiceModel model = cubit.services[i];
    if (model.key == 'additional') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(model.title, style: context.boldText.copyWith(fontSize: 16)).withPadding(bottom: 8.h),
          ...List.generate(
            model.sub.length,
            (index) => Container(
              padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
              child: Row(
                children: [
                  CustomImage(
                    model.sub[index].image,
                    height: 60.h,
                    width: 60.h,
                    borderRadius: BorderRadius.circular(4.r),
                    backgroundColor: context.mainBorderColor,
                  ).withPadding(end: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.sub[index].title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 10.h),
                        Text("${model.sub[index].price} ${LocaleKeys.currency.tr()}",
                            style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryContainer)),
                      ],
                    ),
                  ),
                  IncrementRow(model: model, index: index),
                ],
              ),
            ).withPadding(bottom: 12.h),
          )
        ],
      ).withPadding(horizontal: 16.w);
    } else {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
        child: Column(
          children: [
            Row(
              children: [
                CustomImage(
                  model.image,
                  height: 60.h,
                  width: 60.h,
                  borderRadius: BorderRadius.circular(4.r),
                  backgroundColor: context.mainBorderColor,
                ).withPadding(end: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 6.h),
                      Text(model.subTitle, style: context.regularText.copyWith(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ).withPadding(horizontal: 8.w),
            Divider(),
            ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(model.sub[index].title, style: context.mediumText.copyWith(fontSize: 12)).withPadding(bottom: 5.h),
                      Text("${model.sub[index].price} ${LocaleKeys.currency.tr()}",
                          style: context.mediumText.copyWith(fontSize: 14, color: context.secondaryColor)),
                    ],
                  ),
                  IncrementRow(model: model, index: index),
                ],
              ),
              separatorBuilder: (context, index) => Divider(),
              itemCount: model.sub.length,
            )
          ],
        ),
      ).withPadding(horizontal: 16.w);
    }
  }
}

class IncrementRow extends StatelessWidget {
  final int index;
  final BuyCylinderServiceModel model;

  const IncrementRow({
    super.key,
    required this.model,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
      bloc: sl<ClientDistributeGasCubit>(),
      builder: (context, state) {
        return IncrementWidget(
          count: model.sub[index].count,
          increment: () {
            sl<ClientDistributeGasCubit>().incrementService(key: model.key, model: model.sub[index]);
          },
          decrement: () {
            sl<ClientDistributeGasCubit>().decrementService(key: model.key, model: model.sub[index]);
          },
        );
      },
    );
  }
}
