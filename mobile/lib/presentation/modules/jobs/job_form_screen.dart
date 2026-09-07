import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../core/constants.dart';
import '../../../data/api_service.dart';
import '../../../domain/models/job.dart';

class JobFormScreen extends StatefulWidget {
  final JobApplication? job;
  const JobFormScreen({super.key, this.job});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _urlController = TextEditingController();
  String _status = 'applied';
  DateTime _applicationDate = DateTime.now();
  bool _isLoading = false;
  List<JobWebsite> _websites = [];
  String? _selectedWebsiteId;
  final _websiteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWebsites();
    final j = widget.job;
    if (j != null) {
      _companyController.text = j.companyName;
      _positionController.text = j.position;
      _salaryController.text = j.salaryRange ?? '';
      _locationController.text = j.location ?? '';
      _jobTypeController.text = j.jobType ?? '';
      _descriptionController.text = j.jobDescription ?? '';
      _notesController.text = j.notes ?? '';
      _urlController.text = j.url ?? '';
      _status = j.status;
      _applicationDate = DateTime.tryParse(j.applicationDate) ?? DateTime.now();
      _selectedWebsiteId = j.websiteId;
    }
  }

  Future<void> _loadWebsites() async {
    try {
      final resp = await ApiService().get('${ApiConstants.jobsUrl}/websites');
      setState(() {
        _websites = (resp as List).map((e) => JobWebsite.fromJson(e)).toList();
        // Prefill the typeahead with the selected website's name when editing.
        if (_selectedWebsiteId != null) {
          final selected =
              _websites.where((w) => w.id == _selectedWebsiteId).firstOrNull;
          if (selected != null) _websiteController.text = selected.name;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error load websites: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _applicationDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _applicationDate = picked);
  }

  Future<void> _save() async {
    if (_companyController.text.isEmpty || _positionController.text.isEmpty) {
      return;
    }
    setState(() => _isLoading = true);
    final body = {
      'companyName': _companyController.text,
      'position': _positionController.text,
      'salaryRange': _salaryController.text,
      'location': _locationController.text,
      'jobType': _jobTypeController.text,
      'status': _status,
      'applicationDate': _applicationDate.toIso8601String().split('T')[0],
      'jobDescription': _descriptionController.text,
      'notes': _notesController.text,
      'url': _urlController.text,
      'websiteId': _selectedWebsiteId,
    };
    try {
      final j = widget.job;
      if (j != null) {
        await ApiService().put('${ApiConstants.jobsUrl}/${j.id}', body);
      } else {
        await ApiService().post(ApiConstants.jobsUrl, body);
      }
      if (mounted) context.pop(true);
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
    final isEdit = widget.job != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Job' : 'Add Job Application')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(labelText: 'Position'),
            ),
            const SizedBox(height: 12),
            TypeAheadField<String>(
              controller: _websiteController,
              suggestionsCallback: (pattern) {
                final q = pattern.toLowerCase();
                return _websites
                    .where((w) =>
                        w.name.toLowerCase().contains(q) ||
                        (w.url?.toLowerCase().contains(q) ?? false))
                    .map((w) => w.id)
                    .toList();
              },
              itemBuilder: (context, websiteId) {
                final w = _websites.firstWhere((x) => x.id == websiteId);
                return ListTile(
                  title: Text(w.name),
                  subtitle: Text(w.status),
                );
              },
              onSelected: (websiteId) {
                final w = _websites.firstWhere((x) => x.id == websiteId);
                setState(() {
                  _selectedWebsiteId = websiteId;
                  _websiteController.text = w.name;
                });
              },
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Source Website (type to search)',
                    prefixIcon: Icon(Icons.search),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: const [
                DropdownMenuItem(value: 'applied', child: Text('Applied')),
                DropdownMenuItem(value: 'screening', child: Text('Screening')),
                DropdownMenuItem(value: 'interview', child: Text('Interview')),
                DropdownMenuItem(
                    value: 'technical_test', child: Text('Technical Test')),
                DropdownMenuItem(value: 'offer', child: Text('Offer')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
                DropdownMenuItem(value: 'withdrawn', child: Text('Withdrawn')),
                DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'applied'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Application Date'),
              subtitle: Text(DateFormat('yyyy-MM-dd').format(_applicationDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _salaryController,
              decoration: const InputDecoration(labelText: 'Salary Range'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jobTypeController,
              decoration: const InputDecoration(
                labelText: 'Job Type',
                hintText: 'Remote, Full-time, Contract',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Job URL'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Job Description'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'Update' : 'Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _jobTypeController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _urlController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
