# LionsPhil's Vehicle Modifications
***Because motorised death is fun!***

## About

Lets you swap around the turrets on the vehicles in the game Unreal Tournament 2004. Here's a video of some gameplay with it:

[![A Scorpion with a Goliath turret.](http://img.youtube.com/vi/iN1C7E86ZNQ/0.jpg)](http://www.youtube.com/watch?v=iN1C7E86ZNQ "Watch some gameplay on YouTube")

## Installation

Grab the compiled version (you want the `.u` file) from the [GitHub Release page](https://github.com/LionsPhil/ut2004mods/releases/) and drop it under your UT2004 `System` folder.

You will need ~the last official patch version, which IIRC is 3369, with the ECE bonus pack (which was free). If you have a UT2004 install in 2021, I strongly suspect you already have these.

## Usage

1. Set up an Onslaught match. (It should also work in VCTF.)
2. Add it as a mutator.
3. Click the "Configure Mutators" button at the bottom.
4. Pick some different turrets for different vehicles.

I strongly recommend putting the Goliath tank turret on the little Scorpion buggies, and leaving the "affect physics" toggle on. This is how this mutator started out, and provides exciting jousting silliness since they can now one-shot each-other but handle with the heavy rear-ended waddle and crazy kickback you'd expect.

It's also entertaining to put the Leviathan main cannon on Goliaths, if you want more explosions on maps that don't normally spawn Leviathans.

Putting Cicada belly guns on Raptors make them a lot worse since they can now deal with AVRiLs...

And, finally, not everything will work 100%. Only Scorpions really have their physics tweaked properly, and some guns have special effects that don't work well on a different vehicle (e.g. the Paladin's shield combo will do self-damage).

### Dedicated servers

If you're running a dedicated server, you might need the `.ucl` file from Releases as well, which I think gets automatically generated otherwise when starting a local game. You will still want to run it locally/graphically once to do configuration; you can then copy the `[LionsPhilMut.MutLPVehicleMods]` stanza from `User.ini` to your server. Here's an example one that makes the above suggested swaps:

```ini
[LionsPhilMut.MutLPVehicleMods]
adapthandling=True
weaponselection_manta_d0=
weaponselection_scorpion_d0=Onslaught.ONSHoverTankCannon
weaponselection_hellbender_p0=
weaponselection_hellbender_p1=
weaponselection_goliath_d0=OnslaughtFull.ONSMASCannon
weaponselection_goliath_p0=
weaponselection_iontank_d0=
weaponselection_iontank_p0=
weaponselection_leviathan_d0=
weaponselection_leviathan_d1=
weaponselection_leviathan_p0=
weaponselection_leviathan_p1=
weaponselection_leviathan_p2=
weaponselection_leviathan_p3=
weaponselection_raptor_d0=OnslaughtBP.ONSDualACGatlingGun
weaponselection_paladin_d0=
weaponselection_paladin_p0=
weaponselection_spma_d0=
weaponselection_spma_p0=
weaponselection_cicada_d0=
weaponselection_cicada_d1=
weaponselection_cicada_p0=
```

## Building

Heck if I can remember properly. This was from about forteen years now, I just dug it out again. I think you need the Unreal Development Environment, circa 2005--2006, to compile it.

## License

GNU GPL v3. See `LICENSE`.
