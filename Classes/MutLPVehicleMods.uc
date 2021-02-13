/* LionsPhil's Vehicle Modifications -- because motorised death is fun!
 *
 * Copyright (c) 2005, Philip "LionsPhil" Boulain.
 * This work is licensed under the terms of the GNU General Public License v3.
 */

class MutLPVehicleMods extends Mutator
  dependson(ONSVehicle);
//  dependson(ONSRVMultiturret);

function PostBeginPlay() {
/*  local ONSVehicleFactory factory;

  foreach AllActors(class 'ONSVehicleFactory', factory) {
    // Change all Scorpions for our own, multi-turret version
    if(ClassIsChildOf(factory.VehicleClass, class'Onslaught.ONSRV')) {
      factory.VehicleClass = class'LionsPhilMut.ONSRVMultiturret';
      // factory.VehicleClass = class'OnslaughtFull.ONSGenericSD'; // Useful to debug this ;)
    }
  } */

  Super.PostBeginPlay();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
  local ONSVehicle.DriverWeaponStruct weapon;
  local ONSRV scorpion; scorpion = ONSRV(Other); // Bizzare casting syntax, that...
  if(scorpion != None) {
    // Change the Scorpion's weapon
    weapon.WeaponClass = class'Onslaught.ONSHoverTankCannon';
    weapon.WeaponBone  = 'ChainGunAttachment';
    scorpion.DriverWeapons[0] = weapon;
  }
  return true;
}

// This approach is inefficient and seems to lose team information, making everything locked by red
// Changed to take an approach similar to OnslaughtFull.MutVehicleArena
/* function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
         // if(Other.class == class'Onslaught.ONSRV') { // Won't work for inheritance
         if (Other.IsA('ONSRV')) {
                  // Will later need  && !Other.IsA('LinkingScorpion'), as it'll subclass
                  ReplaceWith(Other, "OnslaughtFull.ONSGenericSD"); // Temporary
                  return false;
         }
         return true;
} */

defaultproperties {
  FriendlyName="LionsPhil's Vehicle Modifications"
  Description="Pimp your Onslaught-bound rides with an assortment of interesting tweaks."
}

/* Useful web links for all this:
http://wiki.beyondunreal.com/wiki/Mutator
http://wiki.beyondunreal.com/wiki/Mutator_Topics
http://wiki.beyondunreal.com/wiki/Mutator_Availability_(UT2004)
http://wiki.beyondunreal.com/wiki/UnrealScript_Lessons
http://wiki.beyondunreal.com/wiki/UnrealScript_Language_Reference/Variables
http://wiki.beyondunreal.com/wiki/UnrealScript_Language_Reference/Language_Functionality
http://wiki.beyondunreal.com/wiki/Class_Syntax
http://wiki.beyondunreal.com/wiki/Weapon_Mutator_Tutorial
http://wiki.beyondunreal.com/wiki/CheckReplacement
http://wiki.beyondunreal.com/wiki/Modifying_The_Bulldog  (Warning: code samples decidedly dodgy, and also for UT2003 vehicles)
http://chimeric.beyondunreal.com/tutorials/tut30.php
http://wiki.beyondunreal.com/wiki/Global_Function
*/
