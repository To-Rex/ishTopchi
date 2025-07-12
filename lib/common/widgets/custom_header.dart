import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/common/widgets/text_small.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRefreshHeader extends StatelessWidget {
  final Color? color;
  const CustomRefreshHeader({super.key, this.color = Colors.white});
  @override
  Widget build(BuildContext context) {
    return CustomHeader(
      height: 100.sp,
      builder: (BuildContext context, RefreshStatus? mode) {
        Widget body;
        if (mode == RefreshStatus.idle) {
          body = TextSmall(text: 'Ma’lumotlarni yangilash uchun tashlang'.tr, fontSize: 14.sp, color: color ?? Colors.white, fontWeight: FontWeight.w400);
        } else if (mode == RefreshStatus.refreshing) {
          body = Container(margin: EdgeInsets.only(top: 20.sp), child: const CircularProgressIndicator(color: Colors.blue, backgroundColor: Colors.white, strokeWidth: 2));
        } else if (mode == RefreshStatus.failed) {
          body = TextSmall(text: 'Ehhh nimadir xato ketdi'.tr, fontSize: 14.sp, color: color ?? Colors.white, fontWeight: FontWeight.w400);
        } else if (mode == RefreshStatus.canRefresh) {
          body = TextSmall(text: 'Ma’lumotlarni yangilash uchun tashlang'.tr, fontSize: 14.sp, color: color ?? Colors.white, fontWeight: FontWeight.w400);
        } else {
          body = TextSmall(text: 'Ma’lumotlar yangilandi'.tr, fontSize: 14.sp, color: color ?? Colors.white, fontWeight: FontWeight.w400);
        }
        return SizedBox(height: 60.sp, child: Center(child: body));
      }
    );
  }
}

class CustomRefreshFooter extends StatelessWidget {
  final Color? color;
  const CustomRefreshFooter({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomFooter(
      builder: (BuildContext context, LoadStatus? mode) {
        Widget body;
        if (mode == LoadStatus.idle) {
          body = const SizedBox();
        } else if (mode == LoadStatus.loading) {
          body = const CircularProgressIndicator(color: Colors.blue, backgroundColor: Colors.white, strokeWidth: 2);
        } else if (mode == LoadStatus.failed) {
          body = TextSmall(text: 'Ehhh nimadir xato ketdi'.tr, fontSize: 14.sp, color: color ?? Colors.white, fontWeight: FontWeight.w400);
        } else if (mode == LoadStatus.canLoading) {
          body = const SizedBox();
        } else {
          body = TextSmall(text: 'Ma’lumotlar yangilandi'.tr, fontSize: 14.sp, color: color ?? Colors.white, fontWeight: FontWeight.w400);
        }
        return SizedBox(height: 60.sp, child: Center(child: body));
      }
    );
  }
}