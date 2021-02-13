/* A Scorpion with a configurable turreted weapon.
 * Used by the "MutLPVehicleMods" mutator.
 *
 * Copyright (c) 2005, Philip "LionsPhil" Boulain.
 * This work is licensed under the terms of the GNU General Public License v3.
 */

class ONSRVMultiturret extends ONSRV;

defaultproperties {
  // The below doesn't work, as LinkGun is a Weapon, not an ONSWeapon
  //DriverWeapons(0)=(WeaponClass=class'XWeapons.LinkGun',WeaponBone=ChainGunAttachment);
  // This does (the Hellbender's SkyMine gun)
  //DriverWeapons(0)=(WeaponClass=class'Onslaught.ONSPRVSideGun',WeaponBone=ChainGunAttachment);
  // As does this, to great comic effect (Goliath's cannon)
  DriverWeapons(0)=(WeaponClass=class'Onslaught.ONSHoverTankCannon',WeaponBone=ChainGunAttachment);
}
