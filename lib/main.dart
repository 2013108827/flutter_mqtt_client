import 'package:dual_screen/dual_screen.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/pojo/dualPanel.dart';
import 'package:mqtt_client/router/myRoute.dart';
import 'package:mqtt_client/store/HomePageProvider.dart';
import 'package:mqtt_client/store/clientAddProvider.dart';
import 'package:mqtt_client/store/conversationManageProvider.dart';
import 'package:mqtt_client/store/conversationMessageProvider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DualPanel(), lazy: false,),
        ChangeNotifierProvider(create: (_) => HomePageProvider()),
        ChangeNotifierProvider(create: (_) => ClientAddProvider()),
        ChangeNotifierProvider(create: (_) => ConversationManageProvider()),
        ChangeNotifierProvider(create: (_) => ConversationMessageProvider(),)
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    DualPanel dualPanel = context.watch<DualPanel>();
    MyRoute? startPanelRoute = dualPanel.startPanel;
    MyRoute? endPanelRoute = dualPanel.endPanel;
    print("main build");
    // print(startPanelRoute);
    // if (endPanelRoute != null) {
    //   print(dualPanel.endPanelList);
    // } else {
    //   print("6666");
    // }


    return MaterialApp(
      title: 'Flutter Demo',
      // onGenerateRoute: _routeGenerator,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: WillPopScope(
        onWillPop: () async  {
          if (startPanelRoute?.name == "HomePage") {
            print(startPanelRoute?.name);
            return true;
          }

          dualPanel.routerPop(context);
          return false;
        },
        child: (startPanelRoute == null || endPanelRoute == null) ? tempWidget(context, dualPanel) : TwoPane(
            startPane: startPanelRoute.widget,
            endPane: endPanelRoute.widget,
            paneProportion: 0.5,
            panePriority: MediaQuery.of(context).size.width > 500
                ? TwoPanePriority.both
                : TwoPanePriority.start),
      )
    );
  }

  Widget tempWidget(BuildContext context, DualPanel dualPanel) {
    // 下面的代码是不能能用来展示广告页？
    // Future.delayed(const Duration(seconds: 2),() {
    //   DualPanel dualPanel = context.read<DualPanel>();
    //   dualPanel.routerInit(context);
    // });
    dualPanel.routerInitAsync(context);

    return const Scaffold(
        body: Center(
          child: Text(
            'This is first page!!!',
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
