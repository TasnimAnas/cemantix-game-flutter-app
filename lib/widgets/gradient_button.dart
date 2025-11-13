import 'package:cemantix/theme.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsets padding;

  const GradientButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 10,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: BoxDecoration(
          color: kPrimary,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: kTextSecondary.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: kAnimationDuration,
          curve: kAnimationCurve,
          padding: padding,
          child: DefaultTextStyle(
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
