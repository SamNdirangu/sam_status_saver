import 'package:flutter/material.dart';
import 'package:sam_status_saver/screens/home/tabs/tab.status.images.dart';
import 'package:sam_status_saver/screens/home/tabs/tab.status.videos.dart';

class SavedFilesTab extends StatefulWidget {
  const SavedFilesTab({Key? key}) : super(key: key);

  @override
  SavedFilesTabState createState() => SavedFilesTabState();
}

class SavedFilesTabState extends State<SavedFilesTab> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), value: 1.0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Key imageTab = UniqueKey();
  Key videoTab = UniqueKey();
  Key savedTab = UniqueKey();

  @override
  Widget build(BuildContext context) {
    //print('homePrinted');
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        indicatorWeight: 3,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const <Widget>[
          Tab(
            text: 'Saved Images',
          ),
          Tab(text: 'Saved Videos'),
        ],
      ),
      backgroundColor: Colors.black,
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          StatusImages(key: imageTab, isSavedFiles: true),
          StatusVideos(key: videoTab, isSavedFiles: true),
        ],
      ),
    );
  }
}
