# Roofline

Roofline is a first-person parkour game for PC. Ten roofs are in the pool. Before each race the room votes on the next map. A clean run takes about two and a half to five minutes, depending on the roof. The roofs are grey for now. The decks are narrow, the sides are open, and bars, hurdles, gaps, and long drops run the whole way, along with hammers, sliding walls, buttons, ice, and boost pads. Off the edge is a city, a long way down. Day roofs look over pale blocks with dark windows. Night roofs look over a darker skyline with lit windows. The streets between the blocks are the death plane. Fall into it and you come back at the last checkpoint. A few times on each roof the deck splits. One line bows out and stays clean. The other is straighter, and it carries a hammer, a hurdle, or a boost gap you cannot flat-jump. Neither sign says which one is faster. Some roofs only connect if you kick up a wall onto a higher one, and some jumps are long falls onto a roof far below. Miss one and you respawn at the last checkpoint.

You race in a lobby of ten. Empty seats are filled by bots. They are a step slower on the flats, so a clean line can beat them.

The movement is the game. Surfaces are flat colors for now, so the run can be tuned before any art pass.

It is a Godot 4 project. You export a Windows, macOS, or Linux binary and that binary is what you sell. Godot is free for commercial games and does not take a royalty.

## Play it

Install [Godot 4.8](https://godotengine.org/download/archive/4.8-dev7/) or newer. On this PC the project is at `Desktop/Dev/Game Dev/Roofline`. `project.godot` sits directly inside `Roofline`, next to `scenes/` and `scripts/`. In Godot, choose Import if it is not already listed, select that `project.godot`, then press F5.

From a terminal, if the Godot binary is on your PATH:

```bash
godot --path .
```

If the window is black, launch with the compatibility renderer:

```bash
godot --path . --rendering-driver opengl3
```

### Controls

Keyboard:

- WASD to run
- Mouse to look
- Space to jump. At a lip, Space or forward pulls you up
- Shift (or C) to slide. Either one lets go of a lip
- Esc releases the mouse
- R restarts a solo race on the same roof

Controller:

- Left stick to run
- Right stick to look
- A (the south button) to jump. A or Start also clicks in to run, the same as a mouse click. At a lip, A or forward pulls you up
- LB, X, or the right trigger to slide. Any of those lets go of a lip
- Start pauses and resumes
- B or Esc releases the mouse
- Back (Select) restarts a solo race, the same as R

On the home screen, the practice picker, the vote, and the results, the D-pad or left stick moves between buttons and A confirms. From Run solo, right reaches the color slider, and left and right change the hue while that slider is highlighted. The screen name is still typed on the keyboard.

- Jump while you are on a wall to kick off it. The kick climbs, so you can bounce upward onto a higher roof
- Kick into the opposite wall to bounce across a gap
- Miss a jump low and your hands catch the lip if they reach it. You hang there. Hold forward or jump to pull up. Back or slide lets go

The race counts 3, 2, 1, RUN!. You can look around during the count. You can run when it says RUN!.

On the home screen, type a screen name and drag the color slider. The mannequin and the name above its head update as you drag. That same name floats over your runner in the race, in the color you picked, so the other nine can tell who is who. Steam names will replace the typed name later. The mannequin is a stand-in until there are more characters.

Click in during the countdown if the mouse is free. Everyone goes on RUN!.

## Maps

Annex, Kiln, Culvert, Highline, Switchback, Overpass, Gallery, Spire, Canal, and Night Market. The vote shows all ten. In a room, the majority wins and a tie draws lots. Solo, your pick starts the race.

## Practice

Practice is a solo run on a roof you pick. Leave the lobby empty, or fill the other nine seats with bots. Speedrun starts a clock on RUN! and keeps your best time for that roof. The next speedrun plays that best back as a ghost in your color. The ghost is see-through and has no collision, so you can run straight through it. The corner shows your current time and your PB. Practice does not pay XP or crowns. R restarts the same roof.

## Crowns and levels

A win earns a crown. Crowns, XP, and level are saved on this computer. XP is a stack of bonuses, so a finish in a field of ten still pays even when you are nowhere near the win.

- Finish: 40 XP for crossing the line. A DNF pays nothing.
- Win: +110 XP and a crown
- 2nd: +55 XP
- 3rd: +35 XP
- Top half: +25 XP for 4th or 5th
- Flawless: +35 XP if you never fall back to a checkpoint
- On pace: +20 XP if you finish at or under the time listed for that roof

The place bonuses do not stack with each other. A win is the win bonus, not the win bonus plus top half. Flawless and on pace stack with whatever place you earned.

Skins are listed as level rewards (chalked palms, a kiln jacket, and the rest). Wearing them is not in yet.

## Ten runners

Host and join work on a local network. One person clicks **Host a room**. The others click **Join** and type that computer's LAN address (often `192.168.x.x`). The room holds ten runners. Open slots are bots until a person takes the seat, and a bot comes back if someone leaves. Everyone needs the same build.

There is no public matchmaking yet.

## Export a build

1. In Godot: Editor → Manage Export Templates, and install the templates for your editor version.
2. Project → Export → Add… → Windows Desktop, Linux, or macOS.
3. Export a release binary.

Ship that file. You do not ship the Godot editor.
