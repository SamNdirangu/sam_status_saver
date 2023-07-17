import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.colors.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:url_launcher/url_launcher.dart';

class BackdropPanel extends StatefulWidget {
  const BackdropPanel({Key? key}) : super(key: key);

  @override
  BackdropPanelState createState() => BackdropPanelState();
}

class BackdropPanelState extends State<BackdropPanel> {
  bool initialise = true;
  bool favGB = false;
  bool favStandard = false;
  bool favBusiness = false;
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

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final dataStatus = ref.watch(dataProvider);
      final toggleAppMode = ref.read(dataProvider.notifier).toggleStatusMode;
      final permissionGranted = ref.watch(permissionProvider).isGranted;

      if (!dataStatus.isWhatsAppInstalled) {
        favBusiness = favStandard = false;
      } else {
        if (dataStatus.isBusinessMode) favBusiness = true;
        favStandard = !favBusiness;
      }

      void toggleWhatsAppMode() {
        if (!permissionGranted) {
          showErrorMessage(0);
        } else if (dataStatus.isBusinessMode &&
            !dataStatus.whatsAppStandardReady) {
          showErrorMessage(1);
        } else if (!dataStatus.isBusinessMode &&
            !dataStatus.whatsAppBusinessReady) {
          showErrorMessage(2);
        } else {
          toggleAppMode();
        }
      }

      return Container(
          decoration: const BoxDecoration(
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text("Sam's Status Saver",
                                    textScaleFactor: 1.8,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor)),
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "Version: 23.7.17.1",
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
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16.0),
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
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: favStandard
                                  ? colorCustom
                                  : Colors.grey.shade700,
                            ),
                            child: const Text('Standard',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () => !dataStatus.isBusinessMode
                                ? toggleWhatsAppMode()
                                : {}),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: favBusiness
                                ? colorCustom
                                : Colors.grey.shade700,
                          ),
                          onPressed: () => !dataStatus.isBusinessMode
                              ? toggleWhatsAppMode()
                              : {},
                          child: const Text('Business',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: isMessageOpacity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(infoMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32))),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 20.0, right: 10.0),
              child: Text(ConstantAppStrings.hintMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, top: 20.0, right: 10.0, bottom: 10),
              child: GestureDetector(
                onTap: () => launchUrl(
                  Uri.https(
                      'samndirangu.github.io/apps/SamsStatusSaver/privacy-policy.html'),
                ),
                child: const Text('Privacy Policy & Terms and Condition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, top: 10.0, right: 10.0, bottom: 10),
              child: GestureDetector(
                onTap: () => launchUrl(
                  Uri.https('github.com/SamNdirangu/status_saver'),
                ),
                child: const Text('Github Repo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600)),
              ),
            ),
            const SaleWidget(),
            const SizedBox(height: 200)
          ])));
    });
  }

  void showErrorMessage(code) {
    //0 => Permission Error
    //1 => Standard
    //2 => BUsiness

    if (code == 0) {
      setState(() {
        infoMessage = "Please Enable read Permissions";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    }
    if (code == 1) {
      setState(() {
        infoMessage =
            "Sorry but you dont have the standard WhatsApp version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    } else {
      setState(() {
        infoMessage =
            "Sorry but you dont have the WhatsApp Business version installed";
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    }
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        isMessageOpacity = 1.0 - isMessageOpacity;
      });
    });
  }
}

class SaleWidget extends StatelessWidget {
  const SaleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 15.0),
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
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ConstantAppStrings.sale,
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.8,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const Text(ConstantAppStrings.sale2,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87)),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 5, backgroundColor: Colors.white),
                    autofocus: true,
                    icon: const Icon(
                      Icons.call,
                      size: 22,
                    ),
                    label: Text(
                      "+254 712 77 8056",
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                    onPressed: () async {
                      await launchUrl(
                        Uri.http('tel:+254712778056'),
                      );
                    },
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        elevation: 5, backgroundColor: Colors.white),
                    autofocus: true,
                    icon: const Icon(
                      Icons.mail,
                      size: 22,
                    ),
                    label: Text(
                      "sakadevsinc@gmail.com",
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                    onPressed: () async {
                      await launchUrl(
                        Uri.http(
                            'mailto:sakadevsinc@gmail.com?subject=Hey there I need an App'),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('SakaDevs Inc © 2021  App made with Flutter',
                      style: TextStyle(color: Colors.black87))
                ])),
      ],
    );
  }
}
