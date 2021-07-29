class Configs {
  static const thumbnailExt = '.webp';
  static const savedExt = '-SAVED';
  static const refreshLimit = 3; //for thumbnail generation so as not to show loading screen long
}

class FolderPaths {
  static const standardStatuses = '/storage/emulated/0/WhatsApp/Media/.Statuses';
  static const standardStatusesFB = '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses';
  static const businessStatuses = '/storage/emulated/0/WhatsApp Business/Media/.Statuses';
  static const businessStatusesFB =
      '/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses';

  static const savesFolder = '/storage/emulated/0/Pictures/Sams Status Saver/';
  static const tempFolder = '/storage/emulated/0/Pictures/Sams Status Saver/.temp';
}

class AppMessageStrings {
  //Error Messages
  static const errWhatsappNotInstalled =
      'Hey it seems you might have not yet installed Whastapp on your phone\n\nThis app requires Whatsapp';
  static const errWhatsappBusinessNotInstalled = 'WhatsApp Business is Not installed';
  static const errWhatsappPersonalNotInstalled = 'WhatsApp Personal is Not installed';

  //Permission Messages
  static const permEnablePermissions =
      'Inorder for this app to work, it requires permission to access your storage.\n\nPlease enable Permissions to access storage';
  static const permOpenPermissionSettings = 'Please go to settings and enable Permissions to access storage';
}
