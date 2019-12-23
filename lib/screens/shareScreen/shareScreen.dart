import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/constants/strings.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({Key key}) : super(key: key);


  shareLink(){
    Share.shareText(share, 'text/*');
  }

  //shareApp(){
  //  final apk = load.bundle()
  //  Share.shareFile(fileByte, fileName, mimeType)
  //}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Share App'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('lib/assets/images/BackdropPanel.jpg'),
            ),
          ),
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 32.0),
              child: Row(
                children: <Widget>[
                  Image.asset(
                    'lib/assets/images/logo.png',
                    height: 70.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text("Sam's Status Saver",
                            textScaleFactor: 2.0,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          "Version: 1.0.6",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Divider(),
            SizedBox(height: 150),
            RaisedButton.icon(


              icon: Icon(Icons.bluetooth, color: Colors.white),
              label: Text('Share App itself'),
              textColor: Colors.white,
              color: Colors.blue.shade700,
              onPressed: () {},
            ),
            SizedBox(height: 20),
            RaisedButton.icon(
              icon: Icon(Icons.share,color: Colors.white),
              color: Colors.green.shade700,
              textColor: Colors.white,
              label: Text('Share download link'),
              onPressed: shareLink,
            )
          ]),
        ));
  }
}
