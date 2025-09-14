import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'main.dart'; // To access supabase
import 'manage_tournament_page.dart';

class AdminTournamentsPage extends StatefulWidget {
  const AdminTournamentsPage({super.key});

  @override
  State<AdminTournamentsPage> createState() => _AdminTournamentsPageState();
}

class _AdminTournamentsPageState extends State<AdminTournamentsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _gameNameController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _prizePoolController = TextEditingController();
  DateTime? _selectedDateTime;

  bool _isLoading = true;
  List<Map<String, dynamic>> _tournaments = [];

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase.from('tournaments').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() => _tournaments = data);
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching tournaments');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addTournament() async {
    if (!_formKey.currentState!.validate() || _selectedDateTime == null) {
      _showErrorSnackBar('Please fill all fields and select a date/time.');
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await supabase.from('tournaments').insert({
        'title': _titleController.text.trim(),
        'game_name': _gameNameController.text.trim(),
        'entry_fee': int.parse(_entryFeeController.text.trim()),
        'prize_pool': int.parse(_prizePoolController.text.trim()),
        'match_time': _selectedDateTime!.toIso8601String(),
      });
      _showSuccessSnackBar('Tournament created successfully!');
      _formKey.currentState!.reset();
      _titleController.clear();
      _gameNameController.clear();
      _entryFeeController.clear();
      _prizePoolController.clear();
      setState(() => _selectedDateTime = null);
      _fetchTournaments(); // Refresh the list
    } catch (e) {
      _showErrorSnackBar('Error creating tournament');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildCreateTournamentForm(),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text('Existing Tournaments', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildTournamentList(),
      ],
    );
  }
  
  Widget _buildCreateTournamentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Tournament', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _gameNameController, decoration: const InputDecoration(labelText: 'Game Name (e.g., BGMI)'), validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _entryFeeController, decoration: const InputDecoration(labelText: 'Entry Fee (₹)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(controller: _prizePoolController, decoration: const InputDecoration(labelText: 'Prize Pool (₹)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_selectedDateTime == null ? 'No Date & Time Selected' : DateFormat('dd/MM/yy hh:mm a').format(_selectedDateTime!)),
                  TextButton(onPressed: () => _selectDateTime(context), child: const Text('Select Time')),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _addTournament, child: const Text('CREATE TOURNAMENT'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentList() {
    if (_tournaments.isEmpty) {
      return const Center(child: Text('No tournaments found. Create one above!'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _tournaments.length,
      itemBuilder: (context, index) {
        final t = _tournaments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(t['title']),
            subtitle: Text('${t['game_name']} - Prize: ₹${t['prize_pool']}'),
            trailing: ElevatedButton(
              child: const Text('Manage'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ManageTournamentPage(tournamentId: t['id'], tournamentTitle: t['title']),
                ));
              },
            ),
          ),
        );
      },
    );
  }
}
