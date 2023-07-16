import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:sam_status_saver/screens/home/tabs/tab.savedfiles.dart';
import 'package:sam_status_saver/screens/home/tabs/tab.status.images.dart';
import 'package:sam_status_saver/screens/home/tabs/tab.status.videos.dart';
import 'package:sam_status_saver/widgets/backdrop/backdrop.dart';
import 'package:sam_status_saver/widgets/backdrop/backdrop.panel.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final animationController = useAnimationController(duration: const Duration(milliseconds: 300), initialValue: 1);

    final funcRefreshData = ref.read(dataProvider.notifier).refreshData();

    return Backdrop(
        controller: animationController,
        backTitle: const Text('More'),
        backLayer: const BackdropPanel(),
        frontTitle: const Text(ConstantAppStrings.appTitle),
        frontLayer: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Material(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  controller: tabController,
                  indicatorWeight: 3,
                  indicatorColor: Colors.white,
                  tabs: const <Widget>[
                    Tab(text: 'Pictures'),
                    Tab(text: 'Videos'),
                    Tab(text: 'Saved'),
                  ],
                ),
              ),
            ),
            backgroundColor: Colors.black,
            body: HomeScreenContent(
              tabController: tabController,
              refreshData: funcRefreshData,
            )));
  }
}

class HomeScreenContent extends StatefulWidget {
  final TabController tabController;
  final refreshData;

  const HomeScreenContent({Key? key, required this.tabController, required this.refreshData}) : super(key: key);

  @override
  HomeScreenContentState createState() => HomeScreenContentState();
}

class HomeScreenContentState extends State<HomeScreenContent> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  ///The function is called whrn the app lifestyle changes
  ///This allows for the calling of get content if one returns to the app
  ///automatically refreshing the content displayed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print('called');
    if (state == AppLifecycleState.resumed) {
      //refresh data
      widget.refreshData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
        StatusImages(key: imageTab, isSavedFiles: false),
        StatusVideos(key: videoTab, isSavedFiles: false),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SavedFilesTab(key: savedTab),
        )
      ],
    );
  }
}
