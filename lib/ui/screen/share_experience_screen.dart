import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:job_task/ui/screen/post_screen.dart';
import 'package:month_year_picker/month_year_picker.dart';
import '../widgets/searchable_dropdown_widget.dart';

class ShareExperienceScreen extends StatefulWidget {
  const ShareExperienceScreen({super.key});

  static String name = 'share-experience-screen';

  @override
  State<ShareExperienceScreen> createState() => _ShareExperienceScreenState();
}

class _ShareExperienceScreenState extends State<ShareExperienceScreen> {
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();


  String? _departureAirport;
  String? _arrivalAirport;
  String? _airline;
  String? _travelClass;
  String? _message;
  DateTime? _travelDate;
  double _rating = 1.0;

  final List<Map<String, String>> _airports = [
    {"code": "DAC", "name": "Hazrat Shahjalal International Airport", "city": "Dhaka, Bangladesh"},
    {"code": "CGP", "name": "Shah Amanat International Airport", "city": "Chattogram, Bangladesh"},
    {"code": "ZYL", "name": "Osmani International Airport", "city": "Sylhet, Bangladesh"},
    {"code": "CXB", "name": "Cox's Bazar International Airport", "city": "Cox's Bazar, Bangladesh"},
    {"code": "SPD", "name": "Saidpur Airport", "city": "Saidpur, Bangladesh"},
    {"code": "JSR", "name": "Jessore Airport", "city": "Jessore, Bangladesh"},
    {"code": "RJH", "name": "Shah Makhdum Airport", "city": "Rajshahi, Bangladesh"},
    {"code": "BZL", "name": "Barisal Airport", "city": "Barisal, Bangladesh"},
  ];

  final List<Map<String, String>> _airlines = [
    {"name": "Biman Bangladesh Airlines", "code": "BG", "country": "Bangladesh"},
    {"name": "US-Bangla Airlines", "code": "BS", "country": "Bangladesh"},
    {"name": "Novoair", "code": "VQ", "country": "Bangladesh"},
    {"name": "Air Astra", "code": "2A", "country": "Bangladesh"},
    {"name": "Singapore Airlines", "code": "SQ", "country": "Singapore"},
    {"name": "Emirates", "code": "EK", "country": "United Arab Emirates"},
    {"name": "Qatar Airways", "code": "QR", "country": "Qatar"},
    {"name": "Turkish Airlines", "code": "TK", "country": "Turkey"},
    {"name": "Lufthansa", "code": "LH", "country": "Germany"},
    {"name": "British Airways", "code": "BA", "country": "United Kingdom"},
    {"name": "Air France", "code": "AF", "country": "France"},
    {"name": "Japan Airlines", "code": "JL", "country": "Japan"},
    {"name": "Etihad Airways", "code": "EY", "country": "United Arab Emirates"},
    {"name": "Delta Air Lines", "code": "DL", "country": "United States"},
    {"name": "IndiGo", "code": "6E", "country": "India"},
  ];

  final List<String> _classes = [
    "Economy",
    "Premium Economy",
    "Business",
    "First Class"
  ];



  Future<void> _selectImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error selecting images: $e')));
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final DateTime? picked = await showMonthYearPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100)

    );

    if (picked != null) {
      setState(() {
        _travelDate = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Your Travel'), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return
            SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),

            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image selection area
                  _buildGestureDetectorImageSelection(),
              
                  const SizedBox(height: 20),

                        // Airport selection
                  SearchableDropdown(
                    label: 'Departure Airport',
                    value: _departureAirport,
                    items:
                        _airports.map((a) => '${a['name']} (${a['code']})\n${a['city']}').toList(),
                    onChanged: (value) => setState(() => _departureAirport = value),
                  ),

                const SizedBox(height: 16),

                  //Arrival Airport
                  SearchableDropdown(
                    label: 'Arrival Airport',
                    value: _arrivalAirport,
                    items:
                        _airports.map((a) => '${a['city']} (${a['code']})\n${a['name']}',).toList(),
              
                    onChanged: (value) => setState(() => _arrivalAirport = value),
                  ),
              
                  const SizedBox(height: 16),

                  //Airline
                  SearchableDropdown(
                    label: 'Airline',
                    value: _airline,
                    items:
                    _airlines.map((a) => '${a['name']} (${a['code']})\n${a['country']}',).toList(),

                    onChanged: (value) => setState(() => _airline = value),
                  ),


                  const SizedBox(height: 16),

                  //Travel Class
                  SearchableDropdown(
                    label: 'Class',
                    value: _travelClass,
                    items: _classes,
                    onChanged: (value) => setState(() => _travelClass = value),
                  ),

                const SizedBox(height: 16),
              
                  // Message field
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Your message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => setState(() => _message = value),
                  ),
              
                  const SizedBox(height: 20),
              
                  // Date and rating row
                  _buildRowDateAndRating(context),
              
                  const SizedBox(height: 30),
              
                  // Share Now button
                  ElevatedButton(
                      onPressed:_shareNowButton,

                      style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius
                          .circular(8)),
                    ),
                    child: const Text(
                        'Share Now', style: TextStyle(fontSize: 18)),
                  ),

                ],
              ),
            ),
          ),
        );
       },
      ),
    );
  }



  //===================================================
  //=====================Method area==============================
  //===================================================


  GestureDetector _buildGestureDetectorImageSelection() {
    return GestureDetector(
                  onTap: _selectImages,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _selectedImages.isEmpty
                            ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_upload,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text('Drop Your Image Here Or Browse'),
                              ],
                            )
                            : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                itemCount: _selectedImages.length + 1,
                                // +1 for the "+" button
                                itemBuilder: (context, index) {
                                  if (index < _selectedImages.length) {
                                    return Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.file(
                                            File(_selectedImages[index].path),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _selectedImages.removeAt(index);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // "+" icon tile
                                    return GestureDetector(
                                      onTap: _selectImages,
                                      child: DottedBorder(
                                        color: Colors.grey,
                                        borderType: BorderType.RRect,
                                        radius: const Radius.circular(8),
                                        dashPattern: const [6, 3],
                                        // Added 'const' here
                                        child: const Center(
                                          // Added 'const' here
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                  ),
                );
  }

  Widget _buildRowDateAndRating(BuildContext context) {
    return Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          _selectMonthYear(context);
                          print('clicked');
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Travel Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _travelDate != null
                                    ? DateFormat('MMM yyyy').format(_travelDate!)
                                    : 'Select date',
                                style: const TextStyle(
                                  fontSize: 16, // Adjust font size as needed
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today,
                                size: 20, // Adjust icon size as needed
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Rating'),
                          Slider(
                            value: _rating,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: _rating.toStringAsFixed(1),
                            onChanged: (value) => setState(() => _rating = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
  }

  void _shareNowButton() async {
    if (_validateForm()) {
      debugPrint('Form is valid. Submitting...');
      _shareExperience();


    } else {
      debugPrint('Form is invalid.');
    }
  }

  bool _validateForm() {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return false;
    }

    if (_departureAirport == null || _arrivalAirport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select departure and arrival airports'),
        ),
      );
      return false;
    }

    if (_travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select travel date')),
      );
      return false;
    }

    return true;
  }


  Future<void> _shareExperience() async {
    // Extract airport codes from the selected strings
    String? departureCode = _airports.firstWhere(
          (a) => '${a['name']} (${a['code']})\n${a['city']}' == _departureAirport,
      orElse: () => {'code': ''},
    )['code'];

    String? arrivalCode = _airports.firstWhere(
          (a) => '${a['city']} (${a['code']})\n${a['name']}' == _arrivalAirport,
      orElse: () => {'code': ''},
    )['code'];

    String? airlineCountry = _airlines.firstWhere(
          (a) => '${a['name']} (${a['code']})\n${a['country']}' == _airline,
      orElse: () => {'country': ''},
    )['country'];



    final experienceData = {
      'departureAirport': _departureAirport,
      'arrivalAirport': _arrivalAirport,
      'airline': _airline,
      'travelClass': _travelClass,
      'message': _message,
      'travelDate': _travelDate?.toIso8601String(),
      'rating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('shared_experiences')
          .add(experienceData);

      final _postId = docRef.id; // post ID
      print('Post shared successfully with ID: $_postId');

      //show a success message or navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post shared with ID: $_postId')),
      );

      // Navigate to FlightPostScreen with the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostScreen(
            departureCode: departureCode ?? 'Unknown',
            arrivalCode: arrivalCode ?? 'Unknown',
            airlineCountry: airlineCountry ?? 'Unknown',
            travelClass: _travelClass ?? 'Unknown',
            travelDate: _travelDate ?? DateTime.now(),
            rating: _rating,
            message: _message ?? '',
            postId: _postId,
            imageFiles: _selectedImages,
          ),
        ),
      );


    } catch (e) {
      print('Error sharing experience: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }



  ///Uploaded image Firebase
/*
    List<String> imageUrls = [];

    try {
      for (XFile imageFile in _selectedImages) {

        String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Firebase Storage
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child(fileName);


        await storageRef.putFile(File(imageFile.path));

        // download URL
        String downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }*/


      await FirebaseFirestore.instance.collection('shared_experiences').add({
        'departureAirport': _departureAirport,
        'arrivalAirport': _arrivalAirport,
        'airline': _airline,
        'travelClass': _travelClass,
        'message': _message,
        'travelDate': _travelDate?.toIso8601String(),
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('post successfully!')),
      );

    }/* catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('d $e')),
      );
    }*/




//===================================================
//=====================Method area end==============================
//===================================================


}




