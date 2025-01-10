import 'package:flutter/material.dart';

class ContainerSelectionScreen extends StatefulWidget {
  @override
  _ContainerSelectionScreenState createState() =>
      _ContainerSelectionScreenState();
}

class _ContainerSelectionScreenState extends State<ContainerSelectionScreen> {
  // To store the selected container index and images
  List<int> selectedIndexes = [-1, -1, -1]; // -1 means not selected for each container

  List<String> images = [
    'https://via.placeholder.com/150/FF5733', // Image for first container
    'https://via.placeholder.com/150/33FF57', // Image for second container
    'https://via.placeholder.com/150/5733FF', // Image for third container
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tap to Select Container"),
      ),
      body: Column(
        children: [
          // First Row with Containers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Toggle selection for each container independently
                    selectedIndexes[index] = selectedIndexes[index] == index ? -1 : index;
                  });
                },
                child: Container(
                  height: 100,
                  width: 100,
                  color: selectedIndexes[index] == index ? Colors.blue : Colors.grey,
                  child: Center(
                    child: Text(
                      'Container ${index + 1}',
                      style: TextStyle(
                        color: selectedIndexes[index] == index ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Display images below each container if it is selected
          for (int i = 0; i < 3; i++)
            if (selectedIndexes[i] == i)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Image.network(
                      images[i], // Image for the selected container
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
