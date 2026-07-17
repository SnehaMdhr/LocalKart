import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localkart/app/theme/app_colors.dart';
import 'package:localkart/core/api/api_client.dart';
import 'package:localkart/core/api/api_endpoints.dart';
import 'package:localkart/core/services/storage/user_session_service.dart';
import 'package:localkart/core/utils/snackbar_utils.dart';
import 'package:localkart/core/widgets/app_background.dart';
import 'package:localkart/core/widgets/custom_button.dart';
import 'package:localkart/feature/auth/presentation/view_model/auth_view_model.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _imageFile;
  String? _existingImageUrl;
  bool _isSaving = false;
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final session = ref.read(userSessionServiceProvider);
    final authState = ref.read(authViewModelProvider);
    final user = authState.authEntity;

    _nameController.text = user?.name ?? session.getCurrentUserName() ?? '';
    _emailController.text = user?.email ?? session.getCurrentUserEmail() ?? '';
    _phoneController.text = user?.phone ?? session.getCurrentUserPhone() ?? '';
    final imageUrl = user?.imageUrl ?? session.getCurrentUserProfilePicture() ?? '';
    _existingImageUrl = imageUrl.isNotEmpty ? imageUrl : null;

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (mounted) _showPermissionDeniedDialog('Camera');
    } else {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Camera permission is required to take a photo.',
        );
      }
    }
    return false;
  }

  Future<bool> _requestGalleryPermission() async {
    // On Android 13+ (API 33+), the photo picker is used and doesn't need
    // storage permission. On iOS 14+, PHPicker is used and doesn't need
    // photo library permission either. We check anyway for older devices.
    Permission permission;
    if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
      return true;
    }

    // Try photos first (Android 13+ / iOS), fall back to storage
    permission = Permission.photos;
    var status = await permission.request();
    if (status.isGranted) return true;

    if (!status.isGranted) {
      permission = Permission.storage;
      status = await permission.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) _showPermissionDeniedDialog('Storage');
    } else {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Storage permission is required to access your gallery.',
        );
      }
    }
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    // Check and request permission before picking
    if (source == ImageSource.camera) {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) return;
    } else {
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Failed to pick image. Please try again.',
      );
    }
  }

  void _showPermissionDeniedDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            Text('$permissionName Permission',
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          ],
        ),
        content: Text(
          '$permissionName permission has been permanently denied. Please enable it from your device settings to access this feature.',
          style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Open Settings',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Profile Photo",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose how to set your profile picture",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _imagePickerOption(
                      icon: Icons.camera_alt_outlined,
                      label: "Camera",
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _imagePickerOption(
                      icon: Icons.photo_library_outlined,
                      label: "Gallery",
                      onTap: () {
                        Navigator.pop(ctx);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              if (_imageFile != null || _existingImageUrl != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _imageFile = null;
                      _existingImageUrl = null;
                    });
                  },
                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                  label: const Text(
                    "Remove current photo",
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _buildImageUrl() {
    if (_imageFile != null) return null;
    if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      if (_existingImageUrl!.startsWith('http://') || _existingImageUrl!.startsWith('https://')) {
        return _existingImageUrl;
      }
      return '${ApiEndpoints.mediaServerUrl}/${_existingImageUrl!.startsWith('/') ? _existingImageUrl!.substring(1) : _existingImageUrl}';
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final apiClient = ref.read(apiClientProvider);

      final formData = FormData.fromMap({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
      });

      if (_imageFile != null) {
        formData.files.add(MapEntry(
          'imageUrl',
          await MultipartFile.fromFile(
            _imageFile!.path,
            filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      // Backend expects PUT /auth/update-profile with multipart form data
      await apiClient.dio.put(
        ApiEndpoints.updateProfile,
        data: formData,
      );

      await ref.read(authViewModelProvider.notifier).fetchCurrentUser();

      final session = ref.read(userSessionServiceProvider);
      final authState = ref.read(authViewModelProvider);
      final user = authState.authEntity;
      if (user != null) {
        await session.saveUserSession(
          userId: user.userId ?? session.getCurrentUserId() ?? '',
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role ?? session.getCurrentUserRole(),
          profilePicture: user.imageUrl,
        );
      }

      if (!mounted) return;
      SnackbarUtils.showSuccess(context, "Profile updated successfully");
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, "Failed to update profile: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          /// Profile Picture
                          GestureDetector(
                            onTap: _showImagePickerOptions,
                            child: Stack(
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withOpacity(0.15),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundColor: AppColors.primaryExtraLight,
                                    backgroundImage: _buildImageUrl() != null
                                        ? NetworkImage(_buildImageUrl()!)
                                        : null,
                                    child: _imageFile != null
                                        ? ClipOval(
                                            child: Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                              width: 110,
                                              height: 110,
                                            ),
                                          )
                                        : _buildImageUrl() == null
                                            ? Text(
                                                _nameController.text.isNotEmpty
                                                    ? _nameController.text[0].toUpperCase()
                                                    : "U",
                                                style: const TextStyle(
                                                  fontSize: 42,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              )
                                            : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.white, width: 3),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: AppColors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// Edit Profile Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.96),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.textPrimary.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Update your personal information",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                /// Name
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Full Name",
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _nameController,
                                  hint: "John Doe",
                                  icon: Icons.person_outline,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Name is required";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                /// Email (non-changeable)
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Email Address",
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: "name@example.com",
                                  icon: Icons.email_outlined,
                                  readOnly: true,
                                  fillColor: AppColors.inputFill,
                                ),
                                const SizedBox(height: 20),

                                /// Phone
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Phone Number",
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _phoneController,
                                  hint: "98XXXXXXXX",
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 28),

                                /// Save Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: CustomButton(
                                    text: "Save Changes",
                                    isLoading: _isSaving,
                                    onPressed: _saveProfile,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    Color? fillColor,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 20, color: readOnly ? AppColors.textSecondary : AppColors.primary),
        filled: true,
        fillColor: fillColor ?? AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      style: TextStyle(
        color: readOnly ? AppColors.textSecondary : AppColors.textPrimary,
        fontWeight: readOnly ? FontWeight.normal : FontWeight.w500,
      ),
    );
  }
}
