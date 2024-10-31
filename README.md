# RCON Combinator Mod

## Overview
The RCON Combinator mod introduces two new combinators to Factorio: 
- input combinator: when a /rcon-input command is executed, the input combinator will receive the signals from the command, parameters allow to set mode of operation:
  - pulse: send signals only one tick
  - update: keep sending signals until the next /rcon-input command is executed affecting the same combinator
- output combinator. when the output combinator is updated, it will send signals to the rcon output, parameters allow to set mode of operation:
  - default: one update per second and only if the signals have changed
  - fast: one update per tick and only if the signals have changed
  - always: one update per second, even if the signals have not changed

## Installation
1. Install the RCON Combinator mod from mod portal.
2. enale rcon in the server settings.
3. Start game as server even for singleplayer.
3. Launch Factorio and enable the RCON Combinator mod in the mods menu.

## Usage
- Place the input combinator in your factory and configure it to receive signals.
- Connect the output combinator to your circuit network to send signals based on the input received.
- Use the in-game interface to adjust settings and parameters for each combinator.

## Compatibility
This mod is compatible with Factorio version X.X.X (replace with the specific version).

## License
This mod is released under the MIT License. See the LICENSE file for more details.