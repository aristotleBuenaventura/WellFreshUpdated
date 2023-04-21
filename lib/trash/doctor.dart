import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wellfreshlogin/doctorSchedule.dart';
import 'package:wellfreshlogin/patient_details.dart';
import 'package:wellfreshlogin/screens/screens.dart';
import 'package:wellfreshlogin/widgets/navigation_drawer.dart';
import '../get_image.dart';
import '../get_patient_details.dart';
import '../list_of_appointments.dart';

class Doctor extends StatefulWidget {
  const Doctor({Key? key}) : super(key: key);

  @override
  State<Doctor> createState() => _DoctorState();
}

class _DoctorState extends State<Doctor> {
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> patientID = [];
  List<String> day = [];
  List<String> month = [];
  List<String> time = [];
  List<String> patientRef = [];
  List<String> docRef = [];

  Future<void> getAppointment() async {
    if (patientID.isEmpty) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      final finalQuerysnapshot = querySnapshot.collection('appointments');
      final querySnapshot2 = await finalQuerysnapshot.get();
      for (var patient in querySnapshot2.docs) {
        if (!patientID.contains(patient.id)) {
          if (patient['status'] == 'ongoing') {
            patientID.add(patient.id);
            patientRef.add(patient['patientReference']);
            docRef.add(patient['docReference']);
            month.add(patient['month']);
            time.add(patient['time']);
            day.add(patient['day'].toString());
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getAppointment();
  }

  void updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey, // Add a Scaffold key
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!
                  .openDrawer(); // Use Scaffold key to open drawer
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Add functionality to show notifications
              },
              icon: const Icon(
                Icons.notifications,
              ),
            ),
            IconButton(
              onPressed: () {
                logout(context);
              },
              icon: const Icon(
                Icons.logout,
              ),
            )
          ],
        ),
        drawer: const NavigationDrawerWidget(),
        body: Container(
          color: Colors.white70,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  ),
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: FutureBuilder(
                  future: usersCollection
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> data =
                          snapshot.data!.data() as Map<String, dynamic>;

                      String docID = snapshot.data!.id;

                      String firstname = data.containsKey('firstname')
                          ? data['firstname']
                          : '';
                      String lastname =
                          data.containsKey('lastname') ? data['lastname'] : '';

                      return Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    25.0, 30.0, 12.0, 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Hi, Dr. $firstname $lastname',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        const CircularProgressIndicator();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DoctorSchedule(
                                              docId: docID,
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 35, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.calendar_month_outlined,
                                              color: Colors.black),
                                          SizedBox(width: 10),
                                          Text(
                                            "Schedules",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        const CircularProgressIndicator();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                list_of_patients(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 15),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.people_alt_rounded,
                                              color: Colors.black),
                                          SizedBox(width: 10),
                                          Text(
                                            "Patients",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching data'),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(25.0, 20.0, 12.0,
                        20.0), // add padding to top, left, and right
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 11.0),
                  child: Expanded(
                    child: FutureBuilder(
                      future: getAppointment(),
                      builder: (context, snapshot) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: patientID.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PatientDetails(
                                        appointmentId: patientID[index],
                                        docId: docRef[index],
                                        patientId: patientRef[index]),
                                  ));
                                },
                                child: SizedBox(
                                  height: 120.0,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: GetUserImage(
                                              documentId: patientRef[index])),
                                      Expanded(
                                          child: SizedBox(
                                        width: 150.0,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 0),
                                              child: GetPatientDetails(
                                                  documentId:
                                                      patientRef[index]),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 10),
                                              child: Text(
                                                '${month[index]} ${day[index]} 2023',
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          5, 0, 0, 0),
                                                  child: Text(
                                                    time[index],
                                                    style: const TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          padding: EdgeInsets.only(bottom: 16.0),
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Future<void> logout(BuildContext context) async {
    const CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }
}