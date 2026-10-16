import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';

class RentOfferContainer extends StatelessWidget {
  RentOfferContainer({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context)=> Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Offered by",
              style: TextStyle(
                color: context.isLightMode ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.isLightMode ? Colors.white : Colors.black, width: 1.5),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: context.isLightMode ? Colors.white : Colors.black, width: 1.5),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: 100 RS",
              style: TextStyle(
                color: context.isLightMode ? Colors.white : Colors.black,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

