import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sam_status_saver/app.dart';
import 'package:sam_status_saver/providers/providers.dart';

class PermRequester extends StatelessWidget {
  const PermRequester({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Provider.of<PermissionProvider>(context).readEnabled) {
      return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.sentiment_dissatisfied,
                size: 56,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                'Please enable Permissions to access storage',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              RaisedButton(
                onPressed: () {
                  App().requestWritePermission(context);
                },
                child: Text('Enable Permissions'),
              )
            ]),
      );
    }
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.sentiment_satisfied,
              size: 56,
              color: Colors.white,
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                'Hey it seems you might have not yet installed Whastapp on your phone\n\nThis app requires Whatsapp',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ]),
    );
  }
}
