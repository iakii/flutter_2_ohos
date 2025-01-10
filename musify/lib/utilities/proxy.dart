// Dart imports:
import 'dart:io';

class ProxyClient extends HttpOverrides {
  ProxyClient({required this.proxyAddress});
  final String proxyAddress;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // print("设置代理==========================");
    // ignore: cascade_invocations
    client
      ..findProxy = (url) {
        return 'PROXY $proxyAddress';
      }
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; // 忽略证书错误
    return client;
  }

  static void toggle() {
    const proxyAddress = '127.0.0.1:1080';
    HttpOverrides.global = ProxyClient(proxyAddress: proxyAddress);
    // HttpOverrides.global = null;
  }
}
