import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:job_task/ui/screen/post_screen.dart';
import 'package:job_task/ui/screen/share_experience_screen.dart';
import '../../utils/assets_path.dart';
import '../widgets/drawer_menu.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  static String name = 'airline-review-screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),

      drawer: DrawerMenu(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Button Row
              _buildButtonRow(context, width),
              const SizedBox(height: 16),
              // Search Box
              _buildSearchBoxTextField(),
              const SizedBox(height: 16),
              // Image Card
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AssetsPath.airport,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: width < 400 ? 150 : 200,
                ),
              ),

              // StreamBuilder for posts
              _buildStreamBuilderForPost()

            ],
          ),
        ),
      ),
    );
  }


  //===================================================
  //=====================Method area==============================
  //===================================================

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Airline Review'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        CircleAvatar(
          radius: 25,
          backgroundImage: (UserController.userData?.photoURL != null &&
              UserController.userData!.photoURL!.isNotEmpty)
              ? NetworkImage(UserController.userData!.photoURL!)
              : null,
          child: (UserController.userData?.photoURL == null ||
              UserController.userData!.photoURL!.isEmpty)
              ? Icon(Icons.person, size: 25)
              : null,
        ),
        const SizedBox(width: 12),
      ],
    );
  }


  // StreamBuilder for posts
  StreamBuilder<QuerySnapshot<Object?>> _buildStreamBuilderForPost() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shared_experiences')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            // Airport code extraction with null safety
            String departureCode = 'Unknown';
            if (data['departureAirport'] != null) {
              final match = RegExp(r'\(([A-Z]{3})\)')
                  .firstMatch(data['departureAirport'].toString());
              departureCode = match?.group(1) ?? 'Unknown';
            }

            String arrivalCode = 'Unknown';
            if (data['arrivalAirport'] != null) {
              final match = RegExp(r'\(([A-Z]{3})\)')
                  .firstMatch(data['arrivalAirport'].toString());
              arrivalCode = match?.group(1) ?? 'Unknown';
            }

            // Airline country extraction
            String airlineCountry = 'Unknown';
            if (data['airline'] != null) {
              final parts = data['airline'].split('\n');
              airlineCountry = parts.length > 1 ? parts.last : 'Unknown';
            }

            // Date parsing with error handling
            DateTime travelDate = DateTime.now();
            try {
              if (data['travelDate'] != null) {
                travelDate = DateTime.parse(data['travelDate'].toString());
              }
            } catch (e) {
              print('Error parsing date: $e');
            }

            // Image URLs handling
            /*  List<String> imageUrls = [];
                    if (data['imageUrls'] != null && data['imageUrls'] is List) {
                      imageUrls = List<String>.from(
                          data['imageUrls'].map((url) => url.toString()));
                    }*/

            return PostScreen(
              departureCode: departureCode,
              arrivalCode: arrivalCode,
              airlineCountry: airlineCountry,
              travelClass: data['travelClass']?.toString() ?? 'Unknown',
              travelDate: travelDate,
              rating: (data['rating'] ?? 0.0).toDouble(),
              message: data['message']?.toString() ?? '',
              postId: doc.id, imageFiles: [],
            );
          },
        );
      },
    );
  }


  // Search Box
  Widget _buildSearchBoxTextField() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black87,
        hintText: 'Search',
        hintStyle: const TextStyle(color: Colors.white),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }


  // Button Row
  Widget _buildButtonRow(BuildContext context, double width) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, ShareExperienceScreen.name);
            },
            icon: const Icon(Icons.share),
            label: Text(
              "Share Your Experience",
              style: TextStyle(fontSize: width * 0.035),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person),
            label: Text(
              "Ask A Question",
              style: TextStyle(fontSize: width * 0.035),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }


//===================================================
//=====================Method area End==============================
//===================================================


}

