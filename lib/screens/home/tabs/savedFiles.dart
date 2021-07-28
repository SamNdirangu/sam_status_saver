import 'package:flutter/material.dart';

class SavedFilesTab extends StatefulWidget {
  const SavedFilesTab({Key? key}) : super(key: key);

  @override
  _SavedFilesTabState createState() => _SavedFilesTabState();
}

class _SavedFilesTabState extends State<SavedFilesTab> with TickerProviderStateMixin {
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

  Key imageTab = UniqueKey();
  Key videoTab = UniqueKey();
  Key savedTab = UniqueKey();

  @override
  Widget build(BuildContext context) {
    //print('homePrinted');
    return Container(
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        child: Scaffold(
          appBar: TabBar(
            controller: _tabController,
            indicatorWeight: 2,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: <Widget>[
              const Tab(
                text: 'Saved Images',
              ),
              const Tab(text: 'Saved Videos'),
            ],
          ),
          backgroundColor: Colors.black,
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              //SavedStatusImages(key: imageTab),
              //SavedStatusVideos(key: videoTab),
            ],
          ),
        ));
  }
}
