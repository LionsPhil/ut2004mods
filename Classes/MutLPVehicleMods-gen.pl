#!/usr/bin/perl
use warnings;
use strict;

# LionsPhil's Vehicle Modifications -- because motorised death is fun!
# Copyright (c) 2005, Philip "LionsPhil" Boulain.
# This work is licensed under the terms of the GNU General Public License v3.

my @vehicles = ({ # TODO Only Scorpion has been tweaked; SPMA has been vaguely
	dname		=> 'Manta',
	clsname		=> 'Onslaught.ONSHoverBike',
	cfgname		=> 'manta',
	big		=> 0,
	driverweps	=> 1,
	passengerweps	=> 0,
	pcmass		=> 2.5,
	pccom		=> {X=>0.0, Y=>0.0, Z=>0.5}, # Original is dead centre
	pcimpulse	=> 131072, # WHAM!
	}, {
	dname		=> 'Scorpion',
	clsname		=> 'Onslaught.ONSRV',
	cfgname		=> 'scorpion',
	big		=> 0,
	driverweps	=> 1,
	passengerweps	=> 0,
	pcmass		=> 1.5,
	# Original * 3.25: feels about right: it's heavy, but not obscene (Scorpions appear front-engined and are near-perfectly balanced by default)
	pccom		=> {X=>-0.8125, Y=>0.0, Z=>-1.3},
	# Just enough to give a healthy kick when firing forward without making it impossible
	pcimpulse	=> 98304,
	}, {
	dname		=> 'Hellbender',
	clsname		=> 'Onslaught.ONSPRV',
	cfgname		=> 'hellbender',
	big		=> 1, # Borderline...but I think its rear gun kicks it into this category
	driverweps	=> 0,
	passengerweps	=> 2,
	pcmass		=> 0.9, # It's not going to lose much mass from smaller weapons
	pccom		=> {X=>-0.3, Y=>0.0, Z=>-0.5}, # Keep original
	pcimpulse	=> 2048,
	}, {
	dname		=> 'Goliath',
	clsname		=> 'Onslaught.ONSHoverTank',
	cfgname		=> 'goliath',
	big		=> 1,
	driverweps	=> 1,
	passengerweps	=> 1,
	pcmass		=> 0.92,
	pccom		=> {X=>0.0, Y=>0.0, Z=>0.2}, # Up a touch
	pcimpulse	=> 1024,
	}, {
	dname		=> 'Ion tank',
	clsname		=> 'OnslaughtFull.ONSHoverTank_IonPlasma',
	cfgname		=> 'iontank',
	big		=> 1,
	driverweps	=> 1,
	passengerweps	=> 1,
	pcmass		=> 0.91,
	pccom		=> {X=>0.0, Y=>0.0, Z=>0.2}, # As Goliath
	pcimpulse	=> 1536,
	}, {
	dname		=> 'Leviathan',
	clsname		=> 'OnslaughtFull.ONSMobileAssaultStation',
	cfgname		=> 'leviathan',
	big		=> 1, # Ya think?
	driverweps	=> 2,
	passengerweps	=> 4,
	pcmass		=> 0.95, # Removing that main cannon may do a bit
	pccom		=> {X=>0.0, Y=>0.0, Z=>0.0}, # Unaltered
	pcimpulse	=> 0, # Did a kitten sneeze somewhere?
	}, {
	dname		=> 'Raptor',
	clsname		=> 'Onslaught.ONSAttackCraft',
	cfgname		=> 'raptor',
	big		=> 0,
	driverweps	=> 1,
	passengerweps	=> 0,
	pcmass		=> 1.75,
	pccom		=> {X=>-0.25, Y=>0.0, Z=>0.5}, # Shift up, as Manta
	pcimpulse	=> 98304,
	}, { # Onto the bonus pack...
	dname		=> 'Paladin',
	clsname		=> 'OnslaughtBP.ONSShockTank',
	cfgname		=> 'paladin',
	big		=> 1,
	driverweps	=> 1,
	passengerweps	=> 1,
	pcmass		=> 0.85, # It's a big turret
	pccom		=> {X=>-0.25, Y=>0.0, Z=>-1.25}, # A touch up
	pcimpulse	=> 4096,
	}, { # The SPMA is an amusing one, as this finds a bug in Epic code (IsDepoyed()'s "None" test is broken)
	dname		=> 'S.P.M.A.',
	clsname		=> 'OnslaughtBP.ONSArtillery',
	cfgname		=> 'spma',
	big		=> 1,
	driverweps	=> 1,
	passengerweps	=> 1,
	pcmass		=> 0.8,
	pccom		=> {X=>0.0, Y=>0.0, Z=>-0.6},
	pcimpulse	=> 4096,
	}, {
	dname		=> 'Cicada',
	clsname		=> 'OnslaughtBP.ONSDualAttackCraft',
	cfgname		=> 'cicada',
	big		=> 0,
	driverweps	=> 2,
	passengerweps	=> 1,
	pcmass		=> 1.5,
	pccom		=> {X=>-0.25, Y=>0.0, Z=>0.25}, # Shift up, as Manta
	pcimpulse	=> 65536,
});

my @weapons = ({
	dname	=> '(Default)',
	clsname	=> '_default_',
	big	=> 0, charging => 0, # irrelevant
	}, {
	dname	=> 'Manta plasma casters',
	clsname	=> 'Onslaught.ONSHoverBikePlasmaGun',
	big	=> 0, charging => 0,
	}, {
	dname	=> 'Scorpion plasma ribbon launcher',
	clsname	=> 'Onslaught.ONSRVWebLauncher',
	big	=> 0, charging => 1,
	}, {
	dname	=> 'Hellbender skymine launcher',
	clsname	=> 'Onslaught.ONSPRVSideGun',
	big	=> 0, charging => 0,
	}, {
	dname	=> 'Hellbender dual laser turret',
	clsname	=> 'Onslaught.ONSPRVRearGun',
	big	=> 1, charging => 1,
	}, {
	dname	=> 'Goliath cannon',
	clsname	=> 'Onslaught.ONSHoverTankCannon',
	big	=> 1, charging => 0,
	}, {
	dname	=> 'Goliath machinegun',
	clsname	=> 'Onslaught.ONSTankSecondaryTurret',
	big	=> 0, charging => 0,
	}, {
	dname	=> 'Ion tank cannon',
	clsname	=> 'OnslaughtFull.ONSHoverTank_IonPlasma_Weapon',
	big	=> 1, charging => 1,
	}, {
	dname	=> 'Leviathan auxillary plasma',
	clsname	=> 'OnslaughtFull.ONSMASSideGun',
	big	=> 0, charging => 0,
	}, {
	dname	=> 'Leviathan rocket pack',
	clsname	=> 'OnslaughtFull.ONSMASRocketPack',
	big	=> 1, charging => 1, # ~= continuous fire of small rockets
	}, {
	dname	=> 'Leviathan main cannon',
	clsname	=> 'OnslaughtFull.ONSMASCannon',
	big	=> 1, charging => 0,
	}, {
	dname	=> 'Raptor plasma/missiles',
	clsname	=> 'Onslaught.ONSAttackCraftGun',
	big	=> 0, charging => 0,
	}, { # And now, the bonus pack...
	dname	=> 'Paladin cannon/shield',
	clsname	=> 'OnslaughtBP.ONSShockTankCannon',
	big	=> 1, charging => 0, # shield is, but hey
	}, {
	dname	=> 'S.P.M.A. cannon',
	clsname	=> 'OnslaughtBP.ONSArtilleryCannon',
	big	=> 1, charging => 0,
	}, {
	dname	=> 'S.P.M.A. skymine launcher',
	clsname	=> 'OnslaughtBP.ONSArtillerySideGun',
	big	=> 0, charging => 0,
	}, {
	dname	=> 'Cicada missile packs',
	clsname	=> 'OnslaughtBP.ONSDualACSideGun',
	big	=> 0, charging => 0, # normal use case isn't
	}, {
	dname	=> 'Cicada belly turret',
	clsname	=> 'OnslaughtBP.ONSDualACGatlingGun',
	big	=> 0, charging => 0,
});

open SOURCE, '<', 'MutLPVehicleMods.uc.src';
my $mutator;
{ local $/; $mutator = <SOURCE>; }
close SOURCE;
# UNIX-ify
$mutator =~ s/\r\n/\n/g;

# Warning about autogenerated source
{
	my $warning = <<EOW;
/*****************************************************************************
 * WARNING! This mutator is automatically generated from a meta-source file! *
 *          Modifications to this generated version will be lost!            *
 *****************************************************************************/
EOW
	$mutator =~ s/__AUTOGEN_WARNING__/$warning/;
}

# Generate config variables. Ah, if only you could beat the configuration interface with a cluebat. Or at least use arrays.
{
	my $configs = '';
	foreach my $v (@vehicles) {
		for(my $w = 0; $w < $v->{'driverweps'   }; $w++) {
			$configs .= 'var config string weaponselection_'.$v->{'cfgname'}."_d$w;\n";
		}
		for(my $w = 0; $w < $v->{'passengerweps'}; $w++) {
			$configs .= 'var config string weaponselection_'.$v->{'cfgname'}."_p$w;\n";
		}
	}
	$mutator =~ s/__MAGIC_CONFIG__/$configs/;
}

# And now the /really/ sick bit...generate code which does a poor man's associative array using the config vars.
# It's a good job this only runs in PostBeginPlay(), because I can't imagine that it's particularly fast(!)
{
	my $hair = "\t\tif(false) { // Make the rest more consistent, and thus easier to generate\n";
	foreach(@vehicles) {
		# Find the configuration variable name which matches this vehicle
		$hair .= "\t\t} else if(vehicle.cfgname == \"".$_->{'cfgname'}."\") {\n";
		my $cfgvar = 'weaponselection_'.$_->{'cfgname'}.'_'; # Sans dN/pN suffix
		# Set up all the driver and passenger slots of the vehicle
		for(my $s = 0; $s < $_->{'driverweps'   }; $s++) {
			$hair .= "\t\t\tSetVehicleWeapon(vehicle, true,  $s, $cfgvar"."d$s);\n";
		}
		for(my $s = 0; $s < $_->{'passengerweps'}; $s++) {
			$hair .= "\t\t\tSetVehicleWeapon(vehicle, false, $s, $cfgvar"."p$s);\n";
		}
	}
	# Watch out for the string concatination in UnrealScript inside a Perl string! Yummy.
	$hair .= "\t\t} else { log(\"MutLPVehicleMods: Unknown vehicle '\" \$ vehicle.cfgname \$ \"'!\"); }\n";
	$mutator =~ s/__LIFE_IS_RIDICULOUS__/$hair/;
}

# Vehicle and weapon structure defaults. The UnrealScript parser is sensitive to whitespace in structure initialisers. I kid you not.
{
	my $index = 0;
	my $vehwep = '';

	foreach(@vehicles) {
		my $c = $_->{'pccom'};
		$vehwep .= "\tvehicles[".($index++).'] = (' .
			'dname="'       .$_->{'dname'        }.'",'.
			'clsname="'     .$_->{'clsname'      }.'",'.
			'cfgname="'     .$_->{'cfgname'      }.'",'.
			'big='         .($_->{'big'} ? 'true' : 'false').','.
			'driverweps='   .$_->{'driverweps'   }.','.
			'passengerweps='.$_->{'passengerweps'}.','.
			'pcmass='       .$_->{'pcmass'       }.','.
			'pccom=(X='.$c->{'X'}.',Y='.$c->{'Y'}.',Z='.$c->{'Z'}.'),'.
			'pcimpulse='    .$_->{'pcimpulse'    }.");\n";
	}
	$vehwep .= "\tvehiclecount = $index;\n\n";

	$index = 0;
	foreach(@weapons) {
		$vehwep .= "\tweapons[".($index++).'] = (' .
			'dname="'   .$_->{'dname'   }.'",'.
			'clsname="' .$_->{'clsname' }.'",'.
			'big='     .($_->{'big'     } ? 'true' : 'false').','.
			'charging='.($_->{'charging'} ? 'true' : 'false').");\n";
	}
	$vehwep .= "\tweaponcount = $index;\n";

	$mutator =~ s/__VEHICLES_AND_WEAPONS__/$vehwep/;
}

open TARGET, '>', 'MutLPVehicleMods.uc';
print TARGET $mutator;
close TARGET;

