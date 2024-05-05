import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/views/empty_page.dart';

import '../views/home_page.dart';

class DualPanel with ChangeNotifier {

  List<Widget> startPaneList = [const HomePage()];
  List<Widget> endPanelList = [const EmptyPage()];

  Widget get startPanel => startPaneList.last;
  Widget get endPanel => endPanelList.last;

  /// 路由下一页 start
  // 仅替换右侧显示page
  void endPanelPush(BuildContext context, Widget widget) {
    if (MediaQuery.of(context).size.width > 500) {
      endPanelList.add(widget);
    } else {
      newPagePush(widget);
    }
  }

  // 从右向左全替换page
  void rightToLeft(Widget widget) {
    Widget firstEndPanel = endPanelList[0];
    startPaneList.add(firstEndPanel);
    // endPanelPush(widget);
  }

  // void popStartPanel(Widget widget) {
  //   startPaneList.removeAt(0);
  //   notifyListeners();
  // }

  // 整个page都替换掉
  void newPagePush(Widget widget) {
    startPaneList.add(widget);
    endPanelList.removeRange(1, endPanelList.length);
    notifyListeners();
  }
  /// 路由下一页 end

  /// 路由返回 start
  // 右侧返回
  void endPanelPop(BuildContext context) {
    print("触发咯");
    if (MediaQuery.of(context).size.width > 500) {
      endPanelList.removeLast();
      print(endPanelList);
    } else {
      newPagePop();
    }

    notifyListeners();
  }

  // 从左向右返回
  void leftToRight() {
    endPanelList.removeLast();
    startPaneList.removeLast();
    // notifyListeners();
  }

  // 整个page都替换掉返回
  void newPagePop() {
    startPaneList.removeLast();
    endPanelList.removeRange(0, endPanelList.length);
    endPanelList = [const EmptyPage()];
    notifyListeners();
  }
  /// 路由返回 end
}
