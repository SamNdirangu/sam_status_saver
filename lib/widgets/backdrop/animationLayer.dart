import 'package:flutter/material.dart';

const Cubic _kAccelerateCurve = Cubic(0.548, 0.0, 0.757, 0.464);
const Cubic _kDecelerateCurve = Cubic(0.23, 0.94, 0.41, 1.0);
const double _kPeakVelocityProgress = 0.379146;
const double _kPeakVelocityTime = 0.248210;

// _layerAnimation animates the front layer between open and close.
// _getLayerAnimation adjusts the values in the TweenSequence so the
// curve and timing are correct in both directions.
Animation<RelativeRect> getLayerAnimation(
    Size layerSize, double layerTop, bool _frontLayerVisible, _controller) {
  Curve firstCurve; // Curve for first TweenSequenceItem
  Curve secondCurve; // Curve for second TweenSequenceItem
  double firstWeight; // Weight of first TweenSequenceItem
  double secondWeight; // Weight of second TweenSequenceItem
  Animation<double> animation; // Animation on which TweenSequence runs

  if (_frontLayerVisible) {
    firstCurve = _kAccelerateCurve;
    secondCurve = _kDecelerateCurve;
    firstWeight = _kPeakVelocityTime;
    secondWeight = 1.0 - _kPeakVelocityTime;
    animation = CurvedAnimation(
      parent: _controller.view,
      curve: Interval(0.0, 0.78),
    );
  } else {
    // These values are only used when the controller runs from t=1.0 to t=0.0
    firstCurve = _kDecelerateCurve.flipped;
    secondCurve = _kAccelerateCurve.flipped;
    firstWeight = 1.0 - _kPeakVelocityTime;
    secondWeight = _kPeakVelocityTime;
    animation = _controller.view;
  }

  return TweenSequence(
    <TweenSequenceItem<RelativeRect>>[
      TweenSequenceItem<RelativeRect>(
        tween: RelativeRectTween(
          begin: RelativeRect.fromLTRB(
            0.0,
            layerTop,
            0.0,
            layerTop - layerSize.height,
          ),
          end: RelativeRect.fromLTRB(
            0.0,
            layerTop * _kPeakVelocityProgress,
            0.0,
            (layerTop - layerSize.height) * _kPeakVelocityProgress,
          ),
        ).chain(CurveTween(curve: firstCurve)),
        weight: firstWeight,
      ),
      TweenSequenceItem<RelativeRect>(
        tween: RelativeRectTween(
          begin: RelativeRect.fromLTRB(
            0.0,
            layerTop * _kPeakVelocityProgress,
            0.0,
            (layerTop - layerSize.height) * _kPeakVelocityProgress,
          ),
          end: RelativeRect.fill,
        ).chain(CurveTween(curve: secondCurve)),
        weight: secondWeight,
      ),
    ],
  ).animate(animation);
}
