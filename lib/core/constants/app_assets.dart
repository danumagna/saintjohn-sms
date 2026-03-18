/// Application asset paths.
class AppAssets {
  AppAssets._();

  // Base paths
  static const String _iconsPath = 'assets/icons';
  static const String _imagesPath = 'assets/images';

  // Logo
  static const String logo = '$_iconsPath/saintjohnlogo.png';

  // Illustrations
  static const String illustrationEmpty =
      '$_imagesPath/illustrations/empty.png';
  static const String illustrationError =
      '$_imagesPath/illustrations/error.png';
  static const String illustrationSuccess =
      '$_imagesPath/illustrations/success.png';
  static const String illustrationNoData =
      '$_imagesPath/illustrations/no_data.png';
  static const String illustrationWelcome =
      '$_imagesPath/illustrations/welcome.png';

  // Avatars
  static const String avatarDefault = '$_imagesPath/avatars/default_avatar.png';
  static const String avatarMale = '$_imagesPath/avatars/male_avatar.png';
  static const String avatarFemale = '$_imagesPath/avatars/female_avatar.png';

  // Backgrounds
  static const String backgroundAuth = '$_imagesPath/backgrounds/auth_bg.png';
  static const String backgroundSplash =
      '$_imagesPath/backgrounds/splash_bg.png';
}
