import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart'; // Ensure this is still imported if you use it elsewhere

class AcceptedRequestsScreen extends StatefulWidget {
  const AcceptedRequestsScreen({super.key});

  @override
  State<AcceptedRequestsScreen> createState() => _AcceptedRequestsScreenState();
}

class _AcceptedRequestsScreenState extends State<AcceptedRequestsScreen> {
  // Change the name to reflect what it's truly fetching
  late Future<List<dynamic>> _collectorInProgressRequests;

  @override
  void initState() {
    super.initState();
    // Call the method that fetches "in progress" requests for the collector
    // These are essentially the requests the collector has "accepted".
    _fetchCollectorInProgressRequests();
  }

  void _fetchCollectorInProgressRequests() {
    setState(() {
      // Use ApiService.getMyActiveRequests() as it maps to /requests/in-progress
      _collectorInProgressRequests = ApiService.getMyActiveRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Accepted Requests (In Progress)")), // Update title
      body: FutureBuilder<List<dynamic>>(
        future: _collectorInProgressRequests, // Use the new future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching accepted/in-progress requests: ${snapshot.error}'); // Log the error
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      "Error fetching accepted requests: ${snapshot.error.toString()}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchCollectorInProgressRequests, // Retry
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
                  const SizedBox(height: 10),
                  const Text("No active requests at the moment.", textAlign: TextAlign.center,),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: _fetchCollectorInProgressRequests,
                      child: const Text("Refresh")
                  )
                ],
              ),
            );
          }

          final requests = snapshot.data!;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              // Ensure correct key names based on your backend response, e.g., 'location', 'description', 'date'
              final String location = request['location'] ?? 'N/A';
              final String description = request['description'] ?? 'No description';
              final String date = request['date'] != null
                  ? (request['date'] as String).substring(0, 10)
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(location),
                  subtitle: Text(description),
                  trailing: Text("Scheduled: $date"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../../../services/api_service.dart';
//
// class AcceptedRequestsScreen extends StatefulWidget {
//   const AcceptedRequestsScreen({super.key});
//
//   @override
//   State<AcceptedRequestsScreen> createState() => _AcceptedRequestsScreenState();
// }
//
// class _AcceptedRequestsScreenState extends State<AcceptedRequestsScreen> {
//   late Future<List<dynamic>> _acceptedRequests;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAcceptedRequests(); // Call a method to fetch requests
//   }
//
//   Future<void> _fetchAcceptedRequests() async {
//     // No need to get collectorId here on the frontend if ApiService.getAcceptedRequests()
//     // uses the token internally to determine the collector.
//     // If your backend endpoint for accepted requests *does* require a collectorId
//     // as a path parameter or query parameter, you'd re-add it here.
//     // Based on ApiService.dart, getAcceptedRequests() takes no parameters now.
//     setState(() {
//       _acceptedRequests = ApiService.getAcceptedRequests();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Accepted Requests")),
//       body: FutureBuilder<List<dynamic>>(
//         future: _acceptedRequests,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             print('Error fetching accepted requests: ${snapshot.error}'); // Log the error
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.error_outline, color: Colors.red, size: 50),
//                     const SizedBox(height: 10),
//                     Text(
//                       "Error fetching accepted requests: ${snapshot.error.toString()}",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.red, fontSize: 16),
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       onPressed: _fetchAcceptedRequests,
//                       child: const Text("Retry"),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.info_outline, color: Colors.blueGrey, size: 50),
//                   const SizedBox(height: 10),
//                   const Text("No accepted requests at the moment.", textAlign: TextAlign.center,),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                       onPressed: _fetchAcceptedRequests,
//                       child: const Text("Refresh")
//                   )
//                 ],
//               ),
//             );
//           }
//
//           final requests = snapshot.data!;
//           return ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               final request = requests[index];
//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 child: ListTile(
//                   title: Text(request['location'] ?? 'N/A'),
//                   subtitle: Text(request['description'] ?? 'No description'),
//                   trailing: Text("Scheduled: ${request['date']?.substring(0, 10) ?? 'N/A'}"),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }