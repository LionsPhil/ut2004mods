#!/usr/bin/perl
use warnings;
use strict;

my @vehicles = ({
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
	dname		=> 'S.P.M.A.',
	clsname		=> 'OnslaughtBP.ONSArtillery',
	cfgname		=> 'spma',
	big		=> 1,
	driverweps	=> 1,
	passengerweps	=> 1,
	pcmass		=> 0.8,
	pccom		=> {X=>0.0, Y=>0.0, Z=>-0.6},
	pcimpulse	=> 4096,
});

my @weapons = ({
	dname	=> '(Default)',
	clsname	=> '_default_',
	big	=> 0, # irrelevant
	}, {
	dname	=> 'Goliath cannon',
	clsname	=> 'Onslaught.ONSHoverTankCannon',
	big	=> 1,
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
			'dname="'  .$_->{'dname'  }.'",'.
			'clsname="'.$_->{'clsname'}.'",'.
			'big='    .($_->{'big'} ? 'true' : 'false').");\n";
	}
	$vehwep .= "\tweaponcount = $index;\n";

	$mutator =~ s/__VEHICLES_AND_WEAPONS__/$vehwep/;
}

open TARGET, '>', 'MutLPVehicleMods.uc';
print TARGET $mutator;
close TARGET;

