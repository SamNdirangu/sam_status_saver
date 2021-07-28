class Configs {
  static const thumbnailExt = '.webp';
  static const savedExt = '-SAVED';
  static const refreshLimit = 3; //for thumbnail generation so as not to show loading screen long
}

class FolderPaths {
  static const standardStatuses = '/storage/emulated/0/WhatsApp/Media/.Statuses';
  static const businessStatuses = '/storage/emulated/0/WhatsApp Business/Media/.Statuses';

  static const savesFolder = '/storage/emulated/0/Pictures/Sams Status Saver/';
  static const tempFolder = '/storage/emulated/0/Pictures/Sams Status Saver/.temp';
}

class AppMessageStrings {
  //Error Messages
  static const errWhatsappNotInstalled = 'Whatsapp not installed';
  static const errWhatsappBusinessNotInstalled = 'WhatsApp Business is Not installed';
  static const errWhatsappPersonalNotInstalled = 'WhatsApp Personal is Not installed';
}
