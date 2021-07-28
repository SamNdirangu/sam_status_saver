import 'package:sam_status_saver/constants/configs.dart';
import 'package:sam_status_saver/providers/dataProvider.dart';

/////////////////////////////////////////////////////////////////////////
///
class DataErrorModel {
  bool isError;
  String? errorMsg;
  DataErrorModel({this.isError = false, this.errorMsg});
}

///
DataErrorModel dataErrorCatcher(DataStatus dataStatus) {
  //End function if whatsapp is not installed
  if (!dataStatus.isWhatsAppInstalled)
    return DataErrorModel(isError: true, errorMsg: AppMessageStrings.errWhatsappNotInstalled);
  //Incase somehow user switches to business mode and no directory is present
  if (dataStatus.isBusinessMode && !dataStatus.whatsAppBusinessReady)
    return DataErrorModel(isError: true, errorMsg: AppMessageStrings.errWhatsappBusinessNotInstalled);
  if (!dataStatus.isBusinessMode && !dataStatus.whatsAppStandardReady)
    return DataErrorModel(isError: true, errorMsg: AppMessageStrings.errWhatsappPersonalNotInstalled);

  return DataErrorModel();
}
