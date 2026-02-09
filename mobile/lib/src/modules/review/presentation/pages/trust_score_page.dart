import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/review_bloc.dart';
import '../../domain/entities/review_entities.dart';

/// Trust Score Page
/// Displays user's trust score and related statistics
class TrustScorePage extends StatefulWidget {
  const TrustScorePage({Key? key}) : super(key: key);

  @override
  State<TrustScorePage> createState() => _TrustScorePageState();
}

class _TrustScorePageState extends State<TrustScorePage> {
  @override
  void initState() {
    super.initState();
    context.read<ReviewBloc>().add(const GetUserTrustScoreEvent());
    context
        .read<ReviewBloc>()
        .add(const GetUserReviewsEvent(limit: 10, offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Trust Score'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoadingState) {
              return const SizedBox(
                height: 400,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is TrustScoreSuccessState) {
              return _buildContent(context, state.trustScore);
            }

            if (state is ReviewErrorState) {
              return SizedBox(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}'),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TrustScoreEntity trustScore) {
    return Column(
      children: [
        // Trust Score Circle
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: trustScore.trustScore / 100,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getTrustScoreColor(trustScore.trustScore),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        trustScore.trustScore.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trustScore.trustLevel,
                        style: TextStyle(
                          fontSize: 18,
                          color: _getTrustScoreColor(trustScore.trustScore),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _getTrustScoreDescription(trustScore.trustScore),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        // Statistics Card
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatRow(
                  'Total Reviews',
                  '${trustScore.totalReviews}',
                  Icons.rate_review_outlined,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Approved Reviews',
                  '${trustScore.totalReviews - trustScore.rejectedReviews}',
                  Icons.check_circle_outline,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Rejected Reviews',
                  '${trustScore.rejectedReviews}',
                  Icons.cancel_outlined,
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  'Helpfulness Rating',
                  '${trustScore.helpfulnessRating.toStringAsFixed(1)}%',
                  Icons.thumb_up_outlined,
                ),
              ],
            ),
          ),
        ),
        // Recent Reviews Section
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Recent Reviews',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              BlocBuilder<ReviewBloc, ReviewState>(
                builder: (context, state) {
                  if (state is UserReviewsSuccessState) {
                    if (state.reviews.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.create_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No reviews yet',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.reviews.length,
                      itemBuilder: (context, index) {
                        final review = state.reviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${review.rating.toStringAsFixed(1)} ⭐',
                                      style:
                                          const TextStyle(color: Colors.amber),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  review.reviewText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Color _getTrustScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getTrustScoreDescription(double score) {
    if (score >= 80) {
      return 'Excellent! You are a trusted member of the community.';
    } else if (score >= 60) {
      return 'Good trust score. Write quality reviews to improve it.';
    } else if (score >= 40) {
      return 'Your trust score could be better. Provide helpful reviews.';
    } else {
      return 'Improve your trust score by submitting quality reviews.';
    }
  }
}
