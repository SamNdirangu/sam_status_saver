import 'package:flutter/material.dart';
import 'package:sam_status_saver/constants/appStrings.dart';
import 'package:sam_status_saver/screens/home/tabs/statusImages.dart';
import 'package:sam_status_saver/screens/home/tabs/statusVideos.dart';
import 'package:sam_status_saver/widgets/backdrop/backdrop.dart';
import 'package:sam_status_saver/widgets/backdrop/backdropPanel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(duration: Duration(milliseconds: 300), value: 1.0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print('homePrinted');
    return Backdrop(
        controller: _animationController,
        backTitle: const Text('More'),
        backLayer: BackdropPanel(),
        frontTitle: const Text(AppStrings.appTitle),
        frontLayer: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Material(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  controller: _tabController,
                  indicatorWeight: 3,
                  indicatorColor: Colors.white,
                  tabs: <Widget>[
                    const Tab(text: 'Pictures'), const Tab(text: 'Videos'), //const Tab(text: 'Saved'),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.black,
            body: HomeScreenContent(tabController: _tabController)));
  }
}

class HomeScreenContent extends StatefulWidget {
  final TabController tabController;

  HomeScreenContent({Key? key, required this.tabController}) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  ///The function is called whrn the app lifestyle changes
  ///This allows for the calling of get content if one returns to the app
  ///automatically refreshing the content displayed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print('called');
    if (state == AppLifecycleState.resumed) {
      //TODO
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Key imageTab = UniqueKey();
  Key videoTab = UniqueKey();
  Key savedTab = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: widget.tabController,
      children: <Widget>[
        StatusImages(key: imageTab),
        StatusVideos(key: videoTab),
      ],
    );
  }
}
