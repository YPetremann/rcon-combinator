# RCON Combinator Mod

The RCON Combinator permit to an external software to interact with the circuit network through RCON

(important: singleplayer is not supported, you need to load your game as a server with rcon support)

## Installation
1. Install the RCON Combinator mod from mod portal.
2. enale rcon in the server settings or in the Rest settings.
3. Start game as server even for singleplayer.
4. Connect to the server with a RCON client (see example in the examples folder).

## Usage

    Add RCON Combinators to your circuit network and add a "smelter" logistic group:
    - On /rcon-output call, if Output enabled, it send signals from RCON to circuit.
    - On /rcon-input call, if Output disabled, it send signals from circuit to RCON.

    /rcon-output {"$schema": "https://raw.githubusercontent.com/YPetremann/rcon-combinator/refs/heads/master/schema.json", "groups": {"smelter":[{"name":"iron-plate","count":75}, {"name":"copper-plate","count":25}, {"name":"steel-plate","count":10}, {"name":"stone-brick":"count":10}]}}

    /rcon-input {"$schema": "https://raw.githubusercontent.com/YPetremann/rcon-combinator/refs/heads/master/schema.json", "request": ["smelter"]}

## License
This mod is released under the MIT License. See the LICENSE file for more details.