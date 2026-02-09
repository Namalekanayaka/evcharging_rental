import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/review_bloc.dart';
import '../../domain/entities/review_entities.dart';

/// Charger Reviews Page
/// Displays all reviews for a specific charger
class ChargerReviewsPage extends StatefulWidget {
  final int chargerId;
  final String chargerName;

  const ChargerReviewsPage({
    Key? key,
    required this.chargerId,
    required this.chargerName,
  }) : super(key: key);

  @override
  State<ChargerReviewsPage> createState() => _ChargerReviewsPageState();
}

class _ChargerReviewsPageState extends State<ChargerReviewsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(
          GetChargerReviewsEvent(widget.chargerId, limit: 20, offset: 0),
        );
    context.read<ReviewBloc>().add(
          GetReviewStatisticsEvent(widget.chargerId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews: ${widget.chargerName}'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics card
          BlocBuilder<ReviewBloc, ReviewState>(
            builder: (context, state) {
              if (state is ReviewStatisticsSuccessState) {
                final stats = state.statistics;
                return _buildStatisticsCard(stats);
              }
              return const SizedBox.shrink();
            },
          ),
          // Reviews list
          Expanded(
            child: BlocBuilder<ReviewBloc, ReviewState>(
              builder: (context, state) {
                if (state is ReviewLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChargerReviewsSuccessState) {
                  if (state.reviews.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No reviews yet'),
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
                    child: Text('Error: ${state.message}'),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(ReviewStatisticsEntity stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.averageRating.toStringAsFixed(1)} ⭐',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Reviews',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '${stats.totalReviews}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Cleanliness', stats.averageCleanliness),
                _buildStatItem('Safety', stats.averageSafety),
                _buildStatItem('Support', stats.averageSupport),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, ChargerReviewEntity review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (review.profilePicture != null)
                            CircleAvatar(
                              radius: 16,
                              backgroundImage:
                                  NetworkImage(review.profilePicture!),
                            )
                          else
                            const CircleAvatar(
                              radius: 16,
                              child: Icon(Icons.person, size: 16),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.userFullName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  review.createdAt.toString().split(' ')[0],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${review.rating.toStringAsFixed(1)} ⭐',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              review.reviewText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Chip(
                  label: Text('Helpful: ${review.isHelpfulCount}'),
                  onDeleted: () {
                    context
                        .read<ReviewBloc>()
                        .add(MarkReviewHelpfulEvent(review.id));
                  },
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('Unhelpful: ${review.isUnhelpfulCount}'),
                  onDeleted: () {
                    context
                        .read<ReviewBloc>()
                        .add(MarkReviewUnhelpfulEvent(review.id));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
