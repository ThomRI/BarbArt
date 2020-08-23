import 'package:flutter/cupertino.dart';

import '../../utils.dart';

class PulsatingImage extends StatefulWidget {
  final AssetImage image;
  final double beginSize, endSize;
  final int milliseconds;

  const PulsatingImage({Key key, this.image, this.beginSize, this.endSize, this.milliseconds = 1000}) : super(key: key);

  @override
  _PulsatingImageState createState() => new _PulsatingImageState(this.beginSize, this.endSize, this.milliseconds);
}

class _PulsatingImageState extends State<PulsatingImage> with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;

  final double beginSize, endSize;
  final int milliseconds;

  _PulsatingImageState(this.beginSize, this.endSize, this.milliseconds);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: Duration(milliseconds: this.milliseconds), vsync: this);
    _animation = Tween<double>(begin: beginSize, end: endSize).animate(_animationController)
      ..addListener(() {
        this.setState(() { }); // Update the state to rebuild with animated size
      });


    /* Cycling the animation */
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed)
        _animationController.reverse();
      else
      if (status == AnimationStatus.dismissed) _animationController.forward();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: widget.image,
      fit: BoxFit.cover,
      width: _animation.value,
    );
  }

}