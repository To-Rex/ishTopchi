import 'package:flutter/material.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'custom_header.dart';

class RefreshComponent extends StatelessWidget {
  final Widget child;
  final RefreshController refreshController;
  final ScrollController scrollController;
  final Color? color;
  final Function()? onLoading;
  final Function()? onRefresh;
  final ScrollPhysics? physics;
  final bool? enablePullUp;

  const RefreshComponent({
    super.key,
    this.enablePullUp,
    required this.child,
    required this.refreshController,
    required this.scrollController,
    this.onLoading,
    this.onRefresh,
    this.color,
    this.physics = const AlwaysScrollableScrollPhysics(),
  });

  void _getData() {
    refreshController.refreshCompleted();
  }

  void _onLoading() async {
    refreshController.refreshCompleted();
    refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    // Asosiy ekranda kontent pastki suzuvchi panel ostidan oʻtadi va
    // `MediaQuery` pastki boʻshligʻi panel balandligiga teng boʻladi.
    // Roʻyxat oxiri (yuklash belgisi yoki oxirgi karta) panel ustida
    // koʻrinishi uchun shu boʻshliq qoʻshiladi. Boshqa ekranlarda bu
    // tizim panelining balandligi xolos.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final pullUp = enablePullUp ?? true;

    return RefreshConfiguration(
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      hideFooterWhenNotFull: false,
      enableBallisticLoad: true,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: pullUp,
        physics: physics,
        header: CustomRefreshHeader(color: color),
        footer: CustomRefreshFooter(color: color, bottomInset: bottomInset),
        onLoading: onLoading ?? _onLoading,
        onRefresh: onRefresh ?? _getData,
        controller: refreshController,
        scrollController: scrollController,
        // Pastki qism oʻchirilgan boʻlsa, boʻshliq kontentning oʻziga
        // qoʻshiladi. `ScrollView` ga tegilmaydi — uni `SmartRefresher`
        // oʻzi ochib, boʻlaklariga ajratadi.
        child:
            pullUp || child is ScrollView
                ? child
                : Padding(
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: child,
                ),
      ),
    );
  }
}
