import 'package:flutter/material.dart';
import 'package:marklin_bluetooth/firebase/race.dart';
import 'package:marklin_bluetooth/firebase/races.dart';
import 'package:marklin_bluetooth/current_race_screen/car_viewer.dart';
import 'package:marklin_bluetooth/widgets.dart';

class CurrentLapsViewer extends StatelessWidget {
  /// A widget that displays the laps for the current race, seperated per car.
  /// The list is automatically updated as laps are added to Firebase
  const CurrentLapsViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Race>(
      future: Races.currentRaceRef.race,
      builder: niceAsyncBuilder(
        loadingText: "Determining number of cars...",
        activeBuilder: (BuildContext c, AsyncSnapshot<Race> snapshot) {
          Race race = snapshot.data!;

          return Row(
            children: List.generate(
              race.nCars * 2 - 1,
              (i) => i.isEven
                  ? Expanded(
                      child: CarViewer(
                          carRef: Races.currentRaceRef.carRef(i ~/ 2)))
                  : const VerticalDivider(thickness: 1.0),
            ),
          );
        },
      ),
    );
  }
}
