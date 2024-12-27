import 'package:beatsguard/components/custom_app_bar.dart';
import 'package:beatsguard/components/services/measurements_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final MeasurementService _measurementsService = MeasurementService();
  List<dynamic> _measurements = [];
  List<dynamic> _filteredMeasurements = [];
  // ignore: unused_field
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchMeasurements();
  }

  Future<void> _fetchMeasurements() async {
    try {
      const int userId = 1; // Replace with dynamic user ID as needed
      final measurements = await _measurementsService.getMeasurementsByUserId(userId);
      setState(() {
        _measurements = measurements;
        _filteredMeasurements = measurements;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch measurements: $e')),
      );
    }
  }

  void _filterMeasurementsByDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _filteredMeasurements = _measurements.where((measurement) {
        final time = DateTime(
          measurement['time'][0],
          measurement['time'][1],
          measurement['time'][2],
        );
        return DateUtils.isSameDay(time, date);
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDate = null;
      _filteredMeasurements = _measurements;
    });
  }

  Widget _buildTable() {
    return PaginatedDataTable(
      header: const Text(
        'Measurements',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('BPM')),
        DataColumn(label: Text('SpO2')),
        DataColumn(label: Text('Temp (°C)')),
        DataColumn(label: Text('Humidity (%)')),
      ],
      source: _MeasurementTableSource(_filteredMeasurements),
      rowsPerPage: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      drawer:const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      _filterMeasurementsByDay(selectedDate);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Filter by Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white, // White text
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white, // White text
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _measurements.isEmpty
                  ? const Center(
                      child: Text(
                        'No measurements available.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : _buildTable(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementTableSource extends DataTableSource {
  final List<dynamic> _measurements;

  _MeasurementTableSource(this._measurements);

  @override
  DataRow? getRow(int index) {
    if (index >= _measurements.length) return null;

    final measurement = _measurements[index];
    final date = DateTime(
      measurement['time'][0],
      measurement['time'][1],
      measurement['time'][2],
      measurement['time'][3],
      measurement['time'][4],
      measurement['time'][5],
    );

    return DataRow(cells: [
      DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(date))),
      DataCell(Text(measurement['avgBpm'].toString())),
      DataCell(Text(measurement['avgSpO2'].toString())),
      DataCell(Text(measurement['avgTemp'].toString())),
      DataCell(Text(measurement['avgHumidity'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _measurements.length;

  @override
  int get selectedRowCount => 0;
}
