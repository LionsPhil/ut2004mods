/* LionsPhil's Vehicle Modifications -- because motorised death is fun!
 *
 * Copyright (c) 2005, Philip "LionsPhil" Boulain.
 * This work is licensed under the terms of the GNU General Public License v3.
 *
 * Massive thanks to UnrealWiki and all its contributors, and to Epic for
 * actually providing a decent, OO approach to modifying their games.
 */

// TODO Create a LinkGunTurret and add support for it
// TODO Look into fiddling with the AI desirability of meddled vehicles (may be impossible without subclassing)

class MutLPVehicleMods extends Mutator
	dependson(ONSVehicle)
	config(User);

struct MutLPVehicleModsVehicle {
	var string dname; // Display name
	var string clsname; // Class name
	var bool big;
	// Number of weapons in driver and passenger slots. Either may be zero.
	var int driverweps;
	var int passengerweps;
	// Physics changes to make for incorrect size (i.e. if big, for undersize weapon, and vica-versa).
	var float  pcmass;    // Multiplier for total mass
	var vector pccom;     // New centre of mass
	var float  pcimpulse; // Firing impulse
	// Cached effects for this game
	var class<ONSVehicle> cls; // Actual class (dynloaded from name)
	var class<ONSWeapon> weaponcls; // Weapon class to use (None if unchanged)
	var bool missized; // Apply over/undersize effects
};

struct MutLPVehicleModsWeapon {
	var string dname; // Display name
	var string clsname; // Class name
	var bool big;
};

var config bool adapthandling; // Make physics adaptations to allow for new weapons
var config array<string> weaponselections; // Hella-magical index nastyness here =/

var array<MutLPVehicleModsVehicle> vehicles;
var int                            vehiclecount;
var array<MutLPVehicleModsWeapon>  weapons;
var int                            weaponcount;

var bool cachingdone;

// GRAPHICAL CONFIGURATION  ////////////////////////////////////////////////////
static event string GetDescriptionText(string propname) {
	if(propname == "adapthandling") {
		return "Over or undersized turrets will change vehicle handling";
	} else if(Left(propname, Len("weaponselections")) == "weaponselections") {
		return "Weapon to use on this turret";
	} else { return Super.GetDescriptionText(propname); }
}

static function FillPlayInfo(PlayInfo playinfo) {
	local int vindex;
	local int i;
	local int selindex;
	local MutLPVehicleModsVehicle vehicle;
	local string weaponstr;

	Super.FillPlayInfo(playinfo);

	for(i = 0; i < default.weaponcount; i++) {
		if(weaponstr != "") { weaponstr $= ";"; }
		weaponstr $= default.weapons[i].clsname $ ";" $ default.weapons[i].dname;
	}

	selindex = 0;
	for(vindex = 0; vindex < default.vehiclecount; vindex++) {
		vehicle = default.vehicles[vindex];
		for(i = 0; i < vehicle.driverweps; i++) {
			PlayInfo.AddSetting(default.GameGroup,
				"weaponselections[" $ selindex $ "]",
				vehicle.dname $ " driver " $ i,
				0, 0, "Select", weaponstr);
			selindex++;
		}
	}

	PlayInfo.AddSetting(default.GameGroup, "adapthandling", "Turrets affect physics", 0, 1, "Check");
}

defaultproperties {
	FriendlyName="LionsPhil's Vehicle Modifications"
	Description="Pimp your Onslaught-bound rides with an assortment of interesting tweaks."
	bAddToServerPackages = true;

	adapthandling = true;
	cachingdone   = false;

	// OMFG. The UnrealScript parser is sensitive to whitespace in these. Ouch.

	vehicles[0] = (dname="Scorpion",clsname="Onslaught.ONSRV",big=false,driverweps=1,passengerweps=0,pcmass=1.5,pccom=(X=-0.8125,Y=0.0,Z=-1.3),pcimpulse=-98304);
	// COM = original * 3.25: feels about right: it's heavy, but not obscene (Scorpions appear front-engined and are near-perfectly balanced by default)
	// Impluse is just enough to give a healthy kick when firing forward without making it impossible
	vehiclecount = 1;

	weapons[0] = (dname="Goliath cannon",clsname="Onslaught.ONSHoverTankCannon",big=true);
	weaponcount = 1;
}

/* // "Bindings" are used in the config array to maintain some kind of persistence across changing vehicles
// No they're not...configuration just don't work like that =(
struct MutLPVehicleModsBinding {
	var string vehicle; // Class name
	var bool passenger;
	var int slot;
	var string weapon; // Class name
};
static function string Binding_Serialise(MutLPVehicleModsBinding binding) {
	return binding.vehicle $ ":" $ (binding.passenger ? "p" : "d") $ binding.slot $ "=" $ binding.weapon;
}
var config array<string> weaponbindings; */

/*

class MutLPVehicleMods extends Mutator
  dependson(ONSVehicle)
  config(User);

var config string wepnam_scorpion;
var config string wepnam_spma;
var config bool   adapthandling; // Make physics adaptations to allow for new weapons
var class<ONSWeapon> wep_scorpion; // Note that these are acutal classes, unlike
var class<ONSWeapon> wep_spma;     // the "nam" string versions
var bool             wep_scorpion_big;
var bool             wep_spma_big;

var localized string GUIDisplayText[3];
var localized string GUIDescText[3];
var localized string GUIPossibleTurretNames[2];
var           string GUIPossibleTurrets[2]; // Classnames; 0 is magical for 'default'
var           int    GUIPossibleTurretBig[2]; // Can't have bool arrays!
var           int    GUIPossibleTurretCount;

// At startup, convert the configuration strings into actual classes for speed
// and general code cleanliness. Likewise cache the 'bigness'.
static function class<ONSWeapon> TurretStringToClass(string turretname) {
  if(turretname == default.GUIPossibleTurrets[0]) { return None; }
  return class<ONSWeapon>(DynamicLoadObject(turretname, class'Class'));
}
static function bool TurretIsBig(string turretname) {
  local int i;
  for(i = 0; i < default.GUIPossibleTurretCount ; i++) {
    if(default.GUIPossibleTurrets[i] ~= turretname)
      { return (default.GUIPossibleTurretBig[i] != 0); }
  }
  log("MutLPVehicleMods: Don't know if turret '" $ turretname $ "' is big!");
  return false; // Erm...we don't know. Should never get here.
}
function PostBeginPlay() {
  wep_scorpion     = TurretStringToClass(wepnam_scorpion);
  wep_scorpion_big = TurretIsBig(wepnam_scorpion);
  wep_spma         = TurretStringToClass(wepnam_spma);
  wep_spma_big     = TurretIsBig(wepnam_spma);
}

// Modify vehicles as they are created in CheckReplacement. This avoids the need
// for subclassing them (and then trying to work out how to convince that
// subclass to accept a configurable turret) and changing the factories.
function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
  local ONSVehicle.DriverWeaponStruct weapon;
  local ONSRV scorpion;
  local ONSArtillery spma;
  local bool modmade;
  local bool bigweapon;

  if(!Other.IsA('ONSVehicle')) { return true; } // Don't bother checking specific subclasses

  // Cast to specific vehicles *if* we've got a turret replacement to perform
  if(wep_scorpion == None) { scorpion = None; }
    else { scorpion = ONSRV(Other); }
  if(wep_spma     == None) { spma     = None; }
    else { spma     = ONSArtillery(Other); }

  modmade = false;
  if(scorpion != None) {
    // Change the Scorpion's weapon
    weapon.WeaponClass = wep_scorpion;
    weapon.WeaponBone  = 'ChainGunAttachment';
    scorpion.DriverWeapons[0] = weapon;
    bigweapon = wep_scorpion_big;
    modmade = true;
  } else if(spma != None) {
    // Change the SPMA's weapon
    weapon.WeaponClass = wep_spma;
    weapon.WeaponBone  = 'CannonAttach';
    spma.DriverWeapons[0] = weapon;
    bigweapon = wep_spma_big;
    modmade = true;
  }

  // Make vehicle handle appropriately for its new weapon
  if(modmade) { ModifyVPhysics(ONSVehicle(Other), bigweapon); }

  return true; // We never actually replace entire objects
}

// Modify the vehicle's physics to feel right for the turret it's equipped with
// "Big" weapons such as the Goliath turret, SPMA cannon and up
// Non-big weapons would be those on the Hellbender, Scorpion, and down
function ModifyVPhysics(ONSVehicle vehicle, bool bigweapon) {
  local ONSRV scorpion;
  local ONSArtillery spma;
  local bool change;
  local float cmass;
  local float ccom;
  local float cimpulse;
  local vector temp;

  if(!adapthandling) { return; }

  change = false;
  scorpion = ONSRV(vehicle);
  spma = ONSArtillery(vehicle);
  if(scorpion != None) {
    if(bigweapon) { // Adapt Scorpion to oversized weapon
      change   = true;
      cmass    = 1.5;
      ccom     = 3.25; // Feels about right: it's heavy, but not obscene (Scorpions appear front-engined and are near-perfectly balanced by default) // X=-0.25,Y=0.0,Z=-0.4
      cimpulse = -98304; // Just enough to give a healthy kick when firing forward without making it impossible
    }
  } else if(spma != None) {
    if(!bigweapon) { // Adapt SPMA to undersized weapon TODO Untweaked
      change   = true;
      cmass    = 0.7;
      ccom     = 0; // Back to geographical centre or so
      cimpulse = 0; // Not going to feel a thing
    }
  } else { log("MutLPVehicleMods: modifyPhysics() called with unknown vehicle!"); }

  if(change) {
    vehicle.VehicleMass *= cmass; // This lives all the way back in SVehicle
    vehicle.KSetMass(vehicle.KGetMass() * cmass);
    vehicle.KGetCOMOffset(temp);
    temp.X *= ccom;
    vehicle.KSetCOMOffset(temp);
    if(cimpulse != 0) {
      vehicle.bHasAltFireImpulse = true;
      temp.X = cimpulse; temp.Y = 0; temp.Z = 0;
      vehicle.FireImpulse = temp;
    } else {
      vehicle.bHasFireImpulse = false;
    }
  }
}

// GRAPHICAL CONFIGURATION  ////////////////////////////////////////////////////
static function int IndexOfWidget(string PropName) {
  switch (PropName) {
    case "wepnam_scorpion": return 0;
    case "wepnam_spma":     return 1;
    case "adapthandling":   return 2;
  }
  return -1;
}

static function string GetDisplayText(string PropName) {
  local int idx; idx = IndexOfWidget(PropName);
  if(idx != -1) { return default.GUIDisplayText[idx]; }
  else {
    //return Super.GetDisplayText(PropName); // This is apparently correct, but no such method exists in Mutator
    return "ERROR"; // So do this instead
  }
}

static event string GetDescriptionText(string PropName) {
  local int idx; idx = IndexOfWidget(PropName);
  if(idx != -1) { return default.GUIDescText[idx]; }
  else { return Super.GetDescriptionText(PropName); }
}

static function FillPlayInfo(PlayInfo PlayInfo) {
  local string turrets;
  local int i;

  Super.FillPlayInfo(PlayInfo);
  turrets = "";
  for(i = 0; i < default.GUIPossibleTurretCount; i++) {
    if(turrets != "") { turrets $= ";"; }
    turrets $= default.GUIPossibleTurrets[i] $ ";" $ default.GUIPossibleTurretNames[i];
  }
  PlayInfo.AddSetting(default.GameGroup, "wepnam_scorpion", GetDisplayText("wepnam_scorpion"),
    0, 0, "Select", turrets);
  PlayInfo.AddSetting(default.GameGroup, "wepnam_spma",     GetDisplayText("wepnam_spma"),
    0, 1, "Select", turrets);
  PlayInfo.AddSetting(default.GameGroup, "adapthandling",   GetDisplayText("adapthandling"),
    0, 2, "Check");
}

defaultproperties {
  FriendlyName="LionsPhil's Vehicle Modifications"
  Description="Pimp your Onslaught-bound rides with an assortment of interesting tweaks."
  bAddToServerPackages = true;

  GUIDisplayText[0] = "Scorpion turret";
  GUIDescText[0]    = "Replace the Scorpion's weapon with another (the blades stay)";
  GUIDisplayText[1] = "SPMA turret";
  GUIDescText[1]    = "Replace the SPMA's weapon with another (the skymine turret stays)";
  GUIDisplayText[2] = "Turrets affect physics";
  GUIDescText[2]    = "Over or undersized turrets will change vehicle handling";
  GUIPossibleTurretNames[0] = "Default";
  GUIPossibleTurrets[0]     = "_default_";
  GUIPossibleTurretBig[0]   = 0; // Doesn't matter; will never cause change
  GUIPossibleTurretNames[1] = "Goliath cannon";
  GUIPossibleTurrets[1]     = "Onslaught.ONSHoverTankCannon";
  GUIPossibleTurretBig[1]   = 1;
  GUIPossibleTurretCount    = 2;

  wepnam_scorpion = "_default_";
  wepnam_spma     = "_default_";
  adapthandling   = true;

  wep_scorpion = None;
  wep_spma     = None;
}

*/

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
http://wiki.beyondunreal.com/wiki/Karma_Functions_And_Events
http://wiki.beyondunreal.com/wiki/ONSVehicle
http://wiki.beyondunreal.com/wiki/Static_Function
http://wiki.beyondunreal.com/wiki/Mutator_Config_GUI_(UT2004)
http://wiki.beyondunreal.com/wiki/Dynamic_Array
http://lists.tunes.org/archives/gclist/1999-July/001634.html
http://udn.epicgames.com/Two/StringsInUnrealScript
*/

/* Car Launcher 5-4's "Improved Vehicle Arena" uses this approach to get a listing of vehicles:
	local array<CacheManager.VehicleRecord> VehicleList;
	class'CacheManager'.static.GetVehicleList(VehicleList);
	for (i=0; i< VehicleList.Length; i++) {
		if (VehicleOptions != "") VehicleOptions $= ";";
		VehicleOptions $= VehicleList[i].ClassName $ ";" $ VehicleList[i].FriendlyName;
	}
   But it doesn't extend out to subclasses of any general class (e.g. ONSWeapon) =( */
