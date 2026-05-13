import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: "T's Mental Foundry",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.grey[900],
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("T's Mental Foundry 🧠"),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Generate", icon: Icon(Icons.palette)),
            Tab(text: "Scrape", icon: Icon(Icons.spider)),
            Tab(text: "Search", icon: Icon(Icons.search)),
            Tab(text: "Webcams", icon: Icon(Icons.videocam)),
            Tab(text: "Voice", icon: Icon(Icons.mic)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GenerateTab(),
          ScrapeTab(),
          SearchTab(),
          WebcamTab(),
          VoiceTab(),
        ],
      ),
    );
  }
}

class GenerateTab extends StatefulWidget {
  const GenerateTab({Key? key}) : super(key: key);

  @override
  State<GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<GenerateTab> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.palette, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text("Image Generation", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: "Describe the image you want to generate...",
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateImage,
              child: _isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Generate Image"),
            ),
          ],
        ),
      ),
    );
  }

  void _generateImage() async {
    if (_promptController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a prompt")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.generateImage(_promptController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Image generated!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}

class ScrapeTab extends StatefulWidget {
  const ScrapeTab({Key? key}) : super(key: key);

  @override
  State<ScrapeTab> createState() => _ScrapeTabState();
}

class _ScrapeTabState extends State<ScrapeTab> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  bool _extractImages = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.spider, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text("Web Scraping", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: "Enter website URL...",
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text("Extract Images"),
              value: _extractImages,
              onChanged: (value) => setState(() => _extractImages = value ?? false),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _scrapeWebsite,
              child: _isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Scrape Website"),
            ),
          ],
        ),
      ),
    );
  }

  void _scrapeWebsite() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a URL")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.scrapeWebsite(_urlController.text, extractImages: _extractImages);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Website scraped!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _queryController = TextEditingController();
  bool _isLoading = false;
  String _searchType = "general";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.search, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text("Public Data Search", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                hintText: "Search for person, topic, or organization...",
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _searchType,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: "general", child: Text("General")),
                DropdownMenuItem(value: "person", child: Text("Person")),
                DropdownMenuItem(value: "organization", child: Text("Organization")),
              ],
              onChanged: (value) => setState(() => _searchType = value ?? "general"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _search,
              child: _isLoading 
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text("Search Information"),
            ),
          ],
        ),
      ),
    );
  }

  void _search() async {
    if (_queryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a search query")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.searchIntelligence(_queryController.text, type: _searchType);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Search complete!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}

class WebcamTab extends StatefulWidget {
  const WebcamTab({Key? key}) : super(key: key);

  @override
  State<WebcamTab> createState() => _WebcamTabState();
}

class _WebcamTabState extends State<WebcamTab> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _cameras = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.videocam, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text("Public Webcams", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "Search by city (e.g., New York, Tokyo)...",
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _searchWebcams,
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Search"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _getPopular,
                    icon: const Icon(Icons.star),
                    label: const Text("Popular"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_cameras.isNotEmpty)
              Column(
                children: _cameras.map((camera) {
                  return Card(
                    color: Colors.grey[800],
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.videocam, color: Colors.red),
                      title: Text(camera['name'] ?? 'Unknown Camera'),
                      subtitle: Text(camera['location'] ?? 'Location unknown'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () => _showCameraDetails(camera),
                    ),
                  );
                }).toList(),
              )
            else if (!_isLoading)
              const Text("Search or select popular to view webcams"),
          ],
        ),
      ),
    );
  }

  void _searchWebcams() async {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a location")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.searchWebcams(_locationController.text);
      setState(() => _cameras = response['cameras'] ?? []);
      if (_cameras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No cameras found for that location")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _getPopular() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.getPopularWebcams();
      setState(() => _cameras = response['cameras'] ?? []);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCameraDetails(dynamic camera) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(camera['name'] ?? 'Camera'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location: ${camera['location'] ?? 'Unknown'}"),
            const SizedBox(height: 8),
            Text("Type: ${camera['type'] ?? 'Unknown'}"),
            const SizedBox(height: 8),
            Text("Source: ${camera['source'] ?? 'Unknown'}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎥 Opening live feed...")),
              );
            },
            child: const Text("View Live Feed"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}

class VoiceTab extends StatefulWidget {
  const VoiceTab({Key? key}) : super(key: key);

  @override
  State<VoiceTab> createState() => _VoiceTabState();
}

class _VoiceTabState extends State<VoiceTab> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.mic, size: 64, color: Colors.purple),
            const SizedBox(height: 16),
            const Text("Voice Commands", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _recordVoice,
              icon: const Icon(Icons.mic),
              label: const Text("Start Recording"),
            ),
            const SizedBox(height: 24),
            const Text("Or synthesize voice:"),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "Enter text to convert to speech...",
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _synthesizeVoice,
              icon: const Icon(Icons.speaker),
              label: const Text("Speak"),
            ),
          ],
        ),
      ),
    );
  }

  void _recordVoice() async {
    setState(() => _isLoading = true);
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎙️ Recording...")),
      );
      // Voice recording functionality would go here
      await Future.delayed(const Duration(seconds: 3));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Recording complete!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _synthesizeVoice() async {
    if (_textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter text")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      await apiService.synthesizeVoice(_textController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎤 Speaking with your ElevenLabs voice!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
