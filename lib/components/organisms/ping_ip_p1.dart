import 'package:flutter/material.dart';
import 'package:dart_ping/dart_ping.dart';

void main() => runApp(PingApp());

class PingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PingWidget(),
    );
  }
}

class PingWidget extends StatefulWidget {
  @override
  _PingWidgetState createState() => _PingWidgetState();
}

class _PingWidgetState extends State<PingWidget> {
  final List<String> ipAddresses = [
    '192.168.0.1',
    '10.84.36.1',
    '172.16.68.17',
  ];
  final List<String> pingResults = [];

  @override
  void initState() {
    super.initState();
    _startPing();
  }

  void _startPing() {
    final List<Ping> pings = ipAddresses.map((ip) => Ping(ip)).toList();

    Future.wait(pings.map((ping) async {
      await for (final event in ping.stream) {
        if (event is PingData) {
          final formattedResult = event.toString();
          if (formattedResult.startsWith("Reply from")) {
            // Exclude summary lines
            continue;
          }
          print(formattedResult);
          setState(() {
            pingResults.insert(
                0, formattedResult); // Insert at the beginning of the list
          });
        }
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ping IP Addresses'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Pinging IP Addresses:',
              style: TextStyle(
                fontSize: 10,
                height: 1.0,
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: ListView.builder(
                reverse: true, // Display items in reverse order
                itemCount: pingResults.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      ListTile(
                        visualDensity: VisualDensity(vertical: -4),
                        dense: true,
                        title: Container(
                          padding: EdgeInsets.all(0),
                          child: Text(
                            pingResults[index],
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      if ((index + 1) % 3 == 0 &&
                          index != pingResults.length - 1)
                        Divider(
                          height: 1,
                          color: Colors.grey,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
