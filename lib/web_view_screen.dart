import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen>
    with TickerProviderStateMixin {
  late webview.WebViewController _controller;
  bool _isLoading = true;
  bool _isWebPlatform = false;
  late AnimationController _loaderController;
  late Animation<double> _loaderAnimation;
  DateTime? _loadStartTime;
  static const int _minimumLoadingDuration = 1500; // 1.5 seconds minimum

  @override
  void initState() {
    super.initState();
    _loaderController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _loaderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loaderController, curve: Curves.easeInOut),
    );

    _loaderController.repeat(reverse: true);
    _initializeWebView();
    // Ask for location permission when WebView screen opens (Android & iOS)
    // so the app has permission before the website requests geolocation
    if (Platform.isAndroid || Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestLocationPermission());
    }
  }

  /// Requests location permission so the app can provide it to the WebView
  /// when the website calls navigator.geolocation.
  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied) {
      await Permission.locationWhenInUse.request();
    }
  }

  void _initializeWebView() {
    _loadStartTime = DateTime.now();
    // Check if running on web
    try {
      _controller = webview.WebViewController()
        ..setJavaScriptMode(webview.JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          webview.NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _loadStartTime = DateTime.now();
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                // Calculate elapsed time
                final elapsedTime =
                    DateTime.now().difference(_loadStartTime!).inMilliseconds;
                final remainingTime =
                    (_minimumLoadingDuration - elapsedTime).clamp(0, _minimumLoadingDuration);

                // Delay hiding the loader to ensure minimum display time
                Future.delayed(Duration(milliseconds: remainingTime), () {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                });
              }
            },
            onWebResourceError: (webview.WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onNavigationRequest: (webview.NavigationRequest request) {
              return webview.NavigationDecision.navigate;
            },
          ),
        );
      _setupGeolocationThenLoad();
    } catch (e) {
      // If webview is not available (web platform), open in browser
      debugPrint('WebView not available: $e');
      setState(() {
        _isWebPlatform = true;
        _isLoading = false;
      });
      _openInBrowser();
    }
  }

  /// Enables WebView geolocation (Android) and then loads the URL.
  /// On Android, sets geolocation enabled and a callback so when the website
  /// calls navigator.geolocation.getCurrentPosition(), we request app location
  /// permission and allow/deny the WebView accordingly.
  Future<void> _setupGeolocationThenLoad() async {
    if (Platform.isAndroid && _controller.platform is AndroidWebViewController) {
      final androidController = _controller.platform as AndroidWebViewController;
      await androidController.setGeolocationEnabled(true);
      await androidController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (GeolocationPermissionsRequestParams params) async {
          final status = await Permission.locationWhenInUse.request();
          return GeolocationPermissionsResponse(
            allow: status.isGranted,
            retain: true,
          );
        },
      );
    }
    if (!mounted) return;
    _loadUrl();
  }

  void _loadUrl() async {
    try {
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (e) {
      debugPrint('Error loading URL: $e');
      if (mounted) {
        setState(() {
          _isWebPlatform = true;
          _isLoading = false;
        });
        _openInBrowser();
      }
    }
  }

  void _openInBrowser() async {
    final Uri url = Uri.parse(widget.url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isWebPlatform
          ? _buildWebFallback()
          : _buildMobileWebView(),
    );
  }

  Widget _buildMobileWebView() {
    return Stack(
      children: [
        webview.WebViewWidget(controller: _controller),
        if (_isLoading) _buildCustomLoader(),
      ],
    );
  }

  Widget _buildCustomLoader() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _loaderAnimation,
              builder: (context, child) {
                return Column(
                  children: [
                    Container(
                      width: 280,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF06B6D4),
                            const Color(0xFF2563EB),
                            const Color(0xFF7C3AED),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 280 * _loaderAnimation.value,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF06B6D4),
                                  Color(0xFF2563EB),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB)
                                      .withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Loading....',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.language, size: 64, color: Color(0xFF2563EB)),
          const SizedBox(height: 20),
          const Text(
            'Opening website in browser...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _openInBrowser,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
            ),
            icon: const Icon(Icons.open_in_new),
            label: const Text(
              'Open Website',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'URL: ${widget.url}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loaderController.dispose();
    super.dispose();
  }
}
