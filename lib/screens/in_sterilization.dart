import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../Config/api_helper.dart';

class InSterilizationPage extends StatefulWidget {
  const InSterilizationPage({super.key});

  @override
  State<InSterilizationPage> createState() => _InSterilizationPageState();
}

class _InSterilizationPageState extends State<InSterilizationPage> {
  bool isLoading = true;
  String? sterilisationId;
  String? productId;

  String? data;
  Map? productList;
  Map? productList1;
  List? finalProductList;

  // Variable to store the selected time
  TimeOfDay? selectedTime;

  // Function to show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      // Time has been selected
      setState(() {
        selectedTime = picked;
      });
    }
  }

  apiForInSterilisation() async {
    var response = await ApiHelper().post(
        endpoint: "sterilizations/getInSterilizationStocks",
        body: {}).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('product details api successful:');
        data = response.toString();
        productList = jsonDecode(response);
        productList1 = productList!["data"];
        finalProductList = productList1!["allStocks"];
        if (kDebugMode) {
          print(finalProductList);
        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  apiFinishSterilisation(String id, String prID, TimeOfDay selectedTime) async {
    // Format selected time as HH:mm
    String formattedTime = selectedTime.format(context);

    var response = await ApiHelper().post(
      endpoint: "sterilizations/FinishUpdateSterilization",
      body: {
        "time_out": formattedTime,
        "sterl_id": id,
        "product": prID,
        "user_id": "1",
        "company_id": "12"
      },
    ).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('finish sterilization api successful:');
        apiForInSterilisation();
        if (kDebugMode) {
          print(response);
          Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 1,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  @override
  void initState() {
    apiForInSterilisation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("IN STERILIZATION"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  finalProductList == null ? 0 : finalProductList?.length,
              itemBuilder: (context, index) => getDetails(index),
            ),
    );
  }

  Widget getDetails(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8),
      child: Card(
        color: Colors.grey.shade100,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(
                finalProductList![index]["productName"].toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Quantity: ${finalProductList![index]["quantity"]}",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Date: ${finalProductList![index]["date"]}",
                        style: TextStyle(fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Time in: ${finalProductList![index]["time_in"]}",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Show time picker
                      await _selectTime(context);

                      // Check if a time has been selected
                      if (selectedTime != null) {
                        sterilisationId = finalProductList![index]["id"].toString();
                        productId = finalProductList![index]["product"].toString();
                        apiFinishSterilisation(
                          sterilisationId!,
                          productId!,
                          selectedTime!,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shadowColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        )),
                    child: Text("Finish", style: TextStyle(color: Colors.white),),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
