import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/constants/paths.dart';
import 'package:sam_status_saver/constants/strings.dart';
import 'package:sam_status_saver/providers/providers.dart';

class BackdropPanel extends StatefulWidget {
  final GettersCallBack callGetters;

  BackdropPanel({Key key, @required this.callGetters}) : super(key: key);

  @override
  _BackdropPanelState createState() => _BackdropPanelState();
}

class _BackdropPanelState extends State<BackdropPanel> {
  bool versionStandard;
  bool versionGB;
  bool versionBusiness;

  bool favStandard;
  bool favGB;
  bool favBusiness;

  double isMessageOpacity = 0.0;
  String infoMessage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showErrorMessage(code) {
    //1 => Standard
    //2 => GB
    //3 => BUsimess

    if (code == 1) {
      setState(() {
        infoMessage =
            "Sorry but you dont have the standard WhatsApp version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    } else if (code == 2) {
      setState(() {
        infoMessage =
            "Sorry but you dont have the WhatsApp GB version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    } else {
      setState(() {
        infoMessage =
            "Sorry but you dont have the WhatsApp Business version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    }

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    versionStandard = false;
    versionGB = false;
    versionBusiness = false;

    favStandard = false;
    favGB = false;
    favBusiness = false;

    final statusPaths = Provider.of<StatusDirectoryPath>(context);
    final favPathProvider = Provider.of<StatusDirectoryFavourite>(context);

    for (var path in statusPaths.statusPathsAvailable) {
      if (path == statusPathStandard) {
        versionStandard = true;
        if (path == favPathProvider.statusPathsFavourite) {
          favStandard = true;
        }
      }
      if (path == statusPathGB) {
        versionGB = true;
        if (path == favPathProvider.statusPathsFavourite) {
          favGB = true;
        }
      }
      if (path == statusPathBusiness) {
        versionBusiness = true;
        if (path == favPathProvider.statusPathsFavourite) {
          favBusiness = true;
        }
      }
    }

    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('lib/assets/images/BackdropPanel.jpg'),
        )),
        child: Scrollbar(
            child: ListView(children: <Widget>[
          Container(
            color: Colors.white24,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0,top: 32.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'lib/assets/images/logo.png',
                        height: 70.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Sam's Status Saver",
                                  textScaleFactor: 2.0,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor)),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Version: 1.0.6",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      "Please select your Whatsapp version below to view status",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RaisedButton(
                        color: favStandard ? colorCustom : Colors.grey.shade700,
                        textColor: Colors.white,
                        child: Text('Standard'),
                        onPressed: () {
                          if (versionStandard) {
                            setState(() {
                              favGB = false;
                              favStandard = true;
                              favBusiness = false;
                            });
                            widget.callGetters(statusPathStandard);
                            favPathProvider
                                .setFavouritePath(statusPathStandard);
                          } else {
                            showErrorMessage(1);
                          }
                        },
                      ),
                      SizedBox(width: 20),
                      RaisedButton(
                        color: favGB ? colorCustom : Colors.grey.shade700,
                        textColor: Colors.white,
                        onPressed: () {
                          if (versionGB) {
                            setState(() {
                              favGB = true;
                              favStandard = false;
                              favBusiness = false;
                            });
                            widget.callGetters(statusPathGB);
                            favPathProvider.setFavouritePath(statusPathGB);
                          } else {
                            showErrorMessage(2);
                          }
                        },
                        child: Text('GB'),
                      ),
                      SizedBox(width: 20),
                      RaisedButton(
                        color: favBusiness ? colorCustom : Colors.grey.shade700,
                        textColor: Colors.white,
                        onPressed: () {
                          if (versionBusiness) {
                            setState(() {
                              favGB = false;
                              favStandard = false;
                              favBusiness = true;
                            });
                            widget.callGetters(statusPathBusiness);
                            favPathProvider
                                .setFavouritePath(statusPathBusiness);
                          } else {
                            showErrorMessage(3);
                          }
                        },
                        child: Text('Buisness'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 350),
                  opacity: isMessageOpacity,
                  child: Text(infoMessage,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 20.0, right: 10.0),
            child: Text(hintMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87, fontWeight: FontWeight.w600)),
          ),
          SaleWidget(),
          SizedBox(height: 200)
        ])));
  }
}

typedef GettersCallBack = dynamic Function(dynamic);

class SaleWidget extends StatelessWidget {
  const SaleWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Made with ',
                style: TextStyle(color: Colors.black87),
              ),
              Icon(Icons.favorite, color: Colors.red),
              Text(' by', style: TextStyle(color: Colors.black87))
            ],
          ),
        ),
        Image.asset(
          'lib/assets/images/sakalogo.png',
          height: 200,
        ),
        Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "$sale",
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.8,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Text("$sale2",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87)),
                  SizedBox(height: 5),
                  RaisedButton.icon(
                    elevation: 5,
                    autofocus: true,
                    textColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                    icon: Icon(
                      Icons.call,
                      size: 22,
                    ),
                    label: Text("+254 712 77 8056"),
                    onPressed: () async {
                      await launch('tel:+254712778056');
                    },
                  ),
                  SizedBox(height: 5),
                  RaisedButton.icon(
                    elevation: 5,
                    autofocus: true,
                    textColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                    icon: Icon(Icons.mail, size: 22),
                    label: Text("sakadevsinc@gmail.com"),
                    onPressed: () async {
                      await launch(
                          'mailto:sakadevsinc@gmail.com?subject=Hey there I need an App');
                    },
                  ),
                  SizedBox(height: 20),
                  Text('SakaDevs Inc © 2020  App made with Flutter',
                      style: TextStyle(color: Colors.black87))
                ])),
      ],
    );
  }
}
