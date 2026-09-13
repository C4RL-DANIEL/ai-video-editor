import 'package:flutter/material.dart';

/// Main scaffold with optional sidebar, top bar, and floating action button area.
class AppScaffold extends StatelessWidget {
  final Widget body;
  final Widget? sidebar;
  final Widget? topBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomBar;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final EdgeInsetsGeometry? bodyPadding;
  final String? title;
  final List<Widget>? topBarActions;

  const AppScaffold({
    Key? key,
    required this.body,
    this.sidebar,
    this.topBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomBar,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.bodyPadding,
    this.title,
    this.topBarActions,
  }) : super(key: key);

  /// Simple scaffold with just title and body.
  const AppScaffold.simple({
    Key? key,
    required Widget body,
    String? title,
    List<Widget>? actions,
  })  : body = body,
        sidebar = null,
        topBar = null,
        floatingActionButton = null,
        floatingActionButtonLocation = null,
        bottomBar = null,
        backgroundColor = null,
        extendBodyBehindAppBar = false,
        bodyPadding = null,
        title = title,
        topBarActions = actions,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? const Color(0xFF0D0D0F);

    // If sidebar is provided, use a custom layout
    if (sidebar != null) {
      return _buildWithSidebar(context, bgColor);
    }

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomBar,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (topBar != null) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: topBar!,
      );
    }

    if (title != null) {
      return AppBar(
        backgroundColor: const Color(0xFF141418),
        elevation: 0,
        centerTitle: false,
        title: Text(
          title!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: topBarActions,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFF222228),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildBody(BuildContext context) {
    Widget content = body;

    if (bodyPadding != null) {
      content = Padding(
        padding: bodyPadding!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildWithSidebar(BuildContext context, Color bgColor) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Row(
        children: [
          // Sidebar
          SizedBox(
            width: 260,
            child: Container(
              color: const Color(0xFF141418),
              child: Column(
                children: [
                  // Sidebar content
                  Expanded(child: sidebar!),
                ],
              ),
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            color: const Color(0xFF222228),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                if (topBar != null)
                  SizedBox(
                    height: 56,
                    child: topBar,
                  ),

                // Body
                Expanded(child: _buildBody(context)),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// Custom top bar widget.
class AppTopBar extends StatelessWidget {
  final String? title;
  final List<Widget>? leading;
  final List<Widget>? actions;
  final Widget? child;
  final bool showDivider;

  const AppTopBar({
    Key? key,
    this.title,
    this.leading,
    this.actions,
    this.child,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Color(0xFF141418),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Leading widgets
                  if (leading != null) ...[
                    ...leading!,
                    const SizedBox(width: 12),
                  ],

                  // Title
                  if (title != null)
                    Text(
                      title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  // Child (center area)
                  if (child != null) Expanded(child: child!),
                  if (child == null) const Spacer(),

                  // Actions
                  if (actions != null) ...actions!,
                ],
              ),
            ),
          ),

          // Divider
          if (showDivider)
            const SizedBox(
              height: 1,
              child: ColoredBox(color: Color(0xFF222228)),
            ),
        ],
      ),
    );
  }
}
