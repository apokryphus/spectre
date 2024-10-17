@wrapMethod( W3GameParams ) function InitArmorAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	ARMOR_COMMON_ABILITIES.PushBack('MA_SlashingResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_PiercingResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_BludgeoningResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_RendingResistance');
	ARMOR_COMMON_ABILITIES.PushBack('MA_ElementalResistance');
	
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
	ARMOR_MASTERWORK_ABILITIES.PushBack('MA_Vitality');
	
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	ARMOR_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function InitGlovesAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	GLOVES_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');		
	
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	GLOVES_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');	
}

@wrapMethod( W3GameParams ) function InitPantsAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
	PANTS_MASTERWORK_ABILITIES.PushBack('MA_Vitality');
	
	PANTS_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	PANTS_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function InitBootsAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BurningResistance');
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_PoisonResistance');
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_BleedingResistance');
	BOOTS_MASTERWORK_ABILITIES.PushBack('MA_AdrenalineGain');
	
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	BOOTS_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function InitWeaponAbilities()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	WEAPON_COMMON_ABILITIES.PushBack('MA_ArmorPenetration');
	WEAPON_COMMON_ABILITIES.PushBack('MA_ArmorPenetrationPerc');
	WEAPON_COMMON_ABILITIES.PushBack('MA_AttackPowerMult');
	WEAPON_COMMON_ABILITIES.PushBack('MA_CriticalChance');
	WEAPON_COMMON_ABILITIES.PushBack('MA_CriticalDamage');
	WEAPON_COMMON_ABILITIES.PushBack('MA_AdrenalineGain');
														
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BleedingChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_FreezingChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_PoisonChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_ConfusionChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_BurningChance');
	WEAPON_MASTERWORK_ABILITIES.PushBack('MA_StaggerChance');
													 
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_AardIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_IgniIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_QuenIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_YrdenIntensity');
	WEAPON_MAGICAL_ABILITIES.PushBack('MA_AxiiIntensity');
}

@wrapMethod( W3GameParams ) function GetDurabilityMultiplier(durabilityRatio : float, isWeapon : bool) : float
{
	var currDiff : EDifficultyMode;
	
	if(false) 
	{
		wrappedMethod(durabilityRatio, isWeapon);
	}
	
	currDiff = theGame.GetDifficultyMode();
	switch( currDiff )
	{
		case EDM_Easy:
			return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.8f, 1.0f);
		case EDM_Medium:
			return ClampF(1.0f - (1.0f - durabilityRatio)/4.0f, 0.7f, 1.0f);
		case EDM_Hard:
			return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.6f, 1.0f);
		case EDM_Hardcore:
			return ClampF(1.0f - (1.0f - durabilityRatio)/2.0f, 0.5f, 1.0f);
		default:
			return 1.0f;
	}
}

@addMethod(W3GameParams) function GetRandomCommonArmorAbility() : name
{
	return ARMOR_COMMON_ABILITIES[RandRange(ARMOR_COMMON_ABILITIES.Size())];
}

@addMethod(W3GameParams) function GetRandomCommonWeaponAbility() : name
{
	return WEAPON_COMMON_ABILITIES[RandRange(WEAPON_COMMON_ABILITIES.Size())];
}

@wrapMethod( W3GameParams ) function GetItemLevel(itemCategory : name, itemAttributes : array<SAbilityAttributeValue>, optional itemName : name, optional out baseItemLevel : int) : int
{
	var stat : SAbilityAttributeValue;
	var stat_f : float;
	var stat1,stat2,stat3,stat4,stat5,stat6,stat7 : SAbilityAttributeValue;
	var stat_min, stat_add : float;
	var level : int;
	
	if(false) 
	{
		wrappedMethod(itemCategory, itemAttributes);
	}
	
	if ( itemCategory == 'armor' )
	{
		stat_min = 25;
		stat_add = 5;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add );
	} else
	if ( itemCategory == 'boots' )
	{
		stat_min = 5;
		stat_add = 2;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add );
	} else
	if ( itemCategory == 'gloves' )
	{
		stat_min = 1;
		stat_add = 2;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); 
	} else
	if ( itemCategory == 'pants' )
	{
		stat_min = 5;
		stat_add = 2;
		stat = itemAttributes[0];
		level = CeilF( ( stat.valueBase - stat_min ) / stat_add ); 
	} else
	if ( itemCategory == 'silversword' )
	{
		stat_min = 90;
		stat_add = 10;
		stat1 = itemAttributes[0];
		stat2 = itemAttributes[1];
		stat3 = itemAttributes[2];
		stat4 = itemAttributes[3];
		stat5 = itemAttributes[4];
		stat6 = itemAttributes[5];
		stat_f = MaxF(0, stat1.valueBase - 1) + MaxF(0, stat2.valueBase - 1) + MaxF(0, stat3.valueBase - 1) + MaxF(0, stat4.valueBase - 1) + MaxF(0, stat5.valueBase - 1) + MaxF(0, stat6.valueBase - 1);
		level = CeilF( ( stat_f - stat_min ) / stat_add );  
	} else
	if ( itemCategory == 'steelsword' )
	{
		stat_min = 25;
		stat_add = 8;
		stat1 = itemAttributes[0];
		stat2 = itemAttributes[1];
		stat3 = itemAttributes[2];
		stat4 = itemAttributes[3];
		stat5 = itemAttributes[4];
		stat6 = itemAttributes[5];
		stat7 = itemAttributes[6];
		stat_f = MaxF(0, stat1.valueBase - 1) + MaxF(0, stat2.valueBase - 1) + MaxF(0, stat3.valueBase - 1) + MaxF(0, stat4.valueBase - 1) + MaxF(0, stat5.valueBase - 1) + MaxF(0, stat6.valueBase - 1) + MaxF(0, stat7.valueBase - 1);
		level = CeilF( ( stat_f - stat_min ) / stat_add );  
	} else
	if ( itemCategory == 'bolt' )
	{
		if ( itemName == 'Tracking Bolt' ) { level = 2; } else
		if ( itemName == 'Bait Bolt' ) { level = 2; }  else
		if ( itemName == 'Blunt Bolt' ) { level = 2; }  else
		if ( itemName == 'Broadhead Bolt' ) { level = 10; }  else
		if ( itemName == 'Target Point Bolt' ) { level = 5; }  else
		if ( itemName == 'Split Bolt' ) { level = 15; }  else
		if ( itemName == 'Explosive Bolt' ) { level = 20; }  else
		if ( itemName == 'Broadhead Bolt Legendary' ) { level = 20; }  else
		if ( itemName == 'Target Point Bolt Legendary' ) { level = 15; }  else
		if ( itemName == 'Blunt Bolt Legendary' ) { level = 12; }  else
		if ( itemName == 'Split Bolt Legendary' ) { level = 24; }  else
		if ( itemName == 'Explosive Bolt Legendary' ) { level = 26; } 
	} else
	if ( itemCategory == 'crossbow' )
	{
		stat = itemAttributes[0];
		level = 1;
		if ( stat.valueMultiplicative > 1.01 ) level = 2;
		if ( stat.valueMultiplicative > 1.1 ) level = 4;
		if ( stat.valueMultiplicative > 1.2 ) level = 8;
		if ( stat.valueMultiplicative > 1.3 ) level = 11;
		if ( stat.valueMultiplicative > 1.4 ) level = 15;
		if ( stat.valueMultiplicative > 1.5 ) level = 19;
		if ( stat.valueMultiplicative > 1.6 ) level = 22;
		if ( stat.valueMultiplicative > 1.7 ) level = 25;
		if ( stat.valueMultiplicative > 1.8 ) level = 27;
		if ( stat.valueMultiplicative > 1.9 ) level = 32;
		
		if ( stat.valueMultiplicative > 2.0 ) level = 34;
		if ( stat.valueMultiplicative > 2.1 ) level = 38;
	} 
	level = Clamp(level, 1, GetWitcherPlayer().GetMaxLevel());
	
	return level;
}

@addMethod(W3GameParams) function GetEnemyHealthMult() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreHealthMultiplier'));
}

@addMethod(W3GameParams) function GetEnemyDamageMult() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreDamageMultiplier'));
}

@addMethod(W3GameParams) function GetBossHealthMult() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreBossHealthMultiplier'));
}

@addMethod(W3GameParams) function GetBossDamageMult() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreBossDamageMultiplier'));
}

@addMethod(W3GameParams) function GetEnemyScalingOption() : int
{
	return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'Virtual_spectreScaling'));
}

@addMethod(W3GameParams) function GetNoAnimalUpscaling() : bool
{
	return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreNoAnimalUpscaling'));
}

@addMethod(W3GameParams) function GetNoAdditionalLevelsForGuards() : bool
{
	return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreNoAddLevelsGuards'));
}

@addMethod(W3GameParams) function GetRandomScalingMinLevel() : int
{
	return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreRandomScalingMinLevel'));
}

@addMethod(W3GameParams) function GetRandomScalingMaxLevel() : int
{
	return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreRandomScalingMaxLevel'));
}

@addMethod(W3GameParams) function GetNonlinearLevelup() : bool
{
	return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreNonlinearLevelup'));
}

@addMethod(W3GameParams) function GetNonlinearLevelDelta() : int
{
	return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreNonlinearLevelDelta'));
}

@addMethod(W3GameParams) function GetNonlinearAbilitiesDelta() : int
{
	return StringToInt(theGame.GetInGameConfigWrapper().GetVarValue('spectreScalingOptions', 'spectreNonlinearAbilitiesDelta'));
}

@addMethod(W3GameParams) function GetFixedExp() : bool
{
	return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreExpOptions', 'spectreUseXMLExp'));
}

@addMethod(W3GameParams) function GetQuestExpModifier() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreExpOptions', 'spectreQuestExpModifier'));
}

@addMethod(W3GameParams) function GetMonsterExpModifier() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreExpOptions', 'spectreMonsterExpModifier'));
}

@addMethod(W3GameParams) function GetNoQuestLevels() : bool
{
	return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreExpOptions', 'spectreNoQuestLevels'));
}

@addMethod(W3GameParams) function GetspectreVersion() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreVersion'));
}

@addMethod(W3GameParams) function GetBoatSinkOption() : bool
{
	return (bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreSinkBoat'));
}

@addMethod(W3GameParams) function GetBoatSinkOverEncumbranceOption() : float
{
	return StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreSinkBoatOverEnc'));
}

@addMethod(W3GameParams) function GetEncumbranceMult() : float
{
	return ClampF(StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreEncumbranceMultiplier'))/100, 0, 1);
}

@addField(W3GameParams)
var isArmorRegenPenaltyEnabled : int;

@addMethod(W3GameParams) function IsArmorRegenPenaltyEnabled() : bool
{
	if(isArmorRegenPenaltyEnabled == 0)
	{
		if((bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreArmorRegenPenalty')))
			isArmorRegenPenaltyEnabled = 2;
		else
			isArmorRegenPenaltyEnabled = 1;
	}
	return (isArmorRegenPenaltyEnabled > 1);
}

@addField(W3GameParams)
var combatStaminaRegen : float;

@addMethod(W3GameParams) function GetCombatStaminaRegen() : float
{
	combatStaminaRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreCombatStaminaRegen'));
	return combatStaminaRegen;
}

@addField(W3GameParams)
var outOfCombatStaminaRegen : float;

@addMethod(W3GameParams) function GetOutOfCombatStaminaRegen() : float
{
	outOfCombatStaminaRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreOutOfCombatStaminaRegen'));
	return outOfCombatStaminaRegen;
}

@addField(W3GameParams)
var combatVitalityRegen : float;

@addMethod(W3GameParams) function GetCombatVitalityRegen() : float
{
	combatVitalityRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreCombatVitalityRegen'));
	return combatVitalityRegen;
}

@addField(W3GameParams) 
var outOfCombatVitalityRegen : float;

@addMethod(W3GameParams) function GetOutOfCombatVitalityRegen() : float
{
	outOfCombatVitalityRegen = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreOutOfCombatVitalityRegen'));
	return outOfCombatVitalityRegen;
}

@addField(W3GameParams)  
var agilityStaminaCostMult : float;

@addMethod(W3GameParams) function GetAgilityStaminaCostMult() : float
{
	agilityStaminaCostMult = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreAgilityStaminaCostMultiplier'));
	return agilityStaminaCostMult;
}

@addField(W3GameParams)  
var meleeStaminaCostMult : float;

@addMethod(W3GameParams) function GetMeleeStaminaCostMult() : float
{
	meleeStaminaCostMult = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreMeleeStaminaCostMultiplier'));
	return meleeStaminaCostMult;
}

@addField(W3GameParams)  
var signStaminaCostMult : float;

@addMethod(W3GameParams) function GetSignStaminaCostMult() : float
{
	signStaminaCostMult = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreSignStaminaCostMultiplier'));
	return signStaminaCostMult;
}

@addField(W3GameParams)  
var staminaDelay : float;

@addMethod(W3GameParams) function GetStaminaDelay() : float
{
	staminaDelay = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreStaminaDelay'));
	return staminaDelay;
}

@addField(W3GameParams)  
var signCooldown : float;

@addMethod(W3GameParams) function GetSignCooldownDuration() : float
{
	signCooldown = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreSignCooldown'));
	return signCooldown;
}

@addField(W3GameParams)  
var altSignCooldown : float;

@addMethod(W3GameParams) function GetAltSignCooldownDuration() : float
{
	altSignCooldown = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreAltSignCooldown'));
	return altSignCooldown;
}

@addField(W3GameParams)  
var meleeSpecialCooldown : float;

@addMethod(W3GameParams) function GetMeleeSpecialCooldownDuration() : float
{
	meleeSpecialCooldown = StringToFloat(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreMeleeSpecialCooldown'));
	return meleeSpecialCooldown;
}

@addMethod(W3GameParams) function spectreResetCachedValuesGameplay()
{
	isArmorRegenPenaltyEnabled = 0;
	combatStaminaRegen = -1000;
	outOfCombatStaminaRegen = -1000;
	combatVitalityRegen = -1000;
	outOfCombatVitalityRegen = -1000;
	agilityStaminaCostMult = -1000;
	meleeStaminaCostMult = -1000;
	signStaminaCostMult = -1000;
	staminaDelay = -1000;
	signCooldown = -1000;
	altSignCooldown = -1000;
	meleeSpecialCooldown = -1000;
	instantCastingToggle = 0;
}

@addField(W3GameParams)  
var instantCastingToggle : int;

@addMethod(W3GameParams) function GetInstantCasting() : bool
{
	if(instantCastingToggle == 0)
	{
		if((bool)(theGame.GetInGameConfigWrapper().GetVarValue('spectreGameplayOptions', 'spectreSignInstantCast')))
			instantCastingToggle = 2;
		else
			instantCastingToggle = 1;
	}
	return (instantCastingToggle > 1);
}