import 'package:flutter/widgets.dart';

class Responsive {
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width > 600;
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;
  

  


}