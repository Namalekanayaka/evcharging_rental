import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/charger/charger_bloc.dart';

/// Add/Edit Charger Page
/// Allows charger owners to add and manage their chargers
class AddChargerPage extends StatefulWidget {
  final Map<String, dynamic>? existingCharger;

  const AddChargerPage({Key? key, this.existingCharger}) : super(key: key);

  @override
  State<AddChargerPage> createState() => _AddChargerPageState();
}

class _AddChargerPageState extends State<AddChargerPage> {
  final _formKey = GlobalKey<FormState>();
  late GoogleMapController _mapController;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _pricePerKwhController;
  late TextEditingController _pricePerHourController;
  late TextEditingController _powerKwController;

  // Form fields
  String _chargerType = 'AC';
  double _latitude = 0;
  double _longitude = 0;
  bool _isPublic = true;
  bool _allowReservations = true;

  // Availability times
  final Map<int, Map<String, String>> _availability = {};

  final List<String> chargerTypes = ['AC', 'DC', 'FAST'];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeForm();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(
      text: widget.existingCharger?['name'] ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingCharger?['description'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingCharger?['address'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.existingCharger?['city'] ?? '',
    );
    _stateController = TextEditingController(
      text: widget.existingCharger?['state'] ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.existingCharger?['postalCode'] ?? '',
    );
    _pricePerKwhController = TextEditingController(
      text: widget.existingCharger?['pricePerKwh']?.toString() ?? '',
    );
    _pricePerHourController = TextEditingController(
      text: widget.existingCharger?['pricePerHour']?.toString() ?? '',
    );
    _powerKwController = TextEditingController(
      text: widget.existingCharger?['powerKw']?.toString() ?? '',
    );
  }

  void _initializeForm() {
    if (widget.existingCharger != null) {
      _chargerType = widget.existingCharger!['chargerType'] ?? 'AC';
      _latitude = widget.existingCharger!['latitude'] ?? 0;
      _longitude = widget.existingCharger!['longitude'] ?? 0;
      _isPublic = widget.existingCharger!['isPublic'] ?? true;
      _allowReservations = widget.existingCharger!['allowReservations'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _pricePerKwhController.dispose();
    _pricePerHourController.dispose();
    _powerKwController.dispose();
    super.dispose();
  }

  /// Set location from map
  void _selectLocationFromMap() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Select Location'),
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_latitude != 0 ? _latitude : 37.7749, 
                           _longitude != 0 ? _longitude : -122.4194),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (LatLng position) {
              Navigator.pop(context, position);
            },
            markers: {
              if (_latitude != 0 && _longitude != 0)
                Marker(
                  markerId: const MarkerId('charger'),
                  position: LatLng(_latitude, _longitude),
                ),
            },
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  /// Submit form
  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == 0 || _longitude == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    final chargerData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'chargerType': _chargerType,
      'powerKw': double.parse(_powerKwController.text),
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'postalCode': _postalCodeController.text,
      'latitude': _latitude,
      'longitude': _longitude,
      'pricePerKwh': double.parse(_pricePerKwhController.text),
      'pricePerHour': double.parse(_pricePerHourController.text),
      'isPublic': _isPublic,
      'allowReservations': _allowReservations,
    };

    if (widget.existingCharger != null) {
      context.read<ChargerBloc>().add(
        UpdateChargerEvent(
          chargerId: widget.existingCharger!['id'],
          name: _nameController.text,
          description: _descriptionController.text,
          type: _chargerType,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _postalCodeController.text,
          latitude: _latitude,
          longitude: _longitude,
          pricePerKwh: double.parse(_pricePerKwhController.text),
          pricePerHour: double.parse(_pricePerHourController.text),
          powerKw: double.parse(_powerKwController.text),
          isPublic: _isPublic,
          allowReservations: _allowReservations,
        ),
      );
    } else {
      context.read<ChargerBloc>().add(
        CreateChargerEvent(
          name: _nameController.text,
          description: _descriptionController.text,
          type: _chargerType,
          address: _addressController.text,
          city: _cityController.text,
          state: _stateController.text,
          postalCode: _postalCodeController.text,
          latitude: _latitude,
          longitude: _longitude,
          pricePerKwh: double.parse(_pricePerKwhController.text),
          pricePerHour: double.parse(_pricePerHourController.text),
          powerKw: double.parse(_powerKwController.text),
          isPublic: _isPublic,
          allowReservations: _allowReservations,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingCharger != null ? 'Edit Charger' : 'Add New Charger',
        ),
      ),
      body: BlocListener<ChargerBloc, ChargerState>(
        listener: (context, state) {
          if (state is ChargerCreated || state is ChargerUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Charger saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ChargerFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Charger Name
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Charger Name',
                      hintText: 'e.g., Tesla Supercharger #1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a charger name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add details about your charger',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Charger Specifications
                  const Text(
                    'Specifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Charger Type
                  DropdownButtonFormField<String>(
                    initialValue: _chargerType,
                    decoration: InputDecoration(
                      labelText: 'Charger Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: chargerTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _chargerType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Power
                  TextFormField(
                    controller: _powerKwController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Power (kW)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter power output';
                      }
                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Location Information
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Street Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // City and State
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'City required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'State required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Postal Code
                  TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Postal Code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Latitude and Longitude display
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Coordinates',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _latitude != 0 && _longitude != 0
                                        ? '$_latitude, $_longitude'
                                        : 'Not selected',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: _selectLocationFromMap,
                                icon: const Icon(Icons.location_on),
                                label: const Text('Select Location'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pricing
                  const Text(
                    'Pricing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Price per kWh
                  TextFormField(
                    controller: _pricePerKwhController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price per kWh (\$)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      try {
                        double.parse(value);
                      } catch (e) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Price per Hour
                  TextFormField(
                    controller: _pricePerHourController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price per Hour (\$)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Settings
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Public/Private toggle
                  CheckboxListTile(
                    value: _isPublic,
                    onChanged: (value) {
                      setState(() => _isPublic = value ?? true);
                    },
                    title: const Text('Make this charger public'),
                    subtitle: const Text('Allow other users to see and book this charger'),
                  ),

                  // Reservations toggle
                  CheckboxListTile(
                    value: _allowReservations,
                    onChanged: (value) {
                      setState(() => _allowReservations = value ?? true);
                    },
                    title: const Text('Allow reservations'),
                    subtitle: const Text('Users can reserve time slots in advance'),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  BlocBuilder<ChargerBloc, ChargerState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is ChargerLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: state is ChargerLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.existingCharger != null
                                      ? 'Update Charger'
                                      : 'Create Charger',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
