import '../app_modules/imports_module.dart';

class FuturisticCardWidget extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const FuturisticCardWidget({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.enableHoverEffect = true,
  });

  @override
  State<FuturisticCardWidget> createState() => _FuturisticCardWidgetState();
}

class _FuturisticCardWidgetState extends State<FuturisticCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      if (isHovered) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  margin: widget.margin,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: AppColors.cardGradient,
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(
                        _glowAnimation.value * 0.5 + 0.1,
                      ),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(
                          _glowAnimation.value * 0.3 + 0.1,
                        ),
                        blurRadius: _glowAnimation.value * 20 + 10,
                        spreadRadius: _glowAnimation.value * 5 + 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: widget.padding ?? const EdgeInsets.all(20),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final double opacity;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.backgroundCard.withOpacity(opacity),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: padding ?? const EdgeInsets.all(20),
                child: child,
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
