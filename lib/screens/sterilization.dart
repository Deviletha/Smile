import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:smile/screens/widgets/assigntask_tileDate.dart';
import '../Config/api_helper.dart';

class SterilizationPage extends StatefulWidget {
  const SterilizationPage({Key? key}) : super(key: key);

  @override
  State<SterilizationPage> createState() => _SterilizationPageState();
}

class _SterilizationPageState extends State<SterilizationPage> {
  ScanResult? scanResult;

  int? _selectedQuantity;

  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  bool isLoading = true;
  String? stockId;
  String? productId;

  String? data;
  Map? productList;
  Map? productList1;
  List? finalProductList;

  String? startDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  DateTime _dateTime = DateTime.now();

  void _showDatePickerStart() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2025),
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime = value;
          startDate = DateFormat('yyyy-MM-dd').format(_dateTime).toString();
        });
      }
    });
  }

  final _quantityController = TextEditingController();

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

  apiForUpdateSterilisation(String prId, int selectedQuantity, String stckId) async {
    String? formattedTime = selectedTime?.format(context);
    var response = await ApiHelper().post(
      endpoint: "sterilizations/StartUpdateSterilization",
      body: {
        "date": startDate.toString(),
        "time_in": formattedTime,
        "time_out": "",
        "qty": selectedQuantity.toString(),  // Use the selected quantity
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
      });
    } else {
      debugPrint('api failed:');
    }
  }


  // Variable to store the selected time
  TimeOfDay? selectedTime = TimeOfDay.now();

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scanResult = this.scanResult;
    return Scaffold(
      appBar: AppBar(
        title: const Text("STERILIZATION"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              InkWell(
                  onTap: _scan,
                  child: Image.asset(
                    "assets/qr_logo.png",
                    height: 120,
                  )),
              Text(
                "Scan QR code",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            children: [
              if (scanResult != null)
                Card(
                  child: ListTile(
                    title: const Text('Raw Content'),
                    subtitle: Text(scanResult.rawContent),
                  ),
                ),
              if (Platform.isAndroid) ...[
                CheckboxListTile(
                  title: const Text('Use autofocus'),
                  value: _useAutoFocus,
                  onChanged: (checked) {
                    setState(() {
                      _useAutoFocus = checked!;
                    });
                  },
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  // Future<void> _scan() async {
  //   try {
  //     final result = await BarcodeScanner.scan(
  //       options: ScanOptions(
  //         autoEnableFlash: _autoEnableFlash,
  //         android: AndroidOptions(
  //           useAutoFocus: _useAutoFocus,
  //         ),
  //       ),
  //     );
  //
  //     setState(() => scanResult = result);
  //
  //     if (scanResult != null && scanResult!.rawContent.isNotEmpty) {
  //       productId = scanResult!.rawContent.toString();
  //       apiForInSterilisation();
  //       showUpdateSterilisationDialog();
  //     }
  //   } on PlatformException catch (e) {
  //     setState(() {
  //       scanResult = ScanResult(
  //         type: ResultType.Error,
  //         rawContent: e.code == BarcodeScanner.cameraAccessDenied
  //             ? 'The user did not grant the camera permission!'
  //             : 'Unknown error: $e',
  //       );
  //     });
  //   }
  // }
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

        await apiForInSterilisation(); // Wait for API call to complete
        showUpdateSterilisationDialog();
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
    List<int> quantityValues = List.generate(
        finalProductList![0]["qty"] as int, (index) => index + 1);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Sterilization'),
          content: isLoading
              ? Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          )
              : Column(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Time In", style: TextStyle(fontSize: 10)),
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
              DropdownButton<int>(
                value: _selectedQuantity, // Update this line
                onChanged: (selectedQuantity) {
                  setState(() {
                    // Update the selected quantity in the state
                    _selectedQuantity = selectedQuantity!;
                  });
                },
                items: quantityValues.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ],
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
                if (_selectedQuantity != null) {
                  apiForUpdateSterilisation(productId.toString(), _selectedQuantity!, stockId.toString());
                  Navigator.of(context).pop();
                } else {
                  // Show an error message or handle the case where the quantity is not selected.
                }
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
