import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class ControlledCarousel extends StatefulWidget {
  List itemList;
  final bool enabled;
  final CarouselController controller;
  ControlledCarousel({Key key, this.itemList, this.enabled = true, this.controller}) : super(key: key);

  @override
  State<ControlledCarousel> createState() => ControlledCarouselState();

}

class ControlledCarouselState extends State<ControlledCarousel> {
  @override
  void initState() {
    super.initState();
  }

  CarouselController get controller => widget.controller; // Accessible by state key

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        options: CarouselOptions(
          enableInfiniteScroll: false,
          carouselController: widget.controller,
          scrollPhysics: (widget.enabled) ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          height: 150,
          aspectRatio: 16/9,
          initialPage: 0,
        ),
        items: widget.itemList.map((item) => Container(
          child: item,
        )).toList()
    );
  }
  
}