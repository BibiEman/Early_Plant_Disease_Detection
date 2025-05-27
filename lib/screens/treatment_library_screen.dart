import 'package:flutter/material.dart';

class TreatmentLibraryScreen extends StatefulWidget {
  const TreatmentLibraryScreen({super.key});

  @override
  State<TreatmentLibraryScreen> createState() => _TreatmentLibraryScreenState();
}

class _TreatmentLibraryScreenState extends State<TreatmentLibraryScreen> {
  String searchQuery = '';
  int selectedCategoryIndex = 0;

  final List<String> categories = [
    'All',
    'Organic',
    'Chemical',
    'Biological',
    'Preventive'
  ];

  final List<TreatmentItem> treatments = [
    TreatmentItem(
      name: 'Neem Oil Solution',
      category: 'Organic',
      description: 'Natural pesticide effective against various insects and fungal infections.',
      application: '- Mix 2-3 ml neem oil with 1L water\n- Add few drops of liquid soap\n- Spray on affected areas\n- Apply weekly until condition improves',
      safetyInfo: '- Avoid contact with eyes\n- Keep away from children\n- Best applied in evening or early morning\n- Safe for most plants',
      effectiveness: 4,
      type: 'Preventive & Curative',
    ),
    TreatmentItem(
      name: 'Copper Fungicide',
      category: 'Chemical',
      description: 'Effective against various fungal and bacterial diseases in plants.',
      application: '- Dilute as per product instructions\n- Spray thoroughly on affected areas\n- Repeat application after 7-14 days\n- Apply in dry conditions',
      safetyInfo: '- Wear protective gear\n- Keep away from water sources\n- Don\'t apply before rain\n- Follow local regulations',
      effectiveness: 5,
      type: 'Curative',
    ),
    TreatmentItem(
      name: 'Beneficial Bacteria',
      category: 'Biological',
      description: 'Promotes plant health and fights harmful pathogens naturally.',
      application: '- Apply to soil or as foliar spray\n- Use in early morning\n- Maintain soil moisture\n- Reapply monthly',
      safetyInfo: '- Safe for humans and pets\n- Store in cool place\n- Don\'t mix with chemical products\n- Check expiration date',
      effectiveness: 3,
      type: 'Preventive',
    ),
    TreatmentItem(
      name: 'Companion Planting',
      category: 'Preventive',
      description: 'Strategic placement of plants that naturally repel pests and diseases.',
      application: '- Plant compatible species together\n- Maintain proper spacing\n- Monitor plant interactions\n- Rotate annually',
      safetyInfo: '- Research plant compatibility\n- Avoid invasive species\n- Consider growth patterns\n- Monitor water competition',
      effectiveness: 3,
      type: 'Preventive',
    ),
    TreatmentItem(
      name: 'Sulfur Spray',
      category: 'Chemical',
      description: 'Controls powdery mildew, rust, and other fungal diseases.',
      application: '- Mix with water as directed\n- Apply early in disease cycle\n- Ensure complete coverage\n- Don\'t apply in hot weather',
      safetyInfo: '- Wear respiratory protection\n- Avoid skin contact\n- Don\'t mix with other chemicals\n- Keep away from heat',
      effectiveness: 4,
      type: 'Curative',
    ),
    TreatmentItem(
      name: 'Garlic Extract',
      category: 'Organic',
      description: 'Natural fungicide and insect repellent with antimicrobial properties.',
      application: '- Blend garlic with water\n- Strain and dilute solution\n- Spray on affected areas\n- Apply weekly',
      safetyInfo: '- May cause eye irritation\n- Strong odor while fresh\n- Safe for edible plants\n- Store in dark bottle',
      effectiveness: 3,
      type: 'Preventive & Curative',
    ),
    TreatmentItem(
      name: 'Trichoderma',
      category: 'Biological',
      description: 'Beneficial fungus that controls soil-borne pathogens and promotes root growth.',
      application: '- Mix with soil or water\n- Apply to root zone\n- Maintain soil moisture\n- Reapply seasonally',
      safetyInfo: '- Store in cool, dry place\n- Use within expiration\n- Safe for all plants\n- Don\'t mix with fungicides',
      effectiveness: 4,
      type: 'Preventive',
    ),
    TreatmentItem(
      name: 'Crop Rotation',
      category: 'Preventive',
      description: 'Systematic rotation of crops to prevent disease buildup in soil.',
      application: '- Plan 3-4 year rotation\n- Group similar crops\n- Record planting history\n- Consider soil nutrients',
      safetyInfo: '- Research crop families\n- Consider growing seasons\n- Monitor soil health\n- Document rotations',
      effectiveness: 4,
      type: 'Preventive',
    ),
    TreatmentItem(
      name: 'Bacillus Thuringiensis',
      category: 'Biological',
      description: 'Natural bacteria effective against various caterpillars and larvae.',
      application: '- Mix fresh solution\n- Apply to affected areas\n- Reapply after rain\n- Target young insects',
      safetyInfo: '- Safe for humans and pets\n- Apply in evening\n- Store properly\n- Check expiration',
      effectiveness: 5,
      type: 'Curative',
    ),
    TreatmentItem(
      name: 'Potassium Bicarbonate',
      category: 'Chemical',
      description: 'Effective against powdery mildew and other fungal diseases.',
      application: '- Dissolve in water\n- Spray entire plant\n- Apply weekly\n- Best as preventive',
      safetyInfo: '- Mild eye irritant\n- Keep away from children\n- Store in dry place\n- Safe for edibles',
      effectiveness: 4,
      type: 'Preventive & Curative',
    ),
  ];

  List<TreatmentItem> get filteredTreatments {
    if (searchQuery.isEmpty && selectedCategoryIndex == 0) {
      return treatments;
    }
    return treatments.where((treatment) {
      final matchesSearch = searchQuery.isEmpty || 
          treatment.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          treatment.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          treatment.type.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategoryIndex == 0 || 
          treatment.category == categories[selectedCategoryIndex];
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatment Library'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search treatments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(categories[index]),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() => selectedCategoryIndex = index);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: filteredTreatments.length,
              itemBuilder: (context, index) {
                final treatment = filteredTreatments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(
                      treatment.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      treatment.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(treatment.category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        treatment.category,
                        style: TextStyle(
                          color: _getCategoryColor(treatment.category),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () => _showTreatmentDetails(context, treatment),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Organic':
        return Colors.green;
      case 'Chemical':
        return Colors.orange;
      case 'Biological':
        return Colors.blue;
      case 'Preventive':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showTreatmentDetails(BuildContext context, TreatmentItem treatment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        treatment.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(treatment.category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        treatment.category,
                        style: TextStyle(
                          color: _getCategoryColor(treatment.category),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailSection('Description', treatment.description),
                _buildDetailSection('Application Method', treatment.application),
                _buildDetailSection('Safety Information', treatment.safetyInfo),
                _buildDetailSection('Type', treatment.type),
                Row(
                  children: [
                    const Text(
                      'Effectiveness: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < treatment.effectiveness
                              ? Colors.amber
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}

class TreatmentItem {
  final String name;
  final String category;
  final String description;
  final String application;
  final String safetyInfo;
  final int effectiveness;
  final String type;

  TreatmentItem({
    required this.name,
    required this.category,
    required this.description,
    required this.application,
    required this.safetyInfo,
    required this.effectiveness,
    required this.type,
  });
} 