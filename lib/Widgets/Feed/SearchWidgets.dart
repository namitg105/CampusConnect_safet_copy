import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Constents/AppConstents.dart';
import '../Buttons/BackWidgets.dart';

class SearchWidgets extends StatelessWidget {
  const SearchWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 5),
      decoration: BoxDecoration(
        color: AppConstants.searchColors,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Theory of Computation...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            height: 50,
            width: 50,
            child: BackWidget(
              imagePath: AppConstants.groupSearchIcon,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}