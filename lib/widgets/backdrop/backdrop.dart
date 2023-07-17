import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sam_status_saver/constants/constant.strings.dart';
import 'package:sam_status_saver/providers/all.providers.dart';
import 'package:share/share.dart';
import 'package:flutter/material.dart';
import 'package:sam_status_saver/widgets/backdrop/front_layer.dart';
import 'package:sam_status_saver/widgets/backdrop/animation.layer.dart';
import 'package:sam_status_saver/widgets/backdrop/backdrop.title.dart';

/// Builds a Backdrop.
///
/// A Backdrop widget has two layers, front and back. The front layer is shown
/// by default, and slides down to show the back layer, from which a user
/// can make a selection. The user can also configure the titles for when the
/// front or back layer is showing.
class Backdrop extends StatefulWidget {
  final Widget frontLayer;
  final Widget backLayer;
  final Widget frontTitle;
  final Widget backTitle;
  final AnimationController controller;

  const Backdrop({
    super.key,
    required this.frontLayer,
    required this.backLayer,
    required this.frontTitle,
    required this.backTitle,
    required this.controller,
  });

  @override
  BackdropState createState() => BackdropState();
}

class BackdropState extends State<Backdrop>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late AnimationController _controller;
  late Animation<RelativeRect> _layerAnimation;
  bool isFav = false;
  //
  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  //
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _frontLayerVisible {
    final AnimationStatus status = _controller.status;
    return status == AnimationStatus.completed ||
        status == AnimationStatus.forward;
  }

  void _toggleBackdropLayerVisibility() {
    // Call setState here to update layerAnimation if that's necessary
    setState(() {
      _frontLayerVisible ? _controller.reverse() : _controller.forward();
    });
  }

  Widget _buildStack(BuildContext context, BoxConstraints constraints) {
    const double layerTitleHeight = 150.0;
    final Size layerSize = constraints.biggest;
    final double layerTop = layerSize.height - layerTitleHeight;

    _layerAnimation =
        getLayerAnimation(layerSize, layerTop, _frontLayerVisible, _controller);

    return Stack(
      key: _backdropKey,
      children: <Widget>[
        widget.backLayer,
        PositionedTransition(
          rect: _layerAnimation,
          child: FrontLayer(
            frontLayerVisible: _frontLayerVisible,
            onTap: _toggleBackdropLayerVisibility,
            child: widget.frontLayer,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final isDarkTheme = ref.watch(appSettingsProvider).isDarkTheme;
      final funcToggleDarkTheme =
          ref.read(appSettingsProvider.notifier).toggleDarkTheme;

      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          elevation: _frontLayerVisible ? 0 : 2,
          titleSpacing: 0.0,
          title: BackdropTitle(
            listenable: _controller.view,
            onPress: _toggleBackdropLayerVisibility,
            frontTitle: widget.frontTitle,
            backTitle: widget.backTitle,
          ),
          actions: <Widget>[
            IconButton(
              tooltip: "Share App",
              icon: const Icon(Icons.share),
              onPressed: () {
                Share.share(ConstantAppStrings.share);
              },
            ),
            IconButton(
                tooltip: "Dark Theme",
                icon: isDarkTheme
                    ? const Icon(Icons.brightness_7)
                    : const Icon(Icons.brightness_3),
                onPressed: () => funcToggleDarkTheme()),
            IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.close_menu,
                  progress: _controller,
                ),
                onPressed: () => _toggleBackdropLayerVisibility()),
          ],
        ),
        body: LayoutBuilder(
          builder: _buildStack,
        ),
      );
    });
  }
}
