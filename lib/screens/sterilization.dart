import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:smile/screens/in_sterilization.dart';
import 'package:smile/screens/update_sterilization.dart';
import 'package:smile/screens/widgets/assigntask_tileDate.dart';
import '../Config/api_helper.dart';

class SterilizationPage extends StatefulWidget {
  const SterilizationPage({Key? key}) : super(key: key);

  @override
  State<SterilizationPage> createState() => _SterilizationPageState();
}

class _SterilizationPageState extends State<SterilizationPage> {
  ScanResult? scanResult;

  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  final _quantityController = TextEditingController();

  bool isLoading = true;
  String? stockId;
  String? productId;
  String? quantity;

  String? data;
  Map? productList;
  Map? productList1;
  List? finalProductList;

  String? selectedRole;

  Map? handleList;
  Map? handleList1;
  List? finalHandleList;

  String? startDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  DateTime _dateTime = DateTime.now();

  void _showDatePickerStart() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2027),
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime = value;
          startDate = DateFormat('yyyy-MM-dd').format(_dateTime).toString();
          print("Selected date: $startDate");
        });
      }
    });
  }

  // Variable to store the selected time
  TimeOfDay? selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        print("Selected time: $selectedTime");
      });
    }
  }

  apiForHandleBy() async {
    var response = await ApiHelper().post(
        endpoint: "sterilizations/getHandledByid",
        body: {
          "handled_by": selectedRoleHandledBy.toString()
        }).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('Handle by api successful:');
        data = response.toString();
        handleList = jsonDecode(response);
        handleList1 = handleList!["data"];
        finalHandleList = handleList1!["handleList"];
        if (kDebugMode) {
          print(finalHandleList);
        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  apiForInSterilisation() async {
    var response = await ApiHelper().post(
        endpoint: "sterilizations/getSterilizationStocksById",
        body: {"product_id": productId}).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('product details api successful:');
        data = response.toString();
        productList = jsonDecode(response);
        productList1 = productList!["data"];
        finalProductList = productList1!["stockDetails"];

        stockId = finalProductList![0]["id"].toString();
        if (kDebugMode) {
          print(finalProductList);
        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  apiForUpdateSterilisation(String prId, String qty, String stckId, String user) async {
    String? formattedTime = selectedTime?.format(context);
    var response = await ApiHelper().post(
      endpoint: "sterilizations/StartUpdateSterilization",
      body: {
        "date": startDate.toString(),
        "time_in": formattedTime,
        "time_out": "",
        "qty": qty, // Use the selected quantity
        "handle_user": user,
        "product": prId,
        "stock_id": stckId,
        "user_id": "1",
        "company_id": "12",
      },
    ).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('product details api successful:');
        if (kDebugMode) {
          print(response);
        }
        Fluttertoast.showToast(
          msg: "Success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        _quantityController.clear();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => InSterilizationPage()));
      });
    } else {
      debugPrint('api failed:');
    }
  }

  //
  // // Function to show time picker
  // Future<void> _selectTime(BuildContext context) async {
  //   final TimeOfDay? picked = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //   );
  //
  //   if (picked != null && picked != selectedTime) {
  //     // Time has been selected
  //     setState(() {
  //       selectedTime = picked;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
  }

  String?
      selectedRoleHandledBy; // Separate variable for the "Handled by" dropdown
  String?
      selectedRoleAdditional; // Separate variable for the additional dropdown

  @override
  Widget build(BuildContext context) {
    // final scanResult = this.scanResult;
    return Scaffold(
      appBar: AppBar(
        title: const Text("STERILIZATION"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            InkWell(
                onTap: _scan,
                child: Image.asset(
                  "assets/qr_logo.png",
                  height: 200,
                )),
            Text(
              "Scan QR code",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            //   ],
            // ),
            // Column(
            //   children: [
            //     if (scanResult != null)
            //       // Card(
            //       //   child: ListTile(
            //       //     title: const Text('Raw Content'),
            //       //     subtitle: Text(scanResult.rawContent),
            //       //   ),
            //       // ),
            //     if (Platform.isAndroid) ...[
            //       CheckboxListTile(
            //         title: const Text('Use autofocus'),
            //         value: _useAutoFocus,
            //         onChanged: (checked) {
            //           setState(() {
            //             _useAutoFocus = checked!;
            //           });
            //         },
            //       ),
            //     ],
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  void _scan() async {
    try {
      final result = await BarcodeScanner.scan(
        options: ScanOptions(
          autoEnableFlash: _autoEnableFlash,
          android: AndroidOptions(
            useAutoFocus: _useAutoFocus,
          ),
        ),
      );

      setState(() => scanResult = result);

      if (scanResult != null && scanResult!.rawContent.isNotEmpty) {
        productId = scanResult!.rawContent.toString();

        await apiForInSterilisation();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => UpdateSterilization(
              productId: productId.toString(),
            )
            ));// Wait for API call to complete

      }
    } on PlatformException catch (e) {
      setState(() {
        scanResult = ScanResult(
          type: ResultType.Error,
          rawContent: e.code == BarcodeScanner.cameraAccessDenied
              ? 'The user did not grant the camera permission!'
              : 'Unknown error: $e',
        );
      });
    }
  }

  // Inside the showUpdateSterilisationDialog() method
  void showUpdateSterilisationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Sterilization'),
          content:
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.grey.shade200),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "Product name : ${finalProductList![0]["productName"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Quantity : ${finalProductList![0]["qty"]}",
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedRoleHandledBy,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRoleHandledBy = newValue;
                            apiForHandleBy();
                          });
                        },
                        items: ["Doctor", "Nurse", "Attendee"].map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Handled by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    // Container(
                    //   height: 50,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.all(Radius.circular(15)),
                    //     border: Border.all(color: Colors.grey)
                    //   ),
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: const [
                    //         Text("User List", style: TextStyle(fontSize: 15),),
                    //         Icon(Icons.arrow_drop_down, color: Colors.grey,)
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    DropdownButtonFormField<String>(
                              value: selectedRoleAdditional,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedRoleAdditional = newValue;
                                  // Additional logic if needed when the second dropdown changes
                                });
                              },
                              items: finalHandleList?.map((handle) {
                                    return DropdownMenuItem<String>(
                                      value: handle["name"].toString(),
                                      child: Text(handle["name"].toString()),
                                    );
                                  }).toList() ??
                                  [],
                              decoration: InputDecoration(
                                labelText: 'User List',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                              ),
                            ),
                      SizedBox(height: 10),
                      AssignTaskTileDate(
                        title: "Date",
                        date: startDate ?? 'date',
                        onTap: () {
                          _showDatePickerStart();
                        },
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () async {
                            await _selectTime(
                                context); // Pass context and await the result
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(color: Colors.grey)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Time In",
                                          style: TextStyle(fontSize: 10)),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                          selectedTime != null
                                              ? selectedTime.toString()
                                              : 'time',
                                          style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.alarm, size: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _quantityController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                          labelStyle: TextStyle(fontSize: 12),
                          labelText: "Quantity",
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                    ],
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Update'),
              onPressed: () {
                quantity = _quantityController.text.toString();
                apiForUpdateSterilisation(productId.toString(),
                    quantity.toString(), stockId.toString(), "");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

// void showUpdateSterilisationDialog() {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Update Sterilization'),
//         content: isLoading
//             ? Center(
//           child: CircularProgressIndicator(
//             color: Colors.blue,
//           ),
//         )
//             :  Column(
//           children: <Widget>[
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                   color: Colors.grey.shade200
//               ),
//               width: double.infinity,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Product name : ${finalProductList![0]["productName"]}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Text(
//                       "Quantity : ${finalProductList![0]["qty"]}",
//                       style: TextStyle(fontSize: 15),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             AssignTaskTileDate(
//               title: "Date",
//               date: startDate ?? 'date',
//               onTap: () {
//                 _showDatePickerStart();
//               },
//             ),
//             SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 10),
//               child: InkWell(
//                 onTap: () async {
//                   await _selectTime(
//                       context); // Pass context and await the result
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                       borderRadius:
//                       BorderRadius.all(Radius.circular(10)),
//                       border: Border.all(color: Colors.grey)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Time In",
//                                 style: TextStyle(fontSize: 10)),
//                             SizedBox(
//                               height: 3,
//                             ),
//                             Text(
//                                 selectedTime != null
//                                     ? selectedTime.toString()
//                                     : 'time',
//                                 style: TextStyle(fontSize: 10)),
//                           ],
//                         ),
//                         SizedBox(width: 3),
//                         Icon(Icons.alarm, size: 30),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 10),
//             TextFormField(
//               maxLines: 1,
//               controller: _quantityController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10)),
//                 labelText: "Quantity",
//               ),
//               keyboardType: TextInputType.number,
//               textInputAction: TextInputAction.next,
//             ),
//           ],
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Cancel'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Update'),
//             onPressed: () {
//               if (_quantityController.text.isNotEmpty) {
//                 apiForUpdateSterilisation(
//                     productId.toString());
//                 Navigator.of(context).pop();
//               } else {
//                 // Show an error message or handle the case where quantity is empty.
//               }
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
}
