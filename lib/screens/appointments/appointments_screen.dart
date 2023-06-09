import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:wellfresh/screens/screens.dart';
import 'package:wellfresh/theme.dart';
import 'package:wellfresh/widgets/widgets.dart';
import 'package:wellfresh/services/firebase_services.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Appointments', backButton: true, color: surfaceColor, scaffoldKey: scaffoldKey),
      body: FutureBuilder(
        future: FirestoreServices.getPatientAppointments(userId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.data!.docs.isEmpty) {
            return const ItemIndicator(icon: IconlyBroken.calendar, text: 'You have no appointments');
          }
          else {
            var data = snapshot.data!.docs;
          
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot appointmentTmp = data[index];
                    Map<String, dynamic> appointment = appointmentTmp.data() as Map<String, dynamic>;
                    String doctorName = '';
                            
                    return Column(
                      children: [
                        Container(
                          clipBehavior: Clip.hardEdge,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [containerShadow],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.to(() => AppointmentDetailsPatientScreen(
                                  appointmentId: data[index].id
                                ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: appointment['status'] == 'ongoing' ? warningColor
                                        : accentColor,
                                      foregroundColor: appointment['status'] != 'ongoing' ? invertTextColor : primaryTextColor,
                                      radius: 24,
                                      child: const Icon(IconlyLight.calendar),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${appointment['month']} ${appointment['day']}, ${appointment['year']}',
                                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                              color: primaryTextColor,
                                            ),
                                          ),
                                          Text(
                                            appointment['time'],
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                              color: accentTextColor,
                                            ),
                                          ),
                                          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                                            future: FirestoreServices.getDoctorName(appointment['docId']),
                                            builder: (_, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container(
                                                  width: 100,
                                                  height: 10,
                                                  margin: const EdgeInsets.only(top: 8),
                                                  decoration: BoxDecoration(
                                                    color: tertiaryTextColor,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                );
                                              }
                                              else {
                                                var data = snapshot.data!.data();
                                                doctorName = 'Dr. ${data!['firstname']} ${data['lastname']}';
                                          
                                                return Text(
                                                  doctorName,
                                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                    color: tertiaryTextColor,
                                                  ),
                                                );
                                              }
                                            }
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      IconlyBroken.arrowRight2,
                                      color: tertiaryTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }
                ),
              ),
            );
          }
        }
      ),
    );
  }
}