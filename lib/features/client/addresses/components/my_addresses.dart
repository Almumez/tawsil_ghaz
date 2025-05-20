import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_btn.dart';
import '../../../../gen/locale_keys.g.dart';
import '../controller/cubit.dart';
import '../controller/state.dart';

class MyAddressWidgets extends StatefulWidget {
  final Function(String) callback;
  final String? initialId;
  const MyAddressWidgets({super.key, required this.callback, this.initialId});

  @override
  State<MyAddressWidgets> createState() => _MyAddressWidgetsState();
}

class _MyAddressWidgetsState extends State<MyAddressWidgets> {
  String selectedOption = '';

  late AddressesCubit cubit;

  @override
  void initState() {
    selectedOption = widget.initialId ?? '';
    sl.resetLazySingleton<AddressesCubit>();
    cubit = sl<AddressesCubit>();

    cubit.getAddresses();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesCubit, AddressesState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.getStateState.isDone) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("• ${LocaleKeys.my_address.tr()}", style: context.semiboldText.copyWith(fontSize: 16)).withPadding(bottom: 15.h),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cubit.addresses.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.callback(cubit.addresses[index].id);
                        selectedOption = cubit.addresses[index].id;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), border: Border.all(color: context.borderColor)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cubit.addresses[index].placeTitle, style: context.mediumText.copyWith(fontSize: 16)).withPadding(bottom: 10.h),
                                Text(cubit.addresses[index].placeDescription, style: context.regularText.copyWith(fontSize: 12)),
                              ],
                            ),
                          ),
                          Radio(
                            value: cubit.addresses[index].id,
                            groupValue: selectedOption,
                            onChanged: (value) {
                              setState(() {
                                widget.callback(cubit.addresses[index].id);
                                selectedOption = cubit.addresses[index].id;
                              });
                            },
                          ),
                        ],
                      ),
                    ).withPadding(bottom: 10.h),
                  );
                },
              ),
              AppBtn(
                title: LocaleKeys.add_new_address.tr(),
                backgroundColor: Colors.transparent,
                textColor: context.primaryColor,
                icon: Icon(Icons.add),
                onPressed: () => push(NamedRoutes.pickLocation),
              ).withPadding(vertical: 15.h)
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
