import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

import '../../features/shared/components/appbar.dart';
import '../../features/shared/controller/payment/bloc.dart';
import '../../features/shared/controller/payment/events.dart';
import '../../features/shared/controller/payment/states.dart';
import '../../gen/locale_keys.g.dart';
import '../utils/extensions.dart';
import '../widgets/app_btn.dart';
import '../widgets/error_widget.dart';
import '../widgets/flash_helper.dart';
import '../widgets/loading.dart';
import 'service_locator.dart';

class PaymentService extends StatefulWidget {
  final String amount;
  final Function(String) onSuccess;
  const PaymentService({super.key, required this.amount, required this.onSuccess});

  @override
  State<PaymentService> createState() => _PaymentServiceState();
}

class _PaymentServiceState extends State<PaymentService> {
  List<MFPaymentMethod> paymentMethods = [];
  List<bool> isSelected = [];
  int selectedPaymentMethodIndex = -1;

  bool visibilityObs = false;

  late String currencyIso, country, mAPIKey, mfEnvironment;

  final bloc = sl<PaymentInfoBloc>();
  getData() {
    bloc.add(StartPaymentInfoEvent());
  }

// String liveToken ='dP4bO9HMaF_HUAT-s0Kr9GWaaIe4fSbr9bRPqE6unS95f4lLBPO98gjew-tKJkIzGPUhJD-qMFz8WpNzcwVrtCPi_4L4ru-PKbXvUAx3EvRW0XxvERRBBistvEz9YOX5gtrLy6-b84iB5kUIiQOXAs16egIHipSr1G8MGChYqqYoi4nDkddIfwwMrm6i8yZCLLcvfoukDGldRRKMeiVOxKPEftiQovBdgWHTkSCsr9jz1FTmeke0Cx_8pfdeOR3LOkvPFQWQUMbpTMIutIxBDQmboTmsDo2at2mQUmxvYaFrzwhdKCr0PkyaxkqPZZ4kraDqStrhnv-7epXqjac80QMFpIpDDgTsDXd1bUG3ITL1UqCLRSVTTfpozipv2bCGCB3U84j5k75V5ZvRbqk4KW31q0FcxzvFsGRebupS1TaEdN9l4d63Rn4_MqzTSTRuU2PabFXbcG_jTe8V3OXccHcGZ8U01JcU-Q-Yfufue5ygu2hGCG_rtIA5LxcXv3hTSXADWbhnu70CV7ZcxKB3sMBgBzHPRQijvxPlVI48IFQax7qnd4gag13AIJUTaUgrMVQy3gSYzCYvdJUXPUpxch0i9v39tQyLbU_aEbTe51fex0t5xImeprmyipusrqnLgCWpbAce6Gq6Dr2Yxu_aZVPDmLOtJytKlTGTu7ZDxxeneWcYZz9TNlVVmjheDkDUMQ5rXXHriEzpWSpWOGgoTzQeBCUhQRsT_Y1Q4nupiGUjLHqc';
  @override
  void initState() {
    getData();

    super.initState();
  }

  void initiatePayment() {
    var request = MFInitiatePaymentRequest(invoiceAmount: double.parse(widget.amount), currencyIso: currencyIso);

    MFSDK
        .initiatePayment(request, LocaleKeys.lang.tr() == 'ar' ? MFLanguage.ARABIC : MFLanguage.ENGLISH)
        .then(
          (value) => {
            log('-=-=-=-==--= ${jsonEncode(value.toJson())}'),
            paymentMethods.addAll(value.paymentMethods!),
            for (int i = 0; i < paymentMethods.length; i++)
              setState(() {
                isSelected.add(false);
              })
          },
        )
        .catchError((error) {
      print('-=-=-=-=-= error ${error.toJson()}');
      FlashHelper.showToast(error.message ?? '');

      //pushBack();
    });

    setState(() {});
  }

  /*
    Execute Regular Payment
   */

  executeRegularPayment(int paymentMethodId) async {
    var request = MFExecutePaymentRequest(paymentMethodId: paymentMethodId, invoiceValue: double.parse(widget.amount));
    await MFSDK.executePayment(request, LocaleKeys.lang.tr() == 'ar' ? MFLanguage.ARABIC : MFLanguage.ENGLISH, (invoiceId) {
      log('-=-=---=- invoiceId $invoiceId');
    }).then((value) {
      print("=-=-=-=-=- $value");
      if (value.invoiceTransactions?.isNotEmpty == true) {
        var transaction = value.invoiceTransactions!.first;
        log('Transaction Status: ${transaction.transactionStatus}');
        if (transaction.transactionStatus == 'Succss' || transaction.transactionStatus == 'Succss') {
          String transId = transaction.transactionId.toString();
          Navigator.pop(context, transId);
          widget.onSuccess(transId);
        } else {
          FlashHelper.showToast(LocaleKeys.payment_failed.tr());
        }
      } else {
        FlashHelper.showToast(LocaleKeys.lang.tr() == 'en' ? "Payment response is empty." : "استجابة الدفع فارغة.");
      }
    }).catchError((error) {
      FlashHelper.showToast(error.message);
      log('-=-=-=-=-= ${error.message}');
    });
  }

  void setPaymentMethodSelected(int index, bool value) {
    for (int i = 0; i < isSelected.length; i++) {
      if (i == index) {
        isSelected[i] = value;
        if (value) {
          selectedPaymentMethodIndex = index;
          visibilityObs = paymentMethods[index].isDirectPayment!;
        } else {
          selectedPaymentMethodIndex = -1;
          visibilityObs = false;
        }
      } else {
        isSelected[i] = false;
      }
    }
  }

  void pay() {
    if (selectedPaymentMethodIndex == -1) {
      FlashHelper.showToast(LocaleKeys.lang.tr() == "en" ? "Please select payment method first" : "الرجاء تحديد طريقة الدفع أولاً");
    } else {
      executeRegularPayment(paymentMethods[selectedPaymentMethodIndex].paymentMethodId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: CustomAppbar(title: LocaleKeys.payment.tr(), withBack: false),
      bottomNavigationBar: paymentMethods.isEmpty
          ? const SizedBox.shrink()
          : AppBtn(
              title: LocaleKeys.confirm.tr(),
              onPressed: pay,
            ).withPadding(horizontal: 20.w, bottom: 20),
      body: BlocConsumer<PaymentInfoBloc, PaymentInfoState>(
          bloc: bloc,
          listener: (context, state) {
            if (state.state.isDone && state.data != null) {
              mAPIKey = state.data!.mAPIKey;
              currencyIso = state.data!.currencyIso;
              country = state.data!.country;
              mfEnvironment = state.data!.mfEnv;
              log('-==- before init mAPIKey:$mAPIKey,\n currencyIso:$currencyIso,country:$country,\n mfEnvironment:$mfEnvironment');
              MFSDK.init(mAPIKey, country, mfEnvironment);
              initiatePayment();
            }
          },
          builder: (context, state) {
            if (state.data != null) {
              return paymentMethods.isEmpty
                  ? const CustomProgress(size: 30).center
                  : ListView.builder(
                      itemCount: paymentMethods.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return
                            // ['ap',].contains(paymentMethods[index].paymentMethodCode.toString())||(paymentMethods[index].paymentMethodCode        .toString() ==         'ap' &&     !Platform.isIOS)  ? SizedBox.shrink():

                            Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: .2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: <Widget>[
                              Checkbox(
                                  value: isSelected[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      setPaymentMethodSelected(index, value!);
                                    });
                                  }),
                              Image.network(paymentMethods[index].imageUrl!, width: 40.0, height: 40.0),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  LocaleKeys.lang.tr() == "en" ? paymentMethods[index].paymentMethodEn ?? "" : paymentMethods[index].paymentMethodAr ?? "",
                                ),
                              )
                            ],
                          ),
                        ).withPadding(horizontal: 16.w, top: 20.h);
                      },
                    );
            } else if (state.state.isError) {
              return CustomErrorWidget(title: state.msg, subtitle: state.msg, errType: state.errorType);
            } else {
              return const LoadingImage();
            }
          }),
    );
  }
}
