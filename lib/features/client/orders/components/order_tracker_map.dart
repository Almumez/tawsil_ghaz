import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/services/server_gate.dart';
import '../../../../gen/locale_keys.g.dart';
import '../../../../core/utils/extensions.dart';

class OrderTrackerMap extends StatefulWidget {
  final String orderId;

  const OrderTrackerMap({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderTrackerMap> createState() => _OrderTrackerMapState();
}

class _OrderTrackerMapState extends State<OrderTrackerMap> {
  GoogleMapController? _controller;
  Timer? _timer;
  LatLng? _deliveryLocation;
  bool _isLoading = true;
  String? _errorMessage;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchDeliveryLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _stopLocationUpdates();
    _controller?.dispose();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Call API every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchDeliveryLocation();
    });
  }

  void _stopLocationUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchDeliveryLocation() async {
    try {
      final response = await ServerGate.i.getFromServer(
        url: 'track-order/${widget.orderId}',
      );

      if (response.success) {
        final data = response.data;
        if (data['status'] == true && data['lat'] != null && data['lng'] != null) {
          final newLocation = LatLng(
            double.parse(data['lat'].toString()),
            double.parse(data['lng'].toString()),
          );
          
          setState(() {
            _deliveryLocation = newLocation;
            _isLoading = false;
            _errorMessage = null;
            _updateMarkers();
          });
          
          // Move camera to new position if controller is available
          if (_controller != null && _deliveryLocation != null) {
            _controller!.animateCamera(
              CameraUpdate.newLatLngZoom(_deliveryLocation!, 15),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = LocaleKeys.location_not_available.tr();
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.msg;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = LocaleKeys.something_went_wrong_please_try_again.tr();
      });
    }
  }

  void _updateMarkers() {
    if (_deliveryLocation == null) return;
    
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('delivery_person'),
        position: _deliveryLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(
          title: LocaleKeys.delivery_person.tr(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 50.r, color: Colors.grey),
                        SizedBox(height: 10.h),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: context.mediumText.copyWith(color: Colors.grey),
                        ),
                        SizedBox(height: 10.h),
                        TextButton(
                          onPressed: _fetchDeliveryLocation,
                          child: Text(LocaleKeys.retry.tr()),
                        ),
                      ],
                    ),
                  )
                : _deliveryLocation == null
                    ? Center(
                        child: Text(
                          LocaleKeys.location_not_available.tr(),
                          style: context.mediumText,
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _deliveryLocation!,
                          zoom: 15,
                        ),
                        markers: _markers,
                        onMapCreated: (controller) {
                          _controller = controller;
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        compassEnabled: true,
                        zoomControlsEnabled: true,
                      ),
      ),
    );
  }
} 