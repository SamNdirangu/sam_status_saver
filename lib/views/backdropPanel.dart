import 'package:flutter/material.dart';
import 'package:sam_status_saver/constants/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class BackdropPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('lib/assets/images/BackdropPanel.jpg'),
          )),
      child: Scrollbar(
        child: ListView(
          children: <Widget>[
            SaleWidget(),
            SizedBox(height: 150)
          ]
        )
      )
    );
  }
}

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
                    Text('Made with ',style: TextStyle(color: Colors.black87),),
                    Icon(Icons.favorite, color: Colors.red),
                    Text(' by',style: TextStyle(color: Colors.black87))
                  ],
                ),
              ),
              Image.asset(
                'lib/assets/images/sakalogo.png',
                height: 200,
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "$sale",
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.8,
                        style:
                            TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        "$sale2",
                        textAlign: TextAlign.center,style: TextStyle(color: Colors.black87)
                      ),
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
                      Text('SakaDevs Inc © 2020  App made with Flutter',style: TextStyle(color: Colors.black87))
                    ]
                )
              ),
            ],
    );
  }
}