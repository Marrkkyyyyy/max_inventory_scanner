
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:max_inventory_scanner/core/theme/color.dart';

Widget customHeader(String name, String location) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(1, 3),
            blurRadius: 3.0,
            spreadRadius: 0,
          ),
        ],
        color: AppColor.lightSky,
        borderRadius: BorderRadius.all(Radius.circular(8))),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.person_circle_fill,
          size: 70,
          color: AppColor.darkBlue,
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                  fontSize: 18,
                  color: AppColor.darkBlue,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  width: 4,
                ),
                const Icon(
                  CupertinoIcons.location_solid,
                  color: Colors.red,
                )
              ],
            )
          ],
        ))
      ],
    ),
  );
}