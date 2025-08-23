import 'package:flutter/material.dart';
import 'package:myapp/dto/farmerservice.dart'; // Service model
import 'package:myapp/services/farmservices.dart'; // Service CRUD
import 'package:myapp/dto/vehicle_model.dart'; // Vehicle model
import 'package:myapp/services/vehicle_service.dart'; // Vehicle service

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
  Service? _editingService;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
    _loadServices();
  }

  Future<void> _loadVehicles() async {
    final fetchedVehicles = await VehicleService.fetchAllVehicles();
    setState(() {
      _vehicles.clear();
      _vehicles.addAll(fetchedVehicles);
    });
  }

  Future<void> _loadServices() async {
    final fetchedServices = await FarmerService.fetchAllServices();
    setState(() {
      _services.clear();
      _services.addAll(fetchedServices);
    });
  }

  void _clearForm() {
    _serviceNameController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedVehicle = null;
      _editingService = null;
      _errorMessage = null;
    });
  }

  Future<void> _submitService() async {
    final serviceName = _serviceNameController.text.trim();
    final description = _descriptionController.text.trim();

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
      final newService = Service(
        serviceName: serviceName,
        description: description,
        vehicleId: _selectedVehicle!.vehicleId!,
      );
      final created = await FarmerService.createService(newService);
      if (created != null) {
        setState(() {
          _services.add(created);
        });
        _clearForm();
        _showSnackBar("Service added successfully");
      }
    } else {
      final updatedService = Service(
        serviceId: _editingService!.serviceId,
        serviceName: serviceName,
        description: description,
        vehicleId: _selectedVehicle!.vehicleId!,
      );
      final success = await FarmerService.updateService(updatedService);
      if (success) {
        await _loadServices();
        _clearForm();
        _showSnackBar("Service updated successfully");
      }
    }
  }

  Future<void> _deleteService(int id) async {
    final confirm = await _showConfirmationDialog(
      "Delete Service",
      "Are you sure you want to delete this service?",
    );
    if (!confirm) return;

    final deleted = await FarmerService.deleteService(id);
    if (deleted) {
      setState(() {
        _services.removeWhere((s) => s.serviceId == id);
      });
      _showSnackBar("Service deleted successfully");
    }
  }

  Future<void> _startEditing(Service service) async {
    if (_editingService != null && _editingService!.serviceId != service.serviceId) {
      final confirm = await _showConfirmationDialog(
        "Editing in Progress",
        "You're currently editing another service. Discard current changes?",
      );
      if (!confirm) return;
    }

    setState(() {
      _editingService = service;
      _serviceNameController.text = service.serviceName;
      _descriptionController.text = service.description;
      _selectedVehicle = _vehicles.firstWhere(
            (v) => v.vehicleId == service.vehicleId,
        orElse: () => _vehicles.first,
      );
    });
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    ) ??
        false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getVehicleDisplayName(int vehicleId) {
    final vehicle = _vehicles.firstWhere(
          (v) => v.vehicleId == vehicleId,
      orElse: () => Vehicle(
        vehicleId: vehicleId,
        model: 'Unknown',
        vehicleType: 'Unknown',
        vehicleNumber: '',
        userName: '',
      ),
    );
    return '${vehicle.model} (${vehicle.vehicleType})';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingService != null;

    return WillPopScope(
      onWillPop: () async {
        if (isEditing) {
          final confirm = await _showConfirmationDialog(
            "Unsaved Changes",
            "You have unsaved changes. Leave anyway?",
          );
          return confirm;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Service Management")),
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
                      onPressed: () => _clearForm(),
                      child: const Text("Cancel"),
                    ),
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    "All Services",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _loadServices,
                    child: const Text(
                      "Refresh List",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const Divider(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    final vehicleName = _getVehicleDisplayName(service.vehicleId);
                    return Card(
                      child: ListTile(
                        title: Text(service.serviceName),
                        subtitle: Text("Vehicle: $vehicleName\n${service.description}"),
                        isThreeLine: true,
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
      ),
    );
  }
}