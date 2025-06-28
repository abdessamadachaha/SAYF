import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sayf/constants.dart';
import 'package:sayf/models/person.dart';
import 'package:sayf/views/success.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/product.dart';

class OrderScreen extends StatefulWidget {
  final Product product;
  final String customerId;


  const OrderScreen({
    super.key,
    required this.product,
    required this.customerId,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final supabase = Supabase.instance.client;
  DateTime? startDate;
  DateTime? endDate;
  final addressController = TextEditingController();
  bool isLoadingLocation = false;
  bool isPlacingOrder = false;
  final _formKey = GlobalKey<FormState>();
  List<DateTimeRange> _reservedDates = [];

  @override
  void initState() {
    super.initState();
    _fetchReservedDates();
  }

  double get totalPrice {
    if (startDate == null || endDate == null) return 0;
    int days = endDate!.difference(startDate!).inDays + 1;
    return days * (widget.product.price ?? 0);
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchReservedDates() async {
    final response = await supabase
        .from('orders')
        .select('start_day, end_day')
        .eq('product_id', widget.product.id)
        .or('status.eq.pending,status.eq.confirmed');

    setState(() {
      _reservedDates = response.map<DateTimeRange>((item) {
        final start = DateTime.parse(item['start_day']).toLocal();
        final end = DateTime.parse(item['end_day']).toLocal();
        return DateTimeRange(start: start, end: end);
      }).toList();
    });
  }

  Future<void> _getCurrentAddress() async {
    setState(() => isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services')),
        );
        setState(() => isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always && 
            permission != LocationPermission.whileInUse) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission required')),
          );
          setState(() => isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        addressController.text = [
          if (place.street != null) place.street,
          if (place.locality != null) place.locality,
          if (place.postalCode != null) place.postalCode,
          if (place.country != null) place.country,
        ].where((part) => part != null && part!.isNotEmpty).join(', ');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Address error: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

 Future<void> _selectDate(bool isStart) async {
  // Helper function to check if a date is selectable
  bool isDateSelectable(DateTime date) {
    for (final range in _reservedDates) {
      if (date.isAfter(range.start.subtract(const Duration(days: 1))) &&
          date.isBefore(range.end.add(const Duration(days: 1)))) {
        return false;
      }
    }
    return true;
  }

  // Get a safe initial date that passes the predicate
  DateTime getSafeInitialDate() {
    final now = DateTime.now();
    DateTime baseDate = isStart ? now : (startDate ?? now);
    
    for (int i = 0; i < 730; i++) { // Check for next 2 years
      final candidate = baseDate.add(Duration(days: i));
      if (isDateSelectable(candidate)) {
        return candidate;
      }
    }
    return baseDate; // Fallback
  }

  final DateTime? picked = await showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStart ? "Select Start Date" : "Select End Date",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: KprimaryColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: getSafeInitialDate(),
                  firstDate: isStart 
                      ? DateTime.now() 
                      : (startDate ?? DateTime.now()),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                  selectableDayPredicate: (day) {
                    // For end date, must be >= start date
                    if (!isStart && startDate != null && day.isBefore(startDate!)) {
                      return false;
                    }
                    return isDateSelectable(day);
                  },
                  onDateChanged: (date) {
                    Navigator.pop(context, date);
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();
                  if (isDateSelectable(now)) {
                    if (!isStart && startDate != null && now.isBefore(startDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("End date must be after start date"),
                        ),
                      );
                    } else {
                      Navigator.pop(context, now);
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Selected date is not available"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KprimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  "Select Today",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  if (picked != null && mounted) {
    setState(() {
      if (isStart) {
        startDate = picked;
        // Reset end date if it's now before the new start date
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
        }
      } else {
        endDate = picked;
      }
    });
  }
}

  Future<bool> _checkAvailability() async {
    for (final range in _reservedDates) {
      if (startDate!.isBefore(range.end) && endDate!.isAfter(range.start)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _placeOrder() async {
  if (!_formKey.currentState!.validate()) return;

  if (startDate == null || endDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select rental dates")),
    );
    return;
  }

  setState(() => isPlacingOrder = true);

  final available = await _checkAvailability();

  if (!available) {
    setState(() => isPlacingOrder = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("This product is already booked for selected dates.")),
    );
    return;
  }

  try {
    final response = await supabase
        .from('orders')
        .insert({
          'product_id': widget.product.id,
          'customer_id': widget.customerId,
          'tenant_id': widget.product.idTenant, // ✅ AJOUTÉ ICI
          'start_day': startDate!.toIso8601String(),
          'end_day': endDate!.toIso8601String(),
          'total_price': totalPrice,
          'address': addressController.text.trim(),
          'status': 'pending',
        })
        .select()
        .single();

    final userResponse = await supabase
        .from('users')
        .select()
        .eq('id', widget.customerId)
        .single();

    final Person currentUser = Person.fromMap(userResponse);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SuccessPaymentPage(person: currentUser),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}")),
    );
  } finally {
    if (mounted) {
      setState(() => isPlacingOrder = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Complete Order",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: KprimaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProductCard(),
              const SizedBox(height: 24),
              _buildAddressCard(),
              const SizedBox(height: 24),
              _buildDateSelectionCard(),
              const SizedBox(height: 24),
              _buildSummaryCard(),
              const SizedBox(height: 32),
              _buildConfirmButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: KprimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(widget.product.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Selection",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.name ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${(widget.product.price ?? 0).toStringAsFixed(2)} MAD/day",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: KprimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: addressController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter delivery address';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: "Enter delivery address",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: isLoadingLocation
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(KprimaryColor),
                      ),
                    )
                  : IconButton(
                      icon: Icon(
                        Icons.my_location,
                        color: KprimaryColor,
                      ),
                      onPressed: _getCurrentAddress,
                    ),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Rental Period",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: "Start Date",
                  date: startDate,
                  isRequired: true,
                  onPressed: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: "End Date",
                  date: endDate,
                  isRequired: true,
                  onPressed: startDate == null ? null : () => _selectDate(false),
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Duration:",
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "${endDate!.difference(startDate!).inDays + 1} days",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KprimaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KprimaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Subtotal:",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
              Text(
                "${(widget.product.price ?? 0).toStringAsFixed(2)} MAD",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (startDate != null && endDate != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rental Days:",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
                Text(
                  "${endDate!.difference(startDate!).inDays + 1}",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Price:",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "${totalPrice.toStringAsFixed(2)} MAD",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: KprimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required bool isRequired,
    required VoidCallback? onPressed,
  }) {
    final isError = isRequired && date == null;
    final color = isError ? Colors.red : KprimaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isError ? Colors.red : Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 24,
                  color: onPressed == null ? Colors.grey[400] : color,
                ),
                const SizedBox(height: 8),
                Text(
                  date == null ? label : DateFormat('MMM dd').format(date),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: onPressed == null
                        ? Colors.grey[400]
                        : isError
                            ? Colors.red
                            : Colors.black,
                  ),
                ),
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: KprimaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isPlacingOrder
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                "Confirm Order",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}