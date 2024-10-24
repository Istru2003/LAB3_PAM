import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(BarbershopApp());
}

Future<List<Barbershop>> loadBarbershops() async {
  String jsonString = await rootBundle.loadString('assets/json/v2.json');

  final jsonResponse = json.decode(jsonString);

  List<dynamic> nearestBarbershopsJson = jsonResponse['nearest_barbershop'];

  return nearestBarbershopsJson.map((json) => Barbershop.fromJson(json)).toList();
}

class BarbershopApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbershop App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Barbershop> allBarbershops = [];
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllBarbershops();
  }

  Future<void> loadAllBarbershops() async {
    String jsonString = await rootBundle.loadString('assets/json/v2.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> nearestBarbershopsData = jsonData['nearest_barbershop'];
    final List<dynamic> recommendedBarbershopsData = jsonData['most_recommended'];

    setState(() {
      allBarbershops = [
        ...nearestBarbershopsData.map((json) => Barbershop.fromJson(json)),
        ...recommendedBarbershopsData.map((json) => Barbershop.fromJson(json))
      ];
      isLoading = false;
    });
  }

  void showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SearchDialog(
          allBarbershops: allBarbershops,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section: Location and Profile Avatar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF9D9DFF),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Yogyakarta',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundImage: AssetImage('assets/images/photo_4_2024-09-23_18-56-35.jpg'),
                      radius: 25,
                    ),
                  ],
                ),
              ),

              // Joe Samanta's name, moved closer to location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                child: Text(
                  'Joe Samanta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              // Booking Card
              BookingCard(),

              // Search Bar with Filter Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showSearchDialog(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                "Search barber's, haircut ser...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Filter Button
                    SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12), // Уменьшили радиус скругления
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Add filter action
                            print('Filter tapped');
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            width: 60,
                            height: 44,
                            child: Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nearest Barbershop List
                  NearestBarbershopList(),

                  // Most Recommended Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Most recommended',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  FeaturedBarbershopCard(),

                  // Most Recommended List
                  MostRecommendedList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Barbershop {
  final String name;
  final String locationWithDistance;
  final String image;
  final double reviewRate;

  Barbershop({
    required this.name,
    required this.locationWithDistance,
    required this.image,
    required this.reviewRate,
  });

  factory Barbershop.fromJson(Map<String, dynamic> json) {
    return Barbershop(
      name: json['name'] as String,
      locationWithDistance: json['location_with_distance'] as String,
      image: json['image'] as String,
      reviewRate: (json['review_rate'] as num).toDouble(),
    );
  }
}

class AllBarbershopsPage extends StatelessWidget {
  final List<Barbershop> barbershops;

  const AllBarbershopsPage({Key? key, required this.barbershops}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Barbershops', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: barbershops.length,
        itemBuilder: (context, index) {
          return BarbershopCard(
            barbershop: {
              'name': barbershops[index].name,
              'location': barbershops[index].locationWithDistance,
              'rating': barbershops[index].reviewRate,
              'image': barbershops[index].image,
            },
          );
        },
      ),
    );
  }
}


class BookingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: screenWidth, // Full screen width
        height: 230, // Increased height for the BookingCard
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/barbershop-seamless-pattern-black-on-white-repeating-pattern-print-for-men-s-barber-shop-a-set-of-accessories-for-men-s-hairdresser-on-white-background-vector.jpg', // Make sure to add this image to your assets
                  fit: BoxFit.cover,
                  opacity: AlwaysStoppedAnimation(0.1), // Adjust opacity as needed
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/photo_5_2024-09-23_18-56-35.png',
                  height: 210, // Increased height for the image
                  width: 210, // Increased width for the image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/Снимок экрана 2024-09-23 191707.png', // Logo in the orange window
                    height: 70,
                    width: 70,
                  ),
                  SizedBox(height: 8),
                  Spacer(), // Pushes the button down
                  ElevatedButton(
                    onPressed: () {
                      // Add booking action
                    },
                    child: Text(
                      'Booking Now',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchDialog extends StatefulWidget {
  final List<Barbershop> allBarbershops;

  const SearchDialog({Key? key, required this.allBarbershops}) : super(key: key);

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  List<Barbershop> searchResults = [];
  final TextEditingController _searchController = TextEditingController();

  void performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        searchResults = [];
      } else {
        searchResults = widget.allBarbershops
            .where((barbershop) =>
            barbershop.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search barber's, haircut ser...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: performSearch,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: searchResults.isEmpty && _searchController.text.isEmpty
                  ? Center(child: Text('Start typing to search...'))
                  : searchResults.isEmpty
                  ? Center(child: Text('No results found'))
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final barbershop = searchResults[index];
                  return BarbershopCard(
                    barbershop: {
                      'name': barbershop.name,
                      'location': barbershop.locationWithDistance,
                      'rating': barbershop.reviewRate,
                      'image': barbershop.image,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeeAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: OutlinedButton(
        onPressed: () {
          // Add action for See All button
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'See All',
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class CenteredSeeAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SeeAllButton(),
    );
  }
}

class NearestBarbershopList extends StatefulWidget {
  @override
  _NearestBarbershopListState createState() => _NearestBarbershopListState();
}

class _NearestBarbershopListState extends State<NearestBarbershopList> {
  late List<Barbershop> nearestbarbershops;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBarbershops();
  }

  Future<void> loadBarbershops() async {
    String jsonString = await rootBundle.loadString('assets/json/v2.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> barbershopData = jsonData['nearest_barbershop'];

    setState(() {
      nearestbarbershops = barbershopData
          .map((json) => Barbershop.fromJson(json))
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearest Barbershop',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: nearestbarbershops.length < 3 ? nearestbarbershops.length : 3,
          itemBuilder: (context, index) {
            return BarbershopCard(
              barbershop: {
                'name': nearestbarbershops[index].name,
                'location': nearestbarbershops[index].locationWithDistance,
                'rating': nearestbarbershops[index].reviewRate,
                'image': nearestbarbershops[index].image,
              },
            );
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllBarbershopsPage(
                    barbershops: nearestbarbershops,
                  ),
                ),
              );
            },
            child: Text('See All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class BarbershopCard extends StatelessWidget {
  final Map<String, dynamic> barbershop;

  BarbershopCard({required this.barbershop});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            barbershop['image'],
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey,
                child: Icon(Icons.error),
              );
            },
          ),
        ),
        title: Text(barbershop['name']),
        subtitle: Text(barbershop['location']),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: Colors.yellow),
            Text(barbershop['rating'].toString()),
          ],
        ),
      ),
    );
  }
}


class MostRecommendedList extends StatefulWidget {
  @override
  _MostRecommendedListState createState() => _MostRecommendedListState();
}

class _MostRecommendedListState extends State<MostRecommendedList> {
  List<Barbershop> featuredBarbershops = [];
  bool _showAll = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFeaturedBarbershops(); // Загружаем данные при инициализации
  }

  Future<void> loadFeaturedBarbershops() async {
    String jsonString = await rootBundle.loadString('assets/json/v2.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> barbershopData = jsonData['most_recommended'];

    setState(() {
      featuredBarbershops = barbershopData
          .map((json) => Barbershop.fromJson(json))
          .toList();
      isLoading = false; // Изменяем состояние загрузки
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Most Recommended',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _showAll ? featuredBarbershops.length : (featuredBarbershops.length < 3 ? featuredBarbershops.length : 3),
          itemBuilder: (context, index) {
            return BarbershopCard(barbershop: {
              'name': featuredBarbershops[index].name,
              'location': featuredBarbershops[index].locationWithDistance,
              'rating': featuredBarbershops[index].reviewRate,
              'image': featuredBarbershops[index].image,
            });
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showAll = !_showAll;
              });
            },
            child: Text(_showAll ? 'Show Less' : 'See All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturedBarbershopCard extends StatefulWidget {
  const FeaturedBarbershopCard({Key? key}) : super(key: key);

  @override
  _FeaturedBarbershopCardState createState() => _FeaturedBarbershopCardState();
}

class _FeaturedBarbershopCardState extends State<FeaturedBarbershopCard> {
  late PageController _pageController;
  int _currentPage = 0;
  List<Barbershop> featuredBarbershops = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1.0);
    loadFeaturedBarbershops();
  }

  Future<void> loadFeaturedBarbershops() async {
    String jsonString = await rootBundle.loadString('assets/json/v2.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);

    final List<dynamic> barbershopData = jsonData['list'];

    setState(() {
      featuredBarbershops = barbershopData
          .map((json) => Barbershop.fromJson(json))
          .toList();
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 350,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (featuredBarbershops.isEmpty) {
      return SizedBox(
        height: 350,
        child: Center(child: Text('No featured barbershops available')),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featuredBarbershops.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final barbershop = featuredBarbershops[index];
              return _buildBarbershopCard(barbershop);
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            featuredBarbershops.length,
                (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.deepPurple : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarbershopCard(Barbershop barbershop) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  barbershop.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: ElevatedButton(
                  onPressed: () {
                    // Add booking functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Booking'),
                      SizedBox(width: 8),
                      Icon(Icons.event, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barbershop.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        barbershop.locationWithDistance,
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.star, size: 16, color: Colors.yellow),
                    SizedBox(width: 4),
                    Text(
                      barbershop.reviewRate.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
