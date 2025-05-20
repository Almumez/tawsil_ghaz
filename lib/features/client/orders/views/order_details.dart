import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/routes/app_routes_fun.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/pull_to_refresh.dart';
import '../../../../core/widgets/app_btn.dart';
import '../components/view/distribution_order_details.dart';
import 'rate_agent.dart';
import '../../../shared/controller/cancel_reasons/states.dart';
import '../../../../models/cancel_reasons.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/select_item_sheet.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../models/client_order.dart';
import '../../../shared/components/appbar.dart';
import '../../../shared/controller/cancel_reasons/cubit.dart';
import '../components/view/maintenance_order_details.dart';
import '../components/view/product_order_details.dart';
import '../components/view/recharge_order_details.dart';
import '../controller/order_details/cubit.dart';
import '../controller/order_details/states.dart';

class ClientOrderDetailsView extends StatefulWidget {
  final String id, type;
  const ClientOrderDetailsView({super.key, required this.id, required this.type});

  @override
  State<ClientOrderDetailsView> createState() => _ClientOrderDetailsViewState();
}

class _ClientOrderDetailsViewState extends State<ClientOrderDetailsView> {
  final cubit = sl<ClientOrderDetailsCubit>();

  @override
  void initState() {
    super.initState();
    cubit.getDetails(id: widget.id, type: widget.type);
  }

  Widget buildBody(ClientOrderModel data) {
    switch (data.type) {
      case 'distribution':
        return ClientDistributionOrderDetails(data: data);
      case "maintenance":
        return ClientMaintenanceOrderDetails(data: data);
      case "recharge":
        return ClientRechargeOrderDetails(data: data);
      case "accessory" || "factory":
        return ClientProductOrderDetails(data: data);
      default:
        return ClientMaintenanceOrderDetails(data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefresh(
      onRefresh: () => cubit.getDetails(id: widget.id, type: widget.type),
      child: BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
        bloc: cubit,
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppbar(title: LocaleKeys.order_details.tr()),
            bottomNavigationBar: ClientOrderDetailsActions(cubit: cubit),
            body: Builder(
              builder: (context) {
                if (state.detailsState.isDone) {
                  var data = cubit.data!;
                  return buildBody(data);
                } else if (state.detailsState.isError) {
                  return CustomErrorWidget(title: state.msg, onTap: () => cubit.getDetails(id: widget.id, type: widget.type));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          );
        },
      ),
    );
  }
}

class ClientOrderDetailsActions extends StatefulWidget {
  final ClientOrderDetailsCubit cubit;
  const ClientOrderDetailsActions({super.key, required this.cubit});

  @override
  State<ClientOrderDetailsActions> createState() => _ClientOrderDetailsActionsState();
}

class _ClientOrderDetailsActionsState extends State<ClientOrderDetailsActions> {
  final cancelCubit = sl<CancelReasonsCubit>();
  @override
  void initState() {
    super.initState();
  }

  bool showPaymentButton(ClientOrderModel? data) {
    if (data == null) return false;
    
    if (data.paymentMethod == 'cash') return false;

    bool isCheckedWithoutPayment = data.status == "checked" && (data.paymentMethod).isEmpty;

    bool isOnWayWithValidTypeAndUnpaid =
        data.status == 'on_way' && ['recharge', 'accessory', 'factory', 'distribution'].contains(data.type) && (data.price) != 0 && !(data.isPaid);

    return isCheckedWithoutPayment || isOnWayWithValidTypeAndUnpaid;
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.cubit.data;
    final isDistribution = data?.type == 'distribution' || data?.type == 'accessory' || data?.type == 'factory';
    if (data?.status == 'pending') {
      return BlocConsumer<CancelReasonsCubit, CancelReasonsState>(
        bloc: cancelCubit,
        listener: (context, state) {
          if (state.reasonsState.isDone) {
            showModalBottomSheet<CancelReasonsModel?>(
              context: context,
              builder: (context) => SelectItemSheet(
                title: LocaleKeys.select_val.tr(args: [LocaleKeys.cancel_reason.tr()]),
                items: cancelCubit.reasons,
                initItem: widget.cubit.cancelReason,
              ),
            ).then((value) {
              if (value != null) {
                widget.cubit.cancelReason = value;
                setState(() {});
                widget.cubit.cancel();
              }
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
              child: AppBtn(
            loading: state.reasonsState.isLoading || widget.cubit.state.cancelState.isLoading,
            title: LocaleKeys.cancel_order.tr(),
            textColor: context.errorColor,
            backgroundColor: context.scaffoldBackgroundColor,
            onPressed: () => cancelCubit.getReasons(),
          ).withPadding(horizontal: 16.w, bottom: 16.h));
        },
      );
    }

    if (data?.status == 'completed' && data!.isRated == false) {
      return BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
        bloc: widget.cubit,
        builder: (context, state) {
          return SafeArea(
              child: AppBtn(
            loading: state.rateState.isLoading,
            title: LocaleKeys.rate_agent.tr(),
            onPressed: () => push(NamedRoutes.rateAgent, arg: {
              "order_id": data.id,
              "callback": (RateData data) {
                widget.cubit.rate(data);
              }
            }),
          ).withPadding(horizontal: 16.w, bottom: 16.h));
        },
      );
    }

    if (!showPaymentButton(data)) return const SizedBox.shrink();

    return BlocBuilder<ClientOrderDetailsCubit, ClientOrderDetailsState>(
      bloc: widget.cubit,
      builder: (context, state) {
        if (isDistribution && data?.paymentMethod == 'visa') {
          return SafeArea(
            child: AppBtn(
              loading: state.payState.isLoading,
              title: isDistribution ? LocaleKeys.pay.tr() : LocaleKeys.choose_payment_method.tr(),
              onPressed: () {
                if (isDistribution) {
                  widget.cubit.paymentMethod = data?.paymentMethod;
                  if (widget.cubit.paymentMethod == 'visa') {
                    push(NamedRoutes.paymentService, arg: {
                      "amount": widget.cubit.data?.totalPrice.toString(),
                      "on_success": (v) {
                        widget.cubit.transactionId = v;
                        widget.cubit.pay();
                      }
                    });
                  }
                } else {
                  push(NamedRoutes.clientOrderDetailsSelectPayment, arg: {"cubit": widget.cubit}).then((value) {
                    if ((widget.cubit.paymentMethod == 'visa' && widget.cubit.transactionId != '') || widget.cubit.paymentMethod == 'cash') {
                      widget.cubit.pay();
                    }
                  });
                }
              },
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          );
        } else {
          return SafeArea(
            child: AppBtn(
              loading: state.payState.isLoading,
              title: LocaleKeys.choose_payment_method.tr(),
              onPressed: () {
                push(NamedRoutes.clientOrderDetailsSelectPayment, arg: {"cubit": widget.cubit}).then((value) {
                  if ((widget.cubit.paymentMethod == 'visa' && widget.cubit.transactionId != '') || widget.cubit.paymentMethod == 'cash') {
                    widget.cubit.pay();
                  }
                });
              },
            ).withPadding(horizontal: 16.w, bottom: 16.h),
          );
        }
      },
    );
  }
}
