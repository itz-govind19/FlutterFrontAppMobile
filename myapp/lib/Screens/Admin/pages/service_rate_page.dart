import 'package:flutter/material.dart';
import 'package:myapp/dto/farmerservice.dart';  // Make sure you have a Service model
import 'package:myapp/services/farmservices.dart'; // Service for CRUD
import 'package:myapp/dto/vehicle_model.dart'; // For vehicle dropdown
import 'package:myapp/services/vehicle_service.dart'; // Vehicle service for fetching vehicles

class ServiceRatePage extends StatefulWidget {
  const ServiceRatePage({Key? key}) : super(key: key);

  @override
  State<ServiceRatePage> createState() => _ServiceRatePageState();
}

class _ServiceRatePageState extends State<ServiceRatePage> {
  final List<Service> _services = [];
  final List<Vehicle> _vehicles = [];
  final _serviceNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Vehicle? _selectedVehicle;
  Service? _editingService;  // To track if we're editing an existing service

  String? _errorMessage;  // To hold error messages

  @override
  void initState() {
    super.initState();
    _loadVehicles();  // Load vehicles for the dropdown
    _loadServices();  // Load existing services
  }

  // Fetch all vehicles to populate the dropdown
  Future<void> _loadVehicles() async {
    final fetchedVehicles = await VehicleService.fetchAllVehicles();
    setState(() {
      _vehicles.clear();
      _vehicles.addAll(fetchedVehicles);
    });
  }

  // Fetch all services
  Future<void> _loadServices() async {
    final fetchedServices = await FarmerService.fetchAllServices();
    setState(() {
      _services.clear();
      _services.addAll(fetchedServices);
    });
  }

  // Clear form inputs
  void _clearForm() {
    _serviceNameController.clear();
    _descriptionController.clear();
    setState(() {
      _errorMessage = null;
      _selectedVehicle = null;  // Reset selected vehicle
      _editingService = null;   // Reset editing state
    });
  }

  // Submit the service (add or update)
  void _submitService() async {
    final serviceName = _serviceNameController.text.trim();
    final description = _descriptionController.text.trim();

    // Validate fields
    if (serviceName.isEmpty || description.isEmpty || _selectedVehicle == null) {
      setState(() {
        _errorMessage = 'All fields are mandatory. Please fill them in.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    if (_editingService == null) {
      // Add service
      final newService = Service(
        serviceName: serviceName,
        description: description,
        vehicleId: _selectedVehicle!.vehicleId!,
      );
      final createdService = await FarmerService.createService(newService);
      if (createdService != null) {
        setState(() {
          _services.add(createdService);
        });
        _clearForm();
      }
    } else {
      // Update service
      final updatedService = Service(
        serviceId: _editingService!.serviceId,
        serviceName: serviceName,
        description: description,
        vehicleId: _selectedVehicle!.vehicleId!,
      );
      final success = await FarmerService.updateService(updatedService);
      if (success) {
        await _loadServices();  // Reload services
        _clearForm();
      }
    }
  }

  // Start editing a service
  void _startEditing(Service service) {
    setState(() {
      _editingService = service;
      _serviceNameController.text = service.serviceName;
      _descriptionController.text = service.description;
      _selectedVehicle = _vehicles.firstWhere((v) => v.vehicleId == service.vehicleId);
    });
  }

  // Delete a service
  Future<void> _deleteService(int id) async {
    final success = await FarmerService.deleteService(id);
    if (success) {
      setState(() {
        _services.removeWhere((service) => service.serviceId == id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingService != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Service Rate Management")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              isEditing ? "Edit Service" : "Add Service",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _serviceNameController,
              decoration: const InputDecoration(labelText: 'Service Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Service Description'),
            ),
            DropdownButtonFormField<Vehicle>(
              value: _selectedVehicle,
              onChanged: (Vehicle? newValue) {
                setState(() {
                  _selectedVehicle = newValue;
                });
              },
              items: _vehicles.map((vehicle) {
                return DropdownMenuItem<Vehicle>(
                  value: vehicle,
                  child: Text('${vehicle.model} (${vehicle.vehicleType})'),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Vehicle'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _submitService,
                    icon: Icon(isEditing ? Icons.save : Icons.add),
                    label: Text(isEditing ? "Update Service" : "Add Service"),
                  ),
                ),
                const SizedBox(width: 10),
                if (isEditing)
                  TextButton(
                    onPressed: _clearForm,
                    child: const Text("Cancel"),
                  ),
              ],
            ),
            const Divider(height: 30),
            const Text(
              "All Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Card(
                    child: ListTile(
                      title: Text(service.serviceName),
                      subtitle: Text("Vehicle: ${service.vehicleId} - ${service.description}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _startEditing(service),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteService(service.serviceId!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
