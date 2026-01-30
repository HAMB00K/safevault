import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Widget pour afficher une icône Rive animée
class RiveIcon extends StatefulWidget {
  final String assetPath;
  final String artboardName;
  final String stateMachineName;
  final String triggerName;
  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const RiveIcon({
    super.key,
    required this.assetPath,
    this.artboardName = 'New Artboard',
    this.stateMachineName = 'State Machine 1',
    this.triggerName = 'active',
    this.isActive = false,
    this.size = 32,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<RiveIcon> createState() => _RiveIconState();
}

class _RiveIconState extends State<RiveIcon> {
  StateMachineController? _controller;
  SMIBool? _activeTrigger;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      widget.stateMachineName,
    );
    
    if (controller != null) {
      artboard.addController(controller);
      _controller = controller;
      _activeTrigger = controller.findInput<bool>(widget.triggerName) as SMIBool?;
      _updateActiveState();
    }
  }

  void _updateActiveState() {
    if (_activeTrigger != null) {
      _activeTrigger!.value = widget.isActive;
    }
  }

  @override
  void didUpdateWidget(RiveIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _updateActiveState();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        widget.assetPath,
        artboard: widget.artboardName,
        onInit: _onRiveInit,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// Fallback avec icônes Material animées quand Rive n'est pas disponible
class AnimatedNavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const AnimatedNavIcon({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    this.size = 28,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = activeColor ?? Theme.of(context).primaryColor;
    final secondaryColor = inactiveColor ?? Colors.grey;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: isActive ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1 + (value * 0.15),
          child: Icon(
            isActive ? activeIcon : icon,
            size: size,
            color: Color.lerp(secondaryColor, primaryColor, value),
          ),
        );
      },
    );
  }
}
