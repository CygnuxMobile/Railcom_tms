import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../main.dart';
import '../../../utils/pref.dart';
import '../../../utils/tms_color.dart';
import '../../../widgets/app_size.dart';
import '../../../widgets/tms_button.dart';
import '../pod_controller.dart';

/// Show dialog to open settings if camera permission is denied
Future<void> _showCameraPermissionDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Camera Permission Required"),
      content: const Text("To capture POD images, please allow camera access in app settings."),
      actions: [
        TextButton(
          child: const Text("Open Settings"),
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// Pick multiple images from gallery (no storage permission required on modern Android)
Future<List<File>?> imagesFromGallery(BuildContext context) async {
  final List<XFile>? selectedFiles = await ImagePicker().pickMultiImage(imageQuality: 50);
  if (selectedFiles != null && selectedFiles.isNotEmpty) {
    return selectedFiles.map((file) => File(file.path)).toList();
  }
  return null;
}

/// Pick single image from camera
Future<File?> imageFromCamera(BuildContext context) async {
  PermissionStatus status = await Permission.camera.request();
  if (status.isGranted) {
    final XFile? capturedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    if (capturedFile != null) {
      return File(capturedFile.path);
    }
  } else if (status.isPermanentlyDenied) {
    _showCameraPermissionDialog(context);
  }
  return null;
}

/// Determines whether the next image should be Front ("F") or Back ("B")
String getNextImageType(List<String> currentImages) {
  bool hasFront = currentImages.any((path) => path.contains('@_F@'));
  bool hasBack = currentImages.any((path) => path.contains('@_B@'));
  if (!hasFront) return "F";
  if (!hasBack) return "B";
  return "F";
}

/// Renames and saves image file directly into application cache directory
Future<File?> saveImageToCache({
  required File sourceFile,
  required String docket,
  required String imageType,
}) async {
  try {
    final Directory cacheDir = await getTemporaryDirectory();
    final Directory targetDir = Directory('${cacheDir.path}/pod_images');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      print("📁 Cache directory created: ${targetDir.path}");
    }

    final String cleanDocket = docket.trim();
    final String cleanUserId = Pref().getUserId().trim();
    final String cleanBranch = Pref().getBranchCode().trim();
    final String imageName = "P@${cleanDocket}@_${imageType}@${cleanUserId}@${cleanBranch}.jpg";
    final String newPath = '${targetDir.path}/$imageName';

    final File targetFile = File(newPath);
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final File savedFile = await sourceFile.copy(newPath);
    print("✅ Saved & renamed image in cache: ${savedFile.path}");
    return savedFile;
  } catch (e) {
    print("⚠️ Error saving image to cache: $e");
    return null;
  }
}

/// Grid view of selected images with delete option
Widget imageView({
  required RxList<String> pickImage,
  required String dockNo,
  required PodUploadController podUploadController,
}) {
  return GridView.builder(
    scrollDirection: Axis.horizontal,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1,
    ),
    itemCount: pickImage.length,
    itemBuilder: (context, index) {
      print("🖼️ Rendering image at index $index: ${pickImage[index]}");
      return Stack(
        children: [
          Container(
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 2, color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(pickImage[index]),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("⚠️ Error loading image: $error");
                  return const Center(child: Text('Image error'));
                },
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () {
                final imagePath = pickImage[index];
                final file = File(imagePath);

                podDb.clearImageByPath(path: imagePath, dockNo: dockNo);

                if (file.existsSync()) {
                  try {
                    file.deleteSync();
                    print("🗑️ File deleted: $imagePath");
                  } catch (e) {
                    print("⚠️ Error deleting file: $e");
                  }
                }

                pickImage.removeAt(index);

                if (pickImage.isEmpty) {
                  podDb.changeButtonName(buttonName: "Upload Pod", dockNo: dockNo);
                  podDb.changePodStatus(status: "No images uploaded", dockNo: dockNo);
                }

                podUploadController.podList.value = podDb.getAllDocket();
              },
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.red, size: 20),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Main Image Picker Widget
Widget podImagePicker({
  required PodUploadController podUploadController,
  required BuildContext context,
  required RxList<String> pickImage,
  required String docket,
  required int index,
}) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 5,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Pick Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// CAMERA BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (pickImage.length >= 2) {
                      Get.snackbar(
                        'Limit reached',
                        'You can only select up to 2 images.',
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    print("📸 Camera button tapped");
                    File? image = await imageFromCamera(context);
                    if (image == null) return;
                    print("📸 Raw Image Picked: ${image.path}");

                    String imageType = getNextImageType(pickImage);
                    File? savedImage = await saveImageToCache(
                      sourceFile: image,
                      docket: docket,
                      imageType: imageType,
                    );

                    if (savedImage != null && await savedImage.exists()) {
                      pickImage.add(savedImage.path);
                      print("📝 Added to pickImage list: ${savedImage.path}");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: const Color(0xffe5eeff),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            color: AppColor.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Camera',
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// GALLERY BUTTON
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (pickImage.length >= 2) {
                      Get.snackbar(
                        'Limit reached',
                        'You can only select up to 2 images.',
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }

                    print("🖼️ Gallery button tapped");
                    List<File> images = await imagesFromGallery(context) ?? [];
                    if (images.isEmpty) return;
                    print("🖼️ Gallery selected: ${images.length} files");

                    int remainingSlots = 2 - pickImage.length;
                    List<File> selectedImages = images.take(remainingSlots).toList();

                    for (var original in selectedImages) {
                      if (pickImage.length >= 2) break;
                      String imageType = getNextImageType(pickImage);
                      File? savedFile = await saveImageToCache(
                        sourceFile: original,
                        docket: docket,
                        imageType: imageType,
                      );
                      if (savedFile != null && await savedFile.exists()) {
                        pickImage.add(savedFile.path);
                        print("🖼️ Saved gallery file: ${savedFile.path}");
                      }
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: const Color(0xffe5eeff),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image,
                            color: AppColor.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Gallery',
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

            /// Image View & Add Button (Observable)
            Obx(() {
              if (pickImage.isEmpty) {
                return const SizedBox();
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 25),
                  SizedBox(
                    height: AppSize.size(context).height * 0.12,
                    child: imageView(
                      pickImage: pickImage,
                      dockNo: docket,
                      podUploadController: podUploadController,
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: TmsButton(
                      text: "+ Add",
                      color: AppColor.primaryColor,
                      onPressed: () {
                        if (pickImage.length < 2) {
                          Get.snackbar(
                            'Add Both Images',
                            'Please add both Front and Back images before submitting.',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        podDb.changePodStatus(
                          status: "Images uploaded - Pending submission",
                          dockNo: docket,
                        );
                        podDb.changeButtonName(buttonName: "Edit Pod", dockNo: docket);
                        podDb.imageInsert(dockNo: docket, podImage: pickImage.toList());
                        podUploadController.podList.value = podDb.getAllDocket();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
  );
}
