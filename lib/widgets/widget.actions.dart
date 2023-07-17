import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.colors.dart';
import 'package:sam_status_saver/functions/actions.share.save.dart';
import 'package:speed_dial_fab/speed_dial_fab.dart';

class FunctionButtons extends HookConsumerWidget {
  final bool isImage;
  final bool isSavedFiles;
  final SnackBar snackBar;
  final String filePath;

  const FunctionButtons({
    Key? key,
    required this.isSavedFiles,
    required this.snackBar,
    required this.filePath,
    required this.isImage,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 10, 30),
        child: SpeedDialFabWidget(
          secondaryIconsList: [
            Icons.reply,
            Icons.share,
            !isSavedFiles ? Icons.save : Icons.delete,
          ],
          secondaryIconsText: [
            "repost",
            "share",
            !isSavedFiles ? "save" : "delete",
          ],
          secondaryIconsOnPress: [
            () => repostFile(filePath: filePath),
            () => shareFiles(filePath: filePath, isImage: isImage),
            () => saveDeleteFile(
                context: context, ref: ref, snackBar: snackBar, filePath: filePath, isSavedFiles: isSavedFiles),
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
