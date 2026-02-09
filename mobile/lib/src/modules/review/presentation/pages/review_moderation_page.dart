import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/review_bloc.dart';
import '../../domain/entities/review_entities.dart';

/// Review Moderation Page
/// Admin page for reviewing and moderating pending reviews
class ReviewModerationPage extends StatefulWidget {
  const ReviewModerationPage({Key? key}) : super(key: key);

  @override
  State<ReviewModerationPage> createState() => _ReviewModerationPageState();
}

class _ReviewModerationPageState extends State<ReviewModerationPage> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    context
        .read<ReviewBloc>()
        .add(const GetPendingReviewsEvent(limit: 20, offset: 0));
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Moderation'),
        elevation: 0,
      ),
      body: BlocBuilder<ReviewBloc, ReviewState>(
        builder: (context, state) {
          if (state is ReviewLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PendingReviewsSuccessState) {
            if (state.reviews.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.done_all, size: 48, color: Colors.green),
                    SizedBox(height: 16),
                    Text('All reviews are moderated!'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: state.reviews.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                return _buildReviewCard(context, state.reviews[index]);
              },
            );
          }

          if (state is ReviewErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, PendingReviewEntity review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with charger and user info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Charger: ${review.chargerName}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reviewer: ${review.firstName} ${review.lastName}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Rating
            Row(
              children: [
                Text(
                  '${review.rating.toStringAsFixed(1)} ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: List.generate(5, (i) {
                    return Icon(
                      i < review.rating.toInt()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Review title and text
            Text(
              review.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              review.reviewText,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showApproveDialog(context, review);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRejectDialog(context, review);
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
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

  void _showApproveDialog(BuildContext context, PendingReviewEntity review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Review'),
        content: Text(
          'Are you sure you want to approve this review from ${review.firstName} ${review.lastName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReviewBloc>().add(
                    ModerateReviewEvent(review.id, true),
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review approved successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, PendingReviewEntity review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject this review from ${review.firstName} ${review.lastName}?',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _rejectionReasonController,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _rejectionReasonController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReviewBloc>().add(
                    ModerateReviewEvent(
                      review.id,
                      false,
                      reason: _rejectionReasonController.text.isNotEmpty
                          ? _rejectionReasonController.text
                          : null,
                    ),
                  );
              _rejectionReasonController.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review rejected successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
