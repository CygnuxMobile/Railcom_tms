import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms_newui/moduls/docket_page/docket_controller.dart';
import 'package:tms_newui/widgets/tms_richtext.dart';

import '../../widgets/app_size.dart';
import '../../widgets/arrival_widgets/custom_bottamsheet.dart';
import '../../widgets/dashboard_widgets/custom_drawer.dart';
import '../../widgets/tms_normaltext.dart';
import 'arrival_controller.dart';

class ArrivalScreen extends StatefulWidget {
  const ArrivalScreen({super.key});

  @override
  State<ArrivalScreen> createState() => _ArrivalScreenState();
}

class _ArrivalScreenState extends State<ArrivalScreen> {
  final ArrivalController ctrl = Get.put(ArrivalController());

  @override
  void initState() {
    super.initState();
    ctrl.getThcArrivalsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff232F34),
        title: const TmsText(
          text: 'Arrival',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                customBottomSheetArrival(context);
              },
              icon: const Icon(
                Icons.edit_calendar,
                color: Colors.white,
                size: 28,
              ),
            ),
          )
        ],
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        switch (ctrl.dataStatus.value) {
          case DataStatus.loading:
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff232F34),
              ),
            );

          case DataStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No Data Found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ctrl.getThcArrivalsData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff232F34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );

          case DataStatus.completed:
            if (ctrl.thcArrivalsData.isEmpty) {
              return const Center(
                child: Text(
                  'No Data Found',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 22,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                await ctrl.getThcArrivalsData();
              },
              color: const Color(0xff232F34),
              child: ListView.builder(
                itemCount: ctrl.thcArrivalsData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: TmsText(
                                text: ctrl.thcArrivalsData[index].thcno,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TmsText(
                                  text: "${ctrl.thcArrivalsData[index].thcDate}",
                                  fontSize: 15,
                                ),
                                TmsText(
                                  text: "${ctrl.thcArrivalsData[index].route}",
                                  fontSize: 15,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TmsRichText(
                                  text: "Pkgs No : ",
                                  richText: "${ctrl.thcArrivalsData[index].pkgsno}",
                                  fontSize: 16,
                                  fontSize1: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                TmsRichText(
                                  text: "Weight : ",
                                  richText: "${ctrl.thcArrivalsData[index].chrgwt}",
                                  fontSize: 16,
                                  fontSize1: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    submitArrivalBottomSheet(context, index: index);
                                  },
                                  child: Container(
                                    width: AppSize.size(context).width * 0.28,
                                    height: AppSize.size(context).height * 0.06,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xff232F34)),
                                    child: const Center(
                                      child: TmsText(
                                        text: 'Submit',
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
        }
      }),
    );
  }
}
