import 'package:flutter/material.dart';
import 'package:sayf/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart'; 

class ReviewPage extends StatefulWidget {
  final String productId;
  const ReviewPage({super.key, required this.productId});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _controller = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    final response = await supabase
        .from('review')
        .select('id, comment, created_at, user_id, users(name, image)')
        .eq('product_id', widget.productId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addReview() async {
    final user = supabase.auth.currentUser;
    if (user == null || _controller.text.trim().isEmpty) return;

    await supabase.from('review').insert({
      'product_id': widget.productId,
      'user_id': user.id,
      'comment': _controller.text.trim(),
    });

    _controller.clear();
    setState(() {});
  }

  Future<void> deleteReview(String reviewId) async {
    await supabase.from('review').delete().eq('id', reviewId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KprimaryColor,
        title: Text(
          "Comments",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchReviews(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reviews = snapshot.data!;
                if (reviews.isEmpty) {
                  return Center(
                    child: Text(
                      "No reviews for this product.",
                      style: GoogleFonts.poppins(fontSize: 17),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final userInfo = review['users'] ?? {};
                    final name = userInfo['name'] ?? 'Inconnu';
                    final image = userInfo['image'];
                    final date = DateFormat(
                      "dd MMMM yyyy 'à' HH:mm",
                    ).format(DateTime.parse(review['created_at']));

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            image != null
                                ? NetworkImage(image)
                                : const AssetImage('assets/avatar.jpg')
                                    as ImageProvider,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(review['comment']),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      trailing:
                          review['user_id'] == user?.id
                              ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteReview(review['id']),
                              )
                              : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: addReview),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
