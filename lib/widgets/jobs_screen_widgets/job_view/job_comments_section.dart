import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/models/jobs_screen_models/job_comment_model.dart';
import 'package:job_seeker/providers/auth_provider.dart';
import 'package:job_seeker/providers/jobs_screen_providers/job_comments_provider.dart';

class JobCommentsSection extends ConsumerStatefulWidget {
  final int jobId;
  final int jobPosterId;

  const JobCommentsSection({
    super.key,
    required this.jobId,
    required this.jobPosterId,
  });

  @override
  ConsumerState<JobCommentsSection> createState() => _JobCommentsSectionState();
}

class _JobCommentsSectionState extends ConsumerState<JobCommentsSection> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(jobCommentsNotifierProvider.notifier).loadComments(widget.jobId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(jobCommentsNotifierProvider.notifier)
          .addComment(widget.jobId, comment);
      _commentController.clear();
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteComment(int commentId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteComment),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(jobCommentsNotifierProvider.notifier)
          .deleteComment(widget.jobId, commentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(jobCommentsNotifierProvider);
    final userId = ref.watch(authProvider).userId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userId != null)
          _CommentInput(
            controller: _commentController,
            isSubmitting: _isSubmitting,
            onSubmit: _submitComment,
          ),
        const SizedBox(height: 24),
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) return const _EmptyComments();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _CommentCard(
                  comment: comment,
                  isOwner: userId == comment.userId,
                  isJobPoster: userId == widget.jobPosterId,
                  onDelete: userId == comment.userId
                      ? () => _deleteComment(comment.id)
                      : null,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ],
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _CommentInput({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Ask a question about this job...',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF4E60FF)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: isSubmitting ? null : onSubmit,
          icon: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF4E60FF),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.question_answer_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noQuestionsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to ask a question!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final JobComment comment;
  final bool isOwner;
  final bool isJobPoster;
  final VoidCallback? onDelete;

  const _CommentCard({
    required this.comment,
    required this.isOwner,
    required this.isJobPoster,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF4E60FF).withValues(alpha: 0.1),
                child: Text(
                  comment.userName.isNotEmpty
                      ? comment.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF4E60FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner && onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: onDelete,
                  iconSize: 20,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.comment,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: comment.replies.map((reply) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${reply.userName} (Employer)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                reply.comment,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
