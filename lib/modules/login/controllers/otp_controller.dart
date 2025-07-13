import 'dart:async';

import 'package:get/get.dart';
import 'package:ishtopchi/core/services/show_toast.dart';

import '../../../controllers/api_controller.dart';

class OtpController extends GetxController {
  final resendAvailable = false.obs;
  final remainingSeconds = 60.obs;

  late final RxInt _countdown;
  late final RxBool _isResending;

  @override
  void onInit() {
    super.onInit();
    _countdown = remainingSeconds;
    _isResending = resendAvailable;
    startTimer();
  }

  void startTimer() {
    resendAvailable.value = false;
    remainingSeconds.value = 60;

    ever(remainingSeconds, (seconds) {
      if (seconds == 0) {
        resendAvailable.value = true;
      }
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void resendCode(phone) {
    print('phone: $phone');
    if (resendAvailable.value) {
      ShowToast.show('Kod yuborildi', 'Yangi kod telefoningizga yuborildi', 1, 1);
      ApiController().generateOtp(phone);
      startTimer();
    }
  }
}