import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final _registered = <String>{};

Widget buildIframe(String url) {
  final viewType = 'spotify-embed-${url.hashCode}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      return web.HTMLIFrameElement()
        ..src = url
        ..allow =
            'autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture'
        ..setAttribute('loading', 'lazy')
        ..style.border = '0'
        ..style.borderRadius = '12px'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }
  return HtmlElementView(viewType: viewType);
}
