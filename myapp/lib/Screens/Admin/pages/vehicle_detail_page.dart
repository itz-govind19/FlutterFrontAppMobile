import 'package:flutter/material.dart';
import 'package:myapp/dto/vehicle_model.dart';
import 'package:myapp/services/vehicle_service.dart';

class VehicleDetailPage extends StatefulWidget {
  final String userName;

  const VehicleDetailPage({Key? key, required this.userName}) : super(key: key);

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final List<Vehicle> _vehicles = [];
  final _typeController = TextEditingController();
  final _modelController = TextEditingController();
  final _numberController = TextEditingController();

  Vehicle? _editingVehicle;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final fetchedVehicles = await VehicleService.fetchAllVehicles();
    setState(() {
      _vehicles.clear();
      _vehicles.addAll(fetchedVehicles);
    });
  }

  void _clearForm() {
    _typeController.clear();
    _modelController.clear();
    _numberController.clear();
    setState(() {
      _editingVehicle = null;
      _errorMessage = null;
    });
  }

  Future<void> _submitVehicle() async {
    final type = _typeController.text.trim();
    final model = _modelController.text.trim();
    final number = _numberController.text.trim();

    if (type.isEmpty || model.isEmpty || number.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are mandatory.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    if (_editingVehicle == null) {
      final newVehicle = Vehicle(
        vehicleId: null,
        vehicleType: type,
        vehicleNumber: number,
        model: model,
        userName: widget.userName,
      );

      final created = await VehicleService.createVehicle(newVehicle);
      if (created != null) {
        setState(() {
          _vehicles.add(created);
        });
        _clearForm();
        _showSnackBar("Vehicle added successfully");
      }
    } else {
      final updatedVehicle = Vehicle(
        vehicleId: _editingVehicle!.vehicleId,
        vehicleType: type,
        vehicleNumber: number,
        model: model,
        userName: widget.userName,
      );

      final success = await VehicleService.updateVehicle(updatedVehicle);
      if (success) {
        await _loadVehicles();
        _clearForm();
        _showSnackBar("Vehicle updated successfully");
      }
    }
  }

  Future<void> _deleteVehicle(int? id) async {
    if (id == null) return;

    final confirm = await _showConfirmationDialog("Delete Vehicle", "Are you sure you want to delete this vehicle?");
    if (!confirm) return;

    final deleted = await VehicleService.deleteVehicle(id);
    if (deleted) {
      setState(() {
        _vehicles.removeWhere((v) => v.vehicleId == id);
      });
      _showSnackBar("Vehicle deleted successfully");
    }
  }

  Future<void> _startEditing(Vehicle vehicle) async {
    if (_editingVehicle != null && _editingVehicle!.vehicleId != vehicle.vehicleId) {
      final confirm = await _showConfirmationDialog(
        "Editing in Progress",
        "You're currently editing another vehicle. Do you want to discard changes?",
      );
      if (!confirm) return;
    }

    setState(() {
      _editingVehicle = vehicle;
      _typeController.text = vehicle.vehicleType;
      _modelController.text = vehicle.model;
      _numberController.text = vehicle.vehicleNumber;
    });
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Confirm")),
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

  @override
  Future<bool> didPopRoute() async {
    if (_editingVehicle != null) {
      final confirm = await _showConfirmationDialog("Unsaved Changes", "You have unsaved changes. Do you want to leave?");
      if (!confirm) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingVehicle != null;

    return WillPopScope(
      onWillPop: () async {
        if (_editingVehicle != null) {
          final confirm = await _showConfirmationDialog("Unsaved Changes", "You have unsaved changes. Leave anyway?");
          return confirm;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Vehicle Details")),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                isEditing ? "Edit Vehicle" : "Add Vehicle",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Vehicle Type (e.g. CAR)'),
              ),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
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
                      onPressed: _submitVehicle,
                      icon: Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? "Update Vehicle" : "Add Vehicle"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All Vehicles",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _loadVehicles,
                    child: const Text(
                      "Refresh List",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const Divider(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _vehicles[index];
                    return Card(
                      child: ListTile(
                        title: Text(vehicle.model),
                        subtitle:
                        Text("No: ${vehicle.vehicleNumber}, Type: ${vehicle.vehicleType}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _startEditing(vehicle),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteVehicle(vehicle.vehicleId),
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