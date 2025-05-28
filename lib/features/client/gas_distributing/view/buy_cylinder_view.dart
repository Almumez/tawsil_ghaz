import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
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

  Future<void> _refresh() async {
    await cubit.fetchServices();
  }
  
  void _addThirdServiceAfterFetch() {
    // Add a mock third service if it doesn't exist yet and there are at least 2 services
    if (cubit.services.length >= 2 && cubit.services.every((s) => s.key != 'third_service')) {
      // Find the index of the 'additional' service (which should be last)
      int additionalIndex = cubit.services.indexWhere((s) => s.key == 'additional');
      
      if (additionalIndex != -1) {
        // Create mock sub items for the third service
        List<BuyCylinderSubServiceModel> subItems = [
          BuyCylinderSubServiceModel.fromJson({
            'id': 'third_1',
            'type': 'medium',
            'title': 'اسطوانة متوسطة الحجم',
            'price': '75.0',
            'description': 'اسطوانة غاز صناعية متوسطة الحجم للاستخدامات المنزلية والتجارية',
            'image': 'assets/images/cylinder_medium.png',
          }),
          BuyCylinderSubServiceModel.fromJson({
            'id': 'third_2',
            'type': 'large',
            'title': 'اسطوانة كبيرة الحجم',
            'price': '120.0',
            'description': 'اسطوانة غاز صناعية كبيرة الحجم للاستخدامات الصناعية والتجارية',
            'image': 'assets/images/cylinder_large.png',
          }),
        ];
        
        // Create the third service model
        BuyCylinderServiceModel thirdService = BuyCylinderServiceModel.fromJson({
          'key': 'third_service',
          'image': 'assets/images/industrial_gas.png',
          'sub': subItems.map((e) => e.toJson()).toList(),
        });
        
        // Insert the third service before the 'additional' service
        cubit.services.insert(additionalIndex, thirdService);
      }
    }
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
        body: PullToRefresh(
          onRefresh: _refresh,
          child: BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
              bloc: cubit,
              builder: (context, state) {
                if (state.requestState.isError) {
                  return CustomErrorWidget(title: state.msg);
                } else if (state.requestState.isDone) {
                  // Add the third service after data is loaded
                  _addThirdServiceAfterFetch();
                  
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    itemCount: cubit.services.length + 1, // +1 for the summary widget that appears after "additional" section
                    itemBuilder: (context, index) {
                      if (index < cubit.services.length) {
                        // Render normal service item
                        final serviceItem = BuyOrRefillWidget(cubit: cubit, i: index).withPadding(bottom: 16.h, horizontal: 4.w);
                        
                        // Add a separator after each item except after the last service item
                        if (index < cubit.services.length - 1) {
                          return Column(
                            children: [
                              serviceItem,
                              Container(
                                width: context.w,
                                height: 10.h,
                                color: context.mainBorderColor.withValues(alpha: .5),
                              ).withPadding(bottom: 15.h),
                            ],
                          );
                        }
                        
                        // For the last service item (usually "additional"), don't add a separator after it
                        return serviceItem;
                      } else {
                        // This is for the summary widget that appears after all services
                        return SelectedItemsSummary(cubit: cubit);
                      }
                    },
                  );
                } else {
                  return Center(child: CustomProgress(size: 30.w));
                }
              }),
        ));
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

class SelectedItemsSummary extends StatelessWidget {
  final ClientDistributeGasCubit cubit;

  const SelectedItemsSummary({
    super.key,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientDistributeGasCubit, ClientDistributeGasState>(
      bloc: cubit,
      builder: (context, state) {
        // Get all selected items (count > 0) from all services
        List<SelectedItemInfo> selectedItems = [];
        
        for (var service in cubit.services) {
          for (var subItem in service.sub) {
            if (subItem.count > 0) {
              selectedItems.add(
                SelectedItemInfo(
                  title: subItem.title,
                  price: double.tryParse(subItem.price.toString()) ?? 0.0,
                  count: subItem.count,
                  total: (double.tryParse(subItem.price.toString()) ?? 0.0) * subItem.count,
                  image: subItem.image,
                )
              );
            }
          }
        }
        
        if (selectedItems.isEmpty) {
          return SizedBox.shrink();
        }
        
        // Calculate total price
        double totalPrice = selectedItems.fold(0, (sum, item) => sum + item.total);
        
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: context.mainBorderColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart, color: context.primaryColor),
                  SizedBox(width: 8.w),
                  Text(
                    LocaleKeys.service_details.tr(),
                    style: context.boldText.copyWith(fontSize: 16.sp),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ...selectedItems.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    if (item.image != null && item.image.isNotEmpty)
                      CustomImage(
                        item.image,
                        height: 40.h,
                        width: 40.h,
                        borderRadius: BorderRadius.circular(4.r),
                        backgroundColor: context.mainBorderColor,
                      ).withPadding(end: 8.w),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              "${item.title} (${item.count}x)",
                              style: context.mediumText.copyWith(fontSize: 14.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${item.total} ${LocaleKeys.currency.tr()}",
                            style: context.mediumText.copyWith(
                              fontSize: 14.sp,
                              color: context.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              Divider(thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.total.tr(),
                    style: context.boldText.copyWith(fontSize: 16.sp),
                  ),
                  Text(
                    "${totalPrice.toStringAsFixed(2)} ${LocaleKeys.currency.tr()}",
                    style: context.boldText.copyWith(
                      fontSize: 16.sp,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SelectedItemInfo {
  final String title;
  final double price;
  final int count;
  final double total;
  final String image;

  SelectedItemInfo({
    required this.title,
    required this.price,
    required this.count,
    required this.total,
    required this.image,
  });
}
