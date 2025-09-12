import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ishtopchi/core/services/show_toast.dart';
import '../../../controllers/api_controller.dart';

class OtpController extends GetxController {
  final resendAvailable = false.obs;
  final remainingSeconds = 60.obs;

  // 🔑 Qo‘shilganlar:
  final isError = false.obs; // rangni boshqarish
  late TextEditingController pinTEC;
  late StreamController<ErrorAnimationType> errorCtrl;

  late final RxInt _countdown;
  late final RxBool _isResending;

  @override
  void onInit() {
    super.onInit();
    _countdown = remainingSeconds;
    _isResending = resendAvailable;
    pinTEC = TextEditingController();
    errorCtrl = StreamController<ErrorAnimationType>();
    startTimer();
  }

  @override
  void onClose() {
    pinTEC.dispose();
    errorCtrl.close();
    super.onClose();
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

  void resendCode(String phone) {
    if (resendAvailable.value) {
      ShowToast.show(
          'Kod yuborildi', 'Yangi kod telefoningizga yuborildi', 1, 1);
      ApiController().generateOtp(phone);
      startTimer();
    }
  }

  // 🔥 Xatolik bo‘lsa qizarish + shake + clear qilish:
  void triggerOtpError() {
    isError.value = true;
    errorCtrl.add(ErrorAnimationType.shake);
    // Silkinish ko‘rinsin, so‘ng clear qilamiz
    Future.delayed(const Duration(milliseconds: 200), () {
      pinTEC.clear();
    });
    // 3 soniyadan so‘ng qayta default rangga qaytariladi
    Future.delayed(const Duration(seconds: 3), () {
      isError.value = false;
    });
  }
}