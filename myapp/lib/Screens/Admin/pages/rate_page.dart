import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/dto/farmerservice.dart';
import 'package:myapp/services/farmservices.dart';
import 'package:myapp/dto/rate_model.dart';
import 'package:myapp/services/rate_service.dart';

class RatePage extends StatefulWidget {
  const RatePage({Key? key}) : super(key: key);

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  final List<Service> _services = [];
  final List<RateDTO> _rates = [];

  final _rateAmountController = TextEditingController();
  final _unitTypes = ['AREA', 'TIME', 'DISTANCE'];
  final Map<String, List<String>> _unitSubTypes = {
    'AREA': ['ACRE', 'GUNTA'],
    'TIME': ['HOUR', 'MINUTE'],
    'DISTANCE': ['KM', 'METER'],
  };

  Service? _selectedService;
  String? _selectedUnitType;
  String? _selectedSubType;
  RateDTO? _editingRate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadRates();
  }

  Future<void> _loadServices() async {
    final fetchedServices = await FarmerService.fetchAllServices();
    setState(() {
      _services.clear();
      _services.addAll(fetchedServices);
    });
  }

  Future<void> _loadRates() async {
    final fetchedRates = await RateService.fetchAllRates();
    setState(() {
      _rates.clear();
      _rates.addAll(fetchedRates);
    });
  }

  void _clearForm() {
    _rateAmountController.clear();
    setState(() {
      _selectedService = null;
      _selectedUnitType = null;
      _selectedSubType = null;
      _editingRate = null;
      _errorMessage = null;
    });
  }

  void _submitRate() async {
    final rateAmount = _rateAmountController.text.trim();
    if (rateAmount.isEmpty ||
        _selectedService == null ||
        _selectedUnitType == null ||
        _selectedSubType == null) {
      setState(() {
        _errorMessage = 'All fields are required.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final dto = CreateRateDTO(
      unitType: _selectedUnitType!,
      subUnitType: _selectedSubType!,
      rateAmount: double.tryParse(rateAmount) ?? 0.0,
      serviceId: _selectedService!.serviceId!,
    );

    bool success = false;

    if (_editingRate == null) {
      final created = await RateService.createService(dto);
      success = created != null;
    } else {
      success = await RateService.updateService(dto);
    }

    if (success) {
      await _loadRates();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingRate == null ? 'Rate created' : 'Rate updated')),
      );
    }
  }

  void _editRate(RateDTO rate) {
    final service = _services.firstWhere((s) => s.serviceId == rate.serviceId, orElse: () => _services.first);
    setState(() {
      _editingRate = rate;
      _selectedService = service;
      _selectedUnitType = rate.unitType;
      _selectedSubType = rate.subUnit;
      _rateAmountController.text = rate.rateAmount.toString();
    });
  }

  void _deleteRate(int? rateId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Rate"),
        content: const Text("Are you sure you want to delete this rate?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await RateService.deleteService(rateId);
      if (success) {
        await _loadRates();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rate deleted")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingRate != null;

    return Scaffold(
      appBar: AppBar(title: const Text("Service Rate Management")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              isEditing ? "Edit Rate" : "Add Rate",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<Service>(
              value: _selectedService,
              onChanged: (Service? newValue) {
                setState(() {
                  _selectedService = newValue;
                });
              },
              items: _services.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text('${s.serviceName} (${s.serviceId})'),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Select Service'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedUnitType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUnitType = newValue;
                  _selectedSubType = null;
                });
              },
              items: _unitTypes
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Select Unit Type'),
            ),
            if (_selectedUnitType != null)
              DropdownButtonFormField<String>(
                value: _selectedSubType,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubType = newValue;
                  });
                },
                items: _unitSubTypes[_selectedUnitType]!
                    .map((sub) => DropdownMenuItem(value: sub, child: Text(sub)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Select Sub Type'),
              ),
            TextField(
              controller: _rateAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Rate Amount'),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitRate,
                    child: Text(isEditing ? "Update" : "Create"),
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
                const Text("All Rates",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _loadRates,
                  child: const Text("Refresh"),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                key: ValueKey(_rates.length),
                itemCount: _rates.length,
                itemBuilder: (context, index) {
                  final rate = _rates[index];
                  return Card(
                    child: ListTile(
                      title: Text('Rate: ${rate.rateAmount.toString()}, Service: ${rate.serviceName}'),
                      subtitle: Text('${rate.unitType} - ${rate.subUnit}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editRate(rate),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRate(rate.rateId),
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
