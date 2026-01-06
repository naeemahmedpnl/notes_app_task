import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../data/models/note_model.dart';

class ModernNoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isSelected;

  const ModernNoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.isSelected = false,
  });

  @override
  State<ModernNoteCard> createState() => _ModernNoteCardState();
}

class _ModernNoteCardState extends State<ModernNoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  //Initialize card animations for smooth interactions
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));

    _elevationAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //Handle hover state changes with animation
  void _handleHover(bool isHovered) {
    if (!mounted) return;
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            decoration: _buildCardDecoration(context),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHover: _handleHover,
                borderRadius: context.responsiveBorderRadius,
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: 12.h),
                      _buildTitle(context),
                      SizedBox(height: 8.h),
                      _buildMessage(context),
                      SizedBox(height: 16.h),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //Build card decoration with responsive shadows and borders
  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: widget.isSelected
          ? context.primary10
          : Theme.of(context).colorScheme.surface,
      borderRadius: context.responsiveBorderRadius,
      border: Border.all(
        color: widget.isSelected ? context.primary30 : context.outline10,
        width: widget.isSelected ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: context.black10,
          blurRadius: _elevationAnimation.value,
          offset: Offset(0, _elevationAnimation.value / 2),
        ),
      ],
    );
  }

  //Build card header with date and action buttons
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateBadge(context),
        _buildActionButtons(context),
      ],
    );
  }

  //Build responsive date badge
  Widget _buildDateBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.primary10, context.primary20],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: context.primary20, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 12.w,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            _formatDate(widget.note.createdAt),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                ),
          ),
        ],
      ),
    );
  }

  //Build action buttons with responsive sizing
  Widget _buildActionButtons(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.7,
      duration: const Duration(milliseconds: 150),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.onEdit != null)
            _buildActionButton(
              icon: CupertinoIcons.pencil,
              onTap: widget.onEdit!,
              color: Theme.of(context).colorScheme.primary,
            ),
          if (widget.onEdit != null && widget.onDelete != null)
            SizedBox(width: 8.w),
          if (widget.onDelete != null)
            _buildActionButton(
              icon: CupertinoIcons.delete,
              onTap: widget.onDelete!,
              color: Theme.of(context).colorScheme.error,
            ),
        ],
      ),
    );
  }

  //Build responsive action button
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Icon(icon, size: 16.w, color: color),
        ),
      ),
    );
  }

  //Build note title with responsive typography
  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.note.title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
            fontSize: 18.sp,
          ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  //Build note message preview with responsive constraints
  Widget _buildMessage(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 60.h),
      child: Text(
        widget.note.message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.onSurface80,
              height: 1.6,
              fontSize: 14.sp,
            ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  //Build card footer with metadata
  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeIndicator(context),
        if (_isNoteEdited()) _buildEditIndicator(context),
      ],
    );
  }

  //Build time indicator with responsive styling
  Widget _buildTimeIndicator(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: context.primary30,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          _getTimeAgo(widget.note.createdAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.onSurface60,
                fontWeight: FontWeight.w500,
                fontSize: 11.sp,
              ),
        ),
      ],
    );
  }

  //Build edit indicator for modified notes
  Widget _buildEditIndicator(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.pencil,
            size: 10.w,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          SizedBox(width: 4.w),
          Text(
            'Edited',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  //Check if note was edited
  bool _isNoteEdited() {
    return widget.note.updatedAt
        .isAfter(widget.note.createdAt.add(const Duration(minutes: 1)));
  }

  //Format date for display with smart formatting
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) return 'Today';
    if (noteDate == yesterday) return 'Yesterday';
    if (now.difference(date).inDays < 7) return DateFormat('EEE').format(date);
    if (date.year == now.year) return DateFormat('MMM d').format(date);
    return DateFormat('MMM d, y').format(date);
  }

  //Get time ago string with smart formatting
  String _getTimeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 365)
      return '${(difference.inDays / 365).floor()}y ago';
    if (difference.inDays > 30)
      return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}

//Compact note card optimized for grid view with simplified structure
class CompactNoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isSelected;

  const CompactNoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.isSelected = false,
  });

  @override
  State<CompactNoteCard> createState() => _CompactNoteCardState();
}

class _CompactNoteCardState extends State<CompactNoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  //Initialize animations for compact card interactions
  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  //Handle hover state for compact card
  void _handleHover(bool isHovered) {
    if (!mounted) return;
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: _buildCompactCardDecoration(context),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onHover: _handleHover,
                borderRadius: context.responsiveBorderRadius,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCompactHeader(context),
                      SizedBox(height: 12.h),
                      _buildCompactContent(context),
                      SizedBox(height: 12.h),
                      _buildCompactFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  //Build compact card decoration with responsive styling
  BoxDecoration _buildCompactCardDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: widget.isSelected
          ? LinearGradient(
              colors: [context.primary10, context.primary20],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: context.responsiveBorderRadius,
      border: Border.all(
        color: widget.isSelected ? context.primary30 : context.outline10,
        width: widget.isSelected ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: _isHovered ? context.black10 : context.black05,
          blurRadius: _isHovered ? 12 : 6,
          offset: Offset(0, _isHovered ? 6 : 3),
        ),
      ],
    );
  }

  //Build compact header with title and actions
  Widget _buildCompactHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.note.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  fontSize: 16.sp,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.onDelete != null || widget.onEdit != null)
          _buildCompactActionMenu(context),
      ],
    );
  }

  //Build compact action menu with responsive options
  Widget _buildCompactActionMenu(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.6,
      duration: const Duration(milliseconds: 150),
      child: PopupMenuButton<String>(
        icon: Icon(
          CupertinoIcons.ellipsis_vertical,
          size: 16.w,
          color: context.onSurface60,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 8,
        itemBuilder: (context) => [
          if (widget.onEdit != null)
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.pencil,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.onDelete != null)
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.delete,
                    size: 16.w,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
        onSelected: (value) {
          switch (value) {
            case 'edit':
              widget.onEdit?.call();
              break;
            case 'delete':
              widget.onDelete?.call();
              break;
          }
        },
      ),
    );
  }

  //Build compact content area with responsive text
  Widget _buildCompactContent(BuildContext context) {
    return Expanded(
      child: Text(
        widget.note.message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.onSurface70,
              height: 1.5,
              letterSpacing: -0.1,
              fontSize: 13.sp,
            ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  //Build compact footer with time and edit indicator
  Widget _buildCompactFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: context.primary10,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _getCompactTimeAgo(widget.note.createdAt),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
          ),
        ),
        if (_isNoteEdited())
          Icon(
            CupertinoIcons.pencil,
            size: 12.w,
            color:
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
          ),
      ],
    );
  }

  //Check if note was edited
  bool _isNoteEdited() {
    return widget.note.updatedAt
        .isAfter(widget.note.createdAt.add(const Duration(minutes: 1)));
  }

  //Get compact time ago string for footer
  String _getCompactTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
