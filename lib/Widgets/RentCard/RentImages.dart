import 'package:flutter/cupertino.dart';

import '../ImageWidgets.dart';

class RentImage extends StatelessWidget {
  const RentImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ImageWidget(
                imagePath: 'assets/image1.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: ImageWidget(
                imagePath: 'assets/image1.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: ImageWidget(
                imagePath: 'assets/image1.png',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
