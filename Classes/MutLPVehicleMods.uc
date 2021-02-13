/* LionsPhil's Vehicle Modifications -- because motorised death is fun!
 * Version 0.3.
 *
 * Copyright (c) 2005, Philip "LionsPhil" Boulain.
 * This work is licensed under the terms of the GNU General Public License v3.
 *
 * Massive thanks to UnrealWiki and all its contributors, and to Epic for
 * actually providing a decent, OO approach to modifying their games.
 *
 * vim: ts=4 syntax=uc
 */

/*****************************************************************************
 * WARNING! This mutator is automatically generated from a meta-source file! *
 *          Modifications to this generated version will be lost!            *
 *****************************************************************************/


// TODO Create a LinkGunTurret and add support for it
// TODO Look into fiddling with the AI desirability of meddled vehicles (may be impossible without subclassing)

class MutLPVehicleMods extends Mutator
	dependson(ONSVehicle)
	config(User);

struct MutLPVehicleModsVehicle {
	var string dname; // Display name
	var string clsname; // Class name
	var string cfgname; // Name for configuration
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
	var array< class<ONSWeapon> > weaponclsdrv; // Weapon classes to use (None if unchanged)
	var array< class<ONSWeapon> > weaponclspas; // ...for passengers
	var bool missized; // Apply over/undersize effects
	var bool modified; // Modified any weapons at all?
};

struct MutLPVehicleModsWeapon {
	var string dname; // Display name
	var string clsname; // Class name
	var bool big;
};

var config bool adapthandling; // Make physics adaptations to allow for new weapons
var config string weaponselection_scorpion_d0;
var config string weaponselection_spma_d0;
var config string weaponselection_spma_p0;


var array<MutLPVehicleModsVehicle> vehicles;
var int                            vehiclecount;
var array<MutLPVehicleModsWeapon>  weapons; // First item (zero) is magical (default)
var int                            weaponcount;

// GAMEPLAY EFFECTS ////////////////////////////////////////////////////////////
// Convert a classname into an index into the weapons array
function int LookupWeapon(string classname) {
	local int windex;
	for(windex = 0; windex < weaponcount; windex++) {
		if(weapons[windex].clsname == classname)
			{ return windex; }
	}
	log("MutLPVehicleMods: Couldn't find weapon '" $ classname $ "' in the weapon listing!");
	return 0; // Default to the default weapon
}

// Set a vehicle's cached weapon, using a form from the configuration variables
// Give me a damn reference (or at least copy back) for vehicle already! Changes 'modified' flag.
function SetVehicleWeapon(out MutLPVehicleModsVehicle vehicle, bool driver, int idx, string wepclass) {
	local int windex;
	local MutLPVehicleModsWeapon weapon;
	local class<ONSWeapon> wclass;

	local string dbg_dp;
	local string dbg_w;
	local string dbg_sz;

	// Find the weapon
	windex = LookupWeapon(wepclass);
	weapon = weapons[windex];

	// Set weaponclsdrv/pas appropriately
	if(windex != 0) {
		wclass = class<ONSWeapon>(DynamicLoadObject(weapon.clsname, class'Class'));
		vehicle.modified = true;
	} else {
		wclass = None;
	}
	if(driver) {
		vehicle.weaponclsdrv[idx] = wclass;
	} else {
		vehicle.weaponclspas[idx] = wclass;
	}

	// Modify missized if needed (ignore if default weapon, as we don't know)
	// This is imperfect if you have a large vehicle with default, large weapons, but hey
	if(windex != 0) {
		if(!vehicle.big && weapon.big) {
			vehicle.missized = true; // Small vehicle has gained big weapon
		} else if(vehicle.big && weapon.big) {
			vehicle.missized = false; // Big vehicle has gained big weapon, so is no long missized
		}
	}

	// Debugging trace
	if(driver){dbg_dp="driver";}else{dbg_dp="passenger";}
	if(wclass == None){dbg_w="(default weapon)";}else{dbg_w=string(wclass.Name);}
	if(vehicle.missized){dbg_sz=", and is missized";}else{dbg_sz="";}
	log("MutLPVehicleMods: Vehicle '" $ vehicle.clsname $ "' has " $ dbg_dp
		$ " weapon " $ idx $ " of " $ dbg_w $ dbg_sz);
}

// Set up the caches, as this is slow and ugly
function BeginPlay() { // Care not for Zones or Volumes, so don't need to wait until PostBeginPlay()
	local int vindex;
	local MutLPVehicleModsVehicle vehicle;

	for(vindex = 0; vindex < vehiclecount; vindex++) {
		vehicle = vehicles[vindex];
  		vehicle.cls = class<ONSVehicle>(DynamicLoadObject(vehicle.clsname, class'Class'));
		if(vehicle.cls == None) {
			log("MutLPVehicleMods: CLASS FOR VEHICLE '" $ vehicle.clsname $ "' NOT FOUND!");
		} else { // Debug
			log("MutLPVehicleMods: class for vehicle '" $ vehicle.clsname $ "' found as '" $ string(vehicle.cls.Name) $ "'");
		}
		vehicle.modified = false;
		// Mis-sized if:
		//   Vehicle small and
		//     Any weapon big OR
		//   Vehicle big and
		//     All weapons small
		vehicle.missized = vehicle.big;

		// Have a STONKING GREAT LUMP of autogenerated code, as the
		// config interface can't handle 'complex' data structures such
		// as arrays, let alone hashtables or the like, and there is no
		// reflection API. Anyway, the pattern is:
		// if(vehicle.cfgname == each_vehicle's_cfgname) {
		//   foreach(driver and passenger slot)
		//     SetVehicleWeapon using the appropriate config variable
		// } else move on to the next cfgname

		if(false) { // Make the rest more consistent, and thus easier to generate
		} else if(vehicle.cfgname == "scorpion") {
			SetVehicleWeapon(vehicle, true,  0, weaponselection_scorpion_d0);
		} else if(vehicle.cfgname == "spma") {
			SetVehicleWeapon(vehicle, true,  0, weaponselection_spma_d0);
			SetVehicleWeapon(vehicle, false, 0, weaponselection_spma_p0);
		} else { log("MutLPVehicleMods: Unknown vehicle '" $ vehicle.cfgname $ "'!"); }

		// End stonking great lump. Have a nice day!

		vehicles[vindex] = vehicle; // Yeah, you WISH it were a reference!
	}
	log("Class of vehicle zero is: " $ string(vehicles[0].cls.Name)); // Debug
	if(vehicles[0].modified) { log("Vehicle zero has been modified"); }
}

// Modify vehicles as they are created in CheckReplacement. This avoids the need
// for subclassing them (and then trying to work out how to convince that
// subclass to accept a configurable turret) and changing the factories.
function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
	local ONSVehicle actvehicle;
	local MutLPVehicleModsVehicle vehicle;
	local vector temp;
	local int vindex;
	local int sindex;

	actvehicle = ONSVehicle(Other);
	if(actvehicle == None) { return true; } // This isn't a vehicle; go away

	for(vindex = 0; vindex < vehiclecount; vindex++) {
		vehicle = vehicles[vindex];
		// Incredibly verbose debug
		log("MutLPVehicleMods: " $ string(Other) $ " <==> " $ string(vehicle.cls.Name) $ "(" $ vindex $ ")");
		if(vehicle.modified && Other.IsA(vehicle.cls.Name)) { // Consider also ClassIsChildOf(Other.class, vehicle.cls)
			log("MutLPVehicleMods: Changing a vehicle of type " $ string(vehicle.cls.Name));
			// Ah, we've found it! Change the weapon slots.
			for(sindex = 0; sindex < vehicle.driverweps; sindex++) {
				if(vehicle.weaponclsdrv[sindex] != None) {
					actvehicle.DriverWeapons[sindex].WeaponClass =
						vehicle.weaponclsdrv[sindex];
				}
			}
/*			for(sindex = 0; sindex < vehicle.passengerweps; sindex++) {
				if(vehicle.weaponclspas[sindex] != None) {
					actvehicle.PassengerWeapons[sindex].WeaponPawnClass =
						vehicle.weaponclspas[sindex];
				}
			} ** Unsupported for now--ONSWeapon != ONSWeaponPawn (latter contains former) */

			// Modify the physical properties if needed
			if(adapthandling && vehicle.missized) {
				actvehicle.VehicleMass *= vehicle.pcmass; // This lives all the way back in SVehicle
				actvehicle.KSetMass(actvehicle.KGetMass() * vehicle.pcmass);
				actvehicle.KSetCOMOffset(vehicle.pccom);
				if(vehicle.pcimpulse != 0) {
					actvehicle.bHasAltFireImpulse = true;
					temp.X = -vehicle.pcimpulse; temp.Y = 0; temp.Z = 0;
					actvehicle.FireImpulse = temp;
				} else {
					actvehicle.bHasFireImpulse = false;
				}
			}

			return true; // Not actually replaced; return early, however
		}
	}
	return true; // Well, we never found it, so leave it alone
}

// GRAPHICAL CONFIGURATION  ////////////////////////////////////////////////////
static event string GetDescriptionText(string propname) {
	if(propname == "adapthandling") {
		return "Over or undersized turrets will change vehicle handling";
	} else if(Left(propname, Len("weaponselection")) == "weaponselection") {
		return "Weapon to use on this turret";
	} else { return Super.GetDescriptionText(propname); }
}

static function FillPlayInfo(PlayInfo playinfo) {
	local int vindex;
	local int i;
	local MutLPVehicleModsVehicle vehicle;
	local string weaponstr;

	Super.FillPlayInfo(playinfo);

	for(i = 0; i < default.weaponcount; i++) {
		if(weaponstr != "") { weaponstr $= ";"; }
		weaponstr $= default.weapons[i].clsname $ ";" $ default.weapons[i].dname;
	}

	for(vindex = 0; vindex < default.vehiclecount; vindex++) {
		vehicle = default.vehicles[vindex];
		for(i = 0; i < vehicle.driverweps; i++) {
			playinfo.AddSetting(default.GameGroup,
				"weaponselection_" $ vehicle.cfgname $ "_d" $ i,
				vehicle.dname $ " driver " $ (i+1),
				0, 0, "Select", weaponstr);
		}
/*		for(i = 0; i < vehicle.passengerweps; i++) {
			playinfo.AddSetting(default.GameGroup,
				"weaponselection_" $ vehicle.cfgname $ "_p" $ i,
				vehicle.dname $ " passenger " $ (i+1),
				0, 0, "Select", weaponstr);
		} */ // Disabled for now---see code which implements this
	}

	playinfo.AddSetting(default.GameGroup, "adapthandling", "Turrets affect physics", 0, 1, "Check");
}

// DATA ////////////////////////////////////////////////////////////////////////
defaultproperties {
	FriendlyName="LionsPhil's Vehicle Modifications"
	Description="Pimp your Onslaught-bound rides with an assortment of interesting tweaks.||http://www.zepler.net/~lionsphil/"
	bAddToServerPackages = true;

	adapthandling = true;

	vehicles[0] = (dname="Scorpion",clsname="Onslaught.ONSRV",cfgname="scorpion",big=false,driverweps=1,passengerweps=0,pcmass=1.5,pccom=(X=-0.8125,Y=0,Z=-1.3),pcimpulse=98304);
	vehicles[1] = (dname="S.P.M.A.",clsname="OnslaughtBP.ONSArtillery",cfgname="spma",big=true,driverweps=1,passengerweps=1,pcmass=0.8,pccom=(X=0,Y=0,Z=-0.6),pcimpulse=4096);
	vehiclecount = 2;

	weapons[0] = (dname="(Default)",clsname="_default_",big=false);
	weapons[1] = (dname="Goliath cannon",clsname="Onslaught.ONSHoverTankCannon",big=true);
	weaponcount = 2;

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
http://wiki.beyondunreal.com/wiki/Karma_Functions_And_Events
http://wiki.beyondunreal.com/wiki/ONSVehicle
http://wiki.beyondunreal.com/wiki/Static_Function
http://wiki.beyondunreal.com/wiki/Mutator_Config_GUI_(UT2004)
http://wiki.beyondunreal.com/wiki/Dynamic_Array
http://lists.tunes.org/archives/gclist/1999-July/001634.html
http://udn.epicgames.com/Two/StringsInUnrealScript
http://udn.epicgames.com/Two/CoreUnrealScriptObjects
*/

/* Car Launcher 5-4's "Improved Vehicle Arena" uses this approach to get a listing of vehicles:
	local array<CacheManager.VehicleRecord> VehicleList;
	class'CacheManager'.static.GetVehicleList(VehicleList);
	for (i=0; i< VehicleList.Length; i++) {
		if (VehicleOptions != "") VehicleOptions $= ";";
		VehicleOptions $= VehicleList[i].ClassName $ ";" $ VehicleList[i].FriendlyName;
	}
   But it doesn't extend out to subclasses of any general class (e.g. ONSWeapon) =( */
