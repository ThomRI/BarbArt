import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextIcon extends StatefulWidget {
  final Text text;
  final Icon icon;

  final Function onPressed;

  final EdgeInsets padding;
  final BoxDecoration decoration;

  final double height, width;

  final bool animate;
  bool checked;

  TextIcon({Key key, this.text, this.icon, this.onPressed, this.padding, this.decoration, this.animate = false, this.height, this.width, this.checked = false}) : super(key: key);

  @override
  _TextIconState createState() => _TextIconState();
}

class _TextIconState extends State<TextIcon> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color>    _colorAnimation;
  Animation<double>   _sizeAnimation;

  double _minSize = 20;
  double _maxSize = 30;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _colorAnimation = new ColorTween(begin: Colors.grey[400], end: Colors.green).animate(_animationController);
    _sizeAnimation = new TweenSequence(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: _minSize, end: _maxSize), weight: 50),
        TweenSequenceItem<double>(tween: Tween<double>(begin: _maxSize, end: _minSize), weight: 50)
      ]
    ).animate(_animationController);

    _animationController.addStatusListener((status) {
      if(status == AnimationStatus.forward || status == AnimationStatus.reverse) this.setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.checked) _animationController.forward();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, _) => GestureDetector(
        child: Container(
          padding: this.widget.padding,
          //color: Colors.red,
          decoration: this.widget.decoration,
          child: Row(
            mainAxisAlignment: widget.animate ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: widget.animate ? Icon(widget.icon.icon, size: _sizeAnimation.value, color: _colorAnimation.value) : widget.icon,
                margin: EdgeInsets.all((_maxSize - _sizeAnimation.value) / 2),
                padding: EdgeInsets.only(right: 5),
              ),

              this.widget.text,
            ],
          ),
        ),

        onTap: () {
          if(this.widget.onPressed != null) this.widget.onPressed();

          /* Animation if required */
          if(!widget.animate) return;
          widget.checked ? _animationController.reverse() : _animationController.forward();


        }
      ),
    );
  }
}