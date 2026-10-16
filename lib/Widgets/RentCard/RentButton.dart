import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

class RentButton extends StatelessWidget {
  RentButton({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: context.isLightMode ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Rent Notes",
              style: TextStyle(
                color: context.isLightMode ? Colors.black : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
