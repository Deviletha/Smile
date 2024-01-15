import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:smile/screens/widgets/assigntask_tileDate.dart';
import '../Config/api_helper.dart';
import 'in_sterilization.dart';

class UpdateSterilization extends StatefulWidget {
  final String productId;
  const UpdateSterilization(
      {super.key, required this.productId});

  @override
  State<UpdateSterilization> createState() => _UpdateSterilizationState();
}

class _UpdateSterilizationState extends State<UpdateSterilization> {
  @override
  void initState() {
    apiForInSterilisation();
    super.initState();
  }
  final _quantityController = TextEditingController();

  bool isLoading = true;
  String? stockId;
  String? productId;
  String? handleUserId;
  String? handledByUserName;
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
          if (kDebugMode) {
            print("Selected date: $startDate");
          }
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
        if (kDebugMode) {
          print("Selected time: $selectedTime");
        }
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
        body: {"product_id": widget.productId}).catchError((err) {});

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

  apiForUpdateSterilisation(String prId, String qty, String stockId, String user) async {
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
        "stock_id": stockId,
        "user_id": "1",
        "company_id": "12",
      },
    ).catchError((err) {});
    if (kDebugMode) {
      print(response);
    }

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

  String?
  selectedRoleHandledBy; // Separate variable for the "Handled by" dropdown


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Sterilization'),
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        height: 20,
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
                      SizedBox(height: 20),
                      InkWell(
                        onTap: (){
                          _showDetailsBottomSheet();
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: Colors.grey)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children:  [
                                Text( handledByUserName ?? "User List", style: TextStyle(fontSize: 15),),
                                Icon(Icons.arrow_drop_down, color: Colors.grey,)
                              ],
                            ),
                          ),
                        ),
                      ),
                      // DropdownButtonFormField<String>(
                      //   value: selectedRoleAdditional,
                      //   onChanged: (String? newValue) {
                      //     setState(() {
                      //       selectedRoleAdditional = newValue;
                      //       // Additional logic if needed when the second dropdown changes
                      //     });
                      //   },
                      //   items: finalHandleList?.map((handle) {
                      //     return DropdownMenuItem<String>(
                      //       value: handle["name"].toString(),
                      //       child: Text(handle["name"].toString()),
                      //     );
                      //   }).toList() ??
                      //       [],
                      //   decoration: InputDecoration(
                      //     labelText: 'User List',
                      //     border: OutlineInputBorder(
                      //       borderRadius:
                      //       BorderRadius.all(Radius.circular(15)),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 20),
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
                                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                                      SizedBox(
                                        height: 3,
                                      ),
                                      Text(
                                          selectedTime != null
                                              ? selectedTime.toString()
                                              : 'time',
                                          style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                                    ],
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.alarm, size: 30, color: Colors.grey.shade600),
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
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Update'),
                          onPressed: () {
                            quantity = _quantityController.text.toString();
                            apiForUpdateSterilisation(widget.productId.toString(),
                                quantity.toString(), stockId.toString(), handleUserId.toString());
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     ElevatedButton(
                      //       child: Text('Cancel'),
                      //       onPressed: () {
                      //         Navigator.of(context).pop();
                      //       },
                      //     ),
                      //     ElevatedButton(
                      //       child: Text('Update'),
                      //       onPressed: () {
                      //         quantity = _quantityController.text.toString();
                      //         apiForUpdateSterilisation(widget.productId.toString(),
                      //             quantity.toString(), stockId.toString(), "");
                      //         Navigator.of(context).pop();
                      //       },
                      //     ),
                      //   ],
                      // ),
                    ],
                ),
              ),
            ),
      ),
    );
  }
  void _showDetailsBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                finalHandleList == null ? 0 : finalHandleList?.length,
                itemBuilder: (context, index) => getDetails(index),
              ),
              SizedBox(height: 20,)
              // Text(
              //   finalHandleList![0]["name"].toString(),
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 20,
              //   ),
              // ),
              // Add more details as needed
            ],
          ),
        );
      },
    );
  }
  Widget getDetails(int index) {
    return InkWell(
      onTap: (){
        handleUserId = finalHandleList![index]["id"].toString();
        handledByUserName = finalHandleList![index]["name"].toString();
        print(handledByUserName);
        print(handleUserId);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              finalHandleList![index]["name"].toString(),
              style: TextStyle( fontSize: 15),
            ),
            Divider()
          ],
        ),
      ),
    );
  }
}
