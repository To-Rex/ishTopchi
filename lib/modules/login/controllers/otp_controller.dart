import 'dart:async';

import 'package:get/get.dart';

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
    remainingSeconds.value = 5;

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

  void resendCode() {
    if (resendAvailable.value) {
      // TODO: kodni qayta yuborish logikasi
      Get.snackbar('Kod yuborildi', 'Yangi kod telefoningizga yuborildi',
          snackPosition: SnackPosition.BOTTOM);
      startTimer();
    }
  }
}