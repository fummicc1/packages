// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Test page for javaScriptCanOpenWindowsAutomatically feature
class WindowOpenTestPage extends StatefulWidget {
  /// Creates a new [WindowOpenTestPage].
  const WindowOpenTestPage({super.key});

  @override
  State<WindowOpenTestPage> createState() => _WindowOpenTestPageState();
}

class _WindowOpenTestPageState extends State<WindowOpenTestPage> {
  late final PlatformWebViewController _controller;
  late final PlatformWebViewController _controllerDisabled;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  Future<void> _initControllers() async {
    // Controller with javaScriptCanOpenWindowsAutomatically ENABLED
    _controller = WebKitWebViewController(
      WebKitWebViewControllerCreationParams(
        javaScriptCanOpenWindowsAutomatically: true,
      ),
    );
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    if (Platform.isIOS) {
      await _controller.setBackgroundColor(Colors.white);
    }

    // Controller with javaScriptCanOpenWindowsAutomatically DISABLED (default)
    _controllerDisabled = WebKitWebViewController(
      WebKitWebViewControllerCreationParams(
        javaScriptCanOpenWindowsAutomatically: false,
      ),
    );
    await _controllerDisabled.setJavaScriptMode(JavaScriptMode.unrestricted);
    if (Platform.isIOS) {
      await _controllerDisabled.setBackgroundColor(Colors.white);
    }

    // Load test HTML
    await _loadTestHtml();

    setState(() {
      _isLoaded = true;
    });
  }

  Future<void> _loadTestHtml() async {
    final String htmlContent =
        await rootBundle.loadString('assets/window_open_test.html');
    await _controller.loadHtmlString(htmlContent);
    await _controllerDisabled.loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('window.open() Test'),
        backgroundColor: Colors.blue,
      ),
      body: !_isLoaded
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.green.shade100,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.check_circle,
                                color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Enabled (javaScriptCanOpenWindowsAutomatically: true)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PlatformWebViewWidget(
                          PlatformWebViewWidgetCreationParams(
                              controller: _controller),
                        ).build(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 2, thickness: 2),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        color: Colors.red.shade100,
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.cancel, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Disabled (javaScriptCanOpenWindowsAutomatically: false)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: PlatformWebViewWidget(
                          PlatformWebViewWidgetCreationParams(
                              controller: _controllerDisabled),
                        ).build(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: WindowOpenTestPage(),
    debugShowCheckedModeBanner: false,
  ));
}
