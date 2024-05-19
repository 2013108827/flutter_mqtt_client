import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/router/index.dart';

import 'package:mqtt_client/router/myRoute.dart';

class DualPanel with ChangeNotifier {

  bool initialized = false;
  List<MyRoute> startPaneList = [];
  List<MyRoute> endPanelList = [];


  MyRoute? get startPanel {
    if (startPaneList.isEmpty) {
      return null;
    }
    return startPaneList.last;
  }

  MyRoute? get endPanel {
    if (endPanelList.isEmpty) {
      return null;
    }
    return endPanelList.last;
  }

  void routerInit(BuildContext context) {
    routerPush(context, "HomePage", {});
    routerPush(context, "EmptyPage", {});
  }

  void routerInitAsync(BuildContext context) {
    Future<void> future = Future(() {
      routerPush(context, "HomePage", {});
      routerPush(context, "EmptyPage", {});
    });
    future.then((_) {
      initialized = true;
      notifyListeners();
    });
  }

  // 路由push
  void routerPush(BuildContext context, String newRouteName, Object arguments) {
    Function? routerFunction = constantRoutes[newRouteName];
    if (routerFunction == null) {
      throw Exception("router not found");
    }

    MyRoute route = routerFunction(context, arguments);
    debugPrint("newRouteName===>$newRouteName:${route.method}");

    switch (route.method) {
      case "endPanelPush":
        if (MediaQuery.of(context).size.width > 500 || !initialized) {
          endPanelPush(route);
        } else {
          newPagePush(route);
        }
        break;
      case "newPagePush":
        newPagePush(route);
        break;
    }
  }

  void routerPop(BuildContext context, {bool isNewPage = false}) {
    if (MediaQuery.of(context).size.width > 500 && !isNewPage) {
      MyRoute lastRoute = endPanelList.last;
      switch (lastRoute.method) {
        case "endPanelPush":
          endPanelPop();
          break;
        case "newPagePush":
          newPagePop();
          break;
      }
    } else {
      newPagePop();
    }
  }


  /// 路由下一页 start
  // 仅替换右侧显示page
  void endPanelPush(MyRoute route) {
    if (endPanelList.isNotEmpty) {
      MyRoute existRoute = endPanelList.last;
      if (existRoute.name == route.name) {
        debugPrint("有重复的widget");
        return;
        endPanelList.removeLast();
      }
    }

    endPanelList.add(route);
    if (initialized) {
      debugPrint("重新渲染dual_widget");
      notifyListeners();
    }
  }

  // 从右向左全替换page
  // void rightToLeft(Widget widget) {
  //   Widget firstEndPanel = endPanelList[0];
  //   startPaneList.add(firstEndPanel);
  //   // endPanelPush(widget);
  // }

  // void popStartPanel(Widget widget) {
  //   startPaneList.removeAt(0);
  //   notifyListeners();
  // }

  // 整个page都替换掉
  void newPagePush(MyRoute route) {
    startPaneList.add(route);
    if (endPanelList.isNotEmpty) {
      endPanelList.removeRange(1, endPanelList.length);
    }
    if (initialized) {
      notifyListeners();
    }
  }
  /// 路由下一页 end

  /// 路由返回 start
  // 右侧返回
  void endPanelPop() {
    if (endPanelList.isNotEmpty) {
      endPanelList.removeLast();
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
    if (startPaneList.isNotEmpty) {
      startPaneList.removeLast();
    }
    if (endPanelList.isNotEmpty) {
      endPanelList.removeRange(1, endPanelList.length);
    }
    notifyListeners();
  }
  /// 路由返回 end
}
