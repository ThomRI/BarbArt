import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class ControlledCarousel extends StatefulWidget {
  List itemList;
  bool enabled = true;
  final CarouselController controller = new CarouselController();
  ControlledCarousel({this.itemList, this.enabled});

  @override
  State<ControlledCarousel> createState() => ControlledCarouselState();

}

class ControlledCarouselState extends State<ControlledCarousel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        options: CarouselOptions(
          carouselController: widget.controller,
          scrollPhysics: (widget.enabled) ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          height: 100,
          aspectRatio: 16/9,
          initialPage: 0,
        ),
        items: widget.itemList.map((item) => Container(
          child: item,
        )).toList()
    );
  }
  
}