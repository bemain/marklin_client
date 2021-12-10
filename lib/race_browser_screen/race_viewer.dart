import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/race_reference.dart';
import 'package:marklin_bluetooth/race_browser_screen/car_viewer.dart';
import 'package:marklin_bluetooth/widgets.dart';

class RaceViewer extends StatelessWidget {
  const RaceViewer({Key? key, required this.raceRef}) : super(key: key);

  final RaceReference raceRef;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Race>(
      future: raceRef.race,
      builder: niceAsyncBuilder(
        loadingText: "Determining number of cars...",
        activeBuilder: (BuildContext c, AsyncSnapshot<Race> snapshot) {
          Race race = snapshot.data!;

          return Row(
            children: List.generate(
              race.nCars * 2 - 1,
              (i) => i.isEven
                  ? Expanded(child: CarViewer(carRef: raceRef.carRef(i ~/ 2)))
                  : const VerticalDivider(thickness: 1.0),
            ),
          );
        },
      ),
    );
  }
}
