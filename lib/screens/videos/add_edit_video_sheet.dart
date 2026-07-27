import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../../models/video.dart';
import '../../services/firestore_service.dart';

/// A bottom sheet for adding a new video or editing/deleting an existing one.
///
/// When [existingVideo] is non-null, the sheet operates in edit mode with a
/// delete button. Otherwise it operates in add mode.
class AddEditVideoSheet extends StatefulWidget {
  final FirestoreService firestoreService;
  final Video? existingVideo;

  const AddEditVideoSheet({
    super.key,
    required this.firestoreService,
    this.existingVideo,
  });

  /// Shows this sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required FirestoreService firestoreService,
    Video? existingVideo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditVideoSheet(
        firestoreService: firestoreService,
        existingVideo: existingVideo,
      ),
    );
  }

  @override
  State<AddEditVideoSheet> createState() => _AddEditVideoSheetState();
}

class _AddEditVideoSheetState extends State<AddEditVideoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  bool _isSaving = false;

  bool get isEditing => widget.existingVideo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingVideo?.title ?? '',
    );
    _urlController = TextEditingController(
      text: widget.existingVideo != null
          ? 'https://youtube.com/watch?v=${widget.existingVideo!.youtubeId}'
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final youtubeId = Video.extractYoutubeId(_urlController.text.trim());
    if (youtubeId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.invalidYoutubeUrl)),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (isEditing) {
        await widget.firestoreService.updateVideo(
          id: widget.existingVideo!.id,
          title: _titleController.text.trim(),
          youtubeId: youtubeId,
        );
      } else {
        await widget.firestoreService.addVideo(
          title: _titleController.text.trim(),
          youtubeId: youtubeId,
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.failedToSave)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteVideoTitle),
        content: Text(AppStrings.deleteVideoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppStrings.back),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppStrings.deleteLabel,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.firestoreService.deleteVideo(widget.existingVideo!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomInset,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isEditing ? AppStrings.editVideo : AppStrings.addVideo,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),

            // Video title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppStrings.videoTitleLabel,
                hintText: AppStrings.videoTitleHint,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return AppStrings.pleaseEnterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // YouTube URL field
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: AppStrings.youtubeUrlLabel,
                hintText: AppStrings.youtubeUrlHint,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return AppStrings.pleaseEnterUrl;
                }
                if (Video.extractYoutubeId(v.trim()) == null) {
                  return AppStrings.invalidYoutubeUrl;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: Text(AppStrings.deleteLabel),
                    ),
                  ),
                if (isEditing) const SizedBox(width: 12),
                Expanded(
                  flex: isEditing ? 2 : 1,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isEditing
                                ? AppStrings.updateVideo
                                : AppStrings.addVideoLabel,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
