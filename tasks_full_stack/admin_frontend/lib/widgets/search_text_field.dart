import 'package:flutter/material.dart';

/// A reusable search text field widget with focus node support
/// Used in both tasks and students screens for consistent search functionality
class SearchTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final bool showClearButton;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const SearchTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.showClearButton = true,
    this.prefixIcon,
    this.contentPadding,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon ?? const Icon(Icons.search),
        suffixIcon:
            controller != null && controller!.text.isNotEmpty && showClearButton
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
      textInputAction: textInputAction ?? TextInputAction.search,
      onSubmitted: onSubmitted,
    );
  }
}
