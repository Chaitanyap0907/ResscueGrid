import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/dimensions.dart';
import '../../data/models/enums.dart';
import '../../data/mock/rescue_grid_state.dart';
import '../../widgets/category_tile.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/rg_text_field.dart';
import '../../widgets/campus_map_panel.dart';

class ReportEmergencyScreen extends StatefulWidget {
  final IncidentCategory? initialCategory;

  const ReportEmergencyScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<ReportEmergencyScreen> createState() => _ReportEmergencyScreenState();
}

class _ReportEmergencyScreenState extends State<ReportEmergencyScreen> {
  late IncidentCategory _selectedCategory;
  String _selectedPeopleAffected = '1';
  final _descriptionController = TextEditingController();
  final _locationNameController = TextEditingController(text: 'Central Library, 2nd Floor');
  final _locationDetailController = TextEditingController(text: 'East Wing Study Carrel #42');
  Uint8List? _attachedPhotoBytes;
  String? _attachedPhotoName;
  int? _attachedPhotoSizeBytes;
  bool _isPickingPhoto = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? IncidentCategory.medical;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationNameController.dispose();
    _locationDetailController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isPickingPhoto = true);
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final length = bytes.length;
        setState(() {
          _attachedPhotoBytes = bytes;
          _attachedPhotoName = pickedFile.name.isNotEmpty
              ? pickedFile.name
              : 'attached_evidence_${DateTime.now().millisecondsSinceEpoch}.jpg';
          _attachedPhotoSizeBytes = length;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(PhosphorIconsFill.checkCircle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Photo attached from local storage: ${_attachedPhotoName!}'),
                  ),
                ],
              ),
              backgroundColor: RgColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image from storage: $e'),
            backgroundColor: RgColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingPhoto = false);
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsBold.cameraPlus, color: RgColors.primaryAccent, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Attach Photo from Storage',
                        style: RgTypography.subheading.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Select a photo from local files/gallery or capture a live camera photo.',
                    style: RgTypography.caption.copyWith(color: RgColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: RgColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsRegular.folderSimplePlus, color: RgColors.primaryAccent, size: 22),
                  ),
                  title: const Text('Choose from Local Files / Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Attach photo from device files or album'),
                  trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: RgColors.secondaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(PhosphorIconsRegular.camera, color: RgColors.secondary, size: 22),
                  ),
                  title: const Text('Take Live Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Capture incident scene directly'),
                  trailing: const Icon(PhosphorIconsRegular.caretRight, size: 16),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _previewPhotoDialog(BuildContext context) {
    if (_attachedPhotoBytes == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.black.withOpacity(0.7),
                elevation: 0,
                title: Text(
                  _attachedPhotoName ?? 'Attached Photo Evidence',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                leading: IconButton(
                  icon: const Icon(PhosphorIconsRegular.x, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: InteractiveViewer(
                  child: Image.memory(
                    _attachedPhotoBytes!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitReport() {
    setState(() => _isSending = true);

    final state = context.read<RescueGridState>();
    final newIncident = state.reportEmergency(
      category: _selectedCategory,
      locationName: _locationNameController.text,
      locationDetail: _locationDetailController.text,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Emergency assistance requested via RescueGrid reporting.',
      peopleAffected: _selectedPeopleAffected,
      photoBytes: _attachedPhotoBytes,
      photoAsset: null,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _isSending = false);
      context.go('/student/tracking/${newIncident.id}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Report Emergency'),
        leading: IconButton(
          icon: const Icon(PhosphorIconsRegular.x, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: RgColors.secondaryLight,
              borderRadius: BorderRadius.circular(RgDimensions.radiusFull),
            ),
            child: Row(
              children: [
                const Icon(PhosphorIconsBold.warningOctagon, size: 14, color: RgColors.secondary),
                const SizedBox(width: 4),
                Text(
                  'PRIORITY DISPATCH',
                  style: RgTypography.badgeLabel.copyWith(
                    color: RgColors.secondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Auto-detected Location Card
                  Text(
                    '1. CONFIRM GPS LOCATION',
                    style: RgTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: RgColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(RgDimensions.radiusCard),
                      border: Border.all(color: RgColors.border),
                      boxShadow: RgDimensions.cardShadow,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Mini Map Preview
                        const CampusMapPanel(
                          height: 120,
                          showFloatingEta: false,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(PhosphorIconsRegular.mapPin, color: RgColors.primaryAccent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _locationNameController.text,
                                      style: RgTypography.subheading.copyWith(fontSize: 14),
                                    ),
                                    Text(
                                      _locationDetailController.text,
                                      style: RgTypography.caption.copyWith(color: RgColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: RgColors.successLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'GPS Â±6 m',
                                  style: RgTypography.caption.copyWith(
                                    color: RgColors.success,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Category Selector
                  Text(
                    '2. EMERGENCY CATEGORY',
                    style: RgTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: RgColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: IncidentCategory.values.map((cat) {
                      return CategoryChip(
                        category: cat,
                        isSelected: _selectedCategory == cat,
                        onTap: () => setState(() => _selectedCategory = cat),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 3. People Affected (Segmented Control)
                  Text(
                    '3. ESTIMATED PEOPLE AFFECTED',
                    style: RgTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: RgColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: RgColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(RgDimensions.radiusButton),
                      border: Border.all(color: RgColors.border),
                    ),
                    child: Row(
                      children: ['1', '2â€“5', '5+'].map((count) {
                        final isSelected = _selectedPeopleAffected == count;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeopleAffected = count),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isSelected ? RgDimensions.cardShadow : const [],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                count == '1'
                                    ? '1 Person'
                                    : (count == '2â€“5' ? '2â€“5 People' : '5+ (Mass)'),
                                style: RgTypography.caption.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? RgColors.textPrimary : RgColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Photo Evidence (Manual Local Storage Attachment)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '4. PHOTO ATTACHMENT (LOCAL STORAGE)',
                        style: RgTypography.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: RgColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      if (_attachedPhotoBytes != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: RgColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(PhosphorIconsFill.checkCircle, size: 12, color: RgColors.success),
                              const SizedBox(width: 4),
                              Text(
                                'ATTACHED',
                                style: RgTypography.badgeLabel.copyWith(
                                  color: RgColors.success,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_attachedPhotoBytes == null)
                    InkWell(
                      onTap: _isPickingPhoto ? null : _showImageSourceDialog,
                      borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: RgColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                          border: Border.all(
                            color: RgColors.borderStrong,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: RgColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: _isPickingPhoto
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : const Icon(
                                      PhosphorIconsBold.uploadSimple,
                                      color: RgColors.primaryAccent,
                                      size: 22,
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isPickingPhoto
                                      ? 'Opening device storage...'
                                      : 'Tap to attach photo from local storage',
                                  style: RgTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: RgColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Choose from device gallery or capture with camera',
                                  style: RgTypography.caption.copyWith(
                                    color: RgColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(RgDimensions.radiusInput),
                        border: Border.all(color: RgColors.success.withOpacity(0.5)),
                        boxShadow: RgDimensions.cardShadow,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _previewPhotoDialog(context),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _attachedPhotoBytes!,
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      PhosphorIconsRegular.magnifyingGlassPlus,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _attachedPhotoName ?? 'incident_evidence.jpg',
                                  style: RgTypography.caption.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Local storage Â· ${_formatFileSize(_attachedPhotoSizeBytes ?? _attachedPhotoBytes!.length)}',
                                  style: RgTypography.caption.copyWith(
                                    color: RgColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _showImageSourceDialog,
                                      child: Text(
                                        'Replace',
                                        style: RgTypography.caption.copyWith(
                                          color: RgColors.primaryAccent,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => _previewPhotoDialog(context),
                                      child: Text(
                                        'Preview',
                                        style: RgTypography.caption.copyWith(
                                          color: RgColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove photo',
                            icon: const Icon(PhosphorIconsRegular.trash, color: RgColors.error, size: 20),
                            onPressed: () {
                              setState(() {
                                _attachedPhotoBytes = null;
                                _attachedPhotoName = null;
                                _attachedPhotoSizeBytes = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // 5. Description Field (Optional)
                  Text(
                    '5. SITUATION DETAILS (OPTIONAL)',
                    style: RgTypography.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      color: RgColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RgTextField(
                    label: 'Description',
                    hint: 'Describe what happened (e.g. collapsed, conscious, fire smoke, suspect clothes)...',
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 200,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Sticky Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: RgColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'Send Emergency Report',
                  isDestructive: true,
                  icon: PhosphorIconsBold.warningOctagon,
                  isLoading: _isSending,
                  onPressed: _submitReport,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(PhosphorIconsRegular.broadcast, size: 12, color: RgColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      'Dispatch engine will alert nearest verified responders immediately',
                      style: RgTypography.caption.copyWith(
                        color: RgColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
