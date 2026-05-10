import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Scaffold racine des écrans Asfar Premium.
///
/// Wrapper qui pose le fond `background`, peut accueillir un [appBar]
/// (typiquement [DynamicAppBar]), un [body] scrollable et un [bottom]
/// (typiquement [BottomNav] ou [BottomBar]).
///
/// Si [scrollable] est `true`, [body] est wrappé dans un `SingleChildScrollView`
/// avec `bottomPadding` configurable.
class ScreenScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottom;
  final bool scrollable;
  final EdgeInsets bodyPadding;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;

  const ScreenScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottom,
    this.scrollable = true,
    this.bodyPadding = const EdgeInsets.symmetric(horizontal: 18),
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = scrollable
        ? SingleChildScrollView(
            padding: bodyPadding,
            child: body,
          )
        : Padding(padding: bodyPadding, child: body);

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: bottom != null,
      body: content,
      bottomNavigationBar: bottom,
    );
  }
}
