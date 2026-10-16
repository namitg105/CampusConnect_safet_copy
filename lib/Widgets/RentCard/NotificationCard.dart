import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

import 'ContainerRow.dart';
import 'RentImages.dart';

class RentCardCustom extends StatelessWidget {
  RentCardCustom({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: context.isLightMode ? Colors.black : Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ContainerRow(),
                SizedBox(height: 15),
                RentImage()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

