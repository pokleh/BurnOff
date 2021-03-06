import 'package:burn_off/model/aliments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class RectangleIndicator extends StatefulWidget {
  final PageController pagerController;
  final int size;
  final double radius;
  final Color baseColor;
  final Color selectedColor;

  RectangleIndicator(this.pagerController, this.size, this.radius,
      this.baseColor, this.selectedColor);

  RectangleIndicator.withIntroduction(
      this.size, this.radius, this.baseColor, this.selectedColor,
      {this.pagerController});

  @override
  State<StatefulWidget> createState() => new _RectangleIndicatorState(
      pagerController, size, radius, baseColor, selectedColor);

  static RectangleIndicator get(
      RectangleIndicator indicator, PageController pagerController) {
    return new RectangleIndicator(pagerController, indicator.size,
        indicator.radius, indicator.baseColor, indicator.selectedColor);
  }
}

class _RectangleIndicatorState extends State<RectangleIndicator>
    with TickerProviderStateMixin {
  final PageController pagerController;
  final int size;

  int oldPage = 0;
  int page = 0;

  double oldOffset = 0.0;

  Row items;

  _RectangleIndicatorState(
      this.pagerController, this.size, radius, baseColor, selectedColor) {
    pagerController.addListener(animate);
    List<Container> icons = List();

    for (int i = 0; i < size; i++) {
      icons.add(Container(
        child: _AnimatedRectangleAvatar(
          controller: AnimationController(
            duration: Duration(milliseconds: 100),
            vsync: this,
          ),
          baseColor: baseColor,
          selectedColor: selectedColor,
          radius: radius,
          image: Aliments.aliments[i].bottomImage,
          isSelected: page == i ? true : false,
        ),
      ));
    }

    items = Row(
      children: icons,
    );
    getController(items.children.elementAt(0)).forward();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      alignment: FractionalOffset.bottomCenter,
      child: items,
    );
  }

  void animate() {

    bool isInLimits =
        pagerController.position.minScrollExtent <= pagerController.offset &&
            pagerController.offset <= pagerController.position.maxScrollExtent;

    page = pagerController.offset ~/ pagerController.position.viewportDimension;

    if (!isInLimits) return;
    bool directionNormal = oldOffset - pagerController.offset <= 0;

    var oldController = getController(items.children.elementAt(oldPage));
    var controller = getController(items.children.elementAt(page));
    var nextController;
    if (page + 1 < size) {
      nextController = getController(items.children.elementAt(page + 1));
    }

    if (directionNormal) {
      oldController.reverse();
      controller.forward();
    } else {
      controller.forward();
      nextController?.reverse();
    }

    oldPage = page;
    oldOffset = pagerController.offset;
  }

  AnimationController getController(Widget widget) {
    if (widget is Container) {
      var i = widget.child;
      if (i is _AnimatedRectangleAvatar) {
        return i.controller;
      }
    }
    return null;
  }
}

class _AnimatedRectangleAvatar extends StatelessWidget {
  final AnimationController controller;
  final double radius;
  final Color baseColor;
  final Color selectedColor;
  final String image;
  final bool isSelected;

  _AnimatedRectangleAvatar(
      {Key key,
      this.controller,
      this.radius,
      this.baseColor,
      this.selectedColor,
      this.image,
      this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Padding selectedRectangle = Padding(
      padding: EdgeInsets.only(top: 38.0),
      child: Column(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: selectedColor,
              ),
              width: radius * 20,
              height: radius / 2),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: SvgPicture.asset(
              image,

              color: selectedColor,
              width: 30.0,
              height: 30.0,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: <Widget>[
        Stack(
          alignment: FractionalOffset.center,
          children: <Widget>[
            Container(
              width: radius * 20,
              height: radius / 2,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.rectangle,
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                  parent: controller,
                  curve: Curves.linear,
                  reverseCurve: Curves.bounceOut),
              child: selectedRectangle,
            ),
            Padding(
              padding: EdgeInsets.only(top: 48.0),
              child: SvgPicture.asset(
                image,
                color: baseColor,
                width: 30.0,
                height: 30.0,
              ),
            ),
          ],
        ),

      ],
    );
  }
}
