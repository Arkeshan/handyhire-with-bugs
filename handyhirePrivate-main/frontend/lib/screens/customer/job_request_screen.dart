import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'app_colors.dart';
import 'finding_provider_screen.dart';
import 'job_status_provider.dart';
import 'home_screen.dart';
import '../../services/cloudinary_service.dart';

class JobRequestScreen extends StatefulWidget {
  final Map<String, dynamic>? selectedProvider;

  const JobRequestScreen({super.key, this.selectedProvider});

  @override
  State<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends State<JobRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  InputDecoration _inputDec(String hint, {IconData? icon}) => InputDecoration(
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
    filled: true,
    fillColor: AppColors.secondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.white54),
  );

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text(
                'Camera',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text(
                'Gallery',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null)
        setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Create Job Request",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          children: [
            TextFormField(
              validator: (v) => v!.isEmpty ? "Title is required" : null,
              decoration: _inputDec("Job Title", icon: Icons.work_outline),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextFormField(
              validator: (v) => v!.isEmpty ? "Description is required" : null,
              maxLines: 3,
              decoration: _inputDec("Job Description"),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildDateTimePicker(),
            const SizedBox(height: 15),
            TextFormField(
              decoration: _inputDec(
                "Address",
                icon: Icons.location_on_outlined,
              ),
              validator: (v) => v!.isEmpty ? "Address is required" : null,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 15),
            TextFormField(
              decoration: _inputDec(
                "Budget (Optional)",
                icon: Icons.attach_money,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _submitRequest,
                child: const Text(
                  "Submit Request",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return _imageFile == null
        ? InkWell(
            onTap: _pickImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: Colors.white54, size: 30),
                  SizedBox(height: 8),
                  Text(
                    "Add Job Photos",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          )
        : Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  _imageFile!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 15,
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
                onPressed: () => setState(() => _imageFile = null),
              ),
            ],
          );
  }

  Widget _buildDateTimePicker() {
    return ListTile(
      tileColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      leading: const Icon(Icons.calendar_today, color: AppColors.accent),
      title: Text(
        _selectedDate == null
            ? "Schedule Date & Time"
            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} at ${_selectedTime!.format(context)}",
        style: TextStyle(
          color: _selectedDate == null ? Colors.white54 : Colors.white,
        ),
      ),
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          if (!mounted) return;
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              _selectedDate = date;
              _selectedTime = time;
            });
          }
        }
      },
    );
  }

  void _submitRequest() async {
    // NOTE: Added 'async' here
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a date and time for the job"),
        ),
      );
      return;
    }

    // 1. Show a loading indicator so the user knows it's uploading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    String? finalImageUrl;

    // 2. Upload the image to Cloudinary if one was selected
    if (_imageFile != null) {
      finalImageUrl = await CloudinaryService.uploadImage(_imageFile!);

      if (finalImageUrl == null) {
        // Pop the loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to upload image. Please try again."),
          ),
        );
        return;
      }
    }

    // Pop the loading dialog now that upload is done!
    if (mounted) Navigator.pop(context);

    // TODO: Send finalImageUrl and the rest of the form data to your Spring Boot Backend here!
    // ApiService.instance.createJobRequest(title, description, finalImageUrl, etc...);

    // 3. Proceed with the rest of your app logic
    JobStatusProvider.isSearching = true;

    if (widget.selectedProvider != null) {
      JobStatusProvider.targetProvider = widget.selectedProvider!["name"];
      JobStatusProvider.updateStatus(
        "Requesting ${JobStatusProvider.targetProvider}...",
        0,
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else {
      JobStatusProvider.targetProvider = null;
      JobStatusProvider.updateStatus("Finding nearby providers...", 0);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FindingProviderScreen()),
        (route) => false,
      );
    }
  }
}
