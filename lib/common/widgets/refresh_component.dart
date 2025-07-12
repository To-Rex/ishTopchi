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
    return RefreshConfiguration(
      enableScrollWhenRefreshCompleted: true,
      enableLoadingWhenFailed: true,
      hideFooterWhenNotFull: false,
      enableBallisticLoad: true,
      enableRefreshVibrate: true,
      enableLoadMoreVibrate: true,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: enablePullUp ?? true,
        physics: physics,
        header: CustomRefreshHeader(color: color),
        footer: CustomRefreshFooter(color: color),
        onLoading: onLoading ?? _onLoading,
        onRefresh: onRefresh ?? _getData,
        controller: refreshController,
        scrollController: scrollController,
        child: child, // SingleChildScrollView olib tashlandi
      ),
    );
  }
}
