import 'package:flutter/material.dart';
import 'package:smile/screens/completed.dart';
import 'package:smile/screens/sterilization.dart';
import 'in_sterilization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Homepage"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,childAspectRatio: 1,
            crossAxisSpacing: 2,mainAxisSpacing: 2
          ),
          children: [
            InkWell(
              onTap: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const SterilizationPage()));
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                child:Column(
                  children:  const [
                    Icon(Icons.clean_hands, size: 40,),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Sterilization", style: TextStyle(
                      fontSize: 20,
                    ),)
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const InSterilizationPage()));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                child:Column(
                  children:  const [
                    Icon(Icons.pending_actions, size: 40,),
                    SizedBox(
                      height: 10,
                    ),
                    Text("In Sterilization", style: TextStyle(
                      fontSize: 20,
                    ),)
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const Completed()));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                child:Column(
                  children:  const [
                    Icon(Icons.done_outline_outlined, size: 40,),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Completed", style: TextStyle(
                      fontSize: 20,
                    ),)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
