import 'package:flutter/material.dart';
import 'package:sam_status_saver/assets/customColor.dart';
import 'package:sam_status_saver/functions/ShareSaveActions.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

class FunctionButtons extends StatelessWidget {
  final bool isImage;
  final SnackBar snackBar;
  final String filePath;

  const FunctionButtons({
    Key? key,
    required this.snackBar,
    required this.filePath,
    required this.isImage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 10, 30),
        child: SpeedDialFabWidget(
          secondaryIconsList: [
            Icons.reply,
            Icons.share,
            Icons.save,
          ],
          secondaryIconsText: [
            "repost",
            "share",
            "save",
          ],
          secondaryIconsOnPress: [
            () => {},
            () => shareFiles(filePath: filePath, isImage: isImage),
            () => saveFile(context: context, snackBar: snackBar, filePath: filePath),
          ],
          secondaryBackgroundColor: colorCustom,
          secondaryForegroundColor: Colors.white,
          primaryBackgroundColor: colorCustom,
          primaryForegroundColor: Colors.white,
          primaryIconExpand: Icons.add,
          primaryIconCollapse: Icons.close,
          rotateAngle: 6,
        ));
  }
}
