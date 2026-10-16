import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:noteswap/core/theme/theme_context.dart';
import '../../Constents/AppConstents.dart';

class ContainerRow extends StatelessWidget {
  ContainerRow({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "CSE 2005",
                    style: TextStyle(
                      color: context.isLightMode ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 90,
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.boxColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        "SCOPE",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Computation of \nMathematics",
                style: TextStyle(
                  color: context.isLightMode ? Colors.white : Colors.black,
                  fontSize: 24,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          width: 170,
          decoration: BoxDecoration(
            color: context.isLightMode ? Colors.white : Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'Modules \nCovered',
                    style: TextStyle(
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const Text(
                '8',
                style: TextStyle(
                  fontSize: 50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
