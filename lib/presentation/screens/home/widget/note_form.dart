import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../data/models/note_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notes_provider.dart';

//Note form widget optimized for creating and editing notes
class NoteForm extends StatefulWidget {
  final NoteModel? note;

  const NoteForm({super.key, this.note});

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  // Form controllers and focus nodes
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _messageFocusNode = FocusNode();

  // State management
  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupTextControllerListeners();
  }

  //Initialize form with existing note data if editing
  void _initializeForm() {
    if (_isEditing) {
      _titleController.text = widget.note!.title;
      _messageController.text = widget.note!.message;
    }
  }

  //Setup text controller listeners for real-time updates
  void _setupTextControllerListeners() {
    _messageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  //Handle form submission with proper validation and error handling
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      _showMessage('Please fix validation errors', isError: true);
      log('[_handleSubmit] Validation failed');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final notesProvider = context.read<NotesProvider>();

    if (authProvider.currentUser == null) {
      _showMessage('User not authenticated', isError: true);
      log('[_handleSubmit] User not authenticated');
      return;
    }

    // Don't manually set loading state - let NotesProvider handle it
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final userId = authProvider.currentUser!.uid;

    log('[_handleSubmit] Attempting to ${_isEditing ? "update" : "create"} note - Title: $title, UserId: $userId');

    try {
      bool success = false;

      if (_isEditing) {
        success = await notesProvider.updateNote(
          noteId: widget.note!.id,
          title: title,
          message: message,
          userId: userId,
        );
        if (success) {
          _showMessage('Note updated successfully');
        }
      } else {
        success = await notesProvider.addNote(
          title: title,
          message: message,
          userId: userId,
        );
        if (success) {
          _showMessage('Note created successfully');
        }
      }

      // Only pop if operation was successful and no error occurred
      if (mounted && success && notesProvider.errorMessage == null) {
        Navigator.of(context).pop();
      } else if (notesProvider.errorMessage != null) {
        _showMessage(notesProvider.errorMessage!, isError: true);
      }
    } catch (e) {
      _showMessage('Failed to save note: ${e.toString()}', isError: true);
      log('[_handleSubmit] Error: ${e.toString()}');
    }

    log('[_handleSubmit] Operation completed');
  }

  //Show success or error message to user
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  //Handle discard changes with confirmation if needed
  void _handleDiscard() {
    final hasChanges = _titleController.text.trim().isNotEmpty ||
        _messageController.text.trim().isNotEmpty;

    if (hasChanges) {
      _showDiscardDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  //Show discard changes confirmation dialog
  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close form
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _titleFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildForm()),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  //Build form header with title and controls
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          const Spacer(),
          // Title
          Text(
            _isEditing ? 'Edit Note' : 'New Note',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          // Close button
          IconButton(
            onPressed: _handleDiscard,
            icon: const Icon(CupertinoIcons.xmark),
            iconSize: 24.w,
          ),
        ],
      ),
    );
  }

  //Build form content with input fields
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 16.h),

            // Title field
            CustomTextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              labelText: 'Title',
              hintText: 'Enter note title...',
              prefixIcon: CupertinoIcons.textformat,
              textInputAction: TextInputAction.next,
              validator: Validators.validateNoteTitle,
              onFieldSubmitted: (_) => _messageFocusNode.requestFocus(),
              autofocus: !_isEditing,
            ),

            SizedBox(height: 20.h),

            // Message field
            CustomTextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              labelText: 'Message',
              hintText: 'Write your note here...',
              prefixIcon: CupertinoIcons.doc_text,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              validator: Validators.validateNoteMessage,
              textCapitalization: TextCapitalization.sentences,
            ),

            SizedBox(height: 24.h),

            // Character count display
            if (_messageController.text.isNotEmpty) _buildCharacterCount(),
          ],
        ),
      ),
    );
  }

  //Build character count indicator
  Widget _buildCharacterCount() {
    final count = _messageController.text.length;
    final isOverLimit = count > 900;

    return Text(
      '$count/1000 characters',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isOverLimit
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
      textAlign: TextAlign.end,
    );
  }

  //Build action buttons with responsive layout
  Widget _buildActionButtons() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: keyboardHeight > 0 ? keyboardHeight + 16.h : 16.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Selector<NotesProvider, bool>(
          selector: (context, notesProvider) => notesProvider.isLoading,
          builder: (context, isLoading, child) {
            return ResponsiveWidget(
              mobile: _buildMobileButtons(isLoading),
              tablet: _buildTabletButtons(isLoading),
            );
          },
        ),
      ),
    );
  }

  //Build mobile action buttons layout
  Widget _buildMobileButtons(bool isLoading) {
    return Column(
      children: [
        // Primary Save/Update Button using AppButtons
        AppButtons.primary(
          text: _isEditing ? 'Update Note' : 'Save Note',
          onPressed: _handleSubmit,
          loading: isLoading,
          icon: _isEditing ? CupertinoIcons.arrow_clockwise : CupertinoIcons.check_mark,
          showIcon: true,
        ),

        SizedBox(height: 12.h),

        // Secondary Discard Button using AppButtons
        AppButtons.secondary(
          text: 'Discard',
          onPressed: isLoading ? null : _handleDiscard,
          icon: CupertinoIcons.xmark,
          loading: false,
          showIcon: true,
        ),
      ],
    );
  }

  //Build tablet action buttons layout
  Widget _buildTabletButtons(bool isLoading) {
    return Row(
      children: [
        // Discard Button
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: AppButtons.secondary(
              text: 'Discard',
              onPressed: isLoading ? null : _handleDiscard,
              icon: CupertinoIcons.xmark,
              loading: false,
              showIcon: true,
            ),
          ),
        ),

        SizedBox(width: 16.w),

        // Save/Update Button (2x wider)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 52.h,
            child: AppButtons.primary(
              text: _isEditing ? 'Update Note' : 'Save Note',
              onPressed: _handleSubmit,
              loading: isLoading,
              icon: _isEditing ? CupertinoIcons.arrow_clockwise : CupertinoIcons.check_mark,
              showIcon: true,
            ),
          ),
        ),
      ],
    );
  }
}
