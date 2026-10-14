import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_dropdown_search.dart';
import '../../widgets/tms_button.dart';
import 'prs_generate_controller.dart';

class PRSGenerateScreen extends GetView<PRSGenerateController> {
  const PRSGenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate PRS', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff232F34),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section 1: Basic Details
                _buildSectionHeader("Basic Details"),
                _buildTextField(
                  "PRS Date",
                  controller.prsDateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);
                      controller.prsDateController.text = formattedDate;
                    }
                  },
                ),
                const SizedBox(height: 12),
                Obx(
                  () => QuickDocketDropdown(
                    text: "Select Vendor Type".obs,
                    label: "Vendor Type",
                    list: controller.vendorTypeList.map((e) => e.vendorType).toList(),
                    enabled: true.obs,
                    isSize: false,
                    isLoading: controller.isLoadingVendorTypes,
                    validator: (val) {
                      if (controller.selectedVendorType.value == null || val == null || val.trim().isEmpty) {
                        return 'Please select vendor type';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      var selected = controller.vendorTypeList.firstWhere((e) => e.vendorType == val);
                      controller.selectedVendorType.value = selected;
                      controller.selectedVendor.value = null;
                      controller.selectedVehicle.value = null;
                      controller.vendorList.clear();
                      controller.vehicleList.clear();
                      controller.manualVendorNameController.clear();
                      controller.manualVehicleNoController.clear();
                      controller.fetchVendors(selected.vendorType_Code);
                    },
                    selectedItem: controller.selectedVendorType.value?.vendorType.obs,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => QuickDocketDropdown(
                    text: "Select Vendor".obs,
                    label: "Vendor Code/Name",
                    list: controller.vendorList.map((e) => e.vendor_Name).toList(),
                    enabled: (controller.vendorList.isNotEmpty).obs,
                    isSize: false,
                    isLoading: controller.isLoadingVendors,
                    validator: (val) {
                      if (controller.selectedVendor.value == null || val == null || val.trim().isEmpty) {
                        return 'Please select vendor';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      var selected = controller.vendorList.firstWhere((e) => e.vendor_Name == val);
                      controller.selectedVendor.value = selected;
                      controller.selectedVehicle.value = null;
                      controller.manualVehicleNoController.clear();
                      controller.vehicleList.clear();
                      controller.fetchVehicles(selected.vendor_Code, controller.selectedVendorType.value?.vendorType_Code ?? "");
                    },
                    selectedItem: controller.selectedVendor.value?.vendor_Name.obs,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  "PAN No",
                  controller.panNoController,
                  maxLength: 10,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length != 10) {
                        return 'PAN number must be 10 characters';
                      }
                      RegExp panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                      if (!panRegex.hasMatch(value.trim().toUpperCase())) {
                        return 'Enter a valid PAN number (e.g. ABCDE1234F)';
                      }
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Section 2: Vehicle Details
                _buildSectionHeader("Vehicle Details"),
                Obx(() {
                  if (controller.selectedVendorType.value?.vendorType_Code == "XX") {
                    return Column(
                      children: [
                        _buildVehicleDigitSelector(),
                        const SizedBox(height: 12),
                        _buildTextField(
                          "Vehicle No.",
                          controller.manualVehicleNoController,
                          maxLength: controller.vehicleNoDigit.value,
                          textCapitalization: TextCapitalization.characters,
                          onChanged: (val) {
                            if (val.trim().length >= 8) {
                              controller.fetchVehicleDetails(val.trim());
                            }
                          },
                          onFieldSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              controller.fetchVehicleDetails(val.trim());
                            }
                          },
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty && value.trim().length != controller.vehicleNoDigit.value) {
                              return 'Vehicle number must be ${controller.vehicleNoDigit.value} digits/chars';
                            }
                            return null;
                          },
                        ),
                      ],
                    );
                  } else {
                    return _buildTextField(
                      "Vehicle No.",
                      controller.manualVehicleNoController,
                      maxLength: 10,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (val) {
                        if (val.trim().length >= 8) {
                          controller.fetchVehicleDetails(val.trim());
                        }
                      },
                      onFieldSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          controller.fetchVehicleDetails(val.trim());
                        }
                      },
                    );
                  }
                }),
                const SizedBox(height: 12),
                _buildTextField(
                  "Driver Name",
                  controller.driverNameController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  "Mobile No.",
                  controller.mobileNoController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      if (value.trim().length != 10) {
                        return 'Mobile number must be 10 digits';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'Enter a valid mobile number';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Section 3: Vehicle Depart Details
                _buildSectionHeader("Vehicle Depart Details"),
                _buildTextField(
                  "Loading Supervisor/User",
                  controller.loadingSupervisorController,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Start KMs.",
                        controller.startKmController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        "End KMs.",
                        controller.endKmController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Section 4: Docket Details
                _buildSectionHeader("Docket Details"),
                Row(
                  children: [
                    Expanded(child: _buildTextField("Cnote No", controller.cnoteNoController)),
                    const SizedBox(width: 10),
                    Obx(
                      () => InkWell(
                        onTap: controller.isLoadingAddCnote.value ? null : () => controller.addCnoteManual(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xff232F34)),
                          child: controller.isLoadingAddCnote.value
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xff232F34), width: 1),
                    color: Colors.white,
                  ),
                  child: Obx(() {
                    if (controller.selectedDockets.isEmpty) {
                      return const Center(
                        child: Text("No Cnotes added yet", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.selectedDockets.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        var docket = controller.selectedDockets[index];
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Docket No: ${docket.dockno}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text("Origin: ${docket.orgncd} | Pkgs: ${docket.pkgsno}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => controller.toggleDocketSelection(docket),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 28),
                Obx(() => TmsButton(text: "GENERATE PRS", size: const Size(double.infinity, 50), isLoading: controller.isLoadingSubmit.value, onPressed: () => controller.submitPRS())),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xff232F34),
            ),
          ),
          const SizedBox(height: 4),
          const Divider(thickness: 1, color: Color(0x33232F34)),
        ],
      ),
    );
  }

  Widget _buildVehicleDigitSelector() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xff232F34), width: 1),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Text(
              "Vehicle No. digit: ",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xff232F34),
              ),
            ),
            const Spacer(),
            ...[10, 9, 8, 7].map((digit) {
              bool isSelected = controller.vehicleNoDigit.value == digit;
              return InkWell(
                onTap: () => controller.vehicleNoDigit.value = digit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        size: 16,
                        color: isSelected ? const Color(0xff232F34) : Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "$digit",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: const Color(0xff232F34),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController textController, {
    bool readOnly = false,
    String? Function(String?)? validator,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    VoidCallback? onTap,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xff232F34), width: 1),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: textController,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        maxLength: maxLength,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }
}
