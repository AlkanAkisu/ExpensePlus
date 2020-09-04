import 'package:expensePlus/expenses_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:carousel_slider/carousel_slider.dart';

class IntroPage extends HookWidget {
  CarouselController carouselController = CarouselController();
  ValueNotifier<int> _current;
  ValueNotifier<bool> _resetState;
  bool introDone = false;
  List<Widget> buttons = new List();
  final bool isHelpButton;

  IntroPage([this.isHelpButton = false]);

  @override
  Widget build(BuildContext context) {
    _current = useState(0);
    _resetState = useState(false);

    return introPage(context);
  }

  List<Widget> imagesList() {
    List<String> list = [
      'FIRST',
      'SECOND',
      'THIRD',
      'FOURTH',
      'FIFTH',
      'SIXTH'
    ];

    return list
        .map((str) => Container(
              child: Image(
                image: AssetImage('assets/$str PAGE.png'),
                fit: BoxFit.cover,
              ),
            ))
        .toList();
  }

  Widget introPage(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                options: CarouselOptions(
                    height: MediaQuery.of(context).size.height,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    disableCenter: true,
                    enableInfiniteScroll: false,
                    initialPage: 0,
                    aspectRatio: 1.949,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    onPageChanged: (index, reason) {
                      _current.value = index;
                    }),
                itemCount: 6,
                itemBuilder: (BuildContext context, int itemIndex) {
                  return imagesList()[itemIndex];
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: carouselButtons(context),
                  ),

                  //navigationDots()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> carouselButtons(BuildContext context) {
    final button = (IconData icon, onTap) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[400],
            ),
            child: Icon(icon),
          ),
        );
    if (buttons?.length != 1) {
      buttons = [
        button(Icons.navigate_before, () => carouselController.previousPage()),
        button(Icons.navigate_next, () => carouselController.nextPage()),
      ];

      if (_current.value == imagesList().length - 1) //Last page
        buttons[1] = button(
          Icons.check_circle_outline,
          () {
            _resetState.value = !_resetState.value;
            if (!isHelpButton) {
              buttons = [Text('Loading...')];
              Future.delayed(
                Duration(milliseconds: 100),
                () => MobxStore.st.introDone = true,
              );
            } else
              Navigator.pop(context, '');
          },
        );
    }
    return buttons;
  }

  Widget navigationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          List.generate(imagesList().length, (index) => index).map((number) {
        int index = List.generate(imagesList().length, (index) => index)
            .indexOf(number);
        return Container(
          width: 8.0,
          height: 8.0,
          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _current.value == index
                ? Color.fromRGBO(255, 255, 255, 0.9)
                : Color.fromRGBO(255, 255, 255, 0.4),
          ),
        );
      }).toList(),
    );
  }
}
