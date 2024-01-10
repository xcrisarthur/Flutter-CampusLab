import 'package:flutter/material.dart';

class CubertoBottomBar extends StatefulWidget {
  final List<TabData> tabs;
  final int selectedTab;
  final Function(int, String, Color?) onTabChangedListener;

  CubertoBottomBar({
    required this.tabs,
    required this.selectedTab,
    required this.onTabChangedListener,
  });

  @override
  _CubertoBottomBarState createState() => _CubertoBottomBarState();
}

class _CubertoBottomBarState extends State<CubertoBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.selectedTab,
      onTap: (index) {
        widget.onTabChangedListener(
          index,
          widget.tabs[index].title,
          widget.tabs[index].tabColor,
        );
      },
      items: widget.tabs
          .map(
            (tabData) => BottomNavigationBarItem(
              icon: Icon(tabData.iconData),
              label: tabData.title,
              backgroundColor: tabData.tabColor,
            ),
          )
          .toList(),
      selectedItemColor: widget.tabs[widget.selectedTab].tabColor,
      unselectedItemColor: widget.tabs[widget.selectedTab].textColor,
      selectedLabelStyle: TextStyle(color: widget.tabs[widget.selectedTab].textColor,),
      unselectedLabelStyle: TextStyle(color: widget.tabs[widget.selectedTab].tabColor),
    );
  }
}


class TabData {
  final IconData iconData;
  final String title;
  final Color? tabColor;
  final Color? textColor;

  TabData({
    required this.iconData,
    required this.title,
    this.tabColor,
    this.textColor,
  });
}

