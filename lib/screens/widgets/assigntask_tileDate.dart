import 'package:flutter/material.dart';

class AssignTaskTileDate extends StatelessWidget {
  final String title;
  final String date;
  void Function()? onTap;
  AssignTaskTileDate({
    Key? key,
    required this.title,
    this.onTap,
    required this.date,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration:BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                  color: Colors.grey
              )
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                    SizedBox(
                      height: 3,
                    ),
                    Text(date,style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                  ],
                ),
                SizedBox(width: 3),
                Icon(Icons.calendar_month_sharp, size: 30, color: Colors.grey.shade600)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
