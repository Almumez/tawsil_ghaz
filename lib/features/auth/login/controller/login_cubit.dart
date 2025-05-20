import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../models/country.dart';

import '../../../../core/services/local_notifications_service.dart';
import '../../../../core/services/server_gate.dart';
import '../../../../core/utils/enums.dart';
import '../../../../models/user_model.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());

  final phone = TextEditingController(text: kDebugMode ? '555555555' : '');
  final password = TextEditingController(text: kDebugMode ? '123456' : '');
  CountryModel? country;

  Future<Map<String, dynamic>> get body async => {
        "phone_code": country?.phoneCode,
        "phone": phone.text,
        "password": password.text,
        "device_type": Platform.operatingSystem,
        "device_token": kDebugMode && Platform.isIOS ? 'test device token' : await GlobalNotification.getFcmToken(),
      };

  Future<void> login() async {
    emit(state.copyWith(requestState: RequestState.loading));
    final result = await ServerGate.i.sendToServer(url: 'general/login', body: await body);
    if (result.success) {
      UserModel.i.fromJson(result.data['data']);
      UserModel.i.save();
      emit(state.copyWith(requestState: RequestState.done, msg: result.msg));
    } else {
      emit(state.copyWith(requestState: RequestState.error, msg: result.msg, errorType: result.errType));
    }
  }
}
