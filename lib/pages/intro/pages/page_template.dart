import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_gtt/widgets/intro/custom_text.dart';

class PageTemplate extends StatefulWidget {
  final String title;
  final List<Widget> children;
  const PageTemplate({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<PageTemplate> createState() => _PageTemplateState();
}

class _PageTemplateState extends State<PageTemplate> {
  late final _scrollController = ScrollController();
  bool _showScrollButton = false;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.position.extentAfter > 0) {
        setState(() {
          _showScrollButton = true;
        });
      }
      _scrollController.addListener(() {
        if (_scrollController.position.extentAfter > 0 && !_showScrollButton) {
          setState(() {
            _showScrollButton = true;
          });
        } else if (_scrollController.position.extentAfter == 0 &&
            _showScrollButton) {
          setState(() {
            _showScrollButton = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(
          widget.title,
          type: CustomTextType.title,
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ).copyWith(top: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: widget.children
                        .expand(
                          (element) => [
                            element,
                            if (widget.children.last != element)
                              const SizedBox(height: 20),
                          ],
                        )
                        .toList(),
                  ),
                  if (_showScrollButton)
                    Positioned(
                      //right: 0,
                      bottom: _scrollController.position.maxScrollExtent,
                      child: IconButton.filled(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              Theme.of(context).primaryColor.withOpacity(0.4)),
                          shape: WidgetStateProperty.all(
                            const CircleBorder(),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () {
                          _scrollController.animateTo(
                            _scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutQuad,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
