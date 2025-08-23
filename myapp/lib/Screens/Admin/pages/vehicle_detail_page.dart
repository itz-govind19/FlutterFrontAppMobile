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

  Vehicle? _editingVehicle; // Track which vehicle is being edited
  String? _errorMessage; // To hold error messages

  @override
  void initState() {
    super.initState();
    _loadVehicles(); // Fetch vehicles when page opens
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
    _editingVehicle = null;
    setState(() {
      _errorMessage = null; // Clear error message when form is cleared
    });
  }

  void _submitVehicle() async {
    final type = _typeController.text.trim();
    final model = _modelController.text.trim();
    final number = _numberController.text.trim();

    // Check if any field is empty and show error
    if (type.isEmpty || model.isEmpty || number.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are mandatory. Please fill them in.';
      });
      return;
    }

    setState(() {
      _errorMessage = null; // Clear error message on successful validation
    });

    if (_editingVehicle == null) {
      // Add vehicle
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
      }
    } else {
      // Update vehicle
      final updatedVehicle = Vehicle(
        vehicleId: _editingVehicle!.vehicleId,
        vehicleType: type,
        vehicleNumber: number,
        model: model,
        userName: widget.userName,
      );

      final success = await VehicleService.updateVehicle(updatedVehicle);
      if (success) {
        await _loadVehicles(); // Reload all vehicles from backend
        _clearForm();
      }
    }
  }

  Future<void> _deleteVehicle(int? id) async {
    if (id == null) return;
    final deleted = await VehicleService.deleteVehicle(id);
    if (deleted) {
      setState(() {
        _vehicles.removeWhere((v) => v.vehicleId == id);
      });
    }
  }

  void _startEditing(Vehicle vehicle) {
    setState(() {
      _editingVehicle = vehicle;
      _typeController.text = vehicle.vehicleType;
      _modelController.text = vehicle.model;
      _numberController.text = vehicle.vehicleNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingVehicle != null;

    return Scaffold(
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
            if (_errorMessage != null) // Display error message if any field is empty
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
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
                    onPressed: () {
                      setState(() {
                        _clearForm();
                      });
                    },
                    child: const Text("Cancel"),
                  ),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "All Vehicles",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _loadVehicles, // Refresh button to reload vehicles
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
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return Card(
                    child: ListTile(
                      title: Text(vehicle.model),
                      subtitle: Text("No: ${vehicle.vehicleNumber}, Type: ${vehicle.vehicleType}"),
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
    );
  }
}