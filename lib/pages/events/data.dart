import 'package:flutter/material.dart';

const Color primary_color = Color(0xFF262793);
const Color primary_color_light = Color(0xFF4F519D);
const Color primary_color_dark = Color(0xFF121347);

final background_color = Colors.grey[200];

Color gradient_color = Color(0x6663F0E8);
Color gradient_color_light = Color(0x1163F0E8);
Color gradient_color_dark = Color(0xFF63F0E8);

List<BoxShadow> shadowBox = [
  BoxShadow(
    color: Colors.grey[300],
    blurRadius: 30,
    offset: const Offset(0, 10),
  )
];

final String lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam at diam vel massa hendrerit blandit nec quis mauris. Maecenas rutrum tellus non erat congue dapibus. Etiam vel urna dapibus tellus vestibulum mollis. Morbi volutpat ligula dolor, ac vestibulum eros tempus quis. Nunc semper, nunc ut laoreet maximus, risus metus rutrum ex, vel ultricies libero lacus eget est. Pellentesque vel dapibus velit. Etiam quis est non risus egestas pellentesque. Vestibulum eu quam nec dolor aliquet iaculis et ut purus. Aenean ac bibendum metus, nec dictum lorem. Sed quis tellus iaculis, consequat magna sit amet, mattis erat. Ut et sem ac erat rhoncus blandit. Vestibulum eu nisl quis tellus finibus ullamcorper. Suspendisse vitae venenatis nunc. In tristique dapibus risus at maximus. Phasellus pharetra fringilla euismod. Phasellus in augue eros. Nunc vitae rutrum diam. Morbi tincidunt sagittis dolor, at ultrices tortor imperdiet dignissim. Sed id tortor eget lacus suscipit suscipit. Fusce suscipit metus non varius blandit. Ut fermentum leo vestibulum congue imperdiet. Duis dictum dui id mollis efficitur. Ut auctor nulla velit, eu pretium arcu placerat eget.";

final Map<int, Map<String, String>> events = {
  1: {
    'name': 'Event 1',
    'date': 'lundi 03/10',
    'time': '18h-22h',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  2: {
    'name': 'Event 2',
    'date': 'lundi 03/10',
    'time': '19h-23h15',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  3: {
    'name': 'Event 3',
    'date': 'lundi 03/10',
    'time': '21h-00h30',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  4: {
    'name': 'Event 4',
    'date': 'lundi 03/10',
    'time': '20h30-22h45',
    'image': 'assets/images/event4.png',
    'description': lorem
  },
  5: {
    'name': 'Event 5',
    'date': 'jeudi 06/10',
    'time': '18h-22h',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  6: {
    'name': 'Event 6',
    'date': 'jeudi 06/10',
    'time': '17h-22h15',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  7: {
    'name': 'Event 7',
    'date': 'jeudi 06/10',
    'time': '14h-17h',
    'image': 'assets/images/event4.png',
    'description': lorem
  },
  8: {
    'name': 'Event 8',
    'date': 'jeudi 06/10',
    'time': '23h-3h30',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  9: {
    'name': 'Event 9',
    'date': 'jeudi 06/10',
    'time': '20h-23h45',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  10: {
    'name': 'Event 10',
    'date': 'samedi 08/10',
    'time': '13h-22h',
    'image': 'assets/images/event4.png',
    'description': lorem
  },
  11: {
    'name': 'Event 11',
    'date': 'samedi 08/10',
    'time': '19h-23h45',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  12: {
    'name': 'Event 12',
    'date': 'mardi 04/11',
    'time': '18h-22h',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  13: {
    'name': 'Event 13',
    'date': 'mardi 04/11',
    'time': '19h-23h15',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  14: {
    'name': 'Event 14',
    'date': 'mardi 04/11',
    'time': '21h-00h30',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  15: {
    'name': 'Event 15',
    'date': 'mardi 04/11',
    'time': '20h30-22h45',
    'image': 'assets/images/event4.png',
    'description': lorem
  },
  16: {
    'name': 'Event 16',
    'date': 'mercredi 05/11',
    'time': '18h-22h',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  17: {
    'name': 'Event 17',
    'date': 'mercredi 05/11',
    'time': '17h-22h15',
    'image': 'assets/images/event.png',
    'description': lorem
  },
  18: {
    'name': 'Event 18',
    'date': 'mercredi 05/11',
    'time': '14h-17h',
    'image': 'assets/images/event4.png',
    'description': lorem
  },
  19: {
    'name': 'Event 19',
    'date': 'mercredi 05/11',
    'time': '23h-3h30',
    'image': 'assets/images/event2.png',
    'description': lorem
  },
  20: {
    'name': 'Event 20',
    'date': 'mercredi 05/11',
    'time': '20h-23h45',
    'image': 'assets/images/event.png',
    'description': lorem
  },
};