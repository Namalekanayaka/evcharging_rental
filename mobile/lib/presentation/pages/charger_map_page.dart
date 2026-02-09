import 'package:flutter/material.dart';

class ChargerMapPage extends StatefulWidget {
  const ChargerMapPage({Key? key}) : super(key: key);

  @override
  State<ChargerMapPage> createState() => _ChargerMapPageState();
}

class _ChargerMapPageState extends State<ChargerMapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Chargers'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search chargers',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.tune),
                  label: const Text('Filter'),
                ),
              ],
            ),
          ),
          // Map (placeholder)
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: const Center(
                child: Text('Google Maps will be integrated here'),
              ),
            ),
          ),
          // Charger List Preview
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildChargerCard();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChargerCard() {
    return SizedBox(
      width: 250,
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 80,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.electric_car)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fast Charger Hub',
                style: TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                '4.5 ⭐ (120 reviews)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '\$5.99/hr',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
