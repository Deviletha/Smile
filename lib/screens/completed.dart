import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../Config/api_helper.dart';

class Completed extends StatefulWidget {
  const Completed({super.key});

  @override
  State<Completed> createState() => _CompletedState();
}

class _CompletedState extends State<Completed> {
  bool isLoading = true;

  String? data;
  Map? productList;
  Map? productList1;
  List? finalProductList;

  apiForInSterilisation() async {
    var response = await ApiHelper().post(
        endpoint: "sterilizations/getCompleteSterilizationStocks",
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

  @override
  void initState() {
    apiForInSterilisation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("COMPLETED"),
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
                          height: 10,
                        ),
                        Text(
                          "Quantity: ${finalProductList![index]["quantity"]}",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Date: ${finalProductList![index]["date"]}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Time in: ${finalProductList![index]["time_in"]}",
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Time out: ${finalProductList![index]["time_out"]}",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    )
                  ],
                ),
            )),
      ),
    );
  }
}
