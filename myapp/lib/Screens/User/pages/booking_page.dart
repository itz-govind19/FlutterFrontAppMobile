import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/dto/Booking_model.dart';
import 'package:myapp/services/booking_service.dart';
import 'package:myapp/services/rate_service.dart';
import 'package:myapp/services/services_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _farmerPhoneController = TextEditingController();

  final TextEditingController _acresController = TextEditingController();
  final TextEditingController _guntasController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _meterController = TextEditingController();

  DateTime? _expectedDate;
  int? _selectedServiceId;
  int _vehicleId = 1; // Hardcoded for now

  List<Map<String, dynamic>> services = [];
  List<String> _unitTypeOptions = []; // Unit types fetched from DB
  String? _selectedUnitType;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final fetched = await FarmerService.fetchAllServices();
      setState(() {
        services = fetched
            .map((s) => {"id": s.serviceId, "name": s.serviceName})
            .toList();
      });
    } catch (e) {
      debugPrint("Error fetching services: $e");
    }
  }

  Future<void> _fetchRateByService(int serviceId) async {
    try {
      final rates = await RateService.fetchRateByServiceId(serviceId);

      if (rates.isNotEmpty) {
        setState(() {
          // Populate unit types dynamically
          _unitTypeOptions = rates.map((r) => r.unitType).toSet().toList();
          _selectedUnitType = null; // Reset selected unit type
        });
      }
    } catch (e) {
      debugPrint("Error fetching rates: $e");
    }
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate() ||
        _expectedDate == null ||
        _selectedServiceId == null ||
        _selectedUnitType == null) {
      return;
    }

    final booking = CreateBookingDTO(
      expectedDate: _expectedDate!,
      farmerName: _farmerNameController.text,
      farmerPhone: _farmerPhoneController.text,
      serviceId: _selectedServiceId!,
      vehicleId: _vehicleId,
      acres: double.tryParse(_acresController.text) ?? 0,
      guntas: double.tryParse(_guntasController.text) ?? 0,
      hours: int.tryParse(_hoursController.text) ?? 0,
      minutes: int.tryParse(_minutesController.text) ?? 0,
      kilometers: double.tryParse(_kmController.text) ?? 0,
      meters: double.tryParse(_meterController.text) ?? 0,
    );

    setState(() => _loading = true);
    final created = await BookingService.createBooking(booking);
    setState(() => _loading = false);

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking created successfully")),
      );
      _formKey.currentState!.reset();
      _farmerNameController.clear();
      _farmerPhoneController.clear();
      _acresController.clear();
      _guntasController.clear();
      _hoursController.clear();
      _minutesController.clear();
      _kmController.clear();
      _meterController.clear();
      setState(() {
        _expectedDate = null;
        _selectedServiceId = null;
        _selectedUnitType = null;
        _unitTypeOptions.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create booking")),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        setState(() {
          _expectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Booking")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Farmer name
              TextFormField(
                controller: _farmerNameController,
                decoration:
                const InputDecoration(labelText: "Farmer Name"),
                validator: (val) =>
                val!.isEmpty ? "Enter farmer name" : null,
              ),

              // Farmer phone
              TextFormField(
                controller: _farmerPhoneController,
                decoration:
                const InputDecoration(labelText: "Farmer Phone"),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                val!.isEmpty ? "Enter farmer phone" : null,
              ),

              const SizedBox(height: 10),

              // Service dropdown
              DropdownButtonFormField<int>(
                value: _selectedServiceId,
                items: services.map((s) {
                  return DropdownMenuItem<int>(
                    value: s["id"],
                    child: Text(s["name"]),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedServiceId = val;
                    _unitTypeOptions.clear();
                    _selectedUnitType = null;
                  });
                  if (val != null) {
                    _fetchRateByService(val);
                  }
                },
                decoration:
                const InputDecoration(labelText: "Select Service"),
                validator: (val) =>
                val == null ? "Please select a service" : null,
              ),

              const SizedBox(height: 10),

              // Unit type dropdown
              if (_unitTypeOptions.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedUnitType,
                  items: _unitTypeOptions.map((u) {
                    return DropdownMenuItem<String>(
                      value: u,
                      child: Text(u),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedUnitType = val;
                    });
                  },
                  decoration:
                  const InputDecoration(labelText: "Select Unit Type"),
                  validator: (val) =>
                  val == null ? "Please select unit type" : null,
                ),

              const SizedBox(height: 10),

              // Date Picker with Time
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _expectedDate == null
                          ? "No Date Chosen"
                          : DateFormat("yyyy-MM-dd HH:mm")
                          .format(_expectedDate!),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _pickDate(context),
                    child: const Text("Pick Date & Time"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Conditional fields with UNIT HEADER (ALL SIDE BY SIDE)
              if (_selectedUnitType != null) ...[
                Text(
                  "Unit: $_selectedUnitType",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
              ],

              if (_selectedUnitType == "AREA") ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _acresController,
                        decoration: const InputDecoration(labelText: "Acres"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _guntasController,
                        decoration: const InputDecoration(labelText: "Guntas"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ] else if (_selectedUnitType == "TIME") ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hoursController,
                        decoration: const InputDecoration(labelText: "Hours"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _minutesController,
                        decoration: const InputDecoration(labelText: "Minutes"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ] else if (_selectedUnitType == "DISTANCE") ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _kmController,
                        decoration:
                        const InputDecoration(labelText: "Kilometers"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _meterController,
                        decoration: const InputDecoration(labelText: "Meters"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitBooking,
                child: const Text("Submit Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}