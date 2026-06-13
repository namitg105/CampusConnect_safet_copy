import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Constents/AppConstents.dart';
import '../ImageWidgets.dart';

class SearchSort extends StatelessWidget {
  const SearchSort({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: (){},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppConstants.searchColors,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Theory of Computaion...",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ImageWidget(
                      imagePath: AppConstants.groupSearchIcon,
                      fit: BoxFit.contain,
                      height: 25,
                      width: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageWidget(
                    imagePath: AppConstants.sortIcon,
                    fit: BoxFit.contain,
                    height: 25,
                    width: 40,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "Sort",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
