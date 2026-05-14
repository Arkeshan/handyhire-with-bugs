import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // UPDATED: Using Image Picker!
import '../../services/api_service.dart';
import '../../services/cloudinary_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  final ImagePicker _picker = ImagePicker(); // ADDED: Image Picker instance

  File? _idProofFile;
  String? _idProofFileName;
  
  File? _certificationFile;
  String? _certificationFileName;

  String _selectedRole = 'Register as Customer';
  final List<String> _roles = [
    'Register as Customer',
    'Register as Provider',
    'Register as Customer & Provider',
  ];

  String? _selectedProfession;
  final List<String> _professions = [
    'AC Technician',
    'Appliance Repair',
    'Carpenter',
    'Cleaner',
    'Electrician',
    'Gardener',
    'Mason',
    'Painter',
    'Pest Control',
    'Plumber',
    'Tiler',
    'Welder',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  // ADDED: The Camera vs Gallery Selection Menu
  Future<void> _pickImage(String title) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: const Color(0xFF1E355B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Take a Photo (Camera)', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      // Compress the image so it uploads to Cloudinary super fast
      final XFile? pickedFile = await _picker.pickImage(
        source: source, 
        imageQuality: 70, // Drop quality slightly more
        maxWidth: 800,    // Shrink max width
        maxHeight: 800,   // Shrink max height
      );      
      if (pickedFile != null) {
        setState(() {
          if (title.contains('NIC')) {
            _idProofFileName = pickedFile.name;
            _idProofFile = File(pickedFile.path);
          } else {
            _certificationFileName = pickedFile.name;
            _certificationFile = File(pickedFile.path);
          }
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? customValidator,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        style: const TextStyle(color: Color(0xFF0B1E3F)),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFC0C0C2),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF0B1E3F)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          counterText: "",
        ),
        validator: customValidator ??
            (value) {
              if (value == null || value.isEmpty) return 'Please enter $hint';
              return null;
            },
      ),
    );
  }

  Widget _buildFileUploadBox(String title, IconData icon) {
    String displayFileName = 'No image selected';
    if (title.contains('NIC') && _idProofFileName != null) {
      displayFileName = _idProofFileName!;
    } else if (title.contains('Certificates') && _certificationFileName != null) {
      displayFileName = _certificationFileName!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E355B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF8EBBFF).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _pickImage(title), // Triggers the Camera/Gallery menu!
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8EBBFF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: const Color(0xFF0B1E3F)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.camera_alt_outlined, color: Color(0xFFC0C0C2)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              displayFileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: displayFileName == 'No image selected'
                    ? Colors.white54
                    : Colors.greenAccent,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPendingApprovalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E355B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Icon(
            Icons.hourglass_top,
            color: Color(0xFFB18E44),
            size: 60,
          ),
          content: const Text(
            'Your account is pending approval.\n\nOur admin team will review your submitted documents and verify your profile. You will be notified once approved to start accepting jobs!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB18E44),
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Go To Login',
                style: TextStyle(
                  color: Color(0xFF0B1E3F),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isProviderOrBoth =
        _selectedRole == 'Register as Provider' ||
        _selectedRole == 'Register as Customer & Provider';

    return Scaffold(
      backgroundColor: const Color(0xFF0B1E3F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30.0,
              vertical: 10.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB18E44),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Join Handy Hire today',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Full Name',
                    icon: Icons.person,
                    customValidator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters long';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
                      ).hasMatch(value)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock,
                    isPassword: true,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 8) {
                        return 'Must be at least 8 characters';
                      }
                      if (value.length > 16) {
                        return 'Must be 16 characters or less';
                      }
                      if (!RegExp(r'[!@#\$&*~%^()\-+=_]').hasMatch(value)) {
                        return 'Must contain at least 1 special character';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    customValidator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match!';
                      }
                      return null;
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0C0C2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        dropdownColor: const Color(0xFFC0C0C2),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF0B1E3F),
                        ),
                        style: const TextStyle(
                          color: Color(0xFF0B1E3F),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        items: _roles
                            .map(
                              (String role) => DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() => _selectedRole = newValue!);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                    child: isProviderOrBoth
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                color: const Color(0xFF8EBBFF).withOpacity(0.3),
                                thickness: 1,
                                height: 40,
                              ),
                              Text(
                                'Professional Details',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8EBBFF),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _phoneController,
                                hint: 'Phone Number',
                                icon: Icons.phone,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                customValidator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (value.length != 10) {
                                    return 'Phone number must be exactly 10 digits';
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedProfession,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF0B1E3F),
                                  ),
                                  dropdownColor: const Color(0xFFC0C0C2),
                                  style: const TextStyle(
                                    color: Color(0xFF0B1E3F),
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFC0C0C2),
                                    hintText: 'Select Profession',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.handyman,
                                      color: Color(0xFF0B1E3F),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  items: _professions
                                      .map(
                                        (String prof) =>
                                            DropdownMenuItem<String>(
                                              value: prof,
                                              child: Text(prof),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(
                                      () => _selectedProfession = newValue,
                                    );
                                  },
                                  validator: (value) => value == null
                                      ? 'Please select a profession'
                                      : null,
                                ),
                              ),
                              _buildTextField(
                                controller: _experienceController,
                                hint: 'Years of Experience',
                                icon: Icons.timeline,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                              
                              _buildFileUploadBox(
                                'Upload NIC (Front & Back Images)',
                                Icons.badge,
                              ),
                              _buildFileUploadBox(
                                'Upload Work/Education Certificates (Images)',
                                Icons.school,
                              ),
                              
                              const SizedBox(height: 10),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFFB18E44),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB18E44),
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              
                              if (isProviderOrBoth) {
                                if (_idProofFile == null || _certificationFile == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please upload both your NIC and Certificate images'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }
                              }

                              setState(() => _isLoading = true);

                              try {
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;

                                String? finalIdProofUrl;
                                String? finalCertificationUrl;

                                if (isProviderOrBoth) {
                                  finalIdProofUrl = await CloudinaryService.uploadImage(_idProofFile!);
                                  finalCertificationUrl = await CloudinaryService.uploadImage(_certificationFile!);

                                  if (finalIdProofUrl == null || finalCertificationUrl == null) {
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Failed to upload images. Please check your connection and try again.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return; 
                                  }
                                }

                                List<String> rolesToRegister = [];
                                if (_selectedRole == 'Register as Customer') {
                                  rolesToRegister.add('CUSTOMER');
                                } else if (_selectedRole == 'Register as Provider') {
                                  rolesToRegister.add('PROVIDER');
                                } else {
                                  rolesToRegister.add('CUSTOMER');
                                  rolesToRegister.add('PROVIDER');
                                }

                                for (String role in rolesToRegister) {
                                  await ApiService.instance.register(
                                    name: name,
                                    email: email,
                                    password: password,
                                    role: role,
                                    phone: _phoneController.text.trim(),
                                    profession: _selectedProfession,
                                    experience: _experienceController.text.trim(),
                                    idProofName: role == 'PROVIDER' ? finalIdProofUrl : null,
                                    certificationName: role == 'PROVIDER' ? finalCertificationUrl : null,
                                  );
                                }

                                if (!mounted) return;
                                setState(() => _isLoading = false);

                                if (_selectedRole == 'Register as Customer') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Registration successful! Please login.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                } else {
                                  _showPendingApprovalDialog();
                                }
                              } catch (e) {
                                if (!mounted) return;
                                setState(() => _isLoading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Registration failed: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF0B1E3F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}