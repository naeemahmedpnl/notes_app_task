import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notes_app/core/utils/app_snackbar.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/note_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notes_provider.dart';
import '../auth/login_screen.dart';
import 'widget/note_card.dart';
import 'widget/note_form.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _headerSlideAnimation;

  String _searchQuery = '';
  bool _isGridView = false;
  bool _showBackToTop = false;
  bool _hasInitializedStream = false;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AuthProvider _authProvider;
  late NotesProvider _notesProvider;
  VoidCallback? _authListener;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = context.read<AuthProvider>();
    _notesProvider = context.read<NotesProvider>();

    if (!_hasInitializedStream) {
      _initializeStreamsAndListeners();
      _hasInitializedStream = true;
    }
  }

  //Initialize data streams and authentication listener
  void _initializeStreamsAndListeners() {
    // Wait for auth to be ready, then initialize notes stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authProvider.currentUser != null) {
        // Force refresh to ensure clean state
        _notesProvider.refreshNotes(_authProvider.currentUser!.uid);
      }
    });

    _authListener = () {
      if (!_authProvider.isAuthenticated && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else if (_authProvider.isAuthenticated &&
          _authProvider.currentUser != null &&
          !_notesProvider.isStreamActive) {
        // If user is authenticated but stream is not active, initialize it
        _notesProvider.initializeNotesStream(_authProvider.currentUser!.uid);
      }
    };

    if (mounted) {
      _authProvider.addListener(_authListener!);
    }
  }

  //Initialize screen animations
  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: AppConstants.shortAnimationDuration,
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
          parent: _headerAnimationController, curve: Curves.easeOutCubic),
    );

    _headerAnimationController.forward();
    _fabAnimationController.forward();
  }

  //Setup scroll listener for back-to-top button
  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (_showBackToTop != showButton && mounted) {
        setState(() => _showBackToTop = showButton);
      }
    });
  }

  //Handle user logout
  Future<void> _handleLogout() async {
    try {
      _notesProvider.clearNotes();
      await _authProvider.signOut();
    } catch (e) {
      if (mounted) {
        context.showError('${AppConstants.genericErrorMessage}: $e');
      }
    }
  }

  //Show modal bottom sheet for forms
  Future<void> _showBottomSheet(Widget child) async {
    if (!mounted) return;

    try {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: context.overlayDark,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppConstants.extraLargeRadius.r),
              topRight: Radius.circular(AppConstants.extraLargeRadius.r),
            ),
          ),
          child: child,
        ),
      );
    } catch (e) {
      if (mounted) {
        context.showError('Error opening form: $e');
      }
    }
  }

  //Show add note form
  Future<void> _showAddNoteForm() => _showBottomSheet(const NoteForm());

  //Show edit note form
  Future<void> _showEditNoteForm(NoteModel note) =>
      _showBottomSheet(NoteForm(note: note));

  //Handle note deletion
  Future<void> _handleDeleteNote(NoteModel note) async {
    if (!mounted || _authProvider.currentUser == null) return;

    try {
      await _notesProvider.deleteNote(
        noteId: note.id,
        userId: _authProvider.currentUser!.uid,
      );

      if (mounted && _notesProvider.errorMessage == null) {
        context.showSuccess(AppConstants.noteDeletedMessage);
      }
    } catch (e) {
      if (mounted) {
        context.showError('Error deleting note: $e');
      }
    }
  }

  //Show confirmation dialog
  void _showConfirmationDialog({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    required VoidCallback onConfirm,
    required String confirmText,
    required Color confirmColor,
  }) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeRadius.r),
        ),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: context.responsiveIconSize),
            SizedBox(width: AppConstants.smallPadding.w),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(content, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppConstants.cancelLabel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  //Show logout confirmation
  void _showLogoutDialog() {
    _showConfirmationDialog(
      title: AppConstants.confirmLogoutTitle,
      icon: CupertinoIcons.arrow_right_square,
      iconColor: Theme.of(context).colorScheme.error,
      content: 'Are you sure you want to logout?',
      onConfirm: _handleLogout,
      confirmText: AppConstants.logoutLabel,
      confirmColor: Theme.of(context).colorScheme.error,
    );
  }

  //Show delete confirmation
  void _showDeleteDialog(NoteModel note) {
    _showConfirmationDialog(
      title: AppConstants.confirmDeleteTitle,
      icon: CupertinoIcons.delete,
      iconColor: Theme.of(context).colorScheme.error,
      content:
          'Are you sure you want to delete "${note.title}"? This action cannot be undone.',
      onConfirm: () => _handleDeleteNote(note),
      confirmText: AppConstants.deleteLabel,
      confirmColor: Theme.of(context).colorScheme.error,
    );
  }

  //Filter notes based on search query
  List<NoteModel> _filterNotes(List<NoteModel> notes) {
    if (_searchQuery.isEmpty) return notes;
    return notes
        .where((note) =>
            note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.message.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  //Scroll to top
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic);
  }

  //Get time-based greeting
  Map<String, dynamic> _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12)
      return {'text': 'Morning Star', 'icon': CupertinoIcons.sun_max};
    if (hour >= 12 && hour < 17)
      return {'text': 'Afternoon Glow', 'icon': CupertinoIcons.sun_max_fill};
    if (hour >= 17 && hour < 22)
      return {'text': 'Evening Spark', 'icon': CupertinoIcons.moon};
    return {'text': 'Night Owl', 'icon': CupertinoIcons.moon_fill};
  }

  @override
  void dispose() {
    if (_authListener != null) {
      try {
        _authProvider.removeListener(_authListener!);
      } catch (e) {
        debugPrint('Error removing auth listener: $e');
      }
    }
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildResponsiveAppBar(),
              SliverFillRemaining(
                hasScrollBody: true,
                child: ResponsiveWidget(
                  mobile: _buildLayout(constraints, crossAxisCount: 2),
                  tablet: _buildLayout(constraints,
                      crossAxisCount: 3, addPadding: true),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  //Build responsive app bar
  Widget _buildResponsiveAppBar() {
    return SliverAppBar(
      expandedHeight: ResponsiveHelper.getResponsiveValue(context,
          mobile: 140.h, tablet: 160.h),
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SlideTransition(
          position: _headerSlideAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primary10,
                  Theme.of(context).scaffoldBackgroundColor
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: context.responsivePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    SizedBox(height: context.responsiveSpacing),
                    _buildSearchAndViewToggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [_buildUserMenu()],
    );
  }

  //Build greeting section
  Widget _buildGreeting() {
    final greeting = _getGreeting();

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final firstName =
            authProvider.currentUser?.displayName?.split(' ').first ?? 'User';

        return Row(
          children: [
            Icon(
              greeting['icon'],
              color: Theme.of(context).colorScheme.primary,
              size: context.responsiveIconSize,
            ),
            SizedBox(width: context.responsiveSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${greeting['text']}, $firstName',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: context.onSurface70,
                          fontWeight: FontWeight.w500,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: AppConstants.mediumFontSize,
                            tablet: AppConstants.largeFontSize,
                          ),
                        ),
                  ),
                  Text(
                    authProvider.currentUser?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: AppConstants.titleFontSize,
                            tablet: AppConstants.headingFontSize,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  //Build search and view toggle
  Widget _buildSearchAndViewToggle() {
    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        SizedBox(width: context.responsiveSpacing),
        _buildViewToggleButton(),
      ],
    );
  }

  //Build search field
  Widget _buildSearchField() {
    return Container(
      height: ResponsiveHelper.getResponsiveValue(context,
          mobile: 48.h, tablet: 56.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: context.responsiveBorderRadius,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        textAlignVertical: TextAlignVertical.center,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: AppConstants.searchHint,
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: context.onSurface50),
          prefixIcon: Icon(CupertinoIcons.search,
              color: context.onSurface50, size: context.responsiveIconSize),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(CupertinoIcons.xmark_circle_fill,
                      size: context.responsiveIconSize),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: false,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppConstants.mediumPadding.w,
            vertical: AppConstants.smallPadding.h,
          ),
        ),
      ),
    );
  }

  //Build view toggle button
  Widget _buildViewToggleButton() {
    return Container(
      width: ResponsiveHelper.getResponsiveValue(context,
          mobile: 48.w, tablet: 56.w),
      height: ResponsiveHelper.getResponsiveValue(context,
          mobile: 48.h, tablet: 56.h),
      decoration: BoxDecoration(
        color: _isGridView
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: context.responsiveBorderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isGridView = !_isGridView),
          borderRadius: context.responsiveBorderRadius,
          child: Icon(
            _isGridView
                ? CupertinoIcons.list_bullet
                : CupertinoIcons.square_grid_2x2,
            color: _isGridView ? Colors.white : context.onSurface70,
            size: context.responsiveIconSize,
          ),
        ),
      ),
    );
  }

  //Build user menu
  Widget _buildUserMenu() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final firstName =
            authProvider.currentUser?.displayName?.split(' ').first ?? 'U';

        return Container(
          margin: EdgeInsets.only(right: AppConstants.mediumPadding.w),
          child: PopupMenuButton<String>(
            icon: Container(
              width: ResponsiveHelper.getResponsiveValue(context,
                  mobile: 36.w, tablet: 40.w),
              height: ResponsiveHelper.getResponsiveValue(context,
                  mobile: 36.w, tablet: 40.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryGradient),
                borderRadius: BorderRadius.circular(AppConstants.smallRadius.r),
              ),
              child: Center(
                child: Text(
                  firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: AppConstants.mediumFontSize,
                      tablet: AppConstants.largeFontSize,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _showProfileDialog();
                  break;
                case 'logout':
                  _showLogoutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.person,
                        size: context.responsiveIconSize),
                    SizedBox(width: AppConstants.smallPadding.w),
                    Text(AppConstants.profileTitle),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(CupertinoIcons.arrow_right_square,
                        size: context.responsiveIconSize,
                        color: Theme.of(context).colorScheme.error),
                    SizedBox(width: AppConstants.smallPadding.w),
                    Text(AppConstants.logoutLabel),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //Build unified layout for mobile/tablet
  Widget _buildLayout(BoxConstraints constraints,
      {required int crossAxisCount, bool addPadding = false}) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      child: IntrinsicHeight(
        child: Padding(
          padding: addPadding
              ? EdgeInsets.symmetric(horizontal: AppConstants.mediumPadding.w)
              : EdgeInsets.zero,
          child: _buildNotesContent(crossAxisCount: crossAxisCount),
        ),
      ),
    );
  }

  //Build notes content with states
  Widget _buildNotesContent({required int crossAxisCount}) {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        if (notesProvider.isLoading && notesProvider.notes.isEmpty) {
          return SizedBox(
              height: 400.h,
              child: const Center(child: CircularProgressIndicator()));
        }

        if (notesProvider.errorMessage != null) {
          return _buildErrorState(notesProvider.errorMessage!);
        }

        final filteredNotes = _filterNotes(notesProvider.notes);

        if (filteredNotes.isEmpty) {
          return _searchQuery.isNotEmpty
              ? _buildSearchEmptyState()
              : _buildNoNotesState();
        }

        return _isGridView
            ? _buildNotesGrid(filteredNotes, crossAxisCount)
            : _buildNotesList(filteredNotes);
      },
    );
  }

  //Build notes list
  Widget _buildNotesList(List<NoteModel> notes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.responsivePadding.left,
        AppConstants.mediumPadding.h,
        context.responsivePadding.right,
        100.h,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return ModernNoteCard(
          note: note,
          onTap: () => _showEditNoteForm(note),
          onEdit: () => _showEditNoteForm(note),
          onDelete: () => _showDeleteDialog(note),
        );
      },
    );
  }

  //Build notes grid
  Widget _buildNotesGrid(List<NoteModel> notes, int crossAxisCount) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.responsivePadding.left,
        AppConstants.mediumPadding.h,
        context.responsivePadding.right,
        100.h,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: ResponsiveHelper.getResponsiveValue(
          context,
          mobile: AppConstants.smallPadding.w,
          tablet: AppConstants.mediumPadding.w,
        ),
        mainAxisSpacing: ResponsiveHelper.getResponsiveValue(
          context,
          mobile: AppConstants.smallPadding.h,
          tablet: AppConstants.mediumPadding.h,
        ),
        childAspectRatio: (MediaQuery.of(context).size.width -
                ((crossAxisCount - 1) *
                    ResponsiveHelper.getResponsiveValue(
                      context,
                      mobile: AppConstants.smallPadding.w,
                      tablet: AppConstants.mediumPadding.w,
                    )) -
                context.responsivePadding.left -
                context.responsivePadding.right) /
            (crossAxisCount * 150.h),
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return CompactNoteCard(
          note: note,
          onTap: () => _showEditNoteForm(note),
          onEdit: () => _showEditNoteForm(note),
          onDelete: () => _showDeleteDialog(note),
        );
      },
    );
  }

  //Build error state
  Widget _buildErrorState(String errorMessage) {
    final isOfflineError = errorMessage.toLowerCase().contains('internet') ||
        errorMessage.toLowerCase().contains('connection') ||
        errorMessage.toLowerCase().contains('network') ||
        errorMessage.toLowerCase().contains('offline');

    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: isOfflineError
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : context.error10,
                borderRadius: BorderRadius.circular(AppConstants.largeRadius.r),
              ),
              child: Icon(
                isOfflineError
                    ? CupertinoIcons.wifi_slash
                    : CupertinoIcons.exclamationmark_circle,
                size: 40.w,
                color: isOfflineError
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
            ),
            SizedBox(height: AppConstants.extraLargePadding.h),
            Text(
              isOfflineError
                  ? 'No Internet Connection'
                  : 'Something went wrong',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: AppConstants.smallPadding.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                errorMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.onSurface70),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppConstants.extraLargePadding.h),
            ElevatedButton.icon(
              onPressed: () {
                if (_authProvider.currentUser != null) {
                  _notesProvider.refreshNotes(_authProvider.currentUser!.uid);
                }
              },
              icon: const Icon(CupertinoIcons.arrow_clockwise),
              label: Text(AppConstants.retryLabel),
            ),
          ],
        ),
      ),
    );
  }

  //Build search empty state
  Widget _buildSearchEmptyState() {
    return SizedBox(
      height: 400.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.surfaceGradient),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Icon(CupertinoIcons.search,
                  size: 48.w, color: context.onSurface50),
            ),
            SizedBox(height: AppConstants.extraLargePadding.h),
            Text(AppConstants.noSearchResultsMessage,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            SizedBox(height: AppConstants.smallPadding.h),
            Text(AppConstants.noSearchResultsDescription,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.onSurface70),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  //Build no notes state
  Widget _buildNoNotesState() {
    return SizedBox(
      height: 500.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.cardGradient),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Icon(CupertinoIcons.doc_text,
                  size: 60.w, color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 40.h),
            Text('Your canvas awaits',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800, letterSpacing: -0.8)),
            SizedBox(height: AppConstants.mediumPadding.h),
            Text(AppConstants.noNotesDescription,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: context.onSurface70, height: 1.6),
                textAlign: TextAlign.center),
            SizedBox(height: 40.h),
            ElevatedButton.icon(
              onPressed: _showAddNoteForm,
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Create First Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.extraLargePadding.w,
                  vertical: AppConstants.mediumPadding.h,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.mediumRadius.r)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Build floating action buttons
  Widget _buildFloatingActionButtons() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showBackToTop)
            ScaleTransition(
              scale: _fabScaleAnimation,
              child: Container(
                margin: EdgeInsets.only(bottom: AppConstants.mediumPadding.h),
                child: FloatingActionButton.small(
                  onPressed: _scrollToTop,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  heroTag: "backToTop",
                  child: const Icon(CupertinoIcons.arrow_up),
                ),
              ),
            ),
          ScaleTransition(
            scale: _fabScaleAnimation,
            child: Consumer<NotesProvider>(
              builder: (context, notesProvider, child) {
                return SizedBox(
                  width: 56.0,
                  height: 56.0,
                  child: FloatingActionButton(
                    onPressed: notesProvider.isLoading ? null : _showAddNoteForm,
                    backgroundColor: notesProvider.isLoading
                        ? context.primary70
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    heroTag: "addNote",
                    elevation: notesProvider.isLoading
                        ? AppConstants.lowElevation
                        : AppConstants.highElevation,
                    shape: const CircleBorder(),
                    child: AnimatedSwitcher(
                      duration: AppConstants.shortAnimationDuration,
                      child: notesProvider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(CupertinoIcons.add,
                              size: AppConstants.extraLargeIconSize),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //Show profile dialog
  void _showProfileDialog() {
    if (!mounted) return;

    final userName = _authProvider.currentUser?.displayName ?? 'User';
    final firstName = userName.split(' ').first;
    final userEmail = _authProvider.currentUser?.email ?? '';
    final greeting = _getGreeting();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320.w,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius:
                BorderRadius.circular(AppConstants.extraLargeRadius.r),
            boxShadow: [
              BoxShadow(
                  color: context.shadowMedium,
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppConstants.extraLargePadding.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.extraLargeRadius.r),
                    topRight: Radius.circular(AppConstants.extraLargeRadius.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: context.white20,
                        borderRadius:
                            BorderRadius.circular(AppConstants.largeRadius.r),
                        border: Border.all(color: context.white30, width: 2),
                        boxShadow: [
                          BoxShadow(
                              color: context.black10,
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Center(
                        child: Text(
                          firstName.isNotEmpty
                              ? firstName[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppConstants.mediumPadding.h),
                    Text(
                      '${greeting['text']}, $firstName',
                      style: TextStyle(
                        color: context.white90,
                        fontSize: AppConstants.largeFontSize.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Profile content
              Padding(
                padding: EdgeInsets.all(AppConstants.extraLargePadding.w),
                child: Column(
                  children: [
                    _buildProfileInfo(
                      context,
                      icon: CupertinoIcons.mail,
                      label: AppConstants.emailLabel,
                      value: userEmail,
                    ),
                    SizedBox(height: AppConstants.smallPadding.h),
                    _buildProfileInfo(
                      context,
                      icon: CupertinoIcons.doc_text,
                      label: 'Total Notes',
                      value: _notesProvider.notesCount.toString(),
                    ),
                    SizedBox(height: AppConstants.smallPadding.h),
                    _buildProfileInfo(
                      context,
                      icon: CupertinoIcons.clock,
                      label: 'Member Since',
                      value: 'Today',
                    ),
                    SizedBox(height: AppConstants.extraLargePadding.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: AppConstants.mediumPadding.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.smallRadius.r)),
                        ),
                        child: Text(
                          AppConstants.closeLabel,
                          style: TextStyle(
                            fontSize: AppConstants.largeFontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Build profile info row
  Widget _buildProfileInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.mediumPadding.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.smallRadius.r),
        border: Border.all(color: context.outline10),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: context.primary10,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: AppConstants.mediumIconSize.w,
            ),
          ),
          SizedBox(width: AppConstants.mediumPadding.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.onSurface60,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
