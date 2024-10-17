@replaceMethod function ResistStatNameToEnum(n : name, out isPointResistance : bool) : ECharacterDefenseStats
{
    isPointResistance = true;
	switch(n)
	{
		case 'physical_resistance' 				: return CDS_PhysicalRes;
		case 'bleeding_resistance'	 			: return CDS_BleedingRes;
		case 'poison_resistance' 				: return CDS_PoisonRes;
		case 'fire_resistance' 					: return CDS_FireRes;
		case 'frost_resistance' 				: return CDS_FrostRes;
		case 'shock_resistance' 				: return CDS_ShockRes;
		case 'force_resistance' 				: return CDS_ForceRes;
		case 'will_resistance'	 				: return CDS_WillRes;
		case 'burning_resistance' 				: return CDS_BurningRes;
		case 'slashing_resistance' 				: return CDS_SlashingRes;
		case 'piercing_resistance'				: return CDS_PiercingRes;
		case 'bludgeoning_resistance'			: return CDS_BludgeoningRes;
		case 'rending_resistance'				: return CDS_RendingRes;
		case 'elemental_resistance'				: return CDS_ElementalRes;
		case 'burning_DoT_damage_resistance'	: return CDS_DoTBurningDamageRes;
		case 'poison_DoT_damage_resistance'		: return CDS_DoTPoisonDamageRes;
		case 'bleeding_DoT_damage_resistance'	: return CDS_DoTBleedingDamageRes;
		default :								;
	}
	
	isPointResistance = false;
	switch(n)
	{
		case 'physical_resistance_perc' 			: return CDS_PhysicalRes;
		case 'bleeding_resistance_perc' 			: return CDS_BleedingRes;
		case 'poison_resistance_perc' 				: return CDS_PoisonRes;
		case 'fire_resistance_perc' 				: return CDS_FireRes;
		case 'frost_resistance_perc' 				: return CDS_FrostRes;
		case 'shock_resistance_perc' 				: return CDS_ShockRes;
		case 'force_resistance_perc' 				: return CDS_ForceRes;
		case 'will_resistance_perc' 				: return CDS_WillRes;
		case 'burning_resistance_perc' 				: return CDS_BurningRes;
		case 'slashing_resistance_perc'				: return CDS_SlashingRes;
		case 'piercing_resistance_perc'				: return CDS_PiercingRes;
		case 'bludgeoning_resistance_perc'			: return CDS_BludgeoningRes;
		case 'rending_resistance_perc'				: return CDS_RendingRes;
		case 'elemental_resistance_perc'			: return CDS_ElementalRes;
		case 'burning_DoT_damage_resistance_perc'	: return CDS_DoTBurningDamageRes;
		case 'poison_DoT_damage_resistance_perc'	: return CDS_DoTPoisonDamageRes;
		case 'bleeding_DoT_damage_resistance_perc'	: return CDS_DoTBleedingDamageRes;
		default 									: return CDS_None;
	}
}

@replaceMethod function ResistStatEnumToName(s : ECharacterDefenseStats, isPointResistance : bool) : name
{
	if(isPointResistance)
	{
		switch(s)
		{
			case CDS_PhysicalRes :				return 'physical_resistance';
			case CDS_BleedingRes : 				return 'bleeding_resistance';
			case CDS_PoisonRes :				return 'poison_resistance';
			case CDS_FireRes :					return 'fire_resistance';
			case CDS_FrostRes :					return 'frost_resistance';
			case CDS_ShockRes :					return 'shock_resistance';
			case CDS_ForceRes :					return 'force_resistance';
			case CDS_WillRes :					return 'will_resistance';
			case CDS_BurningRes : 				return 'burning_resistance';
			case CDS_SlashingRes :	 			return 'slashing_resistance';
			case CDS_PiercingRes :				return 'piercing_resistance';
			case CDS_BludgeoningRes:			return 'bludgeoning_resistance';
			case CDS_RendingRes : 				return 'rending_resistance';
			case CDS_ElementalRes : 			return 'elemental_resistance';
			case CDS_DoTBurningDamageRes : 		return 'burning_DoT_damage_resistance';
			case CDS_DoTPoisonDamageRes :		return 'poison_DoT_damage_resistance';
			case CDS_DoTBleedingDamageRes : 	return 'bleeding_DoT_damage_resistance';
			default :							return '';
		}
	}
	else
	{
		switch(s)
		{
			case CDS_PhysicalRes :				return 'physical_resistance_perc';
			case CDS_BleedingRes : 				return 'bleeding_resistance_perc';
			case CDS_PoisonRes :				return 'poison_resistance_perc';
			case CDS_FireRes :					return 'fire_resistance_perc';
			case CDS_FrostRes :					return 'frost_resistance_perc';
			case CDS_ShockRes :					return 'shock_resistance_perc';
			case CDS_ForceRes :					return 'force_resistance_perc';
			case CDS_WillRes :					return 'will_resistance_perc';
			case CDS_BurningRes : 				return 'burning_resistance_perc';
			case CDS_SlashingRes :	 			return 'slashing_resistance_perc';
			case CDS_PiercingRes :				return 'piercing_resistance_perc';
			case CDS_BludgeoningRes:			return 'bludgeoning_resistance_perc';
			case CDS_RendingRes : 				return 'rending_resistance_perc';
			case CDS_ElementalRes :				return 'elemental_resistance_perc';
			case CDS_DoTBurningDamageRes : 		return 'burning_DoT_damage_resistance_perc';
			case CDS_DoTPoisonDamageRes :		return 'poison_DoT_damage_resistance_perc';
			case CDS_DoTBleedingDamageRes : 	return 'bleeding_DoT_damage_resistance_perc';
			default :							return '';
		}
	}
}

function SignPowerStatToPowerBonus( valueMult : float ) : float
{
	valueMult -= 1;
	if(valueMult <= 0) return 0;
	return	ClampF(valueMult * 2 - 0, 0, 1)*0.40 +
			ClampF(valueMult * 2 - 1, 0, 1)*0.35 +
			ClampF(valueMult * 2 - 2, 0, 1)*0.30 +
			ClampF(valueMult * 2 - 3, 0, 1)*0.25 +
			ClampF(valueMult * 2 - 4, 0, 1)*0.20 +
			ClampF(valueMult * 2 - 5, 0, 1)*0.15 +
			ClampF(valueMult * 2 - 6, 0, 1)*0.10 +
			ClampF(valueMult * 2 - 7, 0, 1)*0.10 +
			ClampF(valueMult * 2 - 8, 0, 1)*0.10 +
			ClampF(valueMult * 2 - 9, 0, 1)*0.05;
}