import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _isLoading = false;
  String _format = 'json';

  Future<void> _export() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService()
          .get('${ApiConstants.baseUrl}/export?format=$_format');
      final data = response != null ? response.toString() : '';
      await Share.share(data, subject: 'Personal Super App Export');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Format',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'json', label: Text('JSON')),
                ButtonSegment(value: 'csv', label: Text('CSV')),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _export,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Export & Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
