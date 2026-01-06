import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/responsive_helper.dart';

enum LoadingType {
  circular,
  linear,
  dots,
  shimmer,
}

class LoadingWidget extends StatelessWidget {
  final LoadingType type;
  final String? message;
  final Color? color;
  final double? size;
  final bool showBackground;

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.color,
    this.size,
    this.showBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = _buildLoadingIndicator(context);

    if (message != null) {
      loadingWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          SizedBox(height: 16.h),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color ??
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (showBackground) {
      return Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(child: loadingWidget),
      );
    }

    return Center(child: loadingWidget);
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    final indicatorColor = color ?? Theme.of(context).colorScheme.primary;
    final indicatorSize = size ??
        ResponsiveHelper.getResponsiveValue(
          context,
          mobile: 32.w,
          tablet: 36.w,
        );

    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            strokeWidth: 3.0,
          ),
        );

      case LoadingType.linear:
        return Container(
          width: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 200.w,
            tablet: 250.w,
          ),
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            backgroundColor: indicatorColor.withOpacity(0.2),
          ),
        );

      case LoadingType.dots:
        return DotsLoadingIndicator(
          color: indicatorColor,
          size: indicatorSize! / 4,
        );

      case LoadingType.shimmer:
        return ShimmerLoadingIndicator(
          color: indicatorColor,
          size: indicatorSize ?? 24.0,
        );
    }
  }
}

//Center loading widget for full screen loading
class CenterLoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;

  const CenterLoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.circular,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingWidget(
        type: type,
        message: message,
        color: color,
      ),
    );
  }
}

class OverlayLoadingWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final LoadingType type;
  final Color? color;

  const OverlayLoadingWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.type = LoadingType.circular,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          LoadingWidget(
            type: type,
            message: loadingMessage,
            color: color,
            showBackground: true,
          ),
      ],
    );
  }
}

class DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const DotsLoadingIndicator({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            final opacity =
                (0.2 + (_animations[index].value * 0.8)).clamp(0.0, 1.0);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

class ShimmerLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const ShimmerLoadingIndicator({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  State<ShimmerLoadingIndicator> createState() =>
      _ShimmerLoadingIndicatorState();
}

class _ShimmerLoadingIndicatorState extends State<ShimmerLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * 2,
          height: widget.size / 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.size / 4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
              colors: [
                widget.color.withOpacity(0.1),
                widget.color.withOpacity(0.3),
                widget.color.withOpacity(0.1),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardLoadingSkeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  const CardLoadingSkeleton({
    super.key,
    this.height,
    this.width,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 120.h,
      width: width ?? double.infinity,
      margin: margin ?? EdgeInsets.symmetric(vertical: 4.h),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoadingIndicator(
                color: Theme.of(context).colorScheme.primary,
                size: 20.w,
              ),
              SizedBox(height: 8.h),
              ShimmerLoadingIndicator(
                color: Theme.of(context).colorScheme.primary,
                size: 16.w,
              ),
              SizedBox(height: 8.h),
              ShimmerLoadingIndicator(
                color: Theme.of(context).colorScheme.primary,
                size: 12.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListLoadingSkeleton extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;

  const ListLoadingSkeleton({
    super.key,
    this.itemCount = 5,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return CardLoadingSkeleton(
          height: itemHeight,
        );
      },
    );
  }
}

class GridLoadingSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double? itemHeight;

  const GridLoadingSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.itemHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return CardLoadingSkeleton(
          height: itemHeight,
          margin: EdgeInsets.zero,
        );
      },
    );
  }
}

class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? icon;
  final double? width;
  final double? height;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ?? Theme.of(context).colorScheme.primary,
          foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
          disabledBackgroundColor:
              (backgroundColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class RefreshLoadingIndicator extends StatelessWidget {
  final String? message;
  final Color? color;

  const RefreshLoadingIndicator({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: 8.h),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color ??
                        Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AdaptiveLoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;
  final LoadingType? type;

  const AdaptiveLoadingWidget({
    super.key,
    this.message,
    this.color,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      type: type ?? LoadingType.circular,
      message: message,
      color: color,
    );
  }
}

class PulseLoadingIndicator extends StatefulWidget {
  final Widget child;
  final Color? pulseColor;
  final Duration duration;

  const PulseLoadingIndicator({
    super.key,
    required this.child,
    this.pulseColor,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}
