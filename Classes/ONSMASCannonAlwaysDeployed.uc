/* LionsPhil's Vehicle Modifications -- because motorised death is fun!
 * Auxillary class for Version 0.3.
 *
 * Copyright (c) 2005, Philip "LionsPhil" Boulain.
 * This work is licensed under the terms of the GNU General Public License v3.
 *
 * Massive thanks to UnrealWiki and all its contributors, and to Epic for
 * actually providing a decent, OO approach to modifying their games.
 *
 * vim: ts=4 syntax=uc
 */

// This is required if the cannon is to even deploy on something which is not a Leviathan. (For those, genuine ONSMASCannons can be used.)
class ONSMASCannonAlwaysDeployed extends OnslaughtFull.ONSMASCannon;

simulated function PostNetBeginPlay() {
    super.PostNetBeginPlay();
    PlayAnim('MASMainGunDeploy');
}

defaultproperties {
    bForceCenterAim = False;
}

