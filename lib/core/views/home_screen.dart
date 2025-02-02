import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/object_provider.dart';
import 'camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final objectProvider = Provider.of<ObjectProvider>(context);
    final objects = ['Laptop', 'Mobile Phone', 'Mouse', 'Bottle'];

    return Scaffold(
      appBar: AppBar(title: const Text("Select an Object")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: objects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(objects[index]),
                  onTap: () {
                    objectProvider.setSelectedObject(objects[index]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
