//lib/features/host/host_calendar_screen
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:travel265/models/property_model.dart';
import 'package:travel265/models/property_models.dart'; // Make sure this import includes CalendarEvent

class HostCalendarScreen extends StatefulWidget {
  final Property property;

  const HostCalendarScreen({super.key, required this.property});

  @override
  State<HostCalendarScreen> createState() => _HostCalendarScreenState();
}

class _HostCalendarScreenState extends State<HostCalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadSampleEvents();
  }

  void _loadSampleEvents() {
    // Sample events for demonstration
    final today = DateTime.now();
    setState(() {
      _events = {
        today: [
          CalendarEvent(
            id: '1',
            title: 'Booking - John Smith',
            startDate: today,
            endDate: today.add(const Duration(days: 2)),
            eventType: 'booking',
          ),
        ],
        today.add(const Duration(days: 5)): [
          CalendarEvent(
            id: '2',
            title: 'Blocked - Maintenance',
            startDate: today.add(const Duration(days: 5)),
            endDate: today.add(const Duration(days: 7)),
            eventType: 'blocked',
          ),
        ],
      };
    });
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    // Normalize the date to remove time part for comparison
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.property.title} - Calendar'),
        backgroundColor: const Color(0xFF0b95da),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: const Color(0xFF0b95da).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF0b95da),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: const Color(0xFF0b95da),
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 16),
          _buildEventsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: const Color(0xFF0b95da),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem(Colors.green, 'Available'),
          _buildLegendItem(Colors.red, 'Booked'),
          _buildLegendItem(Colors.orange, 'Blocked'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEventsList() {
    final dayEvents = _getEventsForDay(_selectedDay);

    if (dayEvents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No events for selected day',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: dayEvents.length,
        itemBuilder: (context, index) {
          final event = dayEvents[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: _getEventIcon(event.eventType),
              title: Text(event.title),
              subtitle: Text(
                '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteEvent(event),
              ),
            ),
          );
        },
      ),
    );
  }

  Icon _getEventIcon(String eventType) {
    switch (eventType) {
      case 'booking':
        return const Icon(Icons.book_online, color: Colors.red);
      case 'blocked':
        return const Icon(Icons.block, color: Colors.orange);
      case 'maintenance':
        return const Icon(Icons.build, color: Colors.blue);
      default:
        return const Icon(Icons.event, color: Colors.grey);
    }
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onEventAdded: (event) {
          setState(() {
            // Add event to all days in the range
            var currentDate = event.startDate;
            while (currentDate.isBefore(event.endDate) ||
                currentDate.isAtSameMomentAs(event.endDate)) {
              final dateKey = DateTime(currentDate.year, currentDate.month, currentDate.day);
              _events[dateKey] = [..._events[dateKey] ?? [], event];
              currentDate = currentDate.add(const Duration(days: 1));
            }
          });
        },
      ),
    );
  }

  void _deleteEvent(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                // Remove event from all days
                _events.forEach((date, events) {
                  _events[date] = events.where((e) => e.id != event.id).toList();
                });
                // Remove empty dates
                _events.removeWhere((date, events) => events.isEmpty);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Simple dialog for adding events
class AddEventDialog extends StatefulWidget {
  final Function(CalendarEvent) onEventAdded;

  const AddEventDialog({super.key, required this.onEventAdded});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _titleController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  String _eventType = 'blocked';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _eventType,
              decoration: const InputDecoration(
                labelText: 'Event Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'blocked', child: Text('Block Dates')),
                DropdownMenuItem(value: 'booking', child: Text('Booking')),
                DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
              ],
              onChanged: (value) => setState(() => _eventType = value!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Date'),
                      TextButton(
                        onPressed: () => _selectDate(true),
                        child: Text(_formatDate(_startDate)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Date'),
                      TextButton(
                        onPressed: () => _selectDate(false),
                        child: Text(_formatDate(_endDate)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0b95da),
          ),
          child: const Text('Add Event'),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _addEvent() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter event title')),
      );
      return;
    }

    final event = CalendarEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      startDate: _startDate,
      endDate: _endDate,
      eventType: _eventType,
    );

    widget.onEventAdded(event);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}