import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'memory_day_screen.dart';

class MemoryCalendarScreen extends StatefulWidget {
  final String? friendUsername;

  const MemoryCalendarScreen({super.key, this.friendUsername});

  @override
  State<MemoryCalendarScreen> createState() => _MemoryCalendarScreenState();
}

class _MemoryCalendarScreenState extends State<MemoryCalendarScreen> {
  late DateTime _currentMonth;
  Map<String, int> _calendar = {};
  bool _isLoading = true;
  bool _memoriesPublic = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final apiService = context.read<ApiService>();
      final authService = context.read<AuthService>();

      // Debug: Check if we have a token
      if (authService.token == null) {
        throw Exception('Nicht angemeldet. Bitte neu einloggen.');
      }

      // Load calendar data
      final calendar = await apiService.getMemoryCalendar(
        username: widget.friendUsername,
        year: _currentMonth.year,
        month: _currentMonth.month,
      );

      // Load privacy status
      bool isPublic = false;
      try {
        isPublic = await apiService.getMemoriesPrivacy(
          username: widget.friendUsername,
        );
      } catch (e) {
        // Ignore error for privacy status
      }

      setState(() {
        _calendar = calendar;
        _memoriesPublic = isPublic;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $_errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _loadData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_currentMonth.year < now.year ||
        (_currentMonth.year == now.year && _currentMonth.month < now.month)) {
      setState(() {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      });
      _loadData();
    }
  }

  bool _canGoNext() {
    final now = DateTime.now();
    return _currentMonth.year < now.year ||
        (_currentMonth.year == now.year && _currentMonth.month < now.month);
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isOwnCalendar = widget.friendUsername == null ||
        widget.friendUsername == authService.user?.username;
    final displayName = isOwnCalendar
        ? 'Meine Memories'
        : '${widget.friendUsername}\'s Memories';
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          if (isOwnCalendar)
            IconButton(
              icon: Icon(_memoriesPublic ? Icons.public : Icons.lock),
              onPressed: _togglePrivacy,
              tooltip: _memoriesPublic ? 'Öffentlich' : 'Privat',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Erneut versuchen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B9D),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildMonthNavigator(),
                    _buildWeekdayHeader(),
                    Expanded(child: _buildCalendar()),
                  ],
                ),
    );
  }

  Widget _buildMonthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
          ),
          Text(
            DateFormat('MMMM yyyy', 'de_DE').format(_currentMonth),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _canGoNext() ? _nextMonth : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: weekdays
            .map((day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Monday is 1, Sunday is 7
    int startWeekday = firstDay.weekday;

    // Calculate total cells needed
    final totalCells = startWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: rows * 7,
      itemBuilder: (context, index) {
        final dayNumber = index - (startWeekday - 1) + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return Container(); // Empty cell
        }

        final date =
            DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final photoCount = _calendar[dateStr] ?? 0;
        final hasPhotos = photoCount > 0;
        final isFuture = date.isAfter(DateTime.now());

        return GestureDetector(
          onTap: hasPhotos && !isFuture ? () => _openDay(dateStr) : null,
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: hasPhotos ? Colors.purple.withOpacity(0.2) : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasPhotos ? Colors.purple : Colors.grey[300]!,
                width: hasPhotos ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '$dayNumber',
                    style: TextStyle(
                      color: isFuture ? Colors.grey : Colors.black,
                      fontWeight:
                          hasPhotos ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (hasPhotos)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minWidth: 16),
                      child: Text(
                        '$photoCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDay(String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemoryDayScreen(
          date: date,
          username: widget.friendUsername,
        ),
      ),
    );
  }

  Future<void> _togglePrivacy() async {
    try {
      final apiService = context.read<ApiService>();
      final newStatus = await apiService.toggleMemoriesPrivacy();

      setState(() => _memoriesPublic = newStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '🌍 Memories sind jetzt öffentlich (Freunde können sie sehen)'
                  : '🔒 Memories sind jetzt privat',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }
}
