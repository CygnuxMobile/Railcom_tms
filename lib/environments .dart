enum Environments { relicom }

abstract class AppEnvironments {
  static late String baseurl;
  static late String title;
  static late String version;
  static late Environments environments;
  static List<String> dashBordList = <String>[];
  static Environments get _environments => environments;

  ///this method is change flavor
  static setupEvm(Environments evm) {
    environments = evm;
    switch (evm) {
      case Environments.relicom:
        // Flavor-specific configuration for Relivr
        title = "Relivr";
        baseurl = "http://43.248.56.36:44398/";
        version = 'v 09.25.25';
        dashBordList = [
          'quickDocket',
          'gcn',
          'pod',
          'prsGenerate',
          'drsGenerate',
          // 'arrival',
          // 'stockUpdate',
          // 'unloadingSheet',
          // 'attendance',
          // 'tracking',
          // 'drs',
          // 'prq'
        ];
        break;
    }
  }
}
