import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? child;
  final bool isLoading;
  final bool isOutlined;
  final bool isTextButton;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.child,
    this.isLoading = false,
    this.isOutlined = false,
    this.isTextButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = child ?? 
      Text(
        text,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: isOutlined || isTextButton 
              ? AppTheme.primaryColor 
              : Colors.white,
        ),
      );

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: isOutlined || isTextButton 
              ? AppTheme.primaryColor 
              : Colors.white,
          strokeWidth: 2,
        ),
      );
    }

    if (isTextButton) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: buttonChild,
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: buttonChild,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: buttonChild,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? child;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      child: child,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? child;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isOutlined: true,
      child: child,
    );
  }
}

class TextButtonCustom extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? child;

  const TextButtonCustom({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isTextButton: true,
      child: child,
    );
  }
}
