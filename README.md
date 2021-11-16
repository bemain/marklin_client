# Märklin Sprint BLE Controller

This is my and my father's attempt at creating wireless hand controllers and lap timers for our Märklin Sprint racing track.
![Racetrack](assets/docs/racetrack.png)

This is very much a homebrew project. It is not meant to be sold or distributed in any way; we do this purely for fun. Don't look at the code too closely, and keep in mind that I'm no professional. I'm learning (slowly, but still), and that's the whole point.

## The Setup

On the "client" side, we have this beautiful mobile app made using Flutter (flutter is great, you should [check it out](https://flutter.dev/)).
![My beautiful Flutter app](assets/docs/controller_screen.png)

On the [server](https://github.com/BeMain/marklin_server) side, we have this nRF52840 which handles Bluetooth. It's also great, and it can handle many Bluetooth connections at once, which is handy since you usually want to be more than one person racing at once.

Everything is wired up in this very ugly blue plastic box. It works great, even though it's ugly. And it has a hole for the wires! (which dad accidentally created when trying to punch a hole in the box for fastening one of the parts).
![Ugly blue box with wires and stuff](assets/docs/blue_box.png)

It has support for 4 cars running at once, but we currently only use two (hence the loose wires).

## The Application

The application consists of three parts:
1. The wireless controller using BLE, including lap timing and counting
2. Statics for the current race
3. The race browser

### Wireless Controller

The main feature of the application is the wireless controller that now also features lap timing and counting.

It features a slider which changes the speed of the car and sends it to the server via BLE. It also contains a selection menu for the different cars.

The controller also receives notifications about laps from the server, and is tasked with determining the time taken for the lap, and publishing it to the Firestore database.

### Current Race Statistics

The Race screen shows statistics - including lap times and (planned) average speed during the lap - for the current race, and includes the option to start a new race.

### Race Browser

The Race Browser allows you to browse through the statistics of finished races - including lap times and (planned) average speed during the lap.