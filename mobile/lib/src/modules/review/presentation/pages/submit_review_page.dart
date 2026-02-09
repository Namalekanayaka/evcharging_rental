import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/review_bloc.dart';

/// Submit Review Page
/// Allows users to submit reviews for chargers
class SubmitReviewPage extends StatefulWidget {
  final int chargerId;
  final String chargerName;

  const SubmitReviewPage({
    Key? key,
    required this.chargerId,
    required this.chargerName,
  }) : super(key: key);

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 5.0;
  double _cleanliness = 5.0;
  double _safety = 5.0;
  double _support = 5.0;
  late TextEditingController _titleController;
  late TextEditingController _reviewController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _reviewController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review: ${widget.chargerName}'),
        elevation: 0,
      ),
      body: BlocListener<ReviewBloc, ReviewState>(
        listener: (context, state) {
          if (state is ReviewSubmittedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Review submitted successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is ReviewErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Rating
                _buildRatingSection('Overall Rating', _rating, (value) {
                  setState(() => _rating = value);
                }),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Review Title',
                    hintText: 'Summarize your experience',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Title is required';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Review Text
                TextFormField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    labelText: 'Your Review',
                    hintText: 'Share details about your experience',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Review is required';
                    if (value!.length < 10) {
                      return 'Review must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Additional ratings
                Text(
                  'Rate specific aspects:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                _buildRatingSection('Cleanliness', _cleanliness, (value) {
                  setState(() => _cleanliness = value);
                }),
                const SizedBox(height: 16),

                _buildRatingSection('Safety', _safety, (value) {
                  setState(() => _safety = value);
                }),
                const SizedBox(height: 16),

                _buildRatingSection('Support Quality', _support, (value) {
                  setState(() => _support = value);
                }),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isSubmitting = true);
                              context.read<ReviewBloc>().add(
                                    SubmitReviewEvent(
                                      widget.chargerId,
                                      _rating,
                                      _titleController.text,
                                      _reviewController.text,
                                      cleanliness: _cleanliness,
                                      safety: _safety,
                                      supportRating: _support,
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Review'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(
      String label, double rating, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${rating.toStringAsFixed(1)} ⭐',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: rating,
          min: 0,
          max: 5,
          divisions: 5,
          onChanged: onChanged,
          label: rating.toStringAsFixed(1),
        ),
      ],
    );
  }
}
