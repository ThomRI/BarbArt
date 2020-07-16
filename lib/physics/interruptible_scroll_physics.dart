import 'package:flutter/cupertino.dart';

class InterruptibleScrollPhysics extends ScrollPhysics {

  bool enabled = true;

  void enable() {
    enabled = true;
  }

  void disable() {
    enabled = false;
  }

  InterruptibleScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  InterruptibleScrollPhysics applyTo(ScrollPhysics ancestor) {
    return InterruptibleScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => enabled;

  @override
  bool get allowImplicitScrolling => enabled;

}