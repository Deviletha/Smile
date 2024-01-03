import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smile/screens/sterilization.dart';
import 'completed.dart';
import 'in_sterilization.dart';


class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int selectIndex = 0;

  List body = <Widget>[Completed(), InSterilizationPage()];

  // void onItemTapped(int index) {
  //   setState(() {
  //     selectIndex = index;
  //   });
  // }



  final iconList = <IconData>[
    Iconsax.clipboard_tick5,
    Icons.clean_hands,
  ];

  List bottomLabels = ["COMPLETED", "IN STERILIZATION"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        clipBehavior: Clip.hardEdge,
        // isExtended: true,
        mini: false,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset("assets/qr_logo.png"),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SterilizationPage();
            }),
          );
        },
        //params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        height: 70,
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color =
          isActive ? Colors.indigo.shade500 : Colors.grey.shade500;
          final color1 =
          isActive ? Colors.grey.shade800 : Colors.grey.shade800;

          // final color = isActive ? colors.activeNavigationBarColor : colors.notActiveNavigationBarColor;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 30,
                color: color,
              ),
              const SizedBox(height: 4),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    bottomLabels[index],
                    style: TextStyle(fontSize: 10, color: color1),
                  ))
            ],
          );
        },
        activeIndex: selectIndex,
        splashSpeedInMilliseconds: 300,
        gapLocation: GapLocation.center,
        onTap: (index) => setState(() => selectIndex = index),
      ),
      body: body.elementAt(selectIndex),
    );
  }
}
