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
  // Track the selected service index
  int _selectedServiceIndex = 0;

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
    _addThirdServiceAfterFetch();
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
                  
                  // We need to ensure the selected index is within bounds
                  if (_selectedServiceIndex >= cubit.services.length - 1) {
                    _selectedServiceIndex = 0;
                  }
                  
                  // Filter out the 'additional' service from the top row
                  List<BuyCylinderServiceModel> mainServices = cubit.services
                      .where((service) => service.key != 'additional')
                      .toList();
                  
                  // Get additional service if exists
                  BuyCylinderServiceModel? additionalService = cubit.services
                      .firstWhere((service) => service.key == 'additional', 
                                orElse: () => BuyCylinderServiceModel.fromJson({'key': 'none'}));
                  
                  return ListView(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    children: [
                      // Service selector row (images side by side)
                      _buildServiceSelectorRow(mainServices, context),
                      
                      SizedBox(height: 20.h),
                      
                      // Selected service details
                      if (_selectedServiceIndex < mainServices.length)
                        _buildSelectedServiceDetails(mainServices[_selectedServiceIndex], context),
                      
                      // Additional options (always visible)
                      if (additionalService.key == 'additional')
                        Column(
                          children: [
                            SizedBox(height: 20.h),
                            AdditionalOptionsWidget(additionalService: additionalService),
                          ],
                        ),
                      
                      // Order summary
                      SelectedItemsSummary(cubit: cubit),
                    ],
                  );
                } else {
                  return Center(child: CustomProgress(size: 30.w));
                }
              }),
        ));
  }

  Widget _buildServiceSelectorRow(List<BuyCylinderServiceModel> services, BuildContext context) {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          services.length,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedServiceIndex = index;
              });
            },
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: _selectedServiceIndex == index 
                    ? context.primaryColor 
                    : context.borderColor,
                  width: _selectedServiceIndex == index ? 2 : 1,
                ),
                color: _selectedServiceIndex == index 
                  ? context.mainBorderColor.withOpacity(0.1)
                  : Colors.transparent,
              ),
              padding: EdgeInsets.all(8.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImage(
                    services[index].image,
                    height: 60.h,
                    width: 60.h,
                    borderRadius: BorderRadius.circular(4.r),
                    backgroundColor: context.mainBorderColor,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    services[index].title,
                    style: context.mediumText.copyWith(
                      fontSize: 12.sp,
                      color: _selectedServiceIndex == index 
                        ? context.primaryColor 
                        : context.borderColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedServiceDetails(BuyCylinderServiceModel model, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        // Border is removed here
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title/header is completely removed
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomImage(
                        model.sub[index].image,
                        height: 40.h,
                        width: 40.h,
                        borderRadius: BorderRadius.circular(4.r),
                        backgroundColor: context.mainBorderColor,
                      ).withPadding(end: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.sub[index].title, 
                            style: context.mediumText.copyWith(fontSize: 14.sp)
                          ).withPadding(bottom: 4.h),
                          Text(
                            "${model.sub[index].price} ${LocaleKeys.currency.tr()}",
                            style: context.mediumText.copyWith(
                              fontSize: 14.sp, 
                              color: context.secondaryColor
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IncrementRow(model: model, index: index),
                ],
              ),
            ),
            itemCount: model.sub.length,
          ),
        ],
      ),
    );
  }
}

class AdditionalOptionsWidget extends StatelessWidget {
  final BuyCylinderServiceModel additionalService;

  const AdditionalOptionsWidget({
    super.key,
    required this.additionalService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          additionalService.title, 
          style: context.boldText.copyWith(fontSize: 16)
        ).withPadding(bottom: 16.h, horizontal: 16.w),
        ...List.generate(
          additionalService.sub.length,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r), 
              border: Border.all(color: context.borderColor)
            ),
            child: Row(
              children: [
                CustomImage(
                  additionalService.sub[index].image,
                  height: 60.h,
                  width: 60.h,
                  borderRadius: BorderRadius.circular(4.r),
                  backgroundColor: context.mainBorderColor,
                ).withPadding(end: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        additionalService.sub[index].title, 
                        style: context.mediumText.copyWith(fontSize: 12)
                      ).withPadding(bottom: 10.h),
                      Text(
                        "${additionalService.sub[index].price} ${LocaleKeys.currency.tr()}",
                        style: context.mediumText.copyWith(
                          fontSize: 14, 
                          color: context.secondaryContainer
                        ),
                      ),
                    ],
                  ),
                ),
                IncrementRow(model: additionalService, index: index),
              ],
            ),
          ),
        )
      ],
    );
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
            SizedBox(height: 16.h),
            ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
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
              ),
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
              SizedBox(height: 16.h),
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
