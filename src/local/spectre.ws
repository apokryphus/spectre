function spectreGetVersion() : float
{
	return 0.36;
}

function spectreSettingsGetConfigValue(menuName, menuItemName : name) : string
{
	var conf: CInGameConfigWrapper;
	var value: string;
	
	conf = theGame.GetInGameConfigWrapper();
	
	value = conf.GetVarValue(menuName, menuItemName);

	return value;
}

function spectreVersionControl(): float
{
	var configValue :float;
	var configValueString : string;

	configValueString = spectreSettingsGetConfigValue('spectreMainOptions', 'spectreVersionControl');
	
	configValue =(float) configValueString;

	if(configValueString=="" || configValue<0)
	{
		return spectreGetVersion();
	}
	
	else return configValue;
}

function spectreInitAttempt()
{
	if (!spectreIsInitialized()) 
	{
		spectreInitializeSettings(); 
    }
	else
	{
		theGame.GetInGameConfigWrapper().SetVarValue('spectreMainOptions', 'spectreVersionControl', spectreGetVersion());
	}
}

function spectreIsInitialized(): bool 
{
	var configValue :int;
	var configValueString : string;
	
	configValueString = spectreSettingsGetConfigValue('spectreMainOptions', 'spectreInit');

	configValue =(int) configValueString;

	if(configValueString=="" || configValue<0)
	{
		return false;
	}

	else return (bool)configValueString;
}

function spectreInitializeSettings() 
{
	theGame.GetInGameConfigWrapper().SetVarValue('spectreMainOptions', 'spectreInit', "true");

	theGame.GetInGameConfigWrapper().SetVarValue('spectreMainOptions', 'spectreVersionControl', spectreGetVersion());

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreScalingOptions', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreExpOptions', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreGameplayOptions', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreLootingOptions', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreAlchemyBrewing', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreAlchemyPotionsAndOils', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreAlchemyToxicitySettings', 0);

	theGame.GetInGameConfigWrapper().ApplyGroupPreset('spectreAlchemyMiscellaneousSettings', 0);

	theGame.SaveUserSettings();
}

function spectreModRegenValue(attributeName : name, out effectValue : SAbilityAttributeValue)
{
	if(attributeName == 'staminaOutOfCombatRegen')
		effectValue.valueAdditive += theGame.params.GetOutOfCombatStaminaRegen();
	else if(attributeName == 'staminaRegenGuarded' || attributeName == 'staminaRegen')
		effectValue.valueAdditive += theGame.params.GetCombatStaminaRegen();
	else if(attributeName == 'vitalityRegen')
		effectValue.valueAdditive += theGame.params.GetOutOfCombatVitalityRegen();
	else if(attributeName == 'vitalityCombatRegen')
		effectValue.valueAdditive += theGame.params.GetCombatVitalityRegen();
}

function spectreModAgilityStaminaCost(out cost : float)
{
	cost *= 1 + theGame.params.GetAgilityStaminaCostMult();
	cost = ClampF(cost, 0, 100);
}

function spectreModMeleeStaminaCost(out cost : float)
{
	cost *= 1 + theGame.params.GetMeleeStaminaCostMult();
	cost = ClampF(cost, 0, 100);
}

function spectreModSignStaminaCost(out cost : float)
{
	cost *= 1 + theGame.params.GetSignStaminaCostMult();
	cost = ClampF(cost, 0, 100);
}

function spectreModStaminaDelay(out delay : float)
{
	delay += theGame.params.GetStaminaDelay();
	delay = MaxF(delay, 0);
}

function spectreUpdateRegenEffects()
{
	var buffs : array<CBaseGameplayEffect>;
	var i : int;
	
	buffs = thePlayer.GetBuffs(EET_AutoVitalityRegen);
	
	for(i = 0; i < buffs.Size(); i += 1)
	{
		((W3Effect_AutoVitalityRegen)buffs[i]).UpdateEffectValue();
	}
	
	if(buffs.Size() < 1)
		thePlayer.StartVitalityRegen();
	
	buffs = thePlayer.GetBuffs(EET_AutoStaminaRegen);
	
	for(i = 0; i < buffs.Size(); i += 1)
	{
		((W3Effect_AutoStaminaRegen)buffs[i]).UpdateEffectValue();
	}
	
	if(buffs.Size() < 1)
		thePlayer.StartStaminaRegen();
}

function spectreIsGameplayOption(optionName : name) : bool
{
	return (optionName == 'spectreSinkBoat' || optionName == 'spectreSinkBoatOverEnc' || optionName == 'spectreEncumbranceMultiplier'
			|| optionName == 'spectreSignStaminaCostMultiplier' || optionName == 'spectreMeleeStaminaCostMultiplier' || optionName == 'spectreAgilityStaminaCostMultiplier'
			|| optionName == 'spectreOutOfCombatVitalityRegen' || optionName == 'spectreCombatVitalityRegen'
			|| optionName == 'spectreOutOfCombatStaminaRegen' || optionName == 'spectreCombatStaminaRegen'
			|| optionName == 'spectreStaminaDelay' || optionName == 'spectreMeleeSpecialCooldown'
			|| optionName == 'spectreSignCooldown' || optionName == 'spectreAltSignCooldown'
			|| optionName == 'spectreArmorRegenPenalty'
			|| optionName == 'spectreSignInstantCast'
			);
}

function spectreIsScalingOption(optionName : name) : bool
{
	return (optionName == 'Virtual_spectreScaling' || optionName == 'spectreRandomScalinspectreinLevel'
			|| optionName == 'spectreRandomScalinspectreaxLevel' || optionName == 'spectreNoAnimalUpscaling'
			|| optionName == 'spectreNoAddLevelsGuards' || optionName == 'spectreHealthMultiplier'
			|| optionName == 'spectreDamageMultiplier');
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function spectreTestCastSignHold() : bool
{
	if( theInput.IsActionPressed( 'CastSign' ) )
		return true;

	if( theInput.GetActionValue( 'CastSignHold' ) > 0.f )
		return true;
	if( theGame.params.GetInstantCasting() )
	{
		if( theInput.IsActionPressed( 'SelectAard' ) ||
			theInput.IsActionPressed( 'SelectIgni' ) ||
			theInput.IsActionPressed( 'SelectYrden' ) ||
			theInput.IsActionPressed( 'SelectQuen' ) ||
			theInput.IsActionPressed( 'SelectAxii' ) )
		{
			return ( theGame.GetEngineTimeAsSeconds() - thePlayer.castSignHoldTimestamp ) > 0.2;
		}
	}
	return false;
}

function spectreForceDeactivateCastSignHold()
{
	theInput.ForceDeactivateAction( 'CastSignHold' );
	theInput.ForceDeactivateAction( 'SelectAard' );
	theInput.ForceDeactivateAction( 'SelectIgni' );
	theInput.ForceDeactivateAction( 'SelectYrden' );
	theInput.ForceDeactivateAction( 'SelectQuen' );
	theInput.ForceDeactivateAction( 'SelectAxii' );
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

enum EEnemyType
{
	EENT_GENERIC,
	EENT_ANIMAL,
	EENT_BOSS,
	//BASE:
	EENT_HUMAN,
	EENT_DOG,
	EENT_WOLF,
	EENT_BEAR,
	EENT_BEAR_BERSERKER,
	EENT_WILD_HUNT_WARRIOR,
	EENT_WILD_HUNT_MINION,
	EENT_NEKKER,
	EENT_DROWNER,
	EENT_ROTFIEND,
	EENT_GHOUL,
	EENT_ALGHOUL,
	EENT_GRYPHON,
	EENT_BASILISK,
	EENT_COCKATRICE,
	EENT_WYVERN,
	EENT_FORKTAIL,
	EENT_WATERHAG,
	EENT_GRAVEHAG,
	EENT_FOGLING,
	EENT_WRAITH,
	EENT_NIGHTWRAITH,
	EENT_NOONWRAITH,
	EENT_ENDRIAGA_WORKER,
	EENT_ENDRIAGA_SOLDIER,
	EENT_ENDRIAGA_TRUTEN,
	EENT_FUGAS,
	EENT_GARGOYLE,
	EENT_ARACHAS,
	EENT_ARACHAS_ARMORED,
	EENT_ARACHAS_POISON,
	EENT_WEREWOLF,
	EENT_KATAKAN,
	EENT_EKIMMA,
	EENT_TROLL,
	EENT_TROLL_ICE,
	EENT_GOLEM,
	EENT_ELEMENTAL,
	EENT_ELEMENTAL_FIRE,
	EENT_ELEMENTAL_ICE,
	EENT_BIES,
	EENT_CZART,
	EENT_CYCLOPS,
	EENT_SIREN,
	EENT_HARPY,
	EENT_ERYNIA,
	EENT_LESSOG,
	//EP1:
	EENT_BOAR,
	EENT_BLACK_SPIDER,
	//EP2:
	EENT_PANTHER,
	EENT_SHARLEY,
	EENT_DRACOLIZARD,
	EENT_KIKIMORA_WORKER,
	EENT_KIKIMORA_WARRIOR,
	EENT_SCOLOPENDROMORPH,
	EENT_ARCHESPOR,
	EENT_SPRIGAN,
	EENT_WIGHT,
	EENT_BARGHEST,
	EENT_NIGHTWRAITH_BANSHEE,
	EENT_BRUXA,
	EENT_ALP,
	EENT_GRAVIER,
	EENT_FLEDER,
	EENT_PROTOFLEDER,
	EENT_GARKAIN,
	EENT_MAX_TYPES
};

function spectreGetEnemyTypeByAbility( actor : CActor ) : EEnemyType
{
	//BOSSES:
	
	if(actor.HasAbility('mon_knight_giant')) return EENT_BOSS;
	if(actor.HasAbility('mon_cloud_giant')) return EENT_BOSS;
	if(actor.HasAbility('mon_fairytale_witch')) return EENT_BOSS;
	if(actor.HasAbility('mon_broom_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_vampire_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_monster_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_dettlaff_construct_base')) return EENT_BOSS;
	if(actor.HasAbility('mon_toad_base')) return EENT_BOSS;
	if(actor.HasAbility('q604_caretaker')) return EENT_BOSS;
	if(actor.HasAbility('olgierd_default_stats')) return EENT_BOSS;
	if(actor.HasAbility('ethereal_default_stats')) return EENT_BOSS;
	if(actor.HasAbility('mon_ice_giant')) return EENT_BOSS;
	if(actor.HasAbility('mon_greater_miscreant')) return EENT_BOSS;
	if(actor.HasAbility('mon_him')) return EENT_BOSS;
	if(actor.HasAbility('mon_witch1')) return EENT_BOSS;
	if(actor.HasAbility('mon_witch2')) return EENT_BOSS;
	if(actor.HasAbility('mon_witch3')) return EENT_BOSS;
	if(actor.HasAbility('mon_djinn')) return EENT_BOSS;
	if(actor.HasAbility('mon_heart_miniboss')) return EENT_BOSS;
	if(actor.HasAbility('WildHunt_Eredin')) return EENT_BOSS;
	if(actor.HasAbility('WildHunt_Imlerith')) return EENT_BOSS;
	if(actor.HasAbility('WildHunt_Caranthir')) return EENT_BOSS;

	//EP2:
	
	if(actor.HasAbility('mon_sharley_young')) return EENT_SHARLEY;
	if(actor.HasAbility('mon_sharley')) return EENT_SHARLEY;
	if(actor.HasAbility('mon_sharley_base')) return EENT_SHARLEY;

	if(actor.HasAbility('mon_bruxa')) return EENT_BRUXA;
	if(actor.HasAbility('mon_alp')) return EENT_BRUXA;
	if(actor.HasAbility('mon_vampiress_base')) return EENT_BRUXA;

	if(actor.HasAbility('mon_draco_base')) return EENT_DRACOLIZARD;

	if(actor.HasAbility('mon_barghest')) return EENT_BARGHEST;
	if(actor.HasAbility('mon_barghest_wight_minion')) return EENT_BARGHEST;
	if(actor.HasAbility('mon_barghest_base')) return EENT_BARGHEST;

	if(actor.HasAbility('mon_black_spider_ep2_large')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider_ep2')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider_ep2_base')) return EENT_BLACK_SPIDER;

	if(actor.HasAbility('mon_kikimora_warrior')) return EENT_KIKIMORA_WARRIOR;
	if(actor.HasAbility('mon_kikimora_worker')) return EENT_KIKIMORA_WORKER;
	if(actor.HasAbility('mon_kikimore_base')) return EENT_KIKIMORA_WORKER;

	if(actor.HasAbility('mon_scolopendromorph_base')) return EENT_SCOLOPENDROMORPH;

	if(actor.HasAbility('mon_archespor_hard')) return EENT_ARCHESPOR;
	if(actor.HasAbility('mon_archespor')) return EENT_ARCHESPOR;
	//if(actor.HasAbility('mon_archespor_turret')) return EENT_ARCHESPOR;
	//if(actor.HasAbility('mon_archespor_petals')) return EENT_ARCHESPOR;
	if(actor.HasAbility('mon_archespor_base')) return EENT_ARCHESPOR;

	if(actor.HasAbility('mon_sprigan')) return EENT_SPRIGAN;
	if(actor.HasAbility('mon_sprigan_base')) return EENT_SPRIGAN;

	if(actor.HasAbility('mon_spooncollector')) return EENT_WIGHT;
	if(actor.HasAbility('mon_wight')) return EENT_WIGHT;

	if(actor.HasAbility('mon_gravier')) return EENT_GRAVIER;

	if(actor.HasAbility('mon_nightwraith_banshee')) return EENT_NIGHTWRAITH_BANSHEE;
	//if(actor.HasAbility('banshee_summons')) return EENT_NIGHTWRAITH;

	if(actor.HasAbility('mon_fleder')) return EENT_FLEDER;
	if(actor.HasAbility('q704_mon_protofleder')) return EENT_PROTOFLEDER;
	if(actor.HasAbility('mon_garkain')) return EENT_GARKAIN;

	if(actor.HasAbility('mon_panther')) return EENT_PANTHER;
	if(actor.HasAbility('mon_panther_ghost')) return EENT_PANTHER;
	if(actor.HasAbility('mon_panther_base')) return EENT_PANTHER;

	if(actor.HasAbility('mon_boar_ep2_base')) return EENT_BOAR;

	//EP1:

	if(actor.HasAbility('mon_nightwraith_iris')) return EENT_NIGHTWRAITH;
	
	if(actor.HasAbility('HaklandMage')) return EENT_HUMAN;
	if(actor.HasAbility('HaklandMagePhase1')) return EENT_HUMAN;

	if(actor.HasAbility('mon_boar_base')) return EENT_BOAR;

	if(actor.HasAbility('mon_black_spider_large')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider')) return EENT_BLACK_SPIDER;
	if(actor.HasAbility('mon_black_spider_base')) return EENT_BLACK_SPIDER;

	//Base game:
	
	if(actor.HasAbility('mon_endriaga_soldier_tailed')) return EENT_ENDRIAGA_SOLDIER;
	if(actor.HasAbility('mon_endriaga_soldier_spikey')) return EENT_ENDRIAGA_TRUTEN;
	if(actor.HasAbility('mon_endriaga_worker')) return EENT_ENDRIAGA_WORKER;
	if(actor.HasAbility('mon_endriaga_base')) return EENT_ENDRIAGA_WORKER;

	if(actor.HasAbility('mon_fugas')) return EENT_FUGAS;
	if(actor.HasAbility('mon_fugas_lesser')) return EENT_FUGAS;
	if(actor.HasAbility('mon_gargoyle')) return EENT_GARGOYLE;
	if(actor.HasAbility('mon_fugas_base')) return EENT_FUGAS;

	if(actor.HasAbility('mon_poison_arachas')) return EENT_ARACHAS_POISON;
	if(actor.HasAbility('mon_arachas_armored')) return EENT_ARACHAS_ARMORED;
	if(actor.HasAbility('mon_arachas')) return EENT_ARACHAS;
	if(actor.HasAbility('mon_arachas_base')) return EENT_ARACHAS;

	if(actor.HasAbility('mon_bear_berserker')) return EENT_BEAR_BERSERKER;
	if(actor.HasAbility('mon_bear_black')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_grizzly')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_white')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_fistfight')) return EENT_BEAR;
	if(actor.HasAbility('mon_bear_base')) return EENT_BEAR;

	if(actor.HasAbility('mon_werewolf_lesser')) return EENT_WEREWOLF;
	if(actor.HasAbility('mon_werewolf')) return EENT_WEREWOLF;
	if(actor.HasAbility('mon_lycanthrope')) return EENT_WEREWOLF;
	if(actor.HasAbility('mon_katakan')) return EENT_KATAKAN;
	if(actor.HasAbility('mon_katakan_large')) return EENT_KATAKAN;
	if(actor.HasAbility('mon_ekimma')) return EENT_EKIMMA;
	if(actor.HasAbility('mon_werewolf_base')) return EENT_WEREWOLF;

	if(actor.HasAbility('mon_ice_troll')) return EENT_TROLL_ICE;
	if(actor.HasAbility('mon_black_troll')) return EENT_TROLL;
	if(actor.HasAbility('mon_cave_troll_young')) return EENT_TROLL;
	if(actor.HasAbility('mon_cave_troll')) return EENT_TROLL;
	if(actor.HasAbility('mon_troll_fistfight')) return EENT_TROLL;
	if(actor.HasAbility('mon_troll_base')) return EENT_TROLL;

	if(actor.HasAbility('mon_golem_lvl1')) return EENT_GOLEM;
	if(actor.HasAbility('mon_golem')) return EENT_GOLEM;
	if(actor.HasAbility('mon_elemental_dao_lesser')) return EENT_ELEMENTAL;
	if(actor.HasAbility('mon_elemental_dao')) return EENT_ELEMENTAL;
	if(actor.HasAbility('mon_ice_golem')) return EENT_ELEMENTAL_ICE;
	if(actor.HasAbility('mon_elemental_fire')) return EENT_ELEMENTAL_FIRE;
	if(actor.HasAbility('mon_elemental_fire_q211')) return EENT_ELEMENTAL_FIRE;
	if(actor.HasAbility('mon_golem_base')) return EENT_GOLEM;

	if(actor.HasAbility('mon_bies')) return EENT_BIES;
	if(actor.HasAbility('mon_bies_lesser')) return EENT_BIES;
	if(actor.HasAbility('mon_czart')) return EENT_CZART;
	if(actor.HasAbility('mon_bies_base')) return EENT_BIES;

	if(actor.HasAbility('mon_cyclops')) return EENT_CYCLOPS;
	
	if(actor.HasAbility('mon_lamia')) return EENT_SIREN;
	if(actor.HasAbility('mon_lamia_stronger')) return EENT_SIREN;
	if(actor.HasAbility('mon_siren')) return EENT_SIREN;
	if(actor.HasAbility('mon_siren_base')) return EENT_SIREN;

	if(actor.HasAbility('mon_erynia')) return EENT_ERYNIA;
	if(actor.HasAbility('mon_harpy')) return EENT_HARPY;
	if(actor.HasAbility('mon_harpy_base')) return EENT_HARPY;

	if(actor.HasAbility('mon_wraith')) return EENT_WRAITH;
	if(actor.HasAbility('mon_wraith_mh')) return EENT_WRAITH;
	if(actor.HasAbility('mon_wraith_base')) return EENT_WRAITH;

	if(actor.HasAbility('mon_nightwraith')) return EENT_NIGHTWRAITH;
	if(actor.HasAbility('mon_nightwraith_mh')) return EENT_NIGHTWRAITH;
	if(actor.HasAbility('mon_pesta')) return EENT_NOONWRAITH;
	if(actor.HasAbility('mon_noonwraith_mh')) return EENT_NOONWRAITH;
	if(actor.HasAbility('mon_noonwraith')) return EENT_NOONWRAITH;
	//if(actor.HasAbility('mon_noonwraith_doppelganger')) return EENT_NOONWRAITH;
	if(actor.HasAbility('mon_noonwraith_base')) return EENT_NOONWRAITH;

	if(actor.HasAbility('mon_nekker_warrior')) return EENT_NEKKER;
	if(actor.HasAbility('mon_nekker')) return EENT_NEKKER;
	if(actor.HasAbility('mon_nekker_base')) return EENT_NEKKER;

	if(actor.HasAbility('mon_rotfiend_large')) return EENT_ROTFIEND;
	if(actor.HasAbility('mon_rotfiend')) return EENT_ROTFIEND;
	if(actor.HasAbility('mon_drowneddead')) return EENT_DROWNER;
	if(actor.HasAbility('mon_drowner_underwater')) return EENT_DROWNER;
	if(actor.HasAbility('mon_drowner')) return EENT_DROWNER;
	if(actor.HasAbility('mon_drowner_base')) return EENT_DROWNER;

	if(actor.HasAbility('mon_wild_hunt_minionMH')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_wild_hunt_minion')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_wild_hunt_minion_lesser')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_wild_hunt_minion_weak')) return EENT_WILD_HUNT_MINION;
	if(actor.HasAbility('mon_alghoul')) return EENT_ALGHOUL;
	if(actor.HasAbility('mon_ghoul_stronger')) return EENT_GHOUL;
	if(actor.HasAbility('mon_ghoul')) return EENT_GHOUL;
	if(actor.HasAbility('mon_ghoul_lesser')) return EENT_GHOUL;
	if(actor.HasAbility('mon_ghoul_base')) return EENT_GHOUL;

	if(actor.HasAbility('mon_gryphon_volcanic')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_gryphon_stronger')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_gryphon')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_gryphon_lesser')) return EENT_GRYPHON;
	if(actor.HasAbility('mon_basilisk')) return EENT_BASILISK;
	if(actor.HasAbility('mon_cockatrice')) return EENT_COCKATRICE;
	if(actor.HasAbility('mon_gryphon_base')) return EENT_GRYPHON;

	if(actor.HasAbility('mon_lessog_ancient')) return EENT_LESSOG;
	if(actor.HasAbility('mon_lessog')) return EENT_LESSOG;
	if(actor.HasAbility('mon_lessog_base')) return EENT_LESSOG;

	if(actor.HasAbility('mon_forktail_mh')) return EENT_FORKTAIL;
	if(actor.HasAbility('mon_forktail')) return EENT_FORKTAIL;
	if(actor.HasAbility('mon_forktail_young')) return EENT_FORKTAIL;
	if(actor.HasAbility('mon_wyvern')) return EENT_WYVERN;
	if(actor.HasAbility('mon_wyvern_base')) return EENT_WYVERN;

	//if(actor.HasAbility('mon_baronswife')) return EENT_GRAVEHAG;
	if(actor.HasAbility('mon_gravehag')) return EENT_GRAVEHAG;
	if(actor.HasAbility('mon_fogling_mh')) return EENT_FOGLING;
	if(actor.HasAbility('mon_fogling_stronger')) return EENT_FOGLING;
	if(actor.HasAbility('mon_fogling')) return EENT_FOGLING;
	if(actor.HasAbility('mon_fogling_lesser')) return EENT_FOGLING;
	//if(actor.HasAbility('mon_fogling_doppelganger')) return EENT_FOGLING;
	if(actor.HasAbility('mon_waterhag_greater')) return EENT_WATERHAG;
	if(actor.HasAbility('mon_waterhag')) return EENT_WATERHAG;
	if(actor.HasAbility('mon_gravehag_base')) return EENT_GRAVEHAG;

	if(actor.HasAbility('mon_wild_hunt_default')) return EENT_WILD_HUNT_WARRIOR;

	if(actor.HasAbility('ConDefault')) return EENT_HUMAN;
	if(actor.HasAbility('ConAverage')) return EENT_HUMAN;
	if(actor.HasAbility('ConAthletic')) return EENT_HUMAN;
	if(actor.HasAbility('ConFrail')) return EENT_HUMAN;
	if(actor.HasAbility('ConFat')) return EENT_HUMAN;
	if(actor.HasAbility('ConPudzian')) return EENT_HUMAN;
	if(actor.HasAbility('ConWitcher')) return EENT_HUMAN;
	if(actor.HasAbility('ConImmortal')) return EENT_HUMAN;

	if(actor.HasAbility('mon_evil_dog_lvl12')) return EENT_DOG;
	if(actor.HasAbility('wild_dog_lvl9')) return EENT_DOG;
	if(actor.HasAbility('mon_evil_dog')) return EENT_DOG;
	if(actor.HasAbility('mon_wolf')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_summon')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_summon_were')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_alpha')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_alpha_weak')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_white')) return EENT_WOLF;
	if(actor.HasAbility('mon_wolf_base')) return EENT_WOLF;

	if(actor.HasAbility('animal_rat_base')) return EENT_ANIMAL;
	if(actor.HasAbility('animal_default_animal')) return EENT_ANIMAL;

	return EENT_GENERIC;
}

function spectreGetExpByEnemyType( et : EEnemyType ) : int
{
	var NO_EXP : int = 0;
	var MIN_EXP : int = 1;		//2 types
	var SMALL_EXP : int = 5;	//20 types
	var MEDIUM_EXP : int = 10;	//18 types
	var BIG_EXP : int = 15;		//9 types
	var BOSS_EXP : int = 20;

	switch(et)
	{
		case EENT_BOSS:
			return BOSS_EXP;
		//BASE:
		case EENT_HUMAN:
			return SMALL_EXP;
		case EENT_DOG:
			return MIN_EXP;
		case EENT_WOLF:
			return MIN_EXP;
		case EENT_BEAR:
			return SMALL_EXP;
		case EENT_BEAR_BERSERKER:
			return MEDIUM_EXP;
		case EENT_ENDRIAGA_WORKER:
			return SMALL_EXP;
		case EENT_ENDRIAGA_SOLDIER:
			return MEDIUM_EXP;
		case EENT_ENDRIAGA_TRUTEN:
			return MEDIUM_EXP;
		case EENT_FUGAS:
			return MEDIUM_EXP;
		case EENT_GARGOYLE:
			return MEDIUM_EXP;
		case EENT_ARACHAS:
			return BIG_EXP;
		case EENT_ARACHAS_ARMORED:
			return BIG_EXP;
		case EENT_ARACHAS_POISON:
			return BIG_EXP;
		case EENT_WEREWOLF:
			return MEDIUM_EXP;
		case EENT_KATAKAN:
			return MEDIUM_EXP;
		case EENT_EKIMMA:
			return MEDIUM_EXP;
		case EENT_TROLL_ICE:
			return MEDIUM_EXP;
		case EENT_TROLL:
			return MEDIUM_EXP;
		case EENT_GOLEM:
			return BIG_EXP;
		case EENT_ELEMENTAL:
			return BIG_EXP;
		case EENT_ELEMENTAL_FIRE:
			return BIG_EXP;
		case EENT_ELEMENTAL_ICE:
			return BIG_EXP;
		case EENT_BIES:
			return BIG_EXP;
		case EENT_CZART:
			return BIG_EXP;
		case EENT_CYCLOPS:
			return MEDIUM_EXP;
		case EENT_SIREN:
			return SMALL_EXP;
		case EENT_HARPY:
			return SMALL_EXP;
		case EENT_ERYNIA:
			return SMALL_EXP;
		case EENT_WRAITH:
			return SMALL_EXP;
		case EENT_NIGHTWRAITH:
			return MEDIUM_EXP;
		case EENT_NOONWRAITH:
			return MEDIUM_EXP;
		case EENT_NEKKER:
			return SMALL_EXP;
		case EENT_DROWNER:
			return SMALL_EXP;
		case EENT_ROTFIEND:
			return SMALL_EXP;
		case EENT_ALGHOUL:
			return SMALL_EXP;
		case EENT_GHOUL:
			return SMALL_EXP;
		case EENT_WILD_HUNT_MINION:
			return SMALL_EXP;
		case EENT_GRYPHON:
			return MEDIUM_EXP;
		case EENT_BASILISK:
			return MEDIUM_EXP;
		case EENT_COCKATRICE:
			return MEDIUM_EXP;
		case EENT_LESSOG:
			return BIG_EXP;
		case EENT_WYVERN:
			return SMALL_EXP;
		case EENT_FORKTAIL:
			return MEDIUM_EXP;
		case EENT_GRAVEHAG:
			return MEDIUM_EXP;
		case EENT_FOGLING:
			return SMALL_EXP;
		case EENT_WATERHAG:
			return SMALL_EXP;
		case EENT_WILD_HUNT_WARRIOR:
			return SMALL_EXP;
		//EP1:
		case EENT_BOAR:
			return SMALL_EXP;
		case EENT_BLACK_SPIDER:
			return SMALL_EXP;
		//EP2:
		case EENT_SHARLEY:
			return BIG_EXP;
		case EENT_BRUXA:
			return MEDIUM_EXP;
		case EENT_ALP:
			return MEDIUM_EXP;
		case EENT_DRACOLIZARD:
			return MEDIUM_EXP;
		case EENT_BARGHEST:
			return SMALL_EXP;
		case EENT_KIKIMORA_WORKER:
			return SMALL_EXP;
		case EENT_KIKIMORA_WARRIOR:
			return MEDIUM_EXP;
		case EENT_SCOLOPENDROMORPH:
			return MEDIUM_EXP;
		case EENT_ARCHESPOR:
			return SMALL_EXP;
		case EENT_SPRIGAN:
			return BIG_EXP;
		case EENT_WIGHT:
			return BIG_EXP;
		case EENT_GRAVIER:
			return MEDIUM_EXP;
		case EENT_NIGHTWRAITH_BANSHEE:
			return MEDIUM_EXP;
		case EENT_FLEDER:
			return MEDIUM_EXP;
		case EENT_PROTOFLEDER:
			return MEDIUM_EXP;
		case EENT_GARKAIN:
			return MEDIUM_EXP;
		case EENT_PANTHER:
			return SMALL_EXP;
		//no exp for unidentified creatures and animals
		case EENT_GENERIC:
		case EENT_ANIMAL:
		default:
			return NO_EXP;
	}
}

function spectreGetLocStringByEnemyType( et : EEnemyType ) : string
{
	switch(et)
	{
		case EENT_HUMAN:
			return GetLocStringByKey("spectre_kills_humans");
		case EENT_WILD_HUNT_WARRIOR:
			return GetLocStringByKey("spectre_kills_wh_warriors");
		case EENT_WILD_HUNT_MINION:
			return GetLocStringById(1077934);		//Hounds of the Wild Hunt
		case EENT_DOG:
			return GetLocStringById(1077512);		//Dogs
		case EENT_WOLF:
			return GetLocStringById(1077510);		//Wolves
		case EENT_BEAR:
			return GetLocStringById(1077511);		//Bears
		case EENT_BEAR_BERSERKER:
			return GetLocStringById(1077471);		//Berserkers
		case EENT_ENDRIAGA_WORKER:
			return GetLocStringById(1077475);		//Endrega workers
		case EENT_ENDRIAGA_SOLDIER:
			return GetLocStringById(339456);		//Endrega warriors
		case EENT_ENDRIAGA_TRUTEN:
			return GetLocStringById(1077474);		//Endrega drones
		case EENT_FUGAS:
			return GetLocStringById(1077882);		//Sylvans
		case EENT_GARGOYLE:
			return GetLocStringById(1082623);		//Gargoyles
		case EENT_ARACHAS:
			return GetLocStringById(1077760);		//Arachasae
		case EENT_ARACHAS_ARMORED:
			return GetLocStringById(1077472);		//Armored Arachasae
		case EENT_ARACHAS_POISON:
			return GetLocStringById(1077473);		//Venomous arachasae
		case EENT_WEREWOLF:
			return GetLocStringById(593528);		//Werewolves
		case EENT_KATAKAN:
			return GetLocStringById(354496);		//Katakans
		case EENT_EKIMMA:
			return GetLocStringById(1077304);		//Ekimmaras
		case EENT_TROLL_ICE:
			return GetLocStringById(1077498);		//Ice trolls
		case EENT_TROLL:
			return GetLocStringById(1077612);		//Rock trolls
		case EENT_GOLEM:
			return GetLocStringById(339451);		//Golems
		case EENT_ELEMENTAL:
			return GetLocStringById(354371);		//Earth Elementals
		case EENT_ELEMENTAL_FIRE:
			return GetLocStringById(1077469);		//Fire Elementals
		case EENT_ELEMENTAL_ICE:
			return GetLocStringById(1077468);		//Ice Elementals
		case EENT_BIES:
			return GetLocStringById(1077880);		//Fiends
		case EENT_CZART:
			return GetLocStringById(1077881);		//Chorts
		case EENT_CYCLOPS:
			return GetLocStringById(1077494);		//Cyclopses
		case EENT_SIREN:
			return GetLocStringById(1077508);		//Sirens
		case EENT_HARPY:
			return GetLocStringById(1077506);		//Harpies
		case EENT_ERYNIA:
			return GetLocStringById(1077504);		//Erynias
		case EENT_WRAITH:
			return GetLocStringById(1077489);		//Wraiths
		case EENT_NIGHTWRAITH:
			return GetLocStringById(397223);		//Nightwraiths
		case EENT_NOONWRAITH:
			return GetLocStringById(354483);		//Noonwraiths
		case EENT_NEKKER:
			return GetLocStringById(1077497);		//Nekkers
		case EENT_DROWNER:
			return GetLocStringById(1077480);		//Drowners
		case EENT_ROTFIEND:
			return GetLocStringById(1077608);		//Rotfiends
		case EENT_ALGHOUL:
			return GetLocStringById(339457);		//Alghouls
		case EENT_GHOUL:
			return GetLocStringById(548214);		//Ghouls
		case EENT_GRYPHON:
			return GetLocStringById(1077505);		//Griffins
		case EENT_BASILISK:
			return GetLocStringById(339458);		//Basilisks
		case EENT_COCKATRICE:
			return GetLocStringById(354425);		//Cockatrices
		case EENT_LESSOG:
			return GetLocStringById(1077879);		//Leshens
		case EENT_WYVERN:
			return GetLocStringById(1077487);		//Wyverns
		case EENT_FORKTAIL:
			return GetLocStringById(1077488);		//Forktails
		case EENT_GRAVEHAG:
			return GetLocStringById(1077483);		//Grave hags
		case EENT_FOGLING:
			return GetLocStringById(1077481);		//Foglets
		case EENT_WATERHAG:
			return GetLocStringById(1077484);		//Water hags
		//EP1:
		case EENT_BOAR:
			return GetLocStringById(1139394);		//Wild Boars
			return GetLocStringById(1214837);		//Wild Boars
		case EENT_BLACK_SPIDER:
			return GetLocStringById(1139683);		//Arachnomorph
			return GetLocStringById(1214635);		//Arachnomorph
		//EP2:
		case EENT_SHARLEY:
			return GetLocStringById(1203524);		//Shaelmaars
		case EENT_BRUXA:
			return GetLocStringById(1188873);		//Bruxae
		case EENT_ALP:
			return GetLocStringById(1208707);		//Alps
		case EENT_DRACOLIZARD:
			return GetLocStringById(1201766);		//Slyzards
		case EENT_BARGHEST:
			return GetLocStringById(1208635);		//Barghests
		case EENT_KIKIMORA_WORKER:
			return GetLocStringById(1208686);		//Kikimore Workers
		case EENT_KIKIMORA_WARRIOR:
			return GetLocStringById(1208683);		//Kikimore Warrior
		case EENT_SCOLOPENDROMORPH:
			return GetLocStringById(1203529);		//Giant Centipedes
		case EENT_ARCHESPOR:
			return GetLocStringById(1208713);		//Archespores
		case EENT_SPRIGAN:
			return GetLocStringById(1170003);		//Spriggans
		case EENT_WIGHT:
			return GetLocStringById(1207197);		//Wights
		case EENT_GRAVIER:
			return GetLocStringById(1190589);		//Scurvers
		case EENT_NIGHTWRAITH_BANSHEE:
			return GetLocStringById(1213774);		//Beann'shies
		case EENT_FLEDER:
			return GetLocStringById(1208893);		//Fleders
		case EENT_PROTOFLEDER:
			return GetLocStringById(1206787);		//Protofleders
		case EENT_GARKAIN:
			return GetLocStringById(1176357);		//Garkains
		case EENT_PANTHER:
			return GetLocStringById(1208643);		//Panthers
		case EENT_BOSS:
		case EENT_GENERIC:
		case EENT_ANIMAL:
		default:
			return "";
	}
	/*
			return 1077509;		//Succubi
			return 1078140;		//Godlings
			return 1082146;		//Doppler
	*/
}

exec function spectreFixQuestItems()
{
	spectreFixQuestItems_internal();
}

exec function spectreResetMutation()
{
	((W3PlayerAbilityManager)thePlayer.abilityManager).ResetMutationsDev();
}


function spectreFixQuestItems_internal()
{
	var journalManager : CWitcherJournalManager;
	var mapManager : CCommonMapManager;
	var journalEntry : CJournalBase;
	var entryStatus : EJournalStatus;
	var playerInv : CInventoryComponent;
	var questItems : array<SItemUniqueId>;
	var itemIdx : int;
	var itemName : name;
	
	playerInv = thePlayer.GetInventory();
	questItems = playerInv.GetItemsByTag( 'Quest' );
	if( questItems.Size() < 1 )
		return;
	journalManager = theGame.GetJournalManager();
	mapManager = theGame.GetCommonMapManager();

	for( itemIdx = 0; itemIdx < questItems.Size(); itemIdx += 1 )
	{
		itemName = playerInv.GetItemName( questItems[itemIdx] );
		LogChannel('modSpectre', "Quest item: " + itemName);
		journalEntry = NULL;
		switch( itemName )
		{
		//keys: reset tag by map pin status
		case 'lw_gr29_cage_key':
			if( mapManager.IsEntityMapPinDisabled( 'nml_mp_gr29' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'lw_sk41_prison_key':
			if( mapManager.IsEntityMapPinDisabled( 'sk41_mp_skellige' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'lw_sk90_cage_key':
			if( mapManager.IsEntityMapPinDisabled( 'sk90_mp_skl' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'poi_bar_a_10_key':
			if( mapManager.IsEntityMapPinDisabled( 'poi_bar_a_10_mp' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		//non quest related notes: reset by map pin status
		case 'poi_gor_d_06_note04':
			if( mapManager.IsEntityMapPinDisabled( 'poi_gor_d_06_mp' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		case 'ep1_poi_12_note_b':
			if( mapManager.IsEntityMapPinDisabled( 'ep1_poi12_mp' ) )
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		//unconditional reset: not used as actual quest item
		case 'camm_trophy':
		case 'q702_vampire_mask':
		case 'q704_vampire_mask':
		case 'sq701_item_wearable_feather':
		case 'q701_hare_mask':
		case 'q701_nml_notice':
		case 'noon_shadow_loot_note':
			playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
			break;
		//quest based reset
		case 'Only Geralt mandragora mask':
			journalEntry = journalManager.GetEntryByString( "Q703 Art 6C2340E8-4E58E618-BF93D5A9-E8E5CB29" );
			break;
		case 'Beauclair Casual Suit 01':
		case 'Beauclair Casual Suit with medal':
		case 'Beauclair Casual Pants 01':
		case 'Beauclair casual shoes 01':
		case 'q705_medal':
		case 'q704_orianas_vampire_key':
			journalEntry = journalManager.GetEntryByString( "Q705 Ceremony 75B389CC-4F5043B3-9CC508A2-88F82183" );
			break;
		case 'q702_wicht_key':
			journalEntry = journalManager.GetEntryByString( "Q702 Reverb Mixture 1" );
			break;
		case 'th700_vault_journal':
			journalEntry = journalManager.GetEntryByString( "th700 Preacher bones 3D231EB3-445C3C97-0F6411B8-6A511BA6" );
			break;
		case 'th700_prison_journal':
		case 'th700_chapel_journal':
		case 'th700_crypt_journal':
		case 'th700_lake_journal':
			journalEntry = journalManager.GetEntryByString( "th700_red_wolf D0589E62-4A43EF34-AF11C692-E0E0D72C" );
			break;
		case 'th701_coward_journal':
		case 'th701_portal_crystal':
		case 'th701_wolf_witcher_note':
			journalEntry = journalManager.GetEntryByString( "th701_wolf_gear 6DBE2D54-4A4E2066-CAC1ABB6-97CB905B" );
			break;
		case 'mh701_usable_lure':
			journalEntry = journalManager.GetEntryByString( "mh701_tectonic_terror 32486D3E-469FB6BB-9FB1D18B-88046F5A" );
			break;
		case 'mq7002_love_letter_01':
		case 'mq7002_love_letter_02':
			journalEntry = journalManager.GetEntryByString( "mq7002 Stubborn Knight C9725EB0-42EB7261-0E491ABB-D0BC09B4" );
			break;
		case 'mq7007_elven_mask':
		case 'mq7007_elven_shield':
			journalEntry = journalManager.GetEntryByString( "mq7007_gargoyles" );
			break;
		case 'Flowers':
		case 'Perfume':
			journalEntry = journalManager.GetEntryByString( "mq7011 Where's My Money" );
			break;
		case 'sq701_victory_laurels':
			journalEntry = journalManager.GetEntryByString( "sq701_tournament" );
			break;
		case 'mq7017_zmora_trophy':
			journalEntry = journalManager.GetEntryByString( "mq7017_talking_horse 9876843E-47D51F74-12868095-A0A7D712" );
			break;
		case 'sq703_accountance_book':
		case 'sq703_hunter_letter':
		case 'sq703_map_alternative':
		case 'sq703_wife_letter': //WBC
			journalEntry = journalManager.GetEntryByString( "sq703_wine_wars 39087354-4BBDC2C0-3D0942B3-0230FD61" );
			break;
		case 'poi_gor_a_10_note':
			journalEntry = journalManager.GetEntryByString( "gor_a_10 0BBCBACE-4099237B-24A55B88-77B4A861" );
			break;
		case 'poi_car_b_10_note_02':
			journalEntry = journalManager.GetEntryByString( "car_b_10 BA4BC5BD-4B52F387-D2C251B6-6873EAF9" );
			break;
		case 'poi_ww_ver_10_note':
			journalEntry = journalManager.GetEntryByString( "ww_vermentino" );
			break;
		case 'mq6004_lab_key':
			journalEntry = journalManager.GetEntryByString( "mq6004_broken_rose B89DD723-4BD41D61-01BB70B8-849A3C8C" );
			break;
		case 'q504_fish':
			journalEntry = journalManager.GetEntryByString( "Q504 Ciri Empress E8D3E37E-443DA208-F6407683-AA607416" );
			break;
		case 'Potestaquisitor':
			journalEntry = journalManager.GetEntryByString( "Q401 Megascope 0BF1484F-4FAE6703-2880A4B3-C08F7F5C" );
			break;
		case 'Trial Potion Kit':
		case 'q401_forktail_brain':
			journalEntry = journalManager.GetEntryByString( "Q401 The Curse F4D14B2F-43C39290-E76256A6-9BB706B9" );
			break;
		case 'q301_burdock':
			journalEntry = journalManager.GetEntryByString( "Q301 Find Dreamer D2C182B4-449540BC-CCB326B2-4FD786E7" );
			break;
		case 'q309_key_orders':
		case 'q309_key_letters':
			journalEntry = journalManager.GetEntryByString( "Q309 Novigrad Under Control" );
			break;
		case 'q310_wine':
			journalEntry = journalManager.GetEntryByString( "Q210 Preparations 3FFACA7E-489A30A5-824E4887-21A507DE" );
			break;
		case 'q206_herb_mixture':
		case 'q206_arnvalds_letter':
			journalEntry = journalManager.GetEntryByString( "Q206 Berserkers B5130AE1-468A2171-0B7BD3B0-3FBE5499" );
			break;
		case 'q111_fugas_top_key':
			journalEntry = journalManager.GetEntryByString( "Q111 Imlerith" );
			break;
		case 'q106_magic_oillamp':
			journalEntry = journalManager.GetEntryByString( "Q106 Tower 38E268CF-431777D8-0A106B87-22F7BA0D" );
			break;
		case 'mq1002_artifact_1':
		case 'mq1002_artifact_2':
		case 'mq1002_artifact_3':
			journalEntry = journalManager.GetEntryByString( "mq1002 Rezydencja B85F69B4-4563B896-339733A6-9223A984" );
			break;
		case 'sq305_trophies':
			journalEntry = journalManager.GetEntryByString( "SQ305 Scoiatael 6AFAFC3C-47D50499-6D21D3A7-0D30C14D" );
			break;
		case 'sq303_robbery_speech':
			journalEntry = journalManager.GetEntryByString( "SQ303 Brothel 1DBEC8F9-4023BB3B-23EB70A1-52D14101" );
			break;
		case 'sq201_ship_manifesto':
		case 'sq201_cursed_jewel':
		case 'sq201_werewolf_meat':
		case 'sq201_padlock_key':
			journalEntry = journalManager.GetEntryByString( "SQ201 Curse FE437B83-49995725-39F6089A-D2A87C27" );
			break;
		case 'sq205_brewing_instructions':
		case 'sq205_brewmasters_log':
			journalEntry = journalManager.GetEntryByString( "SQ205 Alchemist 52DCBB5B-433C44F6-FC2578A2-49BB8D86" );
			break;
		case 'sq104_notes':
			journalEntry = journalManager.GetEntryByString( "SQ104 Werewolf 15CBFA78-4DA5D1B1-FC623EAD-9F73CE73" );
			break;
		case 'q302_crafter_notes':
			journalEntry = journalManager.GetEntryByString( "Q302 Mafia 5E9E0041-463E3ECD-C72D1B98-5CF5D6C6" );
			break;
		case 'q303_bomb_fragment':
		case 'q303_bomb_cap':
		case 'q303_contact_note':
			journalEntry = journalManager.GetEntryByString( "Q303 Treasure 0292F065-4622C52C-4B7C3492-C7B3FA8E" );
			break;
		case 'q308_sermon_1':
		case 'q308_sermon_2':
		case 'q308_sermon_3':
		case 'q308_sermon_4':
		case 'q308_sermon_5':
		case 'q308_nathanel_sermon_1': //WBC
			journalEntry = journalManager.GetEntryByString( "Q308 Psycho 6EDC27E1-46D57C09-1828A6AE-2E6C46D8" );
			break;
		case 'q310_lever':
			journalEntry = journalManager.GetEntryByString( "Q310 Prison Break 5B858684-4A646E08-258AF3AD-635E235B" );
			break;
		case 'q309_mssg_from_triss':
		case 'q309_witch_hunters_orders': //WBC
			journalEntry = journalManager.GetEntryByString( "Q309 Casablanca 06950C40-442252DF-03C66981-3FD2B4F3" );
			break;
		case 'q202_hjalmar_cell_key':
			journalEntry = journalManager.GetEntryByString( "Q202 Ice Giant" );
			break;
		case 'Geralt mask 01':
		case 'Geralt mask 02':
		case 'Geralt mask 03':
			journalEntry = journalManager.GetEntryByString( "SQ301 Triss DF5C1032-43CFD052-056742B1-5E8C57B0" );
			break;
		case 'sq302_agates':
		case 'sq302_eyes':
			journalEntry = journalManager.GetEntryByString( "SQ302 Philippa 9D3E34EB-4DB8F4BA-4B1C649B-7B7BBAA5" );
			break;
		case 'sq204_wolf_heart':
			journalEntry = journalManager.GetEntryByString( "SQ204 Forest Spirit ADF1F1F0-41C5D27D-3397258A-2893B653" );
			break;
		case 'th1009_journal_wolf_part4':
		case 'th1009_journal_wolf_part2a':
			journalEntry = journalManager.GetEntryByString( "Wolf Set ECDA507B-4902A54F-85D7CAA9-E26BF51C" );
			break;
		case 'mq1055_letters':
			journalEntry = journalManager.GetEntryByString( "mq1055_nilfgaard_mom BCBB27C8-4FA7E374-3CC1408F-8CD2AC77" );
			break;
		case 'mq4002_note':
			journalEntry = journalManager.GetEntryByString( "mq4002_anomaly" );
			break;
		case 'mq4005_note_1':
			journalEntry = journalManager.GetEntryByString( "mq4005_sword" );
			break;
		case 'mq4006_book':
			journalEntry = journalManager.GetEntryByString( "mq4006_armor" );
			break;
		case 'mq2001_journal_2b':
			journalEntry = journalManager.GetEntryByString( "mq2001 Kuilu BF18DA51-48A12FC9-7FC49692-3E4593EB" );
			break;
		case 'mq2020_slave_cells_key':
			journalEntry = journalManager.GetEntryByString( "mq2020 Flesh for cash buisness 75CE5700-4B1F1BBE-069237AE-6D20CA0F" );
			break;
		case 'mq2038_headsman_sword':
			journalEntry = journalManager.GetEntryByString( "mq2038_shieldmaiden 1D9F7929-4152C567-320675A4-7DCB72CE" );
			break;
		case 'mq2015_kurisus_note':
			journalEntry = journalManager.GetEntryByString( "mq2015 Long Time Apart 62611322-4F5B1005-3765EA81-5D229FB0" );
			break;
		case 'mq0004_thalers_monocle':
		case 'mq0004_thalers_monocle_wearable':
			journalEntry = journalManager.GetEntryByString( "MQ0004 Locked Shed F7C2C616-4FBFA7E7-3A37FBA1-0FB8CFC8" );
			break;
		case 'mh305_doppler_letter':
			journalEntry = journalManager.GetEntryByString( "Novigrad Hunt : Doppler D713995F-4D748EC3-F8C29892-A5309EB8" );
			break;
		case 'mh207_lighthouse_keeper_letter':
			journalEntry = journalManager.GetEntryByString( "mh207: Wraith F8815175-4F992A27-45F5F19C-7706FA95" );
			break;
		case 'cg100_barons_notes':
			journalEntry = journalManager.GetEntryByString( "CG : No Man's Land BECB3BA0-4C293A48-C3C229B6-31A1439A" );
			break;
		case 'cg700_letter_monniers_brother':
		case 'cg700_letter_merchants':
		case 'cg700_letter_purist':
			journalEntry = journalManager.GetEntryByString( "cg700_tournament DBBF356D-4FFC9CC0-29404AAF-D6208B48" );
			break;
		default:
			break;
		}
		if( journalEntry )
		{
			entryStatus = journalManager.GetEntryStatus(journalEntry);
			if( entryStatus == JS_Success || entryStatus == JS_Failed )
			{
				playerInv.RemoveItemTag( questItems[itemIdx], 'Quest' );
				playerInv.RemoveItemTag( questItems[itemIdx], 'NoDrop' );
			}
		}
	}
}

function spectreSQ102Finished() : bool
{
	var journalManager : CWitcherJournalManager;
	var journalEntry : CJournalBase;
	var entryStatus : EJournalStatus;

	journalManager = theGame.GetJournalManager();
	journalEntry = journalManager.GetEntryByString( "SQ102 Letho 4614B8BA-49B427F1-8D5B8F96-AB94FBF6" );
	entryStatus = journalManager.GetEntryStatus( journalEntry );
	if( entryStatus == JS_Success || entryStatus == JS_Failed )
	{
		return true;
	}
	return false;
}

function spectreFamilyIssuesAutosave( questEntry : CJournalQuest )
{
	var i, j : int;
	var questPhase : CJournalQuestPhase;
	var objective : CJournalQuestObjective;
	var objectiveStatus : EJournalStatus;
	var journalManager : CWitcherJournalManager;
	var objectiveTag : string;
	
	if( NameToString(questEntry.GetUniqueScriptTag()) == "Q103 Family Issues DB024D36-4E9AE35E-FB098D89-C8E7AB0F" )
	{
		//theGame.witcherLog.AddMessage("Q103 Family Issues");
		journalManager = theGame.GetJournalManager();
		for( i = 0; i < questEntry.GetNumChildren(); i += 1 )
		{
			questPhase = (CJournalQuestPhase)questEntry.GetChild(i);
			if( questPhase )
			{				
				for( j = 0; j < questPhase.GetNumChildren(); j += 1 )
				{
					objective = (CJournalQuestObjective)questPhase.GetChild(j);
					objectiveStatus = journalManager.GetEntryStatus( objective );
					objectiveTag = NameToString(objective.GetUniqueScriptTag());
					if( objectiveStatus == JS_Active )
					{
						//theGame.witcherLog.AddMessage("Objective tag = " + objectiveTag);
						if( objectiveTag == "Protect Baron from wraiths" || objectiveTag == "Protect Baron from wraiths once more" )
						{
							//theGame.witcherLog.AddMessage("Checkpoint saved");
							theGame.SaveGame( SGT_CheckPoint, -1 );
						}
					}
				}
			}
		}
	}
}

function spectreArmorFix( npc : CNewNPC )
{
	var template : CEntityTemplate;
	var size, i : int;
	var armorAbility : name;
	
	if(!npc.IsHuman() || spectreHasArmorAbility(npc))
		return;
	
	template = (CEntityTemplate)LoadResource( npc.GetReadableName(), true );
	size = template.includes.Size();
	if(size > 0)
	{
		for(i = 0; i < size; i += 1)
		{
			armorAbility = spectreGetArmorAbilityFromPath(template.includes[i].GetPath());
			if(armorAbility != 'none' && !npc.HasAbility(armorAbility))
			{
				npc.AddAbility(armorAbility);
				break;
			}
		}
	}
	
}

function spectreHasArmorAbility( npc : CNewNPC ) : bool
{
	return (npc.HasAbility('NPC Leather Armor') || npc.HasAbility('NPC Heavy Leather Armor') ||
			npc.HasAbility('NPC Chainmail Armor') || npc.HasAbility('NPC Partial Plate Armor') ||
			npc.HasAbility('NPC Full Plate Armor') || npc.HasAbility('NPC_Wild_Hunt_Armor'));
}

function spectreGetArmorAbilityFromPath( path : string ) : name
{
	if(StrEndsWith(path, "npc_armor_lvl1.w2ent")) return 'NPC Leather Armor';
	if(StrEndsWith(path, "npc_armor_lvl2.w2ent")) return 'NPC Heavy Leather Armor';
	if(StrEndsWith(path, "npc_armor_lvl3.w2ent")) return 'NPC Chainmail Armor';
	if(StrEndsWith(path, "npc_armor_lvl4.w2ent")) return 'NPC Partial Plate Armor';
	if(StrEndsWith(path, "npc_armor_lvl5.w2ent")) return 'NPC Full Plate Armor';
	if(StrEndsWith(path, "npc_armor_lvl6_wild_hunt.w2ent")) return 'NPC_Wild_Hunt_Armor';
	return 'none';
}

function spectreIsAtLWGR13( actor : CActor ) : bool
{
	var mapManager : CCommonMapManager;
	var entityMapPins : array< SEntityMapPinInfo >;
	var i : int;
	
	mapManager = theGame.GetCommonMapManager();
	
	if( mapManager.GetCurrentArea() != AN_NMLandNovigrad )
		return false;
	
	entityMapPins = mapManager.GetEntityMapPins( mapManager.GetWorldPathFromAreaType( AN_NMLandNovigrad ) );
	
	for( i = 0; i < entityMapPins.Size(); i += 1 )
	{
		if( entityMapPins[i].entityName == 'nml_mp_gr13' && VecDistanceSquared( entityMapPins[i].entityPosition, actor.GetWorldPosition() ) <= 2500 )
		{
			return true;
		}
	}
	
	return false;
}

function spectreResetLevels_internal(optional level : int)
{
	var lm : W3LevelManager;
	
	GetWitcherPlayer().Debug_ClearCharacterDevelopment(level > 0);
	lm = GetWitcherPlayer().levelManager;
	if(level > 0)
	{
		lm.AddPoints(EExperiencePoint, lm.GetTotalExpForGivenLevel(level), false, true);
	}
}

function spectreAddAutogenEquipment_internal()
{
	var iID : array<SItemUniqueId>;
	var witcher : W3PlayerWitcher;
	var inv : CInventoryComponent;
	
	witcher = GetWitcherPlayer();
	inv = GetWitcherPlayer().GetInventory();

	iID = inv.AddAnItem('Autogen steel sword', 1);
	witcher.EquipItem(iID[0]);
	iID = inv.AddAnItem('Autogen silver sword', 1);
	witcher.EquipItem(iID[0]);
	iID = inv.AddAnItem('Autogen Pants', 1);
	witcher.EquipItem(iID[0]);
	iID = inv.AddAnItem('Autogen Gloves', 1);
	witcher.EquipItem(iID[0]);
	iID = inv.AddAnItem('Autogen Boots', 1);
	witcher.EquipItem(iID[0]);
	iID = inv.AddAnItem('Autogen Armor', 1);
	witcher.EquipItem(iID[0]);
}

@replaceMethod function addset( set : EItemSetType, optional equip : bool, optional addExp : bool, optional clearGeralt : bool )
{
	spectreAddset_internal( set, equip, addExp, clearGeralt );
}

function spectreAddset_internal( set : EItemSetType, optional equip : bool, optional addExp : bool, optional clearGeralt : bool )
{
	var witcher : W3PlayerWitcher;
	
	witcher = GetWitcherPlayer();
	FactsAdd( "DebugNoLevelUpUpdates" );
	
	if( clearGeralt )
	{
		witcher.Debug_ClearCharacterDevelopment(true);
	}
	
	if( addExp )
	{
		witcher.AddPoints( EExperiencePoint, 85000, false );
	}
	
	switch( set )
	{
		case EIST_Lynx:
		if(equip)
		{
			witcher.AddAndEquipItem( 'Lynx Armor 4' );
			witcher.AddAndEquipItem( 'Lynx Pants 5' );
			witcher.AddAndEquipItem( 'Lynx Gloves 5' );
			witcher.AddAndEquipItem( 'Lynx Boots 5' );
			witcher.AddAndEquipItem( 'Lynx School steel sword 4' );
			witcher.AddAndEquipItem( 'Lynx School silver sword 4' );
		}
		else
		{
			thePlayer.inv.AddAnItem( 'Lynx Armor 4' );
			thePlayer.inv.AddAnItem( 'Lynx Pants 5' );
			thePlayer.inv.AddAnItem( 'Lynx Gloves 5' );
			thePlayer.inv.AddAnItem( 'Lynx Boots 5' );
			thePlayer.inv.AddAnItem( 'Lynx School steel sword 4' );
			thePlayer.inv.AddAnItem( 'Lynx School silver sword 4' );
		}
		break;
		case EIST_Gryphon:
		if(equip)
		{
			witcher.AddAndEquipItem( 'Gryphon Armor 4' );
			witcher.AddAndEquipItem( 'Gryphon Pants 5' );
			witcher.AddAndEquipItem( 'Gryphon Gloves 5' );
			witcher.AddAndEquipItem( 'Gryphon Boots 5' );
			witcher.AddAndEquipItem( 'Gryphon School steel sword 4' );
			witcher.AddAndEquipItem( 'Gryphon School silver sword 4' );
		}
		else
		{
			thePlayer.inv.AddAnItem( 'Gryphon Armor 4' );
			thePlayer.inv.AddAnItem( 'Gryphon Pants 5' );
			thePlayer.inv.AddAnItem( 'Gryphon Gloves 5' );
			thePlayer.inv.AddAnItem( 'Gryphon Boots 5' );
			thePlayer.inv.AddAnItem( 'Gryphon School steel sword 4' );
			thePlayer.inv.AddAnItem( 'Gryphon School silver sword 4' );
		}
		break;
	case EIST_Bear:
		//witcher.Debug_BearSetBonusQuenSkills();
		if(equip)
		{
			witcher.AddAndEquipItem( 'Bear Armor 4' );
			witcher.AddAndEquipItem( 'Bear Pants 5' );
			witcher.AddAndEquipItem( 'Bear Gloves 5' );
			witcher.AddAndEquipItem( 'Bear Boots 5' );
			witcher.AddAndEquipItem( 'Bear School steel sword 4' );
			witcher.AddAndEquipItem( 'Bear School silver sword 4' );
		}
		else
		{
			thePlayer.inv.AddAnItem( 'Bear Armor 4' );
			thePlayer.inv.AddAnItem( 'Bear Pants 5' );
			thePlayer.inv.AddAnItem( 'Bear Gloves 5' );
			thePlayer.inv.AddAnItem( 'Bear Boots 5' );
			thePlayer.inv.AddAnItem( 'Bear School steel sword 4' );
			thePlayer.inv.AddAnItem( 'Bear School silver sword 4' );
		}
		break;
		case EIST_Wolf:
		/*witcher.inv.AddAnItem( 'Grapeshot 2' );
		witcher.inv.AddAnItem( 'Dancing Star 2' );
		witcher.inv.AddAnItem( 'Hybrid Oil 2' );
		witcher.inv.AddAnItem( 'Cursed Oil 2' );
		witcher.inv.AddAnItem( 'Magical Oil 2' );
		witcher.inv.AddAnItem( 'Specter Oil 2' );*/
		if(equip)
		{
			witcher.AddAndEquipItem( 'Wolf Armor 4' );
			witcher.AddAndEquipItem( 'Wolf Pants 5' );
			witcher.AddAndEquipItem( 'Wolf Gloves 5' );
			witcher.AddAndEquipItem( 'Wolf Boots 5' );
			witcher.AddAndEquipItem( 'Wolf School steel sword 4' );
			witcher.AddAndEquipItem( 'Wolf School silver sword 4' );
		}
		else
		{
			thePlayer.inv.AddAnItem( 'Wolf Armor 4' );
			thePlayer.inv.AddAnItem( 'Wolf Pants 5' );
			thePlayer.inv.AddAnItem( 'Wolf Gloves 5' );
			thePlayer.inv.AddAnItem( 'Wolf Boots 5' );
			thePlayer.inv.AddAnItem( 'Wolf School steel sword 4' );
			thePlayer.inv.AddAnItem( 'Wolf School silver sword 4' );
		}
		break;
		case EIST_RedWolf:
		/*witcher.inv.AddAnItem( 'Black Blood 2' );
		witcher.inv.AddAnItem( 'Swallow 2' );
		witcher.inv.AddAnItem( 'Grapeshot 2' );*/
		if(equip)
		{
			witcher.AddAndEquipItem( 'Red Wolf Armor 1' );
			witcher.AddAndEquipItem( 'Red Wolf Pants 1' );
			witcher.AddAndEquipItem( 'Red Wolf Gloves 1' );
			witcher.AddAndEquipItem( 'Red Wolf Boots 1' );
			witcher.AddAndEquipItem( 'Red Wolf School steel sword 1' );
			witcher.AddAndEquipItem( 'Red Wolf School silver sword 1' );
		}
		else
		{
			thePlayer.inv.AddAnItem( 'Red Wolf Armor 1' );
			thePlayer.inv.AddAnItem( 'Red Wolf Pants 1' );
			thePlayer.inv.AddAnItem( 'Red Wolf Gloves 1' );
			thePlayer.inv.AddAnItem( 'Red Wolf Boots 1' );
			thePlayer.inv.AddAnItem( 'Red Wolf School steel sword 1' );
			thePlayer.inv.AddAnItem( 'Red Wolf School silver sword 1' );
		}
		break;
		case EIST_Vampire:
		if( equip )
		{
			witcher.AddAndEquipItem( 'q702_vampire_boots' );
			witcher.AddAndEquipItem( 'q702_vampire_gloves' );
			witcher.AddAndEquipItem( 'q702_vampire_pants' );
			witcher.AddAndEquipItem( 'q702_vampire_armor' );
			witcher.AddAndEquipItem( 'q702 vampire steel sword' );
			witcher.AddAndEquipItem( 'q702_vampire_mask' );
		}
		else
		{
			witcher.inv.AddAnItem( 'q702_vampire_boots' );
			witcher.inv.AddAnItem( 'q702_vampire_gloves' );
			witcher.inv.AddAnItem( 'q702_vampire_pants' );
			witcher.inv.AddAnItem( 'q702_vampire_armor' );
			witcher.inv.AddAnItem( 'q702_vampire_mask' );
			witcher.inv.AddAnItem( 'q702 vampire steel sword' );
		}
		break;
		case EIST_Viper: //modSpectre
		if( equip )
		{
			witcher.AddAndEquipItem('EP1 Witcher Armor');
			witcher.AddAndEquipItem('EP1 Witcher Boots');
			witcher.AddAndEquipItem('EP1 Witcher Gloves');
			witcher.AddAndEquipItem('EP1 Witcher Pants');
			witcher.AddAndEquipItem('EP1 Viper School steel sword');
			witcher.AddAndEquipItem('EP1 Viper School silver sword');
		}
		else
		{
			witcher.inv.AddAnItem('EP1 Witcher Armor');
			witcher.inv.AddAnItem('EP1 Witcher Boots');
			witcher.inv.AddAnItem('EP1 Witcher Gloves');
			witcher.inv.AddAnItem('EP1 Witcher Pants');
			witcher.inv.AddAnItem('EP1 Viper School steel sword');
			witcher.inv.AddAnItem('EP1 Viper School silver sword');
		}
		break;
		case EIST_KaerMorhen: //modSpectre
		if( equip )
		{
			witcher.AddAndEquipItem('Kaer Morhen Armor 3');
			witcher.AddAndEquipItem('Kaer Morhen Pants 3');
			witcher.AddAndEquipItem('Kaer Morhen Boots 3');
			witcher.AddAndEquipItem('Kaer Morhen Gloves 3');
		}
		else
		{
			witcher.inv.AddAnItem('Kaer Morhen Armor 3');
			witcher.inv.AddAnItem('Kaer Morhen Pants 3');
			witcher.inv.AddAnItem('Kaer Morhen Boots 3');
			witcher.inv.AddAnItem('Kaer Morhen Gloves 3');
		}
		break;
	}
}

@replaceMethod function addsetrec( n : EItemSetType, optional clearDev : bool )
{
	var w		: W3PlayerWitcher;
	
	w = GetWitcherPlayer();

	if( clearDev )
	{
		w.Debug_ClearCharacterDevelopment();
	}
	
	if( w.GetLevel() < 50 )
	{
		w.AddPoints( EExperiencePoint, 85000, false );
	}
	
	w.inv.AddAnItem('Infused shard', 30);
	w.inv.AddMoney( 10000 );
	
	
	switch( n )
	{
		case EIST_Lynx:
			w.inv.AddAnItem( 'Lynx School steel sword 3' );
			w.inv.AddAnItem( 'Lynx School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Lynx School silver sword 3' );
			w.inv.AddAnItem( 'Lynx School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Lynx Armor 3' );
			w.inv.AddAnItem( 'Witcher Lynx Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Lynx Gloves 4' );
			w.inv.AddAnItem( 'Witcher Lynx Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Lynx Boots 4' );
			w.inv.AddAnItem( 'Witcher Lynx Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Lynx Pants 4' );
			w.inv.AddAnItem( 'Witcher Lynx Pants Upgrade schematic 5' );
			break;
		case EIST_Gryphon:
			w.inv.AddAnItem( 'Gryphon School steel sword 3' );
			w.inv.AddAnItem( 'Gryphon School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Gryphon School silver sword 3' );
			w.inv.AddAnItem( 'Gryphon School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Gryphon Armor 3' );
			w.inv.AddAnItem( 'Witcher Gryphon Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Gryphon Gloves 4' );
			w.inv.AddAnItem( 'Witcher Gryphon Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Gryphon Boots 4' );
			w.inv.AddAnItem( 'Witcher Gryphon Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Gryphon Pants 4' );
			w.inv.AddAnItem( 'Witcher Gryphon Pants Upgrade schematic 5' );
			break;
		case EIST_Bear:
			w.inv.AddAnItem( 'Bear School steel sword 3' );
			w.inv.AddAnItem( 'Bear School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Bear School silver sword 3' );
			w.inv.AddAnItem( 'Bear School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Bear Armor 3' );
			w.inv.AddAnItem( 'Witcher Bear Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Bear Gloves 4' );
			w.inv.AddAnItem( 'Witcher Bear Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Bear Boots 4' );
			w.inv.AddAnItem( 'Witcher Bear Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Bear Pants 4' );
			w.inv.AddAnItem( 'Witcher Bear Pants Upgrade schematic 5' );
			w.Debug_BearSetBonusQuenSkills();
			break;
		case EIST_Wolf:
			w.inv.AddAnItem( 'Wolf School steel sword 3' );
			w.inv.AddAnItem( 'Wolf School steel sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Wolf School silver sword 3' );
			w.inv.AddAnItem( 'Wolf School silver sword Upgrade schematic 4' );
			w.inv.AddAnItem( 'Wolf Armor 3' );
			w.inv.AddAnItem( 'Witcher Wolf Jacket Upgrade schematic 4' );
			w.inv.AddAnItem( 'Wolf Gloves 4' );
			w.inv.AddAnItem( 'Witcher Wolf Gloves Upgrade schematic 5' );
			w.inv.AddAnItem( 'Wolf Boots 4' );
			w.inv.AddAnItem( 'Witcher Wolf Boots Upgrade schematic 5' );
			w.inv.AddAnItem( 'Wolf Pants 4' );
			w.inv.AddAnItem( 'Witcher Wolf Pants Upgrade schematic 5' );
			w.inv.AddAnItem( 'Grapeshot 2' );
			w.inv.AddAnItem( 'Dancing Star 2' );
			w.inv.AddAnItem( 'Hybrid Oil 2' );
			w.inv.AddAnItem( 'Cursed Oil 2' );
			w.inv.AddAnItem( 'Magical Oil 2' );
			w.inv.AddAnItem( 'Specter Oil 2' );
		case EIST_RedWolf:
			w.inv.AddAnItem( 'Red Wolf School steel sword schematic 1' );
			w.inv.AddAnItem( 'Red Wolf School silver sword schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Jacket schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Gloves schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Boots schematic 1' );
			w.inv.AddAnItem( 'Witcher Red Wolf Pants schematic 1' );
			w.inv.AddAnItem( 'Black Blood 2' );
			w.inv.AddAnItem( 'Swallow 2' );
			w.inv.AddAnItem( 'Grapeshot 2' );
			break;
		default:
			break;	
	}
}

struct spectrelootconfig
{
	var global_range			: float;
	var plant_range				: float;
	var remains_range			: float;
	var clutter_range			: float;
	var max_results				: int;
	var allow_theft				: bool;
	var los_scan				: bool;
	var segregate_types			: bool;
	var no_reactions			: bool;
}

class spectreAoELoot
{	
	public var inventories	 			: array<CInventoryComponent>;   
	public var sorted_inventories		: array<CInventoryComponent>;	
	private var _containers 			: array<W3Container>;           
	private var opts					: spectrelootconfig;
	private const var obstacles			: array<name>;	default obstacles = {'Terrain', 'Static'};
	private var savelock				: int;			default savelock = -1;

	public function initialize (container : W3Container)
	{
		var config : CInGameConfigWrapper = theGame.GetInGameConfigWrapper();
		
		opts.los_scan = config.GetVarValue('spectreLootingOptions', 'spectreLootLos');
		opts.segregate_types = true;
		opts.allow_theft =  config.GetVarValue('spectreLootingOptions', 'spectreLootTheft');
		opts.no_reactions = config.GetVarValue('spectreLootingOptions', 'spectreLootReactions');
		opts.global_range = StringToFloat(config.GetVarValue('spectreLootingOptions', 'spectreLootGlobalRange') );
		opts.plant_range = StringToFloat(config.GetVarValue('spectreLootingOptions', 'spectreLootPlantRange') );
		opts.remains_range = StringToFloat(config.GetVarValue('spectreLootingOptions', 'spectreLootRemainsRange') );
		opts.clutter_range = StringToFloat(config.GetVarValue('spectreLootingOptions', 'spectreLootClutterRange') );
		opts.max_results = StringToInt(config.GetVarValue('spectreLootingOptions', 'spectreLootMaxResults') );

		getInventoriesInRange(container, inventories);
		obtainContainers();
		theGame.CreateNoSaveLock("spectreLootContainerOpened", savelock, true);
	}
	
	public function signalReactionEvent (evntype : name, optional container : W3Container)
	{
		var idx		: int;
		var arg1	: int;
		var arg2	: float;

		switch (evntype)
		{	
			case 'StealingAction':
			case 'LootingAction':
			if (opts.no_reactions)
			{
				return;
			}
				
			arg2 = 10.0f;
			arg1 = -1;
			break ;

			case 'ContainerClosed':
			theGame.ReleaseNoSaveLock(savelock);
			arg2 = 15.0f;
			arg1 = 10;
			break ;

			default:
			break ;
		}

		if (!container)
		{
			container = _containers[idx];
		}
			
		while (container.disableStealing || container.HasQuestItem() || (W3Herb)container || (W3ActorRemains)container)
		{	
			idx += 1;
			if (idx >= _containers.Size() )
			{
				return;
			}
				
			container = _containers[idx];
		}

		arg2 += VecDistance(thePlayer.GetWorldPosition(), container.GetWorldPosition() ); 

		theGame.GetBehTreeReactionManager().CreateReactionEventIfPossible(thePlayer, evntype, arg1, arg2, -1.f, -1, true);
	}

	public function takeAllItems (out container : W3Container) : void
	{	
		var idx : int = _containers.Size();

		for (idx = idx - (int)(bool)idx; idx >= 0; idx -= 1)
		{	
			_containers[idx].TakeAllItems();
			_containers[idx].OnContainerClosed();
			_containers[idx].Enable(false);
		}

		if (idx == -1)
		{
			container = NULL;
		}
	}

	public function takeItem (idx : int, out activated : W3Container) : bool
	{
		var containerInv 		: CInventoryComponent;
		var item 				: SItemUniqueId;
		var invalidatedItems 	: array< SItemUniqueId >;
		var itemQuantity		: int;
        var src_container		: W3Container;
		var itemslist			: array<SItemUniqueId>;
		 
		containerInv = sorted_inventories[idx];

		src_container = ((W3Container)(containerInv.GetEntity() ) );

		signalReactionEvent('StealingAction', src_container);

		containerInv.GetAllItems(itemslist);

		item = itemslist[Max(0, idx - sorted_inventories.FindFirst(sorted_inventories[idx]) )];

		if (containerInv.ItemHasTag(item, 'HerbGameplay') )
		{
			PlayItemEquipSound('herb');
		}
			
		else  
		{
			PlayItemEquipSound(containerInv.GetItemCategory(item) );
		}
		

		itemQuantity = containerInv.GetItemQuantity(item);

		containerInv.NotifyItemLooted(item);

		containerInv.GiveItemTo(GetWitcherPlayer().inv, item, itemQuantity, true, false, true);

		if (itemslist.Size() <= 1)
		{	
			deleteInventoryFromList(containerInv);
			
			src_container.OnContainerClosed();
			
			src_container.Enable(false);

			if (src_container == activated)
			{
				activated = NULL;
			}
		}

		return (getContainersItemCount(inventories) );
	}

    public function getContainersItemCount (containers : array<CInventoryComponent>) : int
	{	
		var contents			: array<SItemUniqueId>;
		var idx					: int;
		var item_count, i		: int;

		for (idx = containers.Size() - 1; idx >= 0; idx -= 1)
		{	
			containers[idx].GetAllItems(contents);

			for(i = contents.Size() - 1; i >= 0; i -= 1)
			{
				item_count += (int)(!containers[idx].ItemHasTag(contents[i], theGame.params.TAG_DONT_SHOW) );
			}	
		}
		return (item_count);
	}
	
	private function obtainContainers ()
	{	
		var idx : int;

		_containers.Resize(inventories.Size() );

		for (idx = inventories.Size() - 1; idx >= 0; idx -= 1)
		{
			_containers[idx] = ((W3Container)inventories[idx].GetEntity() );
		}
			
	}

	private function deleteInventoryFromList (container : CInventoryComponent)
	{
		var idx : int = inventories.FindFirst(container);

		if (idx > -1)
		{
			inventories.Erase(idx);
		}
	}

	private function getContainerType (container : CEntity) : name
	{
		if (!opts.segregate_types)
		{
			return ('W3Container');
		}	
		else if ((W3Herb)container)
		{
			return ('W3Herb');
		}
		else if ((W3ActorRemains)container)
		{
			return ('W3ActorRemains');
		}
		else if ((W3AnimatedContainer)container)
		{
			return ('W3AnimatedContainer');
		}
		else if ((CBeehiveEntity)container)
		{
			return ('CBeehiveEntity');
		}
		else 
		{
			return ('');
		}
	}	
	
	private function getScanRange (type : name) : float
	{
		if (!opts.segregate_types)
		{
			return (opts.global_range);
		}
			
		switch (type)
		{	
			case 'W3Herb':
			return (opts.plant_range);

			case 'W3ActorRemains':
			return (opts.remains_range);

			case 'W3AnimatedContainer':
			return (opts.clutter_range);

			default:
			return (opts.global_range);
		}
	}

	private function getInventoriesInRange (initial : W3Container, out container_inventories : array<CInventoryComponent>) : void
	{	
		var entities			: array<CGameplayEntity>;
		var container_inventory	: CInventoryComponent;
		var container_entity	: CEntity;
		var container			: W3Container;
		var cont_type			: name = getContainerType(initial);
		var i					: int;

		if ((bool)cont_type && opts.max_results > 1)
		{	
			FindGameplayEntitiesInRange(entities, thePlayer, getScanRange(cont_type), opts.max_results,, FLAG_ExcludePlayer,, cont_type);
			
			for (i = entities.Size() - 1; i >= 0; i -= 1)
			{	
				container_entity = (CEntity)entities[i];
				
				container = (W3Container)container_entity;

				if ((!opts.allow_theft && !container.disableStealing) || container.lockedByKey ||
				container.focusModeHighlight == FMV_Clue || container.factOnContainerOpened != "" ||
				container.HasQuestItem() ||	container.disableLooting ||	!container.GetComponent('Loot').IsEnabled() ||
				(opts.los_scan && !getLos(container) ) )
				{
					continue;
				}
						
				container_inventory = entities[i].GetInventory();

				if (container_inventory.GetItemCount() > 0)
				{
					container_inventories.PushBack(container_inventory);

					if (cont_type == 'W3Herb')
					{
						((W3Herb)entities[i]).OnInteractionActivated("", thePlayer);
					}
				}
					
			}
		}

		container_inventory = initial.GetInventory();

		i = container_inventories.FindLast(container_inventory);

		if (i != container_inventories.Size() -1 || i == -1)
		{	
			container_inventories.Erase(i * (int)(i > 0) );
			container_inventories.PushBack(container_inventory);
		}
	}

	private function getLos (target : CEntity) : bool
	{
		var origin		: Vector = thePlayer.GetWorldPosition();
		var destination	: Vector = target.GetWorldPosition();
		var unused		: Vector;
		var obstructed	: bool;
		var collision	: CComponent;
		var mat			: name;
		var z_increment	: float;
		var bbox		: Box;

		origin.Z += ((CMovingPhysicalAgentComponent)thePlayer.GetMovingAgentComponent() ).GetCapsuleHeight() * 0.9f;

		destination.Z += (float)(int)(bool)((W3Herb)target);

		obstructed = theGame.GetWorld().StaticTraceWithAdditionalInfo(origin, destination, unused, unused, mat, collision, obstacles);

		if (obstructed)
		{	
			obstructed = (!collision || collision.GetEntity() != target);

			if (obstructed)
			{	
				target.CalcBoundingBox(bbox);

				z_increment = (bbox.Max.Z - bbox.Min.Z) * 0.25f;

				if (z_increment)
				{
					while (obstructed && destination.Z < bbox.Max.Z)
					{	destination.Z += z_increment;
						obstructed = theGame.GetWorld().StaticTrace(origin, destination, unused, unused, obstacles);
					}
				}
			}
		}

		return (!obstructed);
	}
}

state AlchemyBrewingPostState in W3PlayerWitcher extends Exploration
{
	event OnEnterState(state_name : name)
	{	
		WaitFor(2.4f);
	}

	private entry function WaitFor(duration : float)
	{
		Sleep(duration);
		parent.PopState(true);
	}

	event OnGameCameraTick(out moveData : SCameraMovementData, dt : float) {}

	event OnGameCameraPostTick(out moveData : SCameraMovementData, dt : float)
	{
		DampVectorSpring(moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector(0, 11.0f, 0, 0), 2.2f, dt);
	}
	
}

state AlchemyBrewing in W3PlayerWitcher extends MeditationBase
{
	private var save_lock					: int;
	private var default_hrs_per_minute 		: float;
	private var firesrc 					: CGameplayLightComponent;
	private var using_fire					: bool;
	private var update_interval_threshold 	: float;
	private var end_session					: bool;
	private var advancing_time				: bool;
	private var ready_for_alchemy			: bool;
	private var session_type				: int;
	private var brew_time					: float;
	private var spin_camera			 		: bool;
	private var rotation_speed				: float;
	private var reduce_camera_spin			: bool;
	private var spin_distance_mult			: float;
	private var spin_reduction_threshold 	: float;
	private var spin_distance_mod			: float;
	private var camera_distance				: float;
	private var camera_angle				: float;
	private var camera_height				: float;

	private const var ANIMATION_DURATION	: float;	default ANIMATION_DURATION = 3.64;
	private const var CAMPFIRE_SPAWN_DELAY	: float;	default CAMPFIRE_SPAWN_DELAY = 4.47f;
	private const var KINDLE_DELAY			: float;	default KINDLE_DELAY = 0.2f;
	private const var EXTINGUISH_DELAY		: float;	default EXTINGUISH_DELAY = 1.5f;
	private const var UPDATE_INTERVAL 		: float;	default UPDATE_INTERVAL = 0.25f;
	private const var MEDITATION_TIME_SCALE	: float;	default MEDITATION_TIME_SCALE = 60.0f;
	private const var TIME_LAPSE			: float;	default TIME_LAPSE = 3.0f;



	event OnEnterState(state_name : name)
	{
		super.OnEnterState(state_name);
		if (!GetIsBrewingAllowed() )
		{	parent.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_here") );
			parent.PopState(true);
		}
		else
		{	thePlayer.OnMeleeForceHolster(true);
			thePlayer.OnRangedForceHolster(true);
			theGame.CreateNoSaveLock('alchemyBrewing', save_lock);
			DisablePlayerControls();
			if (thePlayer.IsInInterior() )
			{	spin_distance_mult = 1.96f;
				spin_distance_mod = 0;
				camera_distance = 1.8f;
				camera_angle = -8.0f;
				camera_height = 1.24f;
			}
			else
			{	spin_distance_mult = 1.64f;
				spin_distance_mod = 1.8;
				camera_distance = 3;
				camera_angle = -12.0f;
				camera_height = 0.96f;
			}
			BeginSession();
		}
	}

	event OnLeaveState(nextStateName : name)
	{
		session_type = 0;
		spin_reduction_threshold = 0;
		spin_camera = false;
		reduce_camera_spin = false;
		ready_for_alchemy = false;
		end_session = false;
		using_fire = false;
		firesrc = NULL;
		DisablePlayerControls(true, true);
		theGame.ReleaseNoSaveLock(save_lock);
		parent.EnableManualCameraControl(true, 'meditation_cam_spin');
		if (advancing_time)
			StopTimeAcceleration();
		theInput.UnregisterListener(this, 'MoveTimeFoward');
		theInput.UnregisterListener(this, 'ExitMedState');
	}
	
	event OnPlayerTickTimer(time : float)
	{	super.OnPlayerTickTimer(time);
		update_interval_threshold += time;
		if (update_interval_threshold < UPDATE_INTERVAL)
			return (true);
		update_interval_threshold = 0;
		if (advancing_time)
			theGame.alchexts.UpdateEffectsTime(UPDATE_INTERVAL * MEDITATION_TIME_SCALE);
	}

	event OnTakeDamage(action : W3DamageAction)
	{	
		if ((CPlayer)action.victim && (CNewNPC)action.attacker)
		{	parent.LockEntryFunction(false);
			thePlayer.PlayerStopAction(thePlayer.GetPlayerAction() );
			parent.PopState(true);
		}
		parent.OnTakeDamage(action);
	}

	event OnRtMeditationFowardTime(action : SInputAction)
	{
		if (IsPressed(action) )
		{	StartTimeAcceleration();
			parent.EnableManualCameraControl(false, 'meditation_cam_spin');
		}
		else if (IsReleased(action) ) // !pressed && !released = possible
			StopTimeAcceleration();
	}

	event OnAlchemyMeditationFinish(action : SInputAction)
	{
		if (IsPressed(action) )
			end_session = true;
	}




	public function AddBrewTime(time : float) : void
	{	brew_time += time;
	}

	public function DeclareSessionType(use_fire : bool)
	{	session_type = (1 * (int)use_fire) + (-1 * (int)!use_fire);
	}

	public function OpenAlchemyMenu()
	{	
		if (!ready_for_alchemy)
			return ;
		if (parent.IsActionAllowed(EIAB_OpenAlchemy) )
			theGame.RequestMenuWithBackground('AlchemyMenu', 'CommonMenu');
		else thePlayer.DisplayActionDisallowedHudMessage(EIAB_OpenAlchemy);
	}

	private entry function BeginSession()
	{
		parent.LockEntryFunction(true);
		while (!session_type)
			SleepOneFrame();
		firesrc = theGame.alchexts.GetNearbyFireSource(false, true, true);
		using_fire = (session_type == 1 && CanBuildCampfire(firesrc) );
		if (!using_fire && firesrc && VecDistance(firesrc.GetWorldPosition(), thePlayer.GetWorldPosition() ) <= 3.f)
		{	thePlayer.SetCustomRotation('FaceFireSrc', VecHeading(firesrc.GetWorldPosition() - thePlayer.GetWorldPosition() ), 360.f, 1.f, false);
			using_fire = (firesrc && !firesrc.IsLightOn() );
		}
		parent.SetBehaviorVariable('MeditateWithIgnite', (float)using_fire);
		parent.SetBehaviorVariable('HasCampfire', (float)using_fire);
		if (!parent.PlayerStartAction(PEA_Meditation) )
		{	parent.DisplayHudMessage(GetLocStringByKeyExt("menu_cannot_perform_action_now") );
			parent.LockEntryFunction(false);
			parent.PopState(true);
		}
		else if (using_fire)
			LightFireSrc();
		Sleep(ANIMATION_DURATION - (float)using_fire);
		theInput.RegisterListener(this, 'OnRtMeditationFowardTime', 'MoveTimeFoward');
		theInput.RegisterListener(this, 'OnAlchemyMeditationFinish', 'ExitMedState');
		DisablePlayerControls(true, false, true);
		ready_for_alchemy = true;
		while (!end_session)
		{	if (!brew_time)
			{	Sleep(UPDATE_INTERVAL);
				continue ;
			}
			StartBrewing();
		}
		ready_for_alchemy = false;
		parent.LockEntryFunction(false);
		EndSession();
	}

	private latent function EndSession()
	{
		DisablePlayerControls(true, true);
		parent.PlayerStopAction(PEA_Meditation);
		if (using_fire)
		{	Sleep(EXTINGUISH_DELAY);
			firesrc.SetLight(false);
		}
		parent.GotoState('AlchemyBrewingPostState');
	}

	private latent function StartBrewing() : void
	{
		var hrs_per_minute	: float;
		var system			: CGameFastForwardSystem;

		spin_camera = true;
		reduce_camera_spin = false;
		spin_reduction_threshold = 0;
		rotation_speed = theGame.alchexts.cam_rotation_speed;
		system = theGame.GetFastForwardSystem();
		hrs_per_minute = theGame.GetHoursPerMinute();
		DisablePlayerControls();
		system.BeginFastForward();
		theGame.SetHoursPerMinute((brew_time / TIME_LAPSE) + hrs_per_minute);
		theGame.alchexts.UpdateEffectsTime(brew_time / hrs_per_minute);
		brew_time = 0;
		theSound.SoundEvent("gui_meditation_start");
		theGame.FadeOutAsync(TIME_LAPSE * 0.64f, Color(16, 16, 16, 0) );
		reduce_camera_spin = true;
		Sleep(TIME_LAPSE * 0.8f);
		theGame.FadeInAsync(TIME_LAPSE * 0.36);
		theGame.SetHoursPerMinute(hrs_per_minute);
		system.AllowFastForwardSelfCompletion();
		DisablePlayerControls(true, false, true);
	}

	private function DisablePlayerControls
	(optional allow_camera : bool, optional allow_input : bool, optional exceptions : bool) : void
	{
		var lock_exceptions : array<EInputActionBlock>;

		parent.EnableManualCameraControl(allow_camera, 'alchemyBrewing');
		if (exceptions)
		{	lock_exceptions.PushBack(EIAB_OpenAlchemy);
			lock_exceptions.PushBack(EIAB_OpenInventory);
			lock_exceptions.PushBack(EIAB_OpenGlossary);
			lock_exceptions.PushBack(EIAB_RadialMenu);
			lock_exceptions.PushBack(EIAB_QuickSlots);
			lock_exceptions.PushBack(EIAB_OpenCharacterPanel);
			if (parent.inputHandler.IsActionBlockedBy(EIAB_OpenAlchemy, 'alchemyBrewing') )
				parent.BlockAllActions('alchemyBrewing', false);
		}
		parent.inputHandler.BlockAllActions('alchemyBrewing', !allow_input, lock_exceptions);
	}

	private function CanBuildCampfire(pre_firesrcsource : bool) : bool
	{
		if (pre_firesrcsource)
		{	theGame.GetGuiManager().ShowNotification(GetLocStringByKey("spectre_fire_exists") );
			return (false);
		}
		else if (!theGame.alchexts.campfires)
		{	theGame.GetGuiManager().ShowNotification(GetLocStringByKey("spectre_fire_disabled") );
			return false;
		}
		else if (thePlayer.IsInInterior() && !theGame.alchexts.campfires_interior)
		{	theGame.GetGuiManager().ShowNotification(GetLocStringByKey("spectre_fire_disabled") );
			return false;
		}
		else if (!GetSafePosition(CalcCampfirePosition() ) )
		{	theGame.GetGuiManager().ShowNotification(GetLocStringByKey("spectre_fire_inappropriate") );
			return false;
		}
		else if (!theGame.alchexts.UseKindling() )
		{	theGame.GetGuiManager().ShowNotification(GetLocStringByKey("spectre_fire_nomaterials") );
			return false;
		}
		return true;
	}

	private latent function	LightFireSrc()
	{	
		var campfire_entity		: CEntityTemplate;
		var campfire_position	: Vector;
		var campfire			: CEntity;

		if (!firesrc)
		{	campfire_position = CalcCampfirePosition();
			campfire_position.Z = GetSafePosition(campfire_position);
			campfire_entity = (CEntityTemplate)LoadResource("environment\decorations\light_sources\campfire\campfire_01.w2ent", true);
			Sleep(CAMPFIRE_SPAWN_DELAY);
			campfire = theGame.CreateEntity(campfire_entity, campfire_position,, false);
			firesrc = (CGameplayLightComponent)campfire.GetComponentByClassName('CGameplayLightComponent');
			Sleep(KINDLE_DELAY);
		}
		else Sleep(CAMPFIRE_SPAWN_DELAY + KINDLE_DELAY);
		firesrc.SetLight(true);
	}

	private function GetSafePosition(position : Vector) : float
	{	
		var position_z : float;

		if (theGame.GetWorld().GetWaterLevel(position, true) >= position.Z)
			return 0;
		else if( theGame.GetWorld().NavigationLineTest(thePlayer.GetWorldPosition(), position, 0.2f) )
		{	theGame.GetWorld().PhysicsCorrectZ(position, position_z);
			return position_z;
		}
		return 0;
	}

	private function CalcCampfirePosition() : Vector
	{	return (thePlayer.GetWorldPosition() + VecFromHeading(thePlayer.GetHeading() ) * Vector(0.83f, 0.83f, 1.f, 1.f) );
	}

	private function GetIsBrewingAllowed() : bool
	{	
		return (!theGame.IsBlackscreenOrFading() && parent.IsActionAllowed(EIAB_OpenAlchemy) &&
			parent.CanMeditateHere() && parent.CanPerformPlayerAction(true)  );
	}

	private function StartTimeAcceleration()
	{
		var system : CGameFastForwardSystem;

		spin_camera = true;
		reduce_camera_spin = false;
		spin_reduction_threshold = 0;
		rotation_speed = theGame.alchexts.cam_rotation_speed;
		default_hrs_per_minute = theGame.GetHoursPerMinute();
		theSound.SoundEvent("gui_meditation_start");
		system.BeginFastForward();
		theGame.SetHoursPerMinute(MEDITATION_TIME_SCALE);
		advancing_time = true;
	}

	private function StopTimeAcceleration()
	{
		var system : CGameFastForwardSystem;

		reduce_camera_spin = true;
		theGame.SetHoursPerMinute(default_hrs_per_minute);
		system.AllowFastForwardSelfCompletion();
		advancing_time = false;
	}




	event OnGameCameraTick(out moveData : SCameraMovementData, dt : float )
	{
		var rotation	: EulerAngles;
		var camera_pos	: float;	
		var destination	: float;

		if (!dt)
			return (false);
		if(!spin_camera)
		{	rotation = thePlayer.GetWorldRotation();
			camera_pos = ModF(moveData.pivotRotationValue.Yaw, 360.f);
			destination = rotation.Yaw + 180.f;
			if (AbsF(camera_pos - destination) > 75.f)
				destination = camera_pos + 90.f;
			moveData.pivotDistanceVelocity *= 0.08f;
			RotateCamera(moveData, destination, 0.28f, -8.0f, camera_distance);
		}
		((CCustomCamera)theCamera.GetTopmostCameraObject() ).SetAllowAutoRotation(true);
		DampVectorSpring(moveData.cameraLocalSpaceOffset, moveData.cameraLocalSpaceOffsetVel, Vector(0, 36.f / camera_distance, -10.0f, 0), 2.2f, dt);
	}

	event OnGameCameraPostTick(out moveData : SCameraMovementData, dt : float )
	{
		if (spin_camera)
		{	RotateCamera(moveData, moveData.pivotRotationValue.Yaw + 90.f, (rotation_speed - spin_reduction_threshold), (spin_reduction_threshold * camera_angle), camera_distance * spin_distance_mult);
			if (reduce_camera_spin)	
			{	spin_reduction_threshold += dt * 0.1618f;
				if (rotation_speed > spin_reduction_threshold)
					return (true);
				spin_reduction_threshold = 0;
				spin_camera = false;
				reduce_camera_spin = false;
				parent.EnableManualCameraControl(true, 'meditation_cam_spin');
			}
		}
	}

	private function RotateCamera(out moveData : SCameraMovementData, rotation, speed, pitch, distance : float) : void
	{
		moveData.pivotRotationController.SetDesiredHeading(rotation, speed);
		moveData.pivotRotationController.SetDesiredPitch(pitch, 0.4f);
		moveData.pivotPositionController.offsetZ = camera_height + (spin_reduction_threshold * 0.64f);
		moveData.pivotDistanceController.SetDesiredDistance(distance - spin_distance_mod * spin_reduction_threshold);
	}

}

abstract class SpectreAlchemyExtensionsConfig
{
	public var fire_src						: int;		default fire_src = 2;
	public var campfires					: bool;		default campfires = true;
	public var campfires_interior			: bool;		default campfires_interior = true;
	public var required_kindling			: int;		default required_kindling = 3;
	public var casual_alchemy				: bool;		default casual_alchemy = false;
	public var max_potions					: int;		default max_potions = 0;
	public var max_bombs					: int;		default max_bombs = 0;
	public var max_oils						: int;		default max_oils = 0;
	public var mutagen_uses					: int;		default mutagen_uses = 1;
	public var alcohol_uses					: int;		default alcohol_uses = 2;
	public var potion_duration				: float;	default potion_duration = 0;
	public var decoction_duration			: float;	default decoction_duration = 0;
	public var potion_duration_added		: float;	default potion_duration_added = 240.0;
	public var decoction_duration_added		: float;	default decoction_duration_added = 0;
	public var potion_duration_mult			: float;	default potion_duration_mult = 0;
	public var decoction_duration_mult		: float;	default decoction_duration_mult = 0;
	public var potion_toxicity_mult			: float;	default potion_toxicity_mult = 1.25;
	public var degeneration_rate			: float;	default degeneration_rate = 0.24;
	public var alt_degen_rate				: float;	default alt_degen_rate = 0.16;
	public var alt_degen_threshold			: float;	default alt_degen_threshold = 0.72;
	public var combat_degeneration			: bool;		default combat_degeneration = false;
	public var combat_degen_rate			: float;	default combat_degen_rate = 0;
	public var residual_degen_rate			: float;	default residual_degen_rate = 0.05;
	public var whoney_tox_base				: float;	default whoney_tox_base = 0.25;
	public var cooked_quantity				: int;		default cooked_quantity = 1;
	public var min_primary_ingredients		: int;		default min_primary_ingredients = 9;
	public var time_based_alchemy			: bool;		default time_based_alchemy = true;
	public var alchemy_time_cost			: float;	default alchemy_time_cost = 10.0;
	public var distillation_time			: float;	default distillation_time = 20.0;
	public var digestion_time				: float;	default digestion_time = 30.;
	public var cam_rotation_speed			: float;	default cam_rotation_speed = 1.0;
	public var mod_primary_substances		: bool;		default mod_primary_substances = true;
	public var mod_mutagens					: bool;		default mod_mutagens = true;
	public var bottle_recycling				: bool;		default bottle_recycling = true;
	public var mod_icons					: bool;		default mod_icons = true;
	public var hide_herbs					: bool;		default hide_herbs = true;
	public var ignore_spawns				: bool;		default ignore_spawns = false;
	public var herbs : S_HerbSpawnSettings;
	public var skill_toxicity_modifier		: float;	default skill_toxicity_modifier = 1.f;
	public var toxicity_degen_modifier		: float;	default toxicity_degen_modifier = 1.f;
	public var toxicity_dmg_modifier		: float;	default toxicity_dmg_modifier = 1.f;
	public var digestion_modifier			: float;	default digestion_modifier = 1.f;
	public var yield_modifier				: float;	default yield_modifier = 1.f;
	public var internal_duration_multiplier	: float;	default internal_duration_multiplier = 1.f;
	
	public const var TOX_UPDATE_INTERVAL	: float;	default TOX_UPDATE_INTERVAL = 1.0f;
	protected const var INTERNAL_VERSION	: int;		default INTERNAL_VERSION = 4;


	public function ReadMenuSettings(change : bool) : void
	{	
		var config	: CInGameConfigWrapper = theGame.GetInGameConfigWrapper();
		var alcohol	: int = alcohol_uses;
		var herbs_s	: S_HerbSpawnSettings;

		if (!change)
			return ;
			
		alcohol_uses = StringToInt(config.GetVarValue('spectreAlchemyBrewing', 'spectreAlcoholUses') );
		bottle_recycling = config.GetVarValue('spectreAlchemyBrewing', 'spectreBottleRecycling');
		cooked_quantity = StringToInt(config.GetVarValue('spectreAlchemyBrewing', 'spectreCookedQuantity') );
		time_based_alchemy = config.GetVarValue('spectreAlchemyBrewing', 'spectreTimeBasedAlchemy');
		alchemy_time_cost = StringToFloat(config.GetVarValue('spectreAlchemyBrewing', 'spectreAlchemyTimeCost') );
		distillation_time = StringToFloat(config.GetVarValue('spectreAlchemyBrewing', 'spectreDistillationTime') );
		mod_primary_substances = config.GetVarValue('spectreAlchemyBrewing', 'spectrePrimarySubstances');
		mod_mutagens = config.GetVarValue('spectreAlchemyBrewing', 'spectreMutagens');
		campfires = config.GetVarValue('spectreAlchemyBrewing', 'spectreCampfire');
		fire_src = StringToInt(config.GetVarValue('spectreAlchemyBrewing', 'spectreFireType') );
		campfires_interior = config.GetVarValue('spectreAlchemyBrewing', 'spectreCampfiresInterior');
		required_kindling = StringToInt(config.GetVarValue('spectreAlchemyBrewing', 'spectreRequiredKindling') );
		casual_alchemy = config.GetVarValue('spectreAlchemyBrewing', 'spectreCasualAlchemy');
		digestion_time = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreDigestionTime') );
		max_potions = StringToInt(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreMaxPotions') );
		max_oils = StringToInt(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreMaxOils') );
		max_bombs = StringToInt(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreMaxBombs') );
		potion_duration = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectrePotionDuration') );
		potion_duration_added = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectrePotionDurationAdded') );
		decoction_duration = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreDecoctionDuration') );
		decoction_duration_added = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreDecoctionDurationAdded') );
		potion_duration_mult = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectrePotionDurationMult') );
		decoction_duration_mult = StringToFloat(config.GetVarValue('spectreAlchemyPotionsAndOils', 'spectreDecoctionDurationMult') );
		degeneration_rate = StringToFloat(config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreDegenerationRate') );
		alt_degen_rate = StringToFloat(config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreAltDegenRate') );
		alt_degen_threshold = StringToFloat(config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreAltDegenThreshold') );
		combat_degeneration = config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreCombatDegeneration');
		combat_degen_rate = StringToFloat(config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreCombatDegenRate') );
		residual_degen_rate = StringToFloat(config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreResidualDegenRate') );
		potion_toxicity_mult = StringToFloat(config.GetVarValue('spectreAlchemyToxicitySettings', 'spectreToxicityMultiplier') );
		cam_rotation_speed = StringToFloat(config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreCameraRotationSpeed') );
		mod_icons = config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreModIcons');
		hide_herbs = config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsOnMap');
		ignore_spawns = config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreIgnoreHerbSpawns');
		herbs_s = herbs;
		if (!ignore_spawns)
		{	herbs.min_s = StringToInt(config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsSpawnMin') );
			herbs.max_s = StringToInt(config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsSpawnMax') );
			herbs.min_y = StringToInt(config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsHarvestMin') );
			herbs.max_y = StringToInt(config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsHarvestMax') );
			herbs.chance = StringToInt(config.GetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsSpawnChance') );
		}
		OnMenuSettingsChanged(alcohol != alcohol_uses, herbs != herbs_s);
	}

	
	private function WriteMenuDefaults() : void
	{
		var config : CInGameConfigWrapper = theGame.GetInGameConfigWrapper();

		config.SetVarValue('spectreAlchemyBrewing', 'spectreCampfire', campfires);
		config.SetVarValue('spectreAlchemyBrewing', 'spectreMutagens', mod_mutagens);
		config.SetVarValue('spectreAlchemyBrewing', 'spectreCasualAlchemy', casual_alchemy);
		config.SetVarValue('spectreAlchemyBrewing', 'spectreBottleRecycling', bottle_recycling);
		config.SetVarValue('spectreAlchemyBrewing', 'spectreCampfiresInterior', campfires_interior);
		config.SetVarValue('spectreAlchemyBrewing', 'spectreTimeBasedAlchemy', time_based_alchemy);
		config.SetVarValue('spectreAlchemyBrewing', 'spectrePrimarySubstances', mod_primary_substances);
		config.SetVarValue('spectreAlchemyBrewing', 'spectreAlcoholUses', IntToString(alcohol_uses) );
		config.SetVarValue('spectreAlchemyBrewing', 'spectreCookedQuantity', IntToString(cooked_quantity) );
		config.SetVarValue('spectreAlchemyBrewing', 'spectreFireType', IntToString(fire_src) );
		config.SetVarValue('spectreAlchemyBrewing', 'spectreRequiredKindling', IntToString(required_kindling) );
		config.SetVarValue('spectreAlchemyBrewing', 'spectreAlchemyTimeCost', FloatToString(alchemy_time_cost) );
		config.SetVarValue('spectreAlchemyBrewing', 'spectreDistillationTime', FloatToString(distillation_time) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreDigestionTime', FloatToString(digestion_time) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreMaxPotions', IntToString(max_potions) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreMaxOils', IntToString(max_oils) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreMaxBombs', IntToString(max_bombs) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectrePotionDuration', FloatToString(potion_duration) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectrePotionDurationAdded', (potion_duration_added) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreDecoctionDuration', FloatToString(decoction_duration) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreDecoctionDurationAdded', FloatToString(decoction_duration_added) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectrePotionDurationMult', FloatToString(potion_duration_mult) );
		config.SetVarValue('spectreAlchemyPotionsAndOils', 'spectreDecoctionDurationMult', FloatToString(decoction_duration_mult) );
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreDegenerationRate', FloatToString(degeneration_rate) );
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreAltDegenRate', FloatToString(alt_degen_rate) );
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreAltDegenThreshold', FloatToString(alt_degen_threshold) );
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreCombatDegeneration', combat_degeneration);
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreCombatDegenRate', FloatToString(combat_degen_rate) );
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreResidualDegenRate', FloatToString(residual_degen_rate) );
		config.SetVarValue('spectreAlchemyToxicitySettings', 'spectreToxicityMultiplier', FloatToString(potion_toxicity_mult) );
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreCameraRotationSpeed', FloatToString(cam_rotation_speed) );
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreModIcons', mod_icons);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsOnMap', hide_herbs);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsSpawnMin', herbs.min_s);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsSpawnMax', herbs.max_s);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsHarvestMin', herbs.min_y);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsHarvestMax', herbs.max_y);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreHerbsSpawnChance', herbs.chance);
		config.SetVarValue('spectreAlchemyMiscellaneousSettings', 'spectreIgnoreHerbSpawns', ignore_spawns);
	}

	event OnMenuSettingsChanged(a, b : bool) : void {}

}

class SpectreAlchemyExtensions extends SpectreAlchemyExtensionsConfig
{
	private var substance_recipes	: array<SAlchemyRecipe>;
	private var mutagen_recipes		: array<SAlchemyRecipe>;
	private var reusables			: array<S_ReusableIngredient>;
	private var player				: W3PlayerWitcher;
	private var initialized			: bool;
	private var force_init			: bool;
	public var using_alchemy_table	: bool;
	public var abltymgr				: spectreAbilityManager;
	public var ing_mngr				: IngredientManager;
	public var herbctrl				: spectreHerbController;

	public function Initialize() : void
	{
		herbctrl = new spectreHerbController in this;
		ing_mngr = new ProgrammingHorrors in this;
		if (ing_mngr.ListsFailedToInitialize() )
			((ProgrammingHorrors)ing_mngr).BringFrankensteinToLife();
		ReadMenuSettings(true);
		ModMutagenRecipes();
		ModPrimarySubstancesRecipes();
		if (initialized)
			OnPlayerSpawned(GetWitcherPlayer() );
		initialized = true;
	}


	event OnPlayerSpawned(_player : W3PlayerWitcher)
	{
		player = _player;

		if (!initialized)
		{	
			initialized = true;
			force_init = true;
			return (false);
		}
		theInput.RegisterListener(this, 'OnMeditationRequest', 'MeditationRequest');
		reusables = player.reusables;
		if (!reusables.Size() )
			InitializeReusableIngredients();
		abltymgr = (spectreAbilityManager)player.abilityManager;
		if (!abltymgr)
			ConstructModAbManager();
		if (!FactsQuerySum("spectre_initialized") )
		{	
			NormalizeSingletonItems();
			player.AddAlchemyRecipe('Recipe for Aether', true, true);
			player.AddAlchemyRecipe('Recipe for Hydragenum', true, true);
			player.AddAlchemyRecipe('Recipe for Rebis', true, true);
			player.AddAlchemyRecipe('Recipe for Quebrith', true, true);
			player.AddAlchemyRecipe('Recipe for Vermilion', true, true);
			player.AddAlchemyRecipe('Recipe for Vitriol', true, true);
			player.AddAlchemyRecipe('Recipe for White Gull 1', true, true);
			FactsAdd("spectre_version", INTERNAL_VERSION, -1);
			FactsAdd("spectre_initialized", 1, -1);
			initialized = true;
			return (true);
		}
		if (FactsQuerySum("spectre_version") != INTERNAL_VERSION)
		{	abltymgr.Update(player, force_init);
			FactsSet("spectre_version", INTERNAL_VERSION);
		}
		force_init = false;
	}


	private var activation_time : float;
	event OnMeditationRequest(action : SInputAction) : void
	{
		if (IsReleased(action) && theInput.IsActionPressed('ModifierKeyPressed') && player.IsPCModeEnabled() )
		{	player.GetInputHandler().PushAlchemyScreen();
			return (false);
		}
		if (IsPressed(action) )
			activation_time = theGame.GetEngineTimeAsSeconds();
		else if (IsReleased(action) )
		{	activation_time = theGame.GetEngineTimeAsSeconds() - activation_time;
			switch (player.GetCurrentStateName() )
			{	case 'ExplorationMeditation':
				case 'MeditationWaiting':
				case 'Meditation':
					player.GetInputHandler().PushAlchemyScreen();
				break ;
				case 'AlchemyBrewing':
					if (activation_time < 0.2f)
						((W3PlayerWitcherStateAlchemyBrewing)player.GetCurrentState() ).OpenAlchemyMenu();
				break ;
				case 'AlchemyBrewingPostState':
				case 'Swimming':
				break ;
				case 'Exploration':
					if (player.IsPCModeEnabled() || theInput.IsActionPressed('ModifierKeyPressed') )
					{	player.GotoState('AlchemyBrewing');
						((W3PlayerWitcherStateAlchemyBrewing)player.GetCurrentState() ).DeclareSessionType
							(activation_time >= 0.36f);
					}
				break ;
				default:
					player.DisplayActionDisallowedHudMessage(EIAB_OpenAlchemy);
				break ;
			}
		}
		return (false);
	}
	
	
	event OnAlchemyMenuClosed() : void
	{
		player.reusables = reusables;
		using_alchemy_table = false;
	}


	event OnSingletonChanged(item : SItemUniqueId, remaining : int) : void
	{
		var inventory_menu	: CR4InventoryMenu;

		if (remaining < 1)
		{	if (player.IsItemEquipped(item) )
				player.UnequipItem(item);
			player.inv.AddItemTag(item, 'NoShow');
		}
		else if (player.inv.ItemHasTag(item, 'NoShow') )
			player.inv.RemoveItemTag(item, 'NoShow');
		inventory_menu = (CR4InventoryMenu)((CR4MenuBase)theGame.GetGuiManager().GetRootMenu() ).GetSubMenu();
		if (inventory_menu)
			inventory_menu.updateCurrentTab();
	}


	event OnMenuSettingsChanged(reusables_changed, herbs_changed : bool) : void
	{	
		if (reusables_changed)
		{
			UpdateReusableIngredients(true);
		}
			
		if (herbs_changed)
		{
			herbctrl.UpdateHerbYield(herbs);
		}
	}


	event OnAlchemyTableUsed() : void
	{
		using_alchemy_table = true;
		theGame.RequestMenuWithBackground('AlchemyMenu', 'CommonMenu');
	}


	public function GetCookedItemLimit(type : EAlchemyCookedItemType) : int
	{	
		switch(type)
		{	case EACIT_Potion:
				return max_potions;
			case EACIT_Bomb:
				return max_bombs;
			case EACIT_Oil:
				return max_oils;
			default:
				return (0);
		}
	}


	public function GetMaxAmmoForItem(item : SItemUniqueId, inv : CInventoryComponent) : int
	{
		var ammo : int;

		if (inv.GetEntity() == player && inv.GetItemName(item) != 'Snow Ball'
		&& !inv.ItemHasTag(item, 'NoAdditionalAmmo') )
		{	if (max_potions && inv.IsItemPotion(item) )
				ammo = max_potions;
			else if (max_bombs && inv.IsItemBomb(item) )
				ammo = max_bombs;
			else if (max_oils && inv.IsItemOil(item) )
				ammo = max_oils;
			else ammo = inv.GetItemModifierInt(item, 'ammo_current') + 1;
			return (Max(1, ammo) );
		}
		return ((int)(CalculateAttributeValue(inv.GetItemAttributeValue(item, 'ammo') ) + 0.5f) );
	}


	public function GetNearbyFireSource
	(	optional campfires_only			: bool,
		optional long_range_scan		: bool,
		optional include_extinguished	: bool
	) : CGameplayLightComponent
	{
		var source : CGameplayLightComponent;

		if (campfires_only)
			(FindFireSource('W3Campfire', long_range_scan, include_extinguished, source) );
		else (FindFireSource('W3Campfire', long_range_scan, include_extinguished, source)
			|| FindFireSource('W3FireSource', long_range_scan, include_extinguished, source) );
		return (source);
	}


	public function UseKindling() : bool
	{
		var kindling : int = player.inv.GetItemQuantityByName('Timber') + player.inv.GetItemQuantityByName('Hardened timber');

		if (!required_kindling)
			return true;
		if (kindling >= required_kindling)
		{	if (player.inv.RemoveItemByName('Timber', required_kindling) )
				return true;
			else if (player.inv.RemoveItemByName('Hardened timber', required_kindling) )
				return true;
			else
			{	kindling = player.inv.GetItemQuantityByName('Timber');
				player.inv.RemoveItemByName('Timber', kindling);
				player.inv.RemoveItemByName('Hardened timber', required_kindling - kindling);
				return true;
			}
		}
		return false;
	}


	public function IsValidAlchemyState(statename : name) : bool
	{
		if (using_alchemy_table || casual_alchemy || FactsQuerySum("ACS_In_Meditation") > 0 ||
			theGame.GetTutorialSystem().uiHandler.GetCurrentStateName() == 'Alchemy')
				return (true);
		switch (statename)
		{	case 'AlchemyBrewing':
			case 'Meditation':
			case 'W3EEMeditation':
			case 'PlayerDialogScene':
			case 'ExplorationMeditation':
				return (true);
			return (false);
		}
	}


	public function GetRecipes(out recipes : array<SAlchemyRecipe>)
	{
		var dm			: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var rec_nodes	: SCustomNode = dm.GetCustomDefinition('alchemy_recipes');
		var known		: array<name> = player.GetAlchemyRecipes();
		var remaining	: int = known.Size();
		var ing_nodes	: SCustomNode;
		var rec, empty	: SAlchemyRecipe;
		var ingredient	: SItemParts;
		var ingredients : array<SItemParts>;
		var tmp			: string;
		var i, idx		: int;

		for (i = 0; i < rec_nodes.subNodes.Size() && remaining; i += 1)
		{	if (dm.GetCustomNodeAttributeValueName(rec_nodes.subNodes[i], 'name_name', rec.recipeName)
			&& known.Contains(rec.recipeName) )
			{	dm.GetCustomNodeAttributeValueName(rec_nodes.subNodes[i], 'cookedItem_name', rec.cookedItemName);
				dm.GetCustomNodeAttributeValueName(rec_nodes.subNodes[i], 'type_name', rec.typeName);
				dm.GetCustomNodeAttributeValueInt(rec_nodes.subNodes[i], 'level', rec.level);
				dm.GetCustomNodeAttributeValueString(rec_nodes.subNodes[i], 'cookedItemType', tmp);
				rec.cookedItemType = AlchemyCookedItemTypeStringToEnum(tmp);
				switch (rec.cookedItemType)
				{	case EACIT_MutagenPotion:
					case EACIT_Potion:
					case EACIT_Oil:
					case EACIT_Bomb:
						if (rec.level > 1)
							continue ;
					break ;
					case EACIT_Substance:
						switch (rec.recipeName)
						{	case 'Recipe for Albedo':
							case 'Recipe for Rubedo':
							case 'Recipe for Nigredo':
								continue ;
							default:
								idx = GetIsPrimarySubsRecipe(rec.recipeName);
								if (idx > -1)
								{	if (mod_primary_substances)
										rec.requiredIngredients = substance_recipes[idx].requiredIngredients;
								}
								else if (mod_mutagens)
								{	idx = GetIsMutagenRecipe(rec.recipeName);
									if (idx > -1)
										rec.requiredIngredients = mutagen_recipes[idx].requiredIngredients;
								}
							break ;
						}
					break ;
					case EACIT_Alcohol:
						if (rec.cookedItemName == 'Alcohest')
							continue ;
					break ;
				}
				if (!rec.requiredIngredients.Size() )
				{	ing_nodes = dm.GetCustomDefinitionSubNode(rec_nodes.subNodes[i],'ingredients');
					for (idx = ing_nodes.subNodes.Size() - 1; idx >= 0; idx -= 1)
					{	dm.GetCustomNodeAttributeValueName(ing_nodes.subNodes[idx], 'item_name', ingredient.itemName);
						dm.GetCustomNodeAttributeValueInt(ing_nodes.subNodes[idx], 'quantity', ingredient.quantity);
						rec.requiredIngredients.PushBack(ingredient);
					}
				}
				dm.GetCustomNodeAttributeValueInt(rec_nodes.subNodes[i], 'cookedItemQuantity', rec.cookedItemQuantity);
				rec.cookedItemIconPath = dm.GetItemIconPath(rec.cookedItemName);
				rec.recipeIconPath = dm.GetItemIconPath(rec.recipeName);
				recipes.PushBack(rec);
				rec.requiredIngredients.Clear();
				rec = empty;//SAlchemyRecipe('', EACIT_Undefined, "", 0, '', '', "", '', 0);
				ingredients.Clear();
				remaining -= 1;
			}
		}
	}


	public function GetIsPrimarySubsRecipe(recipe : name) : int
	{
		var i : int;

		for (i = substance_recipes.Size() - 1; i >= 0; i -= 1)
		{	if (substance_recipes[i].recipeName != recipe)
				continue ;
			return (i);
		}
		return (-1);
	}


	public function GetIsMutagenRecipe(recipe : name) : int
	{
		var i : int;

		for (i = mutagen_recipes.Size() - 1; i >= 0; i -= 1)
		{	if (mutagen_recipes[i].recipeName != recipe)
				continue ;
			return (i);
		}
		return (-1);
	}


	public function GetIsReusableIngredient(ingredient : name, out uses : int, out left : int) : bool
	{
		var i : int = reusables.Size();

		while (i) 
		{	i -= 1;
			if (reusables[i].id != ingredient)
				continue ;
			uses = reusables[i].uses;
			left = reusables[i].left;
			return (true);
		}
		return (false);
	}


	public function UpdateReusableIngredients(optional alcohol : bool, optional mutagen : bool) : void
	{
		var mutagens	: array<name>;
		var idx			: array<int>;
		var i, left		: int = 2;

		if (alcohol)
		{	idx.Resize(left);
			for (i = reusables.Size() - 1; i >= 0 && left; i -= 1)
			{	switch (reusables[i].id)
				{	case 'Alcohest':		idx[0] = i; break ;
					case 'White Gull 1':	idx[1] = i; break ;
					default: continue ;
				}
				left -= 1;
			}
			reusables[idx[0]] = S_ReusableIngredient(alcohol_uses, alcohol_uses, 'Alcohest');
			reusables[idx[1]] = S_ReusableIngredient(alcohol_uses + 1, alcohol_uses + 1, 'White Gull 1');
		}
		if (mutagen)
		{	ing_mngr.GetMutagens(mutagens);
			for (i = reusables.Size() - 1; i >= 0; i -= 1)
			{	if (mutagens.Contains(reusables[i].id) )
				{	left = reusables[i].left;
					if (left != reusables[i].uses && left < mutagen_uses)
						reusables[i].left = mutagen_uses - left;
					else reusables[i].left = mutagen_uses;
					reusables[i].uses = mutagen_uses;
				}
			}
		}
		player.reusables = reusables;
	}


	public function CalculatePotionDuration
	(optional potion : SItemUniqueId, is_decoction : bool, optional itemname : name, optional initial : float) : float
	{
		var val			: SAbilityAttributeValue;
		var duration 	: float;
		var _override	: float;
		var increment	: float;
		var multiplier	: float;

		if (player.inv.IsIdValid(potion) )
		{	duration = CalculateAttributeValue(player.inv.GetItemAttributeValue(potion, 'duration') );
			itemname = player.inv.GetItemName(potion);
			if (StrFindFirst(itemname, "White Raffard") > -1)
			{	if (StrEndsWith(itemname, "3") )
					duration = CalculateAttributeValue(player.inv.GetItemAbilityAttributeValue(potion, 'duration',
						'WhiteRaffardDecoctionEffect_Level3') );
				return (duration);
			}
		}
		else
		{	theGame.GetDefinitionsManager().GetItemAttributeValueNoRandom(itemname, true, 'duration', val, val);
			duration = CalculateAttributeValue(val);
			if (!duration && initial)
				return (initial);
		}
		if (is_decoction)
		{	_override = decoction_duration;
			increment = decoction_duration_added;
			multiplier = decoction_duration_mult;
		}
		else
		{	_override = potion_duration;
			increment = potion_duration_added;
			multiplier = potion_duration_mult;
		}
		duration = duration * (int)!((bool)_override) + _override;
		duration += increment * (int)!((bool)_override);
		duration *= (1 + multiplier - (int)(bool)multiplier);
		return (duration * internal_duration_multiplier);
	}


	public function CalculatePotionToxicity
	(optional potion : SItemUniqueId, optional potname : name, optional toxicity : float) : float
	{
		var blank		: SItemUniqueId;
		var potstr		: string;
		var i, len, lvl	: int;
		var offset		: float;
		
		//assert (potion || (potname && toxicity) )
		if (potion != blank)
		{	toxicity = CalculateAttributeValue(player.inv.GetItemAttributeValue(potion, 'toxicity') );
			offset = CalculateAttributeValue(player.inv.GetItemAttributeValue(potion, 'toxicity_offset') );
			potname = player.inv.GetItemName(potion);
		}
		potstr = potname;
		if (StrFindFirst(potstr, "mutagen") < 0)
		{	for (i = 1, len = StrLen(potstr); i < len; i += 1)
			{	lvl = StringToInt(StrRight(potstr, i) );
				if (lvl)
					break ;
			}
			switch (lvl)
			{	case 1: toxicity *= potion_toxicity_mult; break ;
				case 2:	toxicity *= (potion_toxicity_mult + .5f); break ;
				case 3: toxicity *= (potion_toxicity_mult + 1.0f);	break ;
			}
		}
		toxicity += offset;
		return (toxicity * skill_toxicity_modifier);
	}


	public function GetTotalToxicity(potion : SItemUniqueId) : int
	{
		var effects			: array<CBaseGameplayEffect> = player.GetBuffs(EET_PotionDigestion);
		var metab			: W3Effect_PotionDigestion;
		var idx				: int = effects.Size();
		var unprocessed_tox	: float;

		while (idx)
		{	idx -= 1;
			metab = (W3Effect_PotionDigestion)effects[idx];
			if (metab)
				unprocessed_tox += metab.adjusted_toxicity * metab.GetDurationLeft();
		}
		return ((int)(CalculatePotionToxicity(potion) + abltymgr.GetStat(BCS_Toxicity) + unprocessed_tox + 0.5f) );
	}


	public function ChangePotionTooltipData(potion : SItemUniqueId, out att : array<SAttributeTooltip>) : void
	{
		var i : int;

		for (; i < att.Size(); i += 1)
		{	switch (att[i].originName)
			{	case 'duration':
					att[i].value = CalculatePotionDuration(potion, player.inv.ItemHasTag(potion, 'Mutagen') );
				break;
				case 'toxicity':
				case 'toxicity_offset':
					att[i].value = CalculatePotionToxicity(,player.inv.GetItemName(potion), att[i].value);
				break;
			}
		}
		if (StrFindFirst(player.inv.GetItemName(potion), "white honey") > -1)
			GetWhiteHoneyModedStats(att,, potion);
	}


	public function GetItemStatsForAlchemyMenu(item : name, out stats : array<SAttributeTooltip>) : void
	{
		var abs, atts	: array<name>;
		var stat		: SAttributeTooltip;
		var id			: SItemUniqueId = player.inv.GetItemId(item);
		var val			: SAbilityAttributeValue;
		var type		: EEffectType;
		var ability		: name;
		var i, j		: int;

		player.inv.GetItemStatsFromName(item, stats);
		if (player.inv.IsIdValid(id) )
		{	player.inv.GetItemContainedAbilities(id, abs);
			for (i = abs.Size() - 1; i >= 0; i -= 1)
			{	EffectNameToType(abs[i], type, ability);
				if (type != EET_Undefined)
				{	ability = abs[i];
					theGame.GetDefinitionsManager().GetAbilityAttributes(ability, atts);
					for (j = atts.Size() - 1; j >= 0; j -= 1)
					{	val = player.inv.GetItemAbilityAttributeValue(id, atts[j], ability);
						stat.value = val.valueAdditive;
						if (val.valueBase && val.valueMultiplicative)
							stat.value += val.valueBase * val.valueMultiplicative;
						else stat.value += (val.valueBase + val.valueMultiplicative);
						if (stat.value < 0)
							continue ;
						stat.percentageValue = StrCmp(atts[j], 'duration')
							&& (stat.value < 1.0 || (!StrCmp(atts[j], 'vitality') && StrFindFirst(item, "raffard") >= 0)
							|| StrFindFirst(atts[j], 'Perc') >= 0);
						stat.attributeName = GetAttributeNameLocStr(atts[j], false);
						stat.attributeColor = "BAADA0";
						stat.originName = atts[j];
						stats.PushBack(stat);
					}
				}
			}
		}
		if (StrFindFirst(item, "white honey") > -1)
			GetWhiteHoneyModedStats(stats, item);
	}


	public function GetWhiteHoneyModedStats
	(out stats : array<SAttributeTooltip>, optional item : name, optional id : SItemUniqueId) : void
	{
		var stat : SAttributeTooltip;

		//assert item || id
		if (!((bool)item) )
			item = player.inv.GetItemName(id);
		stat = SAttributeTooltip('', GetAttributeNameLocStr('toxicity', false), "BAADA0", 0, true, false);
		stat.value = (1 + StringToInt(StrRight(item, 1) ) ) * -whoney_tox_base;
		stats.PushBack(stat);
	}


	public function GetPotionSecondarySubstance(potion : SItemUniqueId) : name
	{
		if (player.inv.ItemHasTag(potion, 'Albedo') )
			return ('Albedo');
		if (player.inv.ItemHasTag(potion, 'Rubedo') )
			return ('Rubedo');
		if (player.inv.ItemHasTag(potion, 'Nigredo') )
			return ('Nigredo');
		return ('');
	}


	public function GetPotionSubstanceDescription(potion : SItemUniqueId) : string
	{
		switch (GetPotionSecondarySubstance(potion) )
		{	case 'Albedo':
				return ("<br>" + GetLocStringByKeyExt("spectre_dominance") + " <font color=\"#FFFFFF\">"
					+ GetLocStringByKeyExt("spectre_albedo") + "</font>." + "<br/>");
			break ;
			case 'Rubedo':
				return ("<br>" + GetLocStringByKeyExt("spectre_dominance") + " <font color=\"#C52C34\">"
					+ GetLocStringByKeyExt("spectre_rubedo") + "</font>." + "<br/>");
			break ;
			case 'Nigredo':
				return ("<br>" + GetLocStringByKeyExt("spectre_dominance") + " <font color=\"#4F4F4F\">"
					+ GetLocStringByKeyExt("spectre_nigredo") + "</font>." + "<br/>");
			break ;
		}
		return ("");
	}
	

	public function GetIngredientPopupDescription(ingredient : name, is_ingredient : bool) : string
	{
		var description : string;

		if (is_ingredient)
		{	description = ing_mngr.GetIngredientDescription(ingredient);
			if (StrLen(description) )
				return ("<font color='#8B4C96'>" + description + "</font>");
			return (GetLocStringByKeyExt("spectre_unused_ingredient") );
		}
		return ("");
	}


	public function AddSecondarySubstanceEffects(substance : name, duration : float)
	{	
		var effect_parameters : SCustomEffectParams;

		switch (substance) //(In W1, sec susbstances' durations were independent from the potions' duration)
		{	case 'Albedo':
				effect_parameters.customAbilityName = 'AlbedoDominanceEffect';
				effect_parameters.effectType = EET_AlbedoDominance;
				effect_parameters.duration = 240.0f + GetEffectRemainingDuration(EET_AlbedoDominance, ""); 
			break ;
			case 'Rubedo':
				effect_parameters.customAbilityName = 'RubedoDominanceEffect';
				effect_parameters.effectType = EET_RubedoDominance;
				effect_parameters.duration = 480.0f + GetEffectRemainingDuration(EET_RubedoDominance, "");
			break ;
			case 'Nigredo':
				effect_parameters.customAbilityName = 'NigredoDominanceEffect';
				effect_parameters.effectType = EET_NigredoDominance;
				effect_parameters.duration = 960.0f + GetEffectRemainingDuration(EET_NigredoDominance, "");
			break ;
			default:
			return;
		}
		effect_parameters.creator = player;
		effect_parameters.sourceName = NameToString(effect_parameters.customAbilityName);
		player.AddEffectCustom(effect_parameters);
	}

	
	public function GetEffectRemainingDuration(effect : EEffectType, source : string) : float
	{
		var active : CBaseGameplayEffect = player.GetBuff(effect, source);

		if (active)
			return (active.GetDurationLeft() );
		return (0);
	}
	
	
	public function UpdateEffectsTime(time : float) : void
	{	var effect_list : array<CBaseGameplayEffect>;
		var i : int;

		effect_list = player.GetCurrentEffects();
		for (i = effect_list.Size() - 1; i >= 0; i -= 1)
			effect_list[i].OnTimeUpdated(time);
	}


	public function UpdateIngredientUses(ingredient : name, required : int) : int
	{
		var i, used : int;

		for (i = reusables.Size() -1; i >= 0; i -= 1)
		{	if (reusables[i].id != ingredient)
				continue ;
			if (reusables[i].left <= required)
			{	required -= reusables[i].left;
				used = required / reusables[i].uses;
				reusables[i].left = reusables[i].uses - (required % reusables[i].uses);
				return (used + 1);
			}
			reusables[i].left -= required;
			return (0);
		}
		return (required);
	}
	

	private function FindFireSource
	(	fire_type						: name,
		optional long_range				: bool,
		optional include_extinguished	: bool,
		out source						: CGameplayLightComponent
	) : bool
	{
		var game_entities	: array<CGameplayEntity>;
		var lightcomp		: CGameplayLightComponent;
		var scan_range		: float = 2 + (int)long_range;
		var i 				: int;

		FindGameplayEntitiesInRange(game_entities, player, scan_range, 5 ,,FLAG_ExcludePlayer,, fire_type);
		for (i = game_entities.Size() - 1; i >= 0; i -= 1)
		{	lightcomp = (CGameplayLightComponent)game_entities[i].GetComponentByClassName('CGameplayLightComponent');
			if (lightcomp && (lightcomp.IsLightOn() || include_extinguished) )
			{	source = lightcomp;
				return (true);
			}
		}
		return (false);
	}


	private function NormalizeSingletonItems() : void
	{
		var items	: array<SItemUniqueId>;
		var inv		: CInventoryComponent = player.inv;
		var idx		: int;

		inv.GetAllItems(items);
		for (idx = items.Size() - 1; idx >= 0; idx -= 1)
		{	if (((inv.IsItemPotion(items[idx]) || inv.IsItemBomb(items[idx]) ) &&
				inv.GetItemModifierInt(items[idx], 'ammo_current') <= 0) || inv.IsItemOil(items[idx]) )
				 	player.inv.SetItemModifierInt(items[idx],'ammo_current', 1);
		}
	}


	private function ConstructModAbManager() : void
	{
		abltymgr = new spectreAbilityManager in ((CPlayer)player);
		abltymgr.Construct(((W3PlayerAbilityManager)player.abilityManager) );
		force_init = force_init || player.abilityManager.owner;
		player.ResetAbilityManager();
		if (force_init)
			abltymgr.Init(player, player.GetCharacterStats(), true, theGame.GetSpawnDifficultyMode() );
	}


	private function RevertAbilityManager() : void
	{
		var abm : W3PlayerAbilityManager;

		player.abilityManager = new W3PlayerAbilityManager in ((CPlayer)player);
		abm = (W3PlayerAbilityManager)player.abilityManager;
		abm.owner = abltymgr.owner;
		abm.skills = abltymgr.skills;
		abm.tempSkills = abltymgr.tempSkills;
		abm.skillSlots = abltymgr.skillSlots;
		abm.skillAbilities = abltymgr.skillAbilities;
		//abm.blockedAbilities = abltymgr.blockedAbilities;
		abm.difficultyAbilities = abltymgr.difficultyAbilities;
		abm.totalSkillSlotsCount = abltymgr.totalSkillSlotsCount;
		abm.temporaryTutorialSkills = abltymgr.temporaryTutorialSkills;
		abm.mutations = abltymgr.mutations;
		abm.mutagenBonuses = abltymgr.mutagenBonuses;
		abm.mutagenSlots = abltymgr.mutagenSlots;
		abm.isMutationSystemEnabled = abltymgr.isMutationSystemEnabled;
		abm.mutationUnlockedSlotsIndexes = abltymgr.mutationUnlockedSlotsIndexes;
		abm.mutationSkillSlotsInitialized = abltymgr.mutationSkillSlotsInitialized;
		abm.ignoresDifficultySettings = abltymgr.ignoresDifficultySettings;
		abm.pathPointsSpent = abltymgr.pathPointsSpent;
		abm.resistStatsItems = abltymgr.resistStatsItems;
		abm.usedDifficultyMode = abltymgr.usedDifficultyMode;
		abm.usedHealthType = abltymgr.usedHealthType;
		//abm.isInitialized = abltymgr.isInitialized;
		abm.charStats = abltymgr.charStats;
		delete abltymgr;
		abltymgr = NULL;
		abm.CheckBlockedSkills(0);
		abm.Init(player, abm.charStats, true, theGame.GetSpawnDifficultyMode() );
	}


	private function ModPrimarySubstancesRecipes() : void
	{
		var recipe_index, ingredient_index : int;

		substance_recipes.Resize(9);
		substance_recipes[0].recipeName = 'Recipe for Aether';
		substance_recipes[1].recipeName = 'Recipe for Hydragenum';
		substance_recipes[2].recipeName = 'Recipe for Rebis';
		substance_recipes[3].recipeName = 'Recipe for Quebrith';
		substance_recipes[4].recipeName = 'Recipe for Vermilion';
		substance_recipes[5].recipeName = 'Recipe for Vitriol';
		substance_recipes[6].recipeName = 'Recipe for Nigredo';
		substance_recipes[7].recipeName = 'Recipe for Albedo';
		substance_recipes[8].recipeName = 'Recipe for Rubedo';
		for (recipe_index = substance_recipes.Size() - 1; recipe_index >= 0; recipe_index -= 1)
		{	substance_recipes[recipe_index].requiredIngredients.Resize(3);
			substance_recipes[recipe_index].requiredIngredients[2].itemName = 'Alcohest';
			substance_recipes[recipe_index].requiredIngredients[1].itemName = 'Empty bottle';
			substance_recipes[recipe_index].requiredIngredients[2].quantity = 1;
			substance_recipes[recipe_index].requiredIngredients[1].quantity = 2;
			substance_recipes[recipe_index].requiredIngredients[0].quantity = min_primary_ingredients;
		}
		substance_recipes[0].requiredIngredients[0].itemName = 'Berbercane fruit';
		substance_recipes[1].requiredIngredients[0].itemName = 'Mistletoe';
		substance_recipes[2].requiredIngredients[0].itemName = 'Hop umbels';
		substance_recipes[3].requiredIngredients[0].itemName = 'Verbena';
		substance_recipes[4].requiredIngredients[0].itemName = 'Wolfsbane';
		substance_recipes[5].requiredIngredients[0].itemName = 'White myrtle';
		substance_recipes[6].requiredIngredients[0].itemName = 'Sulfur';
		substance_recipes[7].requiredIngredients[0].itemName = 'Bryonia';
		substance_recipes[8].requiredIngredients[0].itemName = 'Cortinarius';
	}


	private function ModMutagenRecipes() : void
	{
		var recipe_index : int;

		mutagen_recipes.Resize(8);
		mutagen_recipes[0].recipeName = 'Recipe for Mutagen red';
		mutagen_recipes[1].recipeName = 'Recipe for Mutagen green';
		mutagen_recipes[2].recipeName = 'Recipe for Mutagen blue';
		mutagen_recipes[3].recipeName = 'Recipe for Mutagen yellow';
		mutagen_recipes[4].recipeName = 'Recipe for Greater mutagen red';
		mutagen_recipes[5].recipeName = 'Recipe for Greater mutagen green';
		mutagen_recipes[6].recipeName = 'Recipe for Greater mutagen blue';
		mutagen_recipes[7].recipeName = 'Recipe for Greater mutagen yellow';
		for (recipe_index = mutagen_recipes.Size() - 1; recipe_index >= 0; recipe_index -= 1)
		{	mutagen_recipes[recipe_index].requiredIngredients.Resize(2);
			mutagen_recipes[recipe_index].requiredIngredients[0].itemName = 'Alcohest';
			mutagen_recipes[recipe_index].requiredIngredients[0].quantity = 1;
			mutagen_recipes[recipe_index].requiredIngredients[1].quantity = 3;
		}
		mutagen_recipes[0].requiredIngredients[1].itemName = 'Lesser mutagen red';
		mutagen_recipes[1].requiredIngredients[1].itemName = 'Lesser mutagen green';
		mutagen_recipes[2].requiredIngredients[1].itemName = 'Lesser mutagen blue';
		mutagen_recipes[3].requiredIngredients[1].itemName = 'Lesser mutagen yellow';
		mutagen_recipes[4].requiredIngredients[1].itemName = 'Mutagen red';
		mutagen_recipes[5].requiredIngredients[1].itemName = 'Mutagen green';
		mutagen_recipes[6].requiredIngredients[1].itemName = 'Mutagen blue';
		mutagen_recipes[7].requiredIngredients[1].itemName = 'Mutagen yellow';
	}


	private function InitializeReusableIngredients() : void
	{
		var mutagens	: array<name>;
		var i			: int;
		
		reusables.Clear();
		ing_mngr.GetMutagens(mutagens);
		for (i = mutagens.Size() - 1; i >= 0; i -= 1)
		{	if (!ing_mngr.IsPlainMutagen(mutagens[i]) )
				reusables.PushBack(S_ReusableIngredient(mutagen_uses, mutagen_uses, mutagens[i]) );
		}
		reusables.PushBack(S_ReusableIngredient(alcohol_uses, alcohol_uses, 'Alcohest') );
		reusables.PushBack(S_ReusableIngredient(alcohol_uses + 1, alcohol_uses + 1, 'White Gull 1') );
		reusables.PushBack(S_ReusableIngredient(2147483647, 2147483647, 'Soltis Vodka') );
	}
}

function SpectreAlchemyInitialize(game : CR4Game) : void
{
	if (!game.alchexts)
	{	game.alchexts = new SpectreAlchemyExtensions in game; //access through 'theGame' is restricted.
		game.alchexts.Initialize();
	}
	game.alchexts.herbctrl.OnGameLoading(game.alchexts.herbs, game.alchexts.ignore_spawns);
}

function NonZeroRound(val : float) : float
{
	var half	: float = (0.5f * (int)(val > 0) ) + (-0.5f * (int)(val < 0) );
	var tmp		: float = (int)(val + half);

	if (tmp)
		return (tmp);
	return (val);
}

class spectreAbilityManager extends W3PlayerAbilityManager
{
	public saved var manticore_bonus	: bool;
	private saved var skills_initd		: bool;
	private var passive_skills			: array<ESkill>; //Alchemy skills the behavior of which has been changed by the mod.
	private var active_skills			: array<ESkill>; //Other skills that are affected by the mod in some manner but aren't alchemy skills, and retain their vanilla 'equip to use' behavior.
	private var player					: W3PlayerWitcher;
	private var	alchexts				: SpectreAlchemyExtensions;



	public function Init(ownr : CActor, cStats : CCharacterStats, isFromLoad : bool, diff : EDifficultyMode) : bool
	{
		super.Init(ownr, cStats, isFromLoad, diff);
		player = (W3PlayerWitcher)ownr;
		alchexts = theGame.alchexts;
		if (skills_initd)
		{	VerifySkills();
			RefreshSkillsEffects();
		}
		return (true);
	}


	public final function PostInit()
	{
		super.PostInit();
		if (!skills_initd)
		{	player.ForceSetStat(BCS_Toxicity, 0);
			player.RemoveAllPotionEffects();
			RefreshSkillList();
			RevertSkills();
			ModSkills();
			skills_initd = true;
		}
		if (GetStat(BCS_Toxicity) && !owner.HasBuff(EET_Toxicity) )
			owner.AddEffectDefault(EET_Toxicity, owner, 'toxicity_change');
	}


	public function Construct(abm : W3PlayerAbilityManager) : void
	{
		owner = abm.owner;
		skills = abm.skills;
		tempSkills = abm.tempSkills;
		skillSlots = abm.GetSkillSlots();
		skillAbilities = abm.skillAbilities;
		blockedAbilities = abm.blockedAbilities;
		difficultyAbilities = abm.difficultyAbilities;
		totalSkillSlotsCount = abm.GetSkillSlotsCount();
		temporaryTutorialSkills = abm.temporaryTutorialSkills;
		mutations = abm.GetMutations();
		mutagenBonuses = abm.mutagenBonuses;
		mutagenSlots = abm.GetPlayerSkillMutagens();
		isMutationSystemEnabled = abm.IsMutationSystemEnabled();
		mutationUnlockedSlotsIndexes = abm.mutationUnlockedSlotsIndexes;
		mutationSkillSlotsInitialized = abm.mutationSkillSlotsInitialized;
		ignoresDifficultySettings = abm.ignoresDifficultySettings;
		pathPointsSpent = abm.pathPointsSpent;	
		resistStatsItems = abm.resistStatsItems;
		usedDifficultyMode = abm.usedDifficultyMode;
		usedHealthType = abm.usedHealthType;
		isInitialized = abm.isInitialized;
		charStats = abm.charStats;
	}


	public function AddSkill(skill : ESkill, isTemporary : bool)
	{
		var path			: ESkillPath;
		var unlocked, i		: int;
		var uiStateCharDev	: W3TutorialManagerUIHandlerStateCharacterDevelopment;
		
		if (IsSkillUsedByMod(skill) )
		{	if (skills[skill].level >= skills[skill].maxLevel)
				return;
			skills[skill].level += 1;
			skills[skill].isTemporary = isTemporary;
			if (!skills[skill].isCoreSkill)
				pathPointsSpent[skills[skill].skillPath] += 1;
			if (!isTemporary)
			{	((W3PlayerWitcher)owner).levelManager.SpendPoints(ESkillPoint, skills[skill].cost);
				path = skills[skill].skillPath;
				for (;i < skills.Size(); i += 1)
				{	if (skills[i].skillPath != path)
						continue ;
					unlocked += (int)(bool)skills[i].level;
				}
				if (unlocked >= 4)
					theGame.GetGamerProfile().AddAchievement(EA_Dendrology);
			}
			if (!active_skills.Contains(skill) )
				UpdateSkillEffects(skill, skills[skill].level);
			if (ShouldProcessTutorial('TutorialCharDevBuySkill') )
			{	uiStateCharDev = (W3TutorialManagerUIHandlerStateCharacterDevelopment)
				theGame.GetTutorialSystem().uiHandler.GetCurrentState();
				if (uiStateCharDev)
					uiStateCharDev.OnBoughtSkill(skill);
			}
		}
		else super.AddSkill(skill, isTemporary);
	}
	

	public function EquipSkill(skill : ESkill, slotID : int) : bool
	{
		var idx			: int;
		var prevColor	: ESkillColor;
		
		if (!IsSkillUsedByMod(skill) )
			return (super.EquipSkill(skill, slotID) );
		idx = GetSkillSlotIndex(slotID, true);		
		if (idx > -1)
		{	prevColor = GetSkillGroupColor(skillSlots[idx].groupID);
			UnequipSkill(slotID);
			skillSlots[idx].socketedSkill = skill;
			LinkUpdate(GetSkillGroupColor(skillSlots[idx].groupID), prevColor);
			if (CanUseSkill(S_Alchemy_s19) )
				MutagensSyngergyBonusUpdate(skillSlots[idx].groupID, skills[S_Alchemy_s19].level);
			theGame.GetGamerProfile().CheckTrialOfGrasses();
			if (active_skills.Contains(skill) )
				UpdateSkillEffects(skill);
			if (ShouldProcessTutorial('TutorialCharDevEquipSkill') )
			{	((W3TutorialManagerUIHandlerStateCharacterDevelopment)
					theGame.GetTutorialSystem().uiHandler.GetCurrentState() ).EquippedSkill();
			}
			return (true);
		}
		return (false);
	}
	
	
	public function UnequipSkill(slotID : int) : bool
	{
		var idx			: int;
		var skill		: ESkill;
		var prevColor	: ESkillColor;
	
		idx = GetSkillSlotIndex(slotID, true);
		skill = skillSlots[idx].socketedSkill;
		if (idx < 0 || skill == S_SUndefined)
			return (false);
		if (!IsSkillUsedByMod(skill) )
			return (super.UnequipSkill(slotID) );
		skillSlots[idx].socketedSkill = S_SUndefined;
		if (active_skills.Contains(skill) )
			UpdateSkillEffects(skill);
		prevColor = GetSkillGroupColor(skillSlots[idx].groupID);
		LinkUpdate(GetSkillGroupColor(skillSlots[idx].groupID), prevColor);
		if (CanUseSkill(S_Alchemy_s19) )
			MutagensSyngergyBonusUpdate(skillSlots[idx].groupID, skills[S_Alchemy_s19].level);
		return (true);
	}
	

	//Dominus' synergy skill fix, moved here to avoid merge conflicts in playerAbilityManager
	public function OnSkillMutagenUnequipped
	(out item : SItemUniqueId, slot : EEquipmentSlots, prevColor : ESkillColor, optional dontMerge : bool)
	{
		var i : int = mutagenSlots.Size() - 1;
		var newColor : ESkillColor;
		var ids : array< SItemUniqueId >;
		var itemName : name;
		
		while (i >= 0 && slot != mutagenSlots[i].equipmentSlot)
			i -= 1;
		if (i < 0)
			return;
		mutagenSlots[i].item = GetInvalidUniqueId();
		newColor = GetSkillGroupColor(mutagenSlots[i].skillGroupID);
		LinkUpdate(newColor, prevColor);
		if (CanUseSkill(S_Alchemy_s19) )
			MutagensSyngergyBonusUpdate(mutagenSlots[i].skillGroupID, GetSkillLevel(S_Alchemy_s19) );
		theGame.GetGuiManager().IgnoreNewItemNotifications(true);
		itemName = thePlayer.inv.GetItemName(item);
		thePlayer.inv.RemoveItem(item);
		ids = thePlayer.inv.AddAnItem(itemName, 1, true, true);
		item = ids[0];
		theGame.GetGuiManager().IgnoreNewItemNotifications(false);
	}


	public function CanUseSkill(skill : ESkill) : bool
	{
		return (!IsSkillUsedByMod(skill) && super.CanUseSkill(skill) );
	}

	public function IsSkillEquipped(skill : ESkill) : bool
	{
		if (passive_skills.Contains(skill) )
			return (skills[skill].level > 0);
		return (super.IsSkillEquipped(skill) );
	}

	
	public function ReplaceSkillTooltip(tooltip, description : string, skill : ESkill, lvl : int) : string
	{
		var args : array<int>;
		
		if (!IsSkillUsedByMod(skill) )
			skill = S_SUndefined;
		switch (skill)
		{	case S_Alchemy_s01:	//Half-Life
				args.PushBack((int)((100.f * (HALF_LIFE_MOD + lvl * ROUNDING_MOD) ) * lvl) );
			break ;
			case S_Alchemy_s02:	//Catalysis
				args.PushBack((int)(100.f * CATALYSIS_MOD) * lvl);
			break ;
			case S_Alchemy_s03:	//Equilibrium
				args.PushBack((int)(100.f * EQUILIBRIUM_TOX_MOD) * lvl);
				args.PushBack((int)(100.f * EQUILIBRIUM_DUR_MOD) * lvl);
			break ;
			case S_Alchemy_s04:	//Alembic
				args.PushBack((int)(100.f * ALEMBIC_MOD) * lvl);
				args.PushBack((int)(100.f * ALEMBIC_MOD2) * lvl);
			break ;
			case S_Alchemy_s13:	//Mitogenesis
				args.PushBack(MITOGENESIS_BASE * lvl);
			break ;
			case S_Alchemy_s14: //Proficiency
				args.PushBack((int)PowF(PROFICIENCY_MOD, lvl) );
			break ;
			case S_Alchemy_s15:	//Metastasis
				args.PushBack(METASTASIS_BASE * lvl);
			break ;
			case S_Alchemy_s17:	//Autophagy
				args.PushBack((int)(100.f * AUTOPHAGY_MOD) * lvl);
			break ;
			case S_Alchemy_s18:	//Angiogenesis
				args.PushBack(ANGIOGENESIS_BASE * lvl);
			break ;
			case S_Alchemy_s20:	//Adaptation
				args.PushBack((int)(100.f * ADAPTATION_MOD) * lvl);
			break ;
			case S_Perk_12:
				args.PushBack(PERK12_BASE);
			break ;
			case S_Perk_13:
				args.PushBack((int)(PERK13_MOD * 100.f) );
			break ;
			default:
				return (tooltip);
		}
		return (GetLocStringByKeyExtWithParams(description, args) );
	}


	public function ApplyHeightenedReflexes(attacker : CActor) : bool
	{
		var player : W3PlayerWitcher = GetWitcherPlayer();

		if (player && (player.IsActionAllowed(EIAB_Dodge) || player.IsActionAllowed(EIAB_Roll) )
		&& skills[S_Alchemy_s16].level && attacker.GetTarget() == player)
		{	player.StartFrenzy();
			return (true);
		}
		return (false);
	}


	public function UpdateManticoreBonus(set : EItemSetType, enable : bool) : void
	{
		if (set == EIST_RedWolf)
		{	if (enable)
				alchexts.toxicity_dmg_modifier -= 0.1f * (int)!manticore_bonus;
			else alchexts.toxicity_dmg_modifier += 0.1f * (int)manticore_bonus;
			manticore_bonus = enable;
		}
	}


	public function ResetAlchemySkills() : void
	{
		var size			: int;
		var i, skillpoints	: int;
		var default_skills	: array<SSkill>;
		var skill			: ESkill;
		
		player.UnequipItemFromSlot(EES_SkillMutagen1);
		player.UnequipItemFromSlot(EES_SkillMutagen2);
		player.UnequipItemFromSlot(EES_SkillMutagen3);
		player.UnequipItemFromSlot(EES_SkillMutagen4);
		CacheSkills('GeraltSkills', default_skills);
		for (i = default_skills.Size() - 1; i >= 0; i -= 1)
		{	if (default_skills[i].skillPath != ESP_Alchemy || default_skills[i].isCoreSkill)
				continue ;
			skill = default_skills[i].skillType;
			if (GetIsSkillInSocket(skill) > -1)
			{	if (passive_skills.Contains(skill) )
					UnequipSkill(GetSkillSlotID(skill) );
				else super.UnequipSkill(GetSkillSlotID(skill) );
			}
			skillpoints += skills[skill].level;
			skills[skill] = default_skills[i];
		}
		pathPointsSpent[ESP_Alchemy] = 0;
		player.levelManager.AddPoints(ESkillPoint, skillpoints, false);
		charStats.RemoveAbilityAll('alchemy_potionduration');
	}


	public function RevertSkills() : void
	{
		var i	: int = active_skills.Size();
		var idx	: int;

		while (i)
		{	i -= 1;
			idx = GetIsSkillInSocket(active_skills[i]);
			if (idx > -1)
				super.UnequipSkill(skillSlots[idx].id);
		}
		ResetAlchemySkills();
		RefreshSkillsEffects();
	}


	public function NGEFixSkillPoints() : void
	{
		super.NGEFixSkillPoints(); //version-diff
		ModSkills();
	}

	public function GetMutagenDiscoveryChance() : int
	{
		return ((int)(skills[S_Alchemy_s04].level * ALEMBIC_MOD2 * 100.f) );
	}


	public function ResetCharacterDev() : void
	{
		super.ResetCharacterDev();
		VerifySkills();
		RefreshSkillsEffects();
	}


	public function Update(player : W3PlayerWitcher, initialize : bool) : void
	{
		skills_initd = false;
		if (initialize)
			Init(player, player.GetCharacterStats(), true, theGame.GetSpawnDifficultyMode() );
	}


	private function GetIsSkillInSocket(skill : ESkill) : int
	{
		var i : int = skillSlots.Size();

		while (i)
		{	i -= 1;
			if (skillSlots[i].socketedSkill != skill)
				continue ;
			return (i);
		}
		return (-1);
	}


	private function IsSkillUsedByMod(skill : ESkill) : bool
	{
		return (passive_skills.Contains(skill) || active_skills.Contains(skill) );
	}


	private function RefreshSkillList() : void
	{
		passive_skills.Clear();
		passive_skills.PushBack(S_Alchemy_s01);
		passive_skills.PushBack(S_Alchemy_s02);
		passive_skills.PushBack(S_Alchemy_s03);
		passive_skills.PushBack(S_Alchemy_s04);
		passive_skills.PushBack(S_Alchemy_s13);
		passive_skills.PushBack(S_Alchemy_s14);
		passive_skills.PushBack(S_Alchemy_s15);
		passive_skills.PushBack(S_Alchemy_s16);
		passive_skills.PushBack(S_Alchemy_s17);
		passive_skills.PushBack(S_Alchemy_s18);
		passive_skills.PushBack(S_Alchemy_s20);
		active_skills.Clear();
		active_skills.PushBack(S_Perk_12);
		active_skills.PushBack(S_Perk_13);
	}


	private function ModSkills() : void
	{
		var ability	: name;
		var i		: int;

		if (!passive_skills.Size() )
			RefreshSkillList();
		for (i = passive_skills.Size() - 1; i >= 0; i -= 1)
		{	ability = SkillEnumToName(passive_skills[i]);
			charStats.RemoveAbilityAll(ability);
			ChangeSkillData(passive_skills[i]);
		}
		SwapSkillPosition(S_Alchemy_s14, S_Alchemy_s18);
		SwapSkillPosition(S_Alchemy_s18, S_Alchemy_s19);
		SwapSkillPosition(S_Alchemy_s13, S_Alchemy_s18);
	}


	private function ChangeSkillData(skill : ESkill)
	{
		switch (skill)
		{	case S_Alchemy_s01:
				skills[skill].localisationNameKey = "spectre_skill_alchemy1";
				skills[S_Alchemy_s01].localisationDescriptionKey = "spectre_descr_alchemy1";
				skills[S_Alchemy_s01].localisationDescriptionLevel2Key = "spectre_descr_alchemy1";
				skills[S_Alchemy_s01].localisationDescriptionLevel3Key = "spectre_descr_alchemy1";
				skills[S_Alchemy_s01].maxLevel = 10;
			break ;
			case S_Alchemy_s02:
				skills[S_Alchemy_s02].localisationNameKey = "spectre_skill_alchemy2";
				skills[S_Alchemy_s02].localisationDescriptionKey = "spectre_descr_alchemy2";
				skills[S_Alchemy_s02].localisationDescriptionLevel2Key = "spectre_descr_alchemy2";
				skills[S_Alchemy_s02].localisationDescriptionLevel3Key = "spectre_descr_alchemy2";
				skills[S_Alchemy_s02].maxLevel = 10;
			break ;
			case S_Alchemy_s03:
				skills[S_Alchemy_s03].localisationNameKey = "spectre_skill_alchemy3";
				skills[S_Alchemy_s03].localisationDescriptionKey = "spectre_descr_alchemy3";
				skills[S_Alchemy_s03].localisationDescriptionLevel2Key = "spectre_descr_alchemy3";
				skills[S_Alchemy_s03].localisationDescriptionLevel3Key = "spectre_descr_alchemy3";
				skills[S_Alchemy_s03].maxLevel = 10;
			break ;
			case S_Alchemy_s04:
				skills[S_Alchemy_s04].localisationNameKey = "spectre_skill_alchemy4";
				skills[S_Alchemy_s04].localisationDescriptionKey = "spectre_descr_alchemy4";
				skills[S_Alchemy_s04].localisationDescriptionLevel2Key = "spectre_descr_alchemy4";
				skills[S_Alchemy_s04].localisationDescriptionLevel3Key = "spectre_descr_alchemy4";
				skills[S_Alchemy_s04].maxLevel = 10;
			break ;
			case S_Alchemy_s13:
				skills[S_Alchemy_s13].localisationNameKey = "spectre_skill_alchemy13";
				skills[S_Alchemy_s13].localisationDescriptionKey = "spectre_descr_alchemy13";
				skills[S_Alchemy_s13].localisationDescriptionLevel2Key = "spectre_descr_alchemy13";
				skills[S_Alchemy_s13].localisationDescriptionLevel3Key = "spectre_descr_alchemy13";
				skills[S_Alchemy_s13].maxLevel = 10;
			break ;
			case S_Alchemy_s14:
				skills[S_Alchemy_s14].localisationNameKey = "spectre_skill_alchemy14";
				skills[S_Alchemy_s14].localisationDescriptionKey = "spectre_descr_alchemy14";
				skills[S_Alchemy_s14].localisationDescriptionLevel2Key = "spectre_descr_alchemy14";
				skills[S_Alchemy_s14].localisationDescriptionLevel3Key = "spectre_descr_alchemy14";
				skills[S_Alchemy_s14].iconPath = "icons\Perks\s_perk_29.png";
				skills[S_Alchemy_s14].maxLevel = 10;
			break ;
			case S_Alchemy_s15:
				skills[S_Alchemy_s15].localisationNameKey = "spectre_skill_alchemy15";
				skills[S_Alchemy_s15].localisationDescriptionKey = "spectre_descr_alchemy15";
				skills[S_Alchemy_s15].localisationDescriptionLevel2Key = "spectre_descr_alchemy15";
				skills[S_Alchemy_s15].localisationDescriptionLevel3Key = "spectre_descr_alchemy15";
				skills[S_Alchemy_s15].maxLevel = 10;
			break ;
			case S_Alchemy_s16:
				skills[S_Alchemy_s16].localisationNameKey = "spectre_skill_alchemy16";
				skills[S_Alchemy_s16].localisationDescriptionKey = "spectre_descr_alchemy16_1";
				skills[S_Alchemy_s16].localisationDescriptionLevel2Key = "spectre_descr_alchemy16_2";
				skills[S_Alchemy_s16].localisationDescriptionLevel3Key = "spectre_descr_alchemy16_3";
				skills[S_Alchemy_s16].maxLevel = 10;
			break ;
			case S_Alchemy_s17:
				skills[S_Alchemy_s17].localisationNameKey = "spectre_skill_alchemy17";
				skills[S_Alchemy_s17].localisationDescriptionKey = "spectre_descr_alchemy17";
				skills[S_Alchemy_s17].localisationDescriptionLevel2Key = "spectre_descr_alchemy17";
				skills[S_Alchemy_s17].localisationDescriptionLevel3Key = "spectre_descr_alchemy17";
				skills[S_Alchemy_s17].maxLevel = 10;
			break ;
			case S_Alchemy_s18:
				skills[S_Alchemy_s18].localisationNameKey = "spectre_skill_alchemy18";
				skills[S_Alchemy_s18].localisationDescriptionKey = "spectre_descr_alchemy18";
				skills[S_Alchemy_s18].localisationDescriptionLevel2Key = "spectre_descr_alchemy18";
				skills[S_Alchemy_s18].localisationDescriptionLevel3Key = "spectre_descr_alchemy18";
				skills[S_Alchemy_s18].iconPath = "icons\Perks\s_perk_7.png";
				skills[S_Alchemy_s18].maxLevel = 10;
			break ;
			case S_Alchemy_s20:
				skills[S_Alchemy_s20].localisationNameKey = "spectre_skill_alchemy20";
				skills[S_Alchemy_s20].localisationDescriptionKey = "spectre_descr_alchemy20";
				skills[S_Alchemy_s20].localisationDescriptionLevel2Key = "spectre_descr_alchemy20";
				skills[S_Alchemy_s20].localisationDescriptionLevel3Key = "spectre_descr_alchemy20";
				skills[S_Alchemy_s20].maxLevel = 10;
			break ;
		}
	}
	

	private function SwapSkillPosition(skill1, skill2 : ESkill) : void
	{
		skills[skill1].requiredPointsSpent = skills[skill1].requiredPointsSpent ^ skills[skill2].requiredPointsSpent;
		skills[skill2].requiredPointsSpent = skills[skill2].requiredPointsSpent ^ skills[skill1].requiredPointsSpent;
		skills[skill1].requiredPointsSpent = skills[skill1].requiredPointsSpent ^ skills[skill2].requiredPointsSpent;
		skills[skill1].positionID = skills[skill1].positionID ^ skills[skill2].positionID;
		skills[skill2].positionID = skills[skill2].positionID ^ skills[skill1].positionID;
		skills[skill1].positionID = skills[skill1].positionID ^ skills[skill2].positionID;
	}


	private function RefreshSkillsEffects() : void
	{
		var i : int;
		
		if (!passive_skills.Size() )
			RefreshSkillList();
		for (i = passive_skills.Size() - 1; i >= 0; i -= 1)
			UpdateSkillEffects(passive_skills[i], skills[passive_skills[i]].level);
	}


	private function VerifySkills() : void
	{
		if (StrCmp(skills[S_Alchemy_s01].localisationNameKey, "spectre_skill_alchemy1") )
			ModSkills();
	}
	

	private const var HALF_LIFE_MOD			: float; default HALF_LIFE_MOD = 0.33f;
	private const var EQUILIBRIUM_DUR_MOD	: float; default EQUILIBRIUM_DUR_MOD = 0.25f;
	private const var EQUILIBRIUM_TOX_MOD	: float; default EQUILIBRIUM_TOX_MOD = 0.10f;
	private const var CATALYSIS_MOD			: float; default CATALYSIS_MOD = 0.25f;
	private const var ALEMBIC_MOD			: float; default ALEMBIC_MOD = 0.25f;
	private const var ALEMBIC_MOD2			: float; default ALEMBIC_MOD2 = 0.05f;
	private const var AUTOPHAGY_MOD			: float; default AUTOPHAGY_MOD = 0.5f;
	private const var ADAPTATION_MOD		: float; default ADAPTATION_MOD = 0.18f;
	private const var PERK13_MOD			: float; default PERK13_MOD = 0.33f;
	private const var METASTASIS_BASE		: int; default METASTASIS_BASE = 10;
	private const var ANGIOGENESIS_BASE		: int; default ANGIOGENESIS_BASE = 5;
	private const var MITOGENESIS_BASE		: int; default MITOGENESIS_BASE = 4;
	private const var PROFICIENCY_MOD		: int; default PROFICIENCY_MOD = 2;
	private const var PERK12_BASE			: int; default PERK12_BASE = 15;
	private const var ROUNDING_MOD			: float; default ROUNDING_MOD = 0.002f;

	private function UpdateSkillEffects(skill : ESkill, optional lvl : int)
	{
		switch (skill)
		{	case S_Alchemy_s01:
				alchexts.internal_duration_multiplier = CalcPotionDurationMultiplier();
			break ;
			case S_Alchemy_s02:
				alchexts.digestion_modifier = CalcPotionDigestionModifier();
			break ;
			case S_Alchemy_s03:
				alchexts.skill_toxicity_modifier = (1.f - EQUILIBRIUM_TOX_MOD * lvl);
				alchexts.internal_duration_multiplier = CalcPotionDurationMultiplier();
			break ;
			case S_Alchemy_s04:
				alchexts.yield_modifier = 1.f + lvl * ALEMBIC_MOD;
			break ;
			case S_Alchemy_s13:
		 		charStats.RemoveAbilityAll('Mitogenesis');
		 		charStats.AddAbilityMultiple('Mitogenesis', MITOGENESIS_BASE * lvl);
			break ;
			case S_Alchemy_s14:
				alchexts.mutagen_uses = (int)PowF(PROFICIENCY_MOD, lvl);
				alchexts.UpdateReusableIngredients(, true);
			break ;
			case S_Alchemy_s15:
		 		charStats.RemoveAbilityAll('Metastasis');
				charStats.AddAbilityMultiple('Metastasis', METASTASIS_BASE * lvl);
			break ;
 			case S_Alchemy_s16: //implementation remains in playerwitcher.ws. TODO: move here.
			break ;
			case S_Alchemy_s17:
				alchexts.toxicity_degen_modifier = CalcToxDegenModifier();
			break ;
			case S_Alchemy_s18:
		 		charStats.RemoveAbilityAll('Angiogenesis');
				charStats.AddAbilityMultiple('Angiogenesis', ANGIOGENESIS_BASE * lvl);
			break ;
			case S_Alchemy_s20:
				alchexts.toxicity_dmg_modifier = 1.f - ADAPTATION_MOD * lvl;
			break ;
			case S_Perk_12:
				charStats.RemoveAbilityAll('alchemy_s18');
				charStats.AddAbilityMultiple('alchemy_s18', PERK12_BASE * 2); //HACK! version-diff
			break ;
			case S_Perk_13:
				alchexts.digestion_modifier = CalcPotionDigestionModifier();
				alchexts.toxicity_degen_modifier = CalcToxDegenModifier();
				alchexts.internal_duration_multiplier = CalcPotionDurationMultiplier();
			break ;
			default:
			break ;
		}
	}

	private function CalcPotionDurationMultiplier() : float
	{
		return (MaxF(0.1f, 1.f + 
			((HALF_LIFE_MOD + skills[S_Alchemy_s01].level * ROUNDING_MOD) * skills[S_Alchemy_s01].level) -
			(EQUILIBRIUM_DUR_MOD * skills[S_Alchemy_s03].level) -
			((float)(GetIsSkillInSocket(S_Perk_13) > -1) * PERK13_MOD) ) );
	}

	private function CalcPotionDigestionModifier() : float
	{
		return (MaxF(0.1f, 1.f - 
			(CATALYSIS_MOD * skills[S_Alchemy_s02].level + (float)(GetIsSkillInSocket(S_Perk_13) > -1) * PERK13_MOD) ) );
	}

	private function CalcToxDegenModifier() : float
	{
		return (1.f + (AUTOPHAGY_MOD * skills[S_Alchemy_s17].level) +
			((float)(GetIsSkillInSocket(S_Perk_13) > -1) * PERK13_MOD) );
	}

}

class ProgrammingHorrors extends IngredientManager
{
	public function BringFrankensteinToLife()
	{
		primary.PushBack('Aether');
		primary.PushBack('Rebis');
		primary.PushBack('Vitriol');
		primary.PushBack('Quebrith');
		primary.PushBack('Hydragenum');
		primary.PushBack('Vermilion');
		rich.PushBack('Calcium equum');
		rich.PushBack('Fifth essence');
		rich.PushBack('Lunar shards');
		rich.PushBack('Optima mater');
		rich.PushBack('Phosphorus');
		rich.PushBack('Quicksilver solution');
		rich.PushBack('Sulfur');
		rich.PushBack('Wine stone');
		rich.PushBack('Diamond dust');
		rich.PushBack('Leshy resin');
		rich.PushBack('Alghoul bone marrow');
		rich.PushBack('Alghoul claw');
		rich.PushBack('Gargoyle dust');
		rich.PushBack('Grave Hag ear');
		rich.PushBack('Cockatrice egg');
		rich.PushBack('Gryphon egg');
		rich.PushBack('Wyvern egg');
		rich.PushBack('Crystalized essence');
		rich.PushBack('Elemental essence');
		rich.PushBack('Nightwraith dark essence');
		rich.PushBack('Wraith essence');
		rich.PushBack('Arachas eyes');
		rich.PushBack('Cyclops eye');
		rich.PushBack('Fiend eye');
		rich.PushBack('Lamia lock of hair');
		rich.PushBack('Nightwraiths hair');
		rich.PushBack('Gargoyle heart');
		rich.PushBack('Golem heart');
		rich.PushBack('Necrophage skin');
		rich.PushBack('Troll skin');
		rich.PushBack('Werewolf pelt');
		rich.PushBack('Ekimma epidermis');
		rich.PushBack('Berserker pelt');
		rich.PushBack('Czart hide');
		rich.PushBack('Cave Troll liver');
		rich.PushBack('Basilisk plate');
		rich.PushBack('Forktail plate');
		rich.PushBack('Wyvern plate');
		rich.PushBack('Vampire saliva');
		rich.PushBack('Werewolf saliva');
		rich.PushBack('Cockatrice maw');
		rich.PushBack('Fogling teeth');
		rich.PushBack('Water Hag teeth');
		rich.PushBack('Vampire fang');
		rich.PushBack('Basilisk venom');
		rich.PushBack('Siren vocal cords');
		rich.PushBack('Centipede discharge');
		rich.PushBack('Kikimore discharge');
		rich.PushBack('Vampire blood');
		rich.PushBack('Barghest essence');
		rich.PushBack('Centipede mandible');
		rich.PushBack('Dracolizard plate');
		rich.PushBack('Archespore juice');
		rich.PushBack('Mistletoe');
		rich.PushBack('Buckthorn');
		rich.PushBack('Winter cherry');
		rich.PushBack('Holy basil');
		rich.PushBack('Blue lotus');
		rich.PushBack('Wight hair');
		poor.PushBack('Balisse fruit');
		poor.PushBack('Beggartick blossoms');
		poor.PushBack('Blowbill');
		poor.PushBack('Celandine');
		poor.PushBack('Ginatia petals');
		poor.PushBack('Han');
		poor.PushBack('Hellebore petals');
		poor.PushBack('Hop umbels');
		poor.PushBack('Moleyarrow');
		poor.PushBack('Ribleaf');
		poor.PushBack('Sewant mushrooms');
		poor.PushBack('White myrtle');
		poor.PushBack('Wolfsbane');
		top.PushBack('Alcohest');
		top.PushBack('White Gull 1');
		top.PushBack('Alchemical paste');
		top.PushBack('Alchemists powder');
		top.PushBack('Greater mutagen red');
		top.PushBack('Greater mutagen green');
		top.PushBack('Greater mutagen blue');
		top.PushBack('Katakan mutagen');
		top.PushBack('Volcanic Gryphon mutagen');
		top.PushBack('Water Hag mutagen');
		top.PushBack('Wyvern mutagen');
		top.PushBack('Doppler mutagen');
		top.PushBack('Succubus mutagen');
		top.PushBack('Fogling 2 mutagen');
		top.PushBack('Werewolf mutagen');
		top.PushBack('Nekker Warrior mutagen');
		top.PushBack('Arachas mutagen');
		top.PushBack('Gryphon mutagen');
		top.PushBack('Nightwraith mutagen');
		top.PushBack('Ekimma mutagen');
		top.PushBack('Troll mutagen');
		top.PushBack('Noonwraith mutagen');
		top.PushBack('Fiend mutagen');
		top.PushBack('Grave Hag mutagen');
		top.PushBack('Wraith mutagen');
		top.PushBack('Cockatrice mutagen');
		top.PushBack('Czart mutagen');
		top.PushBack('Fogling 1 mutagen');
		top.PushBack('Forktail mutagen');
		top.PushBack('Dao mutagen');
		top.PushBack('Lamia mutagen');
		top.PushBack('Ancient Leshy mutagen');
		top.PushBack('Basilisk mutagen');
		top.PushBack('Leshy mutagen');
		high.PushBack('Cherry Cordial');
		high.PushBack('Dwarven spirit');
		high.PushBack('Mandrake cordial');
		high.PushBack('Soltis Vodka');
		high.PushBack('Bear fat');
		high.PushBack('Stammelfords dust');
		high.PushBack('Mutagen red');
		high.PushBack('Mutagen green');
		high.PushBack('Mutagen blue');
		standard.PushBack('Mahakam Spirit');
		standard.PushBack('Nilfgaardian Lemon');
		standard.PushBack('Redanian Herbal');
		standard.PushBack('Temerian Rye');
		standard.PushBack('Free nilfgaardian lemon');
		standard.PushBack('Dog tallow');
		standard.PushBack('Saltpetre');
		albedo.PushBack('Bison Grass');
		albedo.PushBack('Bloodmoss');
		albedo.PushBack('Honeysuckle');
		albedo.PushBack('Hornwort');
		albedo.PushBack('Longrube');
		albedo.PushBack('Nostrix');
		albedo.PushBack('Ranogrin');
		albedo.PushBack('Fifth essence');
		albedo.PushBack('Wine stone');
		albedo.PushBack('Drowner brain');
		albedo.PushBack('Harpy talon');
		albedo.PushBack('Specter dust');
		albedo.PushBack('Cockatrice egg');
		albedo.PushBack('Elemental essence');
		albedo.PushBack('Erynie eye');
		albedo.PushBack('Cyclops eye');
		albedo.PushBack('Fiend eye');
		albedo.PushBack('Gryphon feathers');
		albedo.PushBack('Lamia lock of hair');
		albedo.PushBack('Nekker warrior liver');
		albedo.PushBack('Cockatrice maw');
		albedo.PushBack('Water Hag teeth');
		albedo.PushBack('Siren vocal cords');
		albedo.PushBack('Dracolizard plate');
		albedo.PushBack('Archespore tendril');
		albedo.PushBack('Blue lotus');
		albedo.PushBack('Wight hair');
		rubedo.PushBack('Arenaria');
		rubedo.PushBack('Balisse fruit');
		rubedo.PushBack('Cortinarius');
		rubedo.PushBack('Ergot seeds');
		rubedo.PushBack('Green mold');
		rubedo.PushBack('Calcium equum');
		rubedo.PushBack('Lunar shards');
		rubedo.PushBack('Optima mater');
		rubedo.PushBack('Leshy resin');
		rubedo.PushBack('Harpy egg');
		rubedo.PushBack('Endriag embryo');
		rubedo.PushBack('Noonwraith light essence');
		rubedo.PushBack('Water essence');
		rubedo.PushBack('Arachas eyes');
		rubedo.PushBack('Golem heart');
		rubedo.PushBack('Ekimma epidermis');
		rubedo.PushBack('Berserker pelt');
		rubedo.PushBack('Cave Troll liver');
		rubedo.PushBack('Basilisk plate');
		rubedo.PushBack('Vampire saliva');
		rubedo.PushBack('Werewolf saliva');
		rubedo.PushBack('Fogling teeth');
		rubedo.PushBack('Hag teeth');
		rubedo.PushBack('Vampire fang');
		rubedo.PushBack('Vampire blood');
		rubedo.PushBack('Centipede mandible');
		rubedo.PushBack('Winter cherry');
		rubedo.PushBack('Wight ear');
		nigredo.PushBack('Allspice root');
		nigredo.PushBack('Bryonia');
		nigredo.PushBack('Mandrake root');
		nigredo.PushBack('Ducal water');
		nigredo.PushBack('Phosphorus');
		nigredo.PushBack('Quicksilver solution');
		nigredo.PushBack('Diamond dust');
		nigredo.PushBack('Ghoul blood');
		nigredo.PushBack('Rotfiend blood');
		nigredo.PushBack('Greater Rotfiend blood');
		nigredo.PushBack('Alghoul bone marrow');
		nigredo.PushBack('Grave Hag ear');
		nigredo.PushBack('Gryphon egg');
		nigredo.PushBack('Nightwraith dark essence');
		nigredo.PushBack('Nekker eye');
		nigredo.PushBack('Nekker heart');
		nigredo.PushBack('Troll skin');
		nigredo.PushBack('Werewolf pelt');
		nigredo.PushBack('Forktail plate');
		nigredo.PushBack('Wyvern plate');
		nigredo.PushBack('Arachas venom');
		nigredo.PushBack('Basilisk venom');
		nigredo.PushBack('Centipede discharge');
		nigredo.PushBack('Kikimore discharge');
		nigredo.PushBack('Barghest essence');
		nigredo.PushBack('Holy basil');
		vitriol.PushBack('Balisse fruit');
		vitriol.PushBack('Bloodmoss');
		vitriol.PushBack('Crows eye');
		vitriol.PushBack('Ribleaf');
		vitriol.PushBack('Sewant mushrooms');
		vitriol.PushBack('White myrtle');
		vitriol.PushBack('Calcium equum');
		vitriol.PushBack('Vitriol');
		vitriol.PushBack('Ghoul blood');
		vitriol.PushBack('Leshy resin');
		vitriol.PushBack('Alghoul claw');
		vitriol.PushBack('Nekker eye');
		vitriol.PushBack('Erynie eye');
		vitriol.PushBack('Werewolf pelt');
		vitriol.PushBack('Cave Troll liver');
		vitriol.PushBack('Wyvern plate');
		vitriol.PushBack('Siren vocal cords');
		vitriol.PushBack('Vampire blood');
		vitriol.PushBack('Archespore tendril');
		vitriol.PushBack('Archespore juice');
		vitriol.PushBack('Blue lotus');
		rebis.PushBack('Blowbill');
		rebis.PushBack('Celandine');
		rebis.PushBack('Green mold');
		rebis.PushBack('Han');
		rebis.PushBack('Hop umbels');
		rebis.PushBack('Lunar shards');
		rebis.PushBack('Rebis');
		rebis.PushBack('Wine stone');
		rebis.PushBack('Drowner brain');
		rebis.PushBack('Specter dust');
		rebis.PushBack('Wyvern egg');
		rebis.PushBack('Crystalized essence');
		rebis.PushBack('Nightwraith dark essence');
		rebis.PushBack('Arachas eyes');
		rebis.PushBack('Nekker heart');
		rebis.PushBack('Golem heart');
		rebis.PushBack('Arachas venom');
		rebis.PushBack('Barghest essence');
		rebis.PushBack('Holy basil');
		rebis.PushBack('Wight hair');
		rebis.PushBack('Sharley dust');
		aether.PushBack('Allspice root');
		aether.PushBack('Arenaria');
		aether.PushBack('Berbercane fruit');
		aether.PushBack('Ginatia petals');
		aether.PushBack('Hellebore petals');
		aether.PushBack('Hornwort');
		aether.PushBack('Pringrape');
		aether.PushBack('Aether');
		aether.PushBack('Quicksilver solution');
		aether.PushBack('Cockatrice egg');
		aether.PushBack('Gryphon egg');
		aether.PushBack('Water essence');
		aether.PushBack('Cyclops eye');
		aether.PushBack('Berserker pelt');
		aether.PushBack('Nekker warrior liver');
		aether.PushBack('Werewolf saliva');
		aether.PushBack('Drowned dead tongue');
		aether.PushBack('Cockatrice maw');
		quebrith.PushBack('Bison Grass');
		quebrith.PushBack('Fools parsley leaves');
		quebrith.PushBack('Honeysuckle');
		quebrith.PushBack('Mandrake root');
		quebrith.PushBack('Moleyarrow');
		quebrith.PushBack('Verbena');
		quebrith.PushBack('Wolf liver');
		quebrith.PushBack('Ducal water');
		quebrith.PushBack('Quebrith');
		quebrith.PushBack('Sulfur');
		quebrith.PushBack('Alghoul bone marrow');
		quebrith.PushBack('Grave Hag ear');
		quebrith.PushBack('Harpy egg');
		quebrith.PushBack('Endriag embryo');
		quebrith.PushBack('Fiend eye');
		quebrith.PushBack('Gargoyle heart');
		quebrith.PushBack('Vampire saliva');
		quebrith.PushBack('Hag teeth');
		quebrith.PushBack('Water Hag teeth');
		quebrith.PushBack('Centipede mandible');
		hydragenum.PushBack('Beggartick blossoms');
		hydragenum.PushBack('Cortinarius');
		hydragenum.PushBack('Mistletoe');
		hydragenum.PushBack('Nostrix');
		hydragenum.PushBack('Pigskin puffball');
		hydragenum.PushBack('Fifth essence');
		hydragenum.PushBack('Hydragenum');
		hydragenum.PushBack('Optima mater');
		hydragenum.PushBack('Diamond dust');
		hydragenum.PushBack('Rotfiend blood');
		hydragenum.PushBack('Nekker claw');
		hydragenum.PushBack('Harpy talon');
		hydragenum.PushBack('Noonwraith light essence');
		hydragenum.PushBack('Wraith essence');
		hydragenum.PushBack('Gryphon feathers');
		hydragenum.PushBack('Nightwraiths hair');
		hydragenum.PushBack('Endriag heart');
		hydragenum.PushBack('Czart hide');
		hydragenum.PushBack('Vampire fang');
		hydragenum.PushBack('Basilisk venom');
		hydragenum.PushBack('Dracolizard plate');
		vermilion.PushBack('Bryonia');
		vermilion.PushBack('Ergot seeds');
		vermilion.PushBack('Longrube');
		vermilion.PushBack('Ranogrin');
		vermilion.PushBack('Wolfsbane');
		vermilion.PushBack('Buckthorn');
		vermilion.PushBack('Phosphorus');
		vermilion.PushBack('Vermilion');
		vermilion.PushBack('Nekker blood');
		vermilion.PushBack('Greater Rotfiend blood');
		vermilion.PushBack('Gargoyle dust');
		vermilion.PushBack('Elemental essence');
		vermilion.PushBack('Harpy feathers');
		vermilion.PushBack('Lamia lock of hair');
		vermilion.PushBack('Necrophage skin');
		vermilion.PushBack('Troll skin');
		vermilion.PushBack('Ekimma epidermis');
		vermilion.PushBack('Basilisk plate');
		vermilion.PushBack('Forktail plate');
		vermilion.PushBack('Fogling teeth');
		vermilion.PushBack('Centipede discharge');
		vermilion.PushBack('Kikimore discharge');
		vermilion.PushBack('Winter cherry');
		vermilion.PushBack('Wight ear');
		red.PushBack('Greater mutagen red');
		red.PushBack('Mutagen red');
		red.PushBack('Lesser mutagen red');
		red.PushBack('Katakan mutagen');
		red.PushBack('Volcanic Gryphon mutagen');
		red.PushBack('Water Hag mutagen');
		red.PushBack('Wyvern mutagen');
		red.PushBack('Doppler mutagen');
		red.PushBack('Succubus mutagen');
		red.PushBack('Fogling 2 mutagen');
		red.PushBack('Werewolf mutagen');
		red.PushBack('Nekker Warrior mutagen');
		green.PushBack('Greater mutagen green');
		green.PushBack('Mutagen green');
		green.PushBack('Lesser mutagen green');
		green.PushBack('Arachas mutagen');
		green.PushBack('Gryphon mutagen');
		green.PushBack('Nightwraith mutagen');
		green.PushBack('Ekimma mutagen');
		green.PushBack('Troll mutagen');
		green.PushBack('Noonwraith mutagen');
		green.PushBack('Fiend mutagen');
		green.PushBack('Grave Hag mutagen');
		green.PushBack('Wraith mutagen');
		the_compiler_is_having_a_coronary();
	}	
	
	private function the_compiler_is_having_a_coronary()
	{
		blue.PushBack('Greater mutagen blue');
		blue.PushBack('Mutagen blue');
		blue.PushBack('Lesser mutagen blue');
		blue.PushBack('Cockatrice mutagen');
		blue.PushBack('Czart mutagen');
		blue.PushBack('Fogling 1 mutagen');
		blue.PushBack('Forktail mutagen');
		blue.PushBack('Dao mutagen');
		blue.PushBack('Lamia mutagen');
		blue.PushBack('Ancient Leshy mutagen');
		blue.PushBack('Basilisk mutagen');
		blue.PushBack('Leshy mutagen');
		plain.PushBack('Lesser mutagen red');
		plain.PushBack('Mutagen red');
		plain.PushBack('Greater mutagen red');
		plain.PushBack('Lesser mutagen green');
		plain.PushBack('Mutagen green');
		plain.PushBack('Greater mutagen green');
		plain.PushBack('Lesser mutagen blue');
		plain.PushBack('Mutagen blue');
		plain.PushBack('Greater mutagen blue');
		plain.PushBack('Lesser mutagen yellow');
		plain.PushBack('Mutagen yellow');
		plain.PushBack('Greater mutagen yellow');
		spirit.PushBack('Alcohest');
		spirit.PushBack('White Gull 1');
		spirit.PushBack('Soltis Vodka');
		spirit.PushBack('Dwarven spirit');
		spirit.PushBack('Temerian Rye');
		spirit.PushBack('Cherry Cordial');
		spirit.PushBack('Mandrake cordial');
		spirit.PushBack('Mahakam Spirit');
		spirit.PushBack('Nilfgaardian Lemon');
		spirit.PushBack('Redanian Herbal');
		catalyst.PushBack('Alchemists powder');
		catalyst.PushBack('Stammelfords dust');
		catalyst.PushBack('Saltpetre');
		solvent.PushBack('Alchemical paste');
		solvent.PushBack('Bear fat');
		solvent.PushBack('Dog tallow');
		base.PushBack('Alcohest');
		base.PushBack('White Gull 1');
		base.PushBack('Dwarven spirit');
		base.PushBack('Temerian Rye');
		base.PushBack('Cherry Cordial');
		base.PushBack('Mandrake cordial');
		base.PushBack('Mahakam Spirit');
		base.PushBack('Nilfgaardian Lemon');
		base.PushBack('Redanian Herbal');
		base.PushBack('Alchemists powder');
		base.PushBack('Stammelfords dust');
		base.PushBack('Saltpetre');
		base.PushBack('Alchemical paste');
		base.PushBack('Bear fat');
		base.PushBack('Dog tallow');
		container.PushBack('Bottle');
		container.PushBack('Empty vial');
		container.PushBack('Empty bottle');
	}
}

class spectreHerbController
{
	private var spawned			: array<S_SpawnData>;
	private var signature		: array<int>;
	private var areaname		: EAreaName;
	private var area_procd		: bool;
	private var removed			: int;
	private var minspawns		: int;
	private var maxspawns	 	: int;
	private var yield_min		: int;
	private var yield_max		: int;
	private var spawnchance		: float;
	private var spawns_disabled : bool;

	

	event OnGameLoading(settings : S_HerbSpawnSettings, optional ignore_spawns : bool) : void
	{
		minspawns = settings.min_s;
		maxspawns = settings.max_s;
		yield_min = settings.min_y;
		yield_max = settings.max_y;
		spawnchance = settings.chance * 0.01f;
		spawns_disabled = ignore_spawns;
		signature.Clear();
		spawned.Clear();
		area_procd = false;
		removed = 0;
	}

	event OnGameAreaLoaded(area : EAreaName)
	{
		var idx		: int;
		var game	: CR4Game = theGame;

		if (spawns_disabled)
			return (false);
		areaname = area;
		if (IsKnownArea(area,, idx) )
			return (false);
		game.spawnareas.PushBack(S_SpawnArea(signature, area, (int)(removed * .5f + 0.5f) ) );
		FactsAdd("spectre_" + area + "_processed", 1, -1);
	}

	event OnRespawnTimerElapsed(herb : W3Herb) : void
	{
		var inv		: CInventoryComponent = herb.GetInventory();
		var game	: CR4Game = theGame;
		var idx 	: int;

		if (!inv.IsReadyToRenew() || RandRange(100) < 25)
			return (false);
		inv.UpdateLoot();
		if (inv.IsEmpty() )
			return (false);
		herb.RemoveTimer('respawn_herb');
		herb.growing = false;
		herb.Enable(true, false, true);
		if (!spawns_disabled && IsKnownArea(areaname,, idx) )
		{	game.spawnareas[idx].resetcount -= 1;
			if (game.spawnareas[idx].resetcount <= 0)
			{	game.spawnareas.Erase(idx);
				FactsRemove("spectre_" + areaname + "_processed");
			}
		}
	}

	event OnHerbSpawnRequest(herb : W3Herb)
	{
		var items	: array<name>;
		var inv		: CInventoryComponent = herb.GetInventory();
		var hash	: int = herb.GetGuidHash();
		var id		: SItemUniqueId;
		var pos		: int;

		if (spawns_disabled || IsAreaProcessed(herb, inv, hash) )
			return (false);
		items = inv.GetItemsNames();
		id = inv.GetItemId(items[0]);
		if (inv.ItemHasTag(id, 'Quest') )
			return (false);
		if (CanSpawnHerb(items[0], pos) )
		{	if (pos >= 0)
				spawned[pos].count += 1;
			else spawned.PushBack(S_SpawnData(items[0], 1) );
			return (false);
		}
		removed += 1;
		inv.NotifyItemLooted(id);
		inv.RemoveAllItems();
		herb.growing = true;
		herb.Enable(false);
	}

	public function GetHerbYield() : int
	{
		return (RandRange(yield_max + 1, yield_min) ); //yield_max is not inclusive.
	}

	private var seed : int;
	public function GetSeededRand(max : float, optional min : float) : float
	{
		seed += 1;
		return (RandNoiseF(seed, max, min) );
	}

	public function UpdateHerbYield(settings : S_HerbSpawnSettings) : void
	{
		yield_min = settings.min_y;
		yield_max = settings.max_y;
	}

	private function CanSpawnHerb(herb : name, out idx : int) : bool
	{
		var chance : float;

		for (idx = spawned.Size() - 1; idx >= 0; idx -= 1)
		{	if (spawned[idx].herb != herb)
				continue ;
			return (spawned[idx].count < minspawns ||
				(spawned[idx].count < maxspawns && 
				spawnchance > GetSeededRand((float)spawned[idx].count / (float)maxspawns) ) );
		}
		return (true);
	}

	private function IsKnownArea(optional area : EAreaName, optional signature : int, out idx : int) : bool
	{
		var area_data	: S_SpawnArea;
		var i			: int;	

		for (i = theGame.spawnareas.Size() - 1; i >= 0; i -= 1)
		{	area_data = theGame.spawnareas[i];
			if ((area != AN_Undefined && area_data.area == area) || area_data.signature.Contains(signature) )
			{	idx = i;
				return (true);
			}
		}
		return (false);
	}

	private function IsAreaProcessed(herb : W3Herb, inv : CInventoryComponent, hash : int) : bool
	{
		var idx		: int;
		var game	: CR4Game = theGame;

		if (area_procd)
			return (true);
		if (IsKnownArea(, hash, idx) )
		{	area_procd = FactsQuerySum("spectre_" + game.spawnareas[idx].area + "_processed");
			if (!area_procd)
				game.spawnareas.Erase(idx);
		}
		switch (signature.Size() )
		{	case 0:
				herb.AddTimer('get_area_name', 2);
			//[[fallthrough]]
			case 1:
			case 2:
			case 3:
				signature.PushBack(hash);
			default:
			break ;
		}
		return (inv.IsEmpty() || area_procd);
	}

}

struct S_SpawnData
{
	var herb	: name;
	var count	: int;
}

class IngredientManager
{	
	protected const var primary		: array<name>;
	protected const var rich		: array<name>;
	protected const var poor		: array<name>;
	protected const var top			: array<name>;
	protected const var high		: array<name>;
	protected const var standard	: array<name>;
	protected const var albedo		: array<name>;
	protected const var rubedo		: array<name>;
	protected const var nigredo 	: array<name>;
	protected const var vitriol		: array<name>;
	protected const var rebis		: array<name>;
	protected const var aether		: array<name>;
	protected const var quebrith	: array<name>;
	protected const var hydragenum	: array<name>;
	protected const var vermilion	: array<name>;
	protected const var spirit		: array<name>;
	protected const var catalyst	: array<name>;
	protected const var solvent		: array<name>;
	protected const var red			: array<name>;
	protected const var green		: array<name>;
	protected const var blue		: array<name>;
	protected const var plain		: array<name>;
	protected const var container	: array<name>;
	protected const var base		: array<name>;
	

	
	public function ListsFailedToInitialize() : bool
	{	
		return !aether.Size();
	}

	public function IsBase(ingredient : name) : bool
	{
		return (base.Contains(ingredient) );
	}

	public function IsSpirit(ingredient : name) : bool
	{
		return (spirit.Contains(ingredient) );
	}
	
	public function IsContainer(ingredient : name) : bool
	{
		return (container.Contains(ingredient) );
	}
	
	public function IsMonsterMutagen(ingredient : name) : bool
	{
		switch (GetIngredientCategory(ingredient, cat_archetype) )
		{	case 'spectre_mutagen_red':
			case 'spectre_mutagen_green':
			case 'spectre_mutagen_blue':
				return (!plain.Contains(ingredient) );
			default:
				return (false);
		}
	}

	public function IsPlainMutagen(ingredient : name) : bool
	{
		return plain.Contains(ingredient);
	}


	public function GetMutagens(out mutagens : array<name>)
	{
		mutagens = red;
		ArrayOfNamesAppend(mutagens, blue);
		ArrayOfNamesAppend(mutagens, green);
	}	
	

	public function GetIngredientDescription
	(ingredient : name, optional plaintxt : bool, optional newline : bool) : string
	{
		var description : string;

		description = GetLocStringByKeyExt(NameToString(GetIngredientCategory(ingredient, cat_phenotype) ) );
		if (IsBase(ingredient) )
			description += " " + GetLocStringByKeyExt(NameToString(GetIngredientCategory(ingredient, cat_base) ) );
		else
		{	if (!StrLen(description) )
				description = GetLocStringByKeyExt("spectre_typical");
			switch (GetIngredientCategory(ingredient, cat_substance) )
			{	case 'spectre_vitriol':
					description += " " + "<font color='#1595b0'>" + GetLocStringByKeyExt("spectre_vitriol") + "</font>";
				break ;
				case 'spectre_rebis':
					description += " " + "<font color='#4db323'>" + GetLocStringByKeyExt("spectre_rebis") + "</font>";
				break ;
				case 'spectre_aether':
					description += " " + "<font color='#7764a9'>" + GetLocStringByKeyExt("spectre_aether") + "</font>";
				break ;
				case 'spectre_quebrith':
					description += " " + "<font color='#be8728'>" + GetLocStringByKeyExt("spectre_quebrith") + "</font>";
				break ;
				case 'spectre_hydragenum':
					description += " " + "<font color='#b0b0b0'>" + GetLocStringByKeyExt("spectre_hydragenum")+"</font>";
				break ;
				case 'spectre_vermilion':
					description += " " + "<font color='#d25212'>" + GetLocStringByKeyExt("spectre_vermilion") +"</font>";
				break ;
				default:
					if (IsContainer(ingredient) )
						return (GetLocStringByKeyExt("spectre_container") );
					return ("");
			}
			switch (GetIngredientCategory(ingredient, cat_composite) )
			{	case 'spectre_albedo':
					description += ", " + "<font color='#e0e0e0'>" + GetLocStringByKeyExt("spectre_albedo") + "</font>";
				break ;
				case 'spectre_nigredo':
					description += ", " + "<font color='#4F4F4F'>" + GetLocStringByKeyExt("spectre_nigredo") + "</font>";
				break ;
				case 'spectre_rubedo':
					description += ", " + "<font color='#C52C34'>" + GetLocStringByKeyExt("spectre_rubedo") + "</font>";
				break ;
			}
		}
		description += ".";
		if (newline)
			description = "<br>" + description;
		if (plaintxt)
			return (RemoveFormat(description) );
		return (description);
	}


	public function GetIngredientCategory(ingredient : name, type : E_IngNomenclature) : name
	{
		switch (type)
		{	case cat_archetype:
				if (red.Contains(ingredient) )
					return ('spectre_mutagen_red');
				if (green.Contains(ingredient) )
					return ('spectre_mutagen_green');
				if (blue.Contains(ingredient) )
					return ('spectre_mutagen_blue');
				if (spirit.Contains(ingredient) )
					return ('spectre_spirit');
				if (catalyst.Contains(ingredient) )
					return ('spectre_catalyst');
				if (solvent.Contains(ingredient) )
					return ('spectre_solvent');
				if (container.Contains(ingredient) )
					return ('spectre_container');
			//[[fallthrough]]
			case cat_substance:
				if (vitriol.Contains(ingredient) )
					return ('spectre_vitriol');
				if (rebis.Contains(ingredient) )
					return ('spectre_rebis');
				if (aether.Contains(ingredient) )
					return ('spectre_aether');
				if (quebrith.Contains(ingredient) )
					return ('spectre_quebrith');
				if (hydragenum.Contains(ingredient) )
					return ('spectre_hydragenum');
				if (vermilion.Contains(ingredient) )
					return ('spectre_vermilion');
			break ;
			case cat_phenotype:
				if (primary.Contains(ingredient) )
					return ('spectre_primary');
				if (rich.Contains(ingredient) )
					return ('spectre_rich');
				if (poor.Contains(ingredient) )
					return ('spectre_poor');
				if (top.Contains(ingredient) )
					return ('spectre_top');
				if (high.Contains(ingredient) )
					return ('spectre_high');
				if (standard.Contains(ingredient) )
					return ('spectre_standard');
			break ;
			case cat_base:
				if (spirit.Contains(ingredient) )
					return ('spectre_spirit');
				if (catalyst.Contains(ingredient) )
					return ('spectre_catalyst');
				if (solvent.Contains(ingredient) )
					return ('spectre_solvent');
			break ;
			case cat_composite:
				if (albedo.Contains(ingredient) )
					return ('spectre_albedo');
				if (rubedo.Contains(ingredient) )
					return ('spectre_rubedo');
				if (nigredo.Contains(ingredient) )
					return ('spectre_nigredo');
		}
		return ('');
	}


	public function GetIngredientQuality(ingredient : name) : int
	{
		if (primary.Contains(ingredient) )
			return (4);
		if (rich.Contains(ingredient) )
			return (3);
		if (!poor.Contains(ingredient) )
			return (2);
		return (1);
	}
	

	public function	PopulateIngredientMenu
	(	out flashArray	: CScriptedFlashArray,
		flashobj		: CScriptedFlashObject,
		data			: W3ItemSelectionPopupData,
		inventory		: W3GuiPlayerInventoryComponent
	) : void
	{
		var i, j		: int;
		var invalid		: bool;
		var item		: name;
		var items		: array<SItemUniqueId>;
		var flsh_object : CScriptedFlashObject;

		thePlayer.inv.GetAllItems(items);
		for (i = items.Size() - 1; i >= 0; i -= 1)
		{	item = thePlayer.inv.GetItemName(items[i]);
			if (GetIngredientCategory(item, cat_archetype) != data.category)
				continue ;
			for (j = data.filterForbiddenTagsList.Size() - 1; j >= 0 && !invalid; j -= 1)
			{	switch (data.filterForbiddenTagsList[j])	//blacklist
				{	case 'spectre_top':		invalid = top.Contains(item);		break ;
					case 'spectre_high':		invalid = high.Contains(item);		break ;
					case 'spectre_standard': invalid = standard.Contains(item);	break ;
					case 'spectre_primary':	invalid = primary.Contains(item);	break ;
					case 'spectre_albedo':	invalid = albedo.Contains(item);	break ;
					case 'spectre_rubedo':	invalid = rubedo.Contains(item);	break ;
					case 'spectre_nigredo':	invalid = nigredo.Contains(item);	break ;
					default: //invalid = theGame.GetDefinitionsManager().ItemHasTag(item, data.filterForbiddenTagsList[j]);
					break ;
				}
				invalid = (invalid || item == data.filterForbiddenTagsList[j]);
			}
			for (j = (data.filterTagsList.Size() - 1) * (int)!invalid - (int)invalid; j >= 0; j -= 1)
			{	switch(data.filterTagsList[j])				//whitelist
				{	case 'spectre_albedo':	invalid = !albedo.Contains(item);	break ;
					case 'spectre_rubedo':	invalid = !rubedo.Contains(item);	break ;
					case 'spectre_nigredo':	invalid = !nigredo.Contains(item);	break ;
					case 'spectre_primary':	invalid = !primary.Contains(item);	break ;
					case 'plain_mutagen':	invalid = !plain.Contains(item);	break ;
					default: invalid = true; break ;
				}
				if (!invalid)
					break ;
			}
			if (!invalid)
			{	flsh_object = flashobj.CreateFlashObject("red.game.witcher3.menus.common.ItemDataStub");
				inventory.SetInventoryFlashObjectForItem(items[i], flsh_object );
				flashArray.PushBackFlashObject(flsh_object);
			}
			invalid = false;
		}
	}
	
	
	private function RemoveFormat(str : string) : string
	{
		var left : string;

		left = StrBeforeFirst(str, "<font color=");
		if (StrLen(left) )
			str = (left + RemoveFormat(StrAfterFirst(str, "'>") ) );
		return (StrReplace(str, "</font>", "") );
	}
		
	
	default primary = {'Aether', 'Rebis', 'Vitriol', 'Quebrith', 'Hydragenum', 'Vermilion'};
	default rich =
	{	'Calcium equum', 'Fifth essence', 'Lunar shards', 'Optima mater', 'Phosphorus', 'Quicksilver solution',
		'Sulfur', 'Wine stone', 'Diamond dust', 'Leshy resin', 'Alghoul bone marrow', 'Alghoul claw', 'Gargoyle dust',
		'Grave Hag ear', 'Cockatrice egg', 'Gryphon egg', 'Wyvern egg', 'Crystalized essence', 'Elemental essence',
		'Nightwraith dark essence', 'Wraith essence', 'Arachas eyes', 'Cyclops eye', 'Fiend eye', 'Lamia lock of hair',
		'Nightwraiths hair', 'Gargoyle heart', 'Golem heart', 'Necrophage skin', 'Troll skin', 'Werewolf pelt',
		'Ekimma epidermis', 'Berserker pelt', 'Czart hide', 'Cave Troll liver', 'Basilisk plate', 'Forktail plate',
		'Wyvern plate', 'Vampire saliva', 'Werewolf saliva', 'Cockatrice maw', 'Fogling teeth', 'Water Hag teeth',
		'Vampire fang', 'Basilisk venom', 'Siren vocal cords', 'Centipede discharge','Kikimore discharge',
		'Vampire blood', 'Barghest essence', 'Centipede mandible', 'Dracolizard plate',	'Archespore juice',
		'Mistletoe', 'Buckthorn', 'Winter cherry', 'Holy basil', 'Blue lotus', 'Wight hair'
	};
	default poor =
	{	'Balisse fruit', 'Beggartick blossoms', 'Blowbill', 'Celandine', 'Ginatia petals', 'Han', 'Hellebore petals',
		'Hop umbels', 'Moleyarrow', 'Ribleaf', 'Sewant mushrooms', 'White myrtle', 'Wolfsbane' 
	};
	default top =
	{	'Alcohest', 'White Gull 1', 'Alchemical paste', 'Alchemists powder', 'Greater mutagen red',
		'Greater mutagen green', 'Greater mutagen blue', 'Katakan mutagen', 'Volcanic Gryphon mutagen',
		'Water Hag mutagen', 'Wyvern mutagen', 'Doppler mutagen', 'Succubus mutagen', 'Fogling 2 mutagen',
		'Werewolf mutagen', 'Nekker Warrior mutagen', 'Arachas mutagen', 'Gryphon mutagen',
		'Nightwraith mutagen', 'Ekimma mutagen', 'Troll mutagen', 'Noonwraith mutagen', 'Fiend mutagen',
		'Grave Hag mutagen', 'Wraith mutagen', 'Cockatrice mutagen', 'Czart mutagen',
		'Fogling 1 mutagen', 'Forktail mutagen', 'Dao mutagen', 'Lamia mutagen', 'Ancient Leshy mutagen',
		'Basilisk mutagen', 'Leshy mutagen'
	};
	default high = 
	{	'Soltis Vodka', 'Cherry Cordial', 'Dwarven spirit', 'Mandrake cordial', 'Bear fat', 'Stammelfords dust',
		'Mutagen red', 'Mutagen green', 'Mutagen blue', 'Protofleder mutagen'
	};
	default standard =
	{	'Mahakam Spirit', 'Nilfgaardian Lemon', 'Redanian Herbal', 'Temerian Rye', 'Free nilfgaardian lemon',
		'Dog tallow', 'Saltpetre'
	};
	default albedo = 
	{	'Bison Grass', 'Bloodmoss', 'Honeysuckle', 'Hornwort', 'Longrube', 'Nostrix', 'Ranogrin', 'Fifth essence',
		'Wine stone', 'Drowner brain', 'Harpy talon', 'Specter dust', 'Cockatrice egg', 'Elemental essence',
		'Erynie eye', 'Cyclops eye', 'Fiend eye', 'Gryphon feathers', 'Lamia lock of hair', 'Nekker warrior liver',
		'Cockatrice maw', 'Water Hag teeth', 'Siren vocal cords', 'Dracolizard plate', 'Archespore tendril',
		'Blue lotus', 'Wight hair', 'Aloe leaves'
	};
	default rubedo =
	{	'Arenaria', 'Balisse fruit', 'Cortinarius', 'Ergot seeds', 'Green mold', 'Calcium equum', 'Lunar shards',
		'Optima mater', 'Leshy resin', 'Harpy egg', 'Endriag embryo', 'Noonwraith light essence', 'Water essence',
		'Arachas eyes', 'Golem heart', 'Ekimma epidermis', 'Berserker pelt', 'Cave Troll liver', 'Basilisk plate',
		'Vampire saliva', 'Werewolf saliva', 'Fogling teeth', 'Hag teeth', 'Vampire fang', 'Vampire blood',
		'Centipede mandible', 'Winter cherry', 'Wight ear', 'Chamomile'
	};
	default nigredo = 
	{	'Allspice root', 'Bryonia', 'Mandrake root', 'Ducal water', 'Phosphorus', 'Quicksilver solution',
		'Diamond dust', 'Ghoul blood', 'Rotfiend blood', 'Greater Rotfiend blood', 'Alghoul bone marrow',
		'Grave Hag ear', 'Gryphon egg', 'Nightwraith dark essence', 'Nekker eye', 'Nekker heart', 'Troll skin',
		'Werewolf pelt', 'Forktail plate', 'Wyvern plate', 'Arachas venom', 'Basilisk venom', 'Centipede discharge',
		'Kikimore discharge', 'Barghest essence', 'Holy basil', 'Caelum'
	};
	default vitriol = 
	{	'Balisse fruit', 'Bloodmoss', 'Crows eye', 'Ribleaf', 'Sewant mushrooms', 'White myrtle', 'Calcium equum',
		'Vitriol', 'Ghoul blood', 'Leshy resin', 'Alghoul claw', 'Nekker eye', 'Erynie eye', 'Werewolf pelt',
		'Cave Troll liver', 'Wyvern plate', 'Siren vocal cords', 'Vampire blood', 'Archespore tendril', 'Wight stomach',
		'Archespore juice', 'Blue lotus', 'Belladonna'
	};
	default rebis =
	{	'Blowbill', 'Celandine', 'Green mold', 'Han', 'Hop umbels', 'Lunar shards', 'Rebis', 'Wine stone',
		'Drowner brain', 'Specter dust', 'Wyvern egg', 'Crystalized essence', 'Nightwraith dark essence', 'Arachas eyes',
		'Nekker heart', 'Golem heart', 'Arachas venom', 'Barghest essence', 'Holy basil', 'Wight hair', 'Sharley dust',
		'Hemlock', 'Sol'
	};
	default aether =
	{	'Allspice root', 'Arenaria', 'Berbercane fruit', 'Ginatia petals', 'Hellebore petals', 'Hornwort', 'Pringrape',
		'Aether', 'Quicksilver solution', 'Cockatrice egg', 'Gryphon egg', 'Water essence', 'Cyclops eye',
		'Berserker pelt', 'Nekker warrior liver', 'Werewolf saliva', 'Drowned dead tongue', 'Cockatrice maw', 'Scleroderm'
	};
	default quebrith =
	{	'Bison Grass', 'Fools parsley leaves', 'Honeysuckle', 'Mandrake root', 'Moleyarrow', 'Verbena', 'Wolf liver',
		'Ducal water', 'Quebrith', 'Sulfur', 'Alghoul bone marrow', 'Grave Hag ear', 'Harpy egg', 'Endriag embryo',
		'Fiend eye', 'Gargoyle heart', 'Vampire saliva', 'Hag teeth', 'Water Hag teeth', 'Centipede mandible', 'Chamomile'
	};
	default hydragenum =
	{	'Beggartick blossoms', 'Cortinarius', 'Mistletoe', 'Nostrix', 'Pigskin puffball', 'Fifth essence',
		'Hydragenum', 'Optima mater', 'Diamond dust', 'Rotfiend blood', 'Nekker claw', 'Harpy talon',
		'Noonwraith light essence', 'Wraith essence', 'Gryphon feathers', 'Nightwraiths hair', 'Endriag heart',
		'Czart hide', 'Vampire fang', 'Basilisk venom', 'Dracolizard plate', 'Aloe leaves', 'Burmarigold', 'Fulgur'
	};
	default vermilion = 
	{	'Bryonia', 'Ergot seeds', 'Longrube', 'Ranogrin', 'Wolfsbane', 'Buckthorn', 'Phosphorus', 'Vermilion',
		'Nekker blood', 'Greater Rotfiend blood', 'Gargoyle dust', 'Elemental essence', 'Harpy feathers',
		'Lamia lock of hair', 'Necrophage skin', 'Troll skin', 'Ekimma epidermis', 'Basilisk plate', 'Forktail plate',
		'Fogling teeth', 'Centipede discharge', 'Kikimore discharge', 'Winter cherry', 'Wight ear', 'Caelum'
	};
	default red =
	{	'Greater mutagen red', 'Mutagen red', 'Lesser mutagen red', 'Katakan mutagen', 'Volcanic Gryphon mutagen',
		'Water Hag mutagen', 'Wyvern mutagen', 'Doppler mutagen', 'Succubus mutagen', 'Fogling 2 mutagen',
		'Werewolf mutagen', 'Nekker Warrior mutagen', 'Protofleder mutagen'
	};
	default green =
	{	'Greater mutagen green', 'Mutagen green', 'Lesser mutagen green', 'Arachas mutagen', 'Gryphon mutagen',
		'Nightwraith mutagen', 'Ekimma mutagen', 'Troll mutagen', 'Noonwraith mutagen', 'Fiend mutagen',
		'Grave Hag mutagen', 'Wraith mutagen'
	};
	default blue =
	{	'Greater mutagen blue', 'Mutagen blue', 'Lesser mutagen blue', 'Cockatrice mutagen', 'Czart mutagen',
		'Fogling 1 mutagen', 'Forktail mutagen', 'Dao mutagen', 'Lamia mutagen', 'Ancient Leshy mutagen',
		'Basilisk mutagen', 'Leshy mutagen'
	};
	default plain = 
	{	'Lesser mutagen red', 'Mutagen red', 'Greater mutagen red', 'Lesser mutagen green',
		'Mutagen green', 'Greater mutagen green', 'Lesser mutagen blue', 'Mutagen blue', 'Greater mutagen blue',
		'Lesser mutagen yellow', 'Mutagen yellow', 'Greater mutagen yellow'
	};
	default spirit = 
	{	'Alcohest', 'White Gull 1', 'Soltis Vodka', 'Dwarven spirit', 'Temerian Rye', 'Cherry Cordial',
		'Mandrake cordial', 'Mahakam Spirit', 'Nilfgaardian Lemon', 'Redanian Herbal'
	};
	default catalyst = {'Alchemists powder', 'Stammelfords dust', 'Saltpetre'};
	default solvent = {'Alchemical paste', 'Bear fat', 'Dog tallow'};
	default base =
	{	'Alcohest', 'White Gull 1', 'Dwarven spirit', 'Temerian Rye', 'Cherry Cordial', 'Mandrake cordial',
		'Mahakam Spirit', 'Nilfgaardian Lemon', 'Redanian Herbal', 'Alchemists powder', 'Stammelfords dust', 'Saltpetre',
		'Alchemical paste', 'Bear fat', 'Dog tallow'
	};
	default container = {'Bottle', 'Empty vial', 'Empty bottle'};
}

class CR4AlchemyMenu extends CR4ListBaseMenu
{
	private var alchemist				: CNewNPC;
	private var alchemist_inv			: CInventoryComponent;
	private var alchemist_inv_cmpnt		: W3GuiShopInventoryComponent;
	private var player_inv				: CInventoryComponent;
	private var player_inv_cmpnt		: W3GuiPlayerInventoryComponent;
	private var df_mngr					: CDefinitionsManagerAccessor;
	private var f_SetCraftingEnabled	: CScriptedFlashFunction;
	private var f_SetCraftedItem 		: CScriptedFlashFunction;
	private var f_HideContent	 		: CScriptedFlashFunction;
	private var f_SetFilters			: CScriptedFlashFunction;
	private var f_SetRecipePin			: CScriptedFlashFunction;
	private var recipe_list				: array<SAlchemyRecipe>;
	private var guiIngList				: array<name>;
	private var ing_mngr				: IngredientManager;
	private var alchexts				: SpectreAlchemyExtensions;
	private var original_ingredients	: IngredientList;
	private var filters					: S_IngredientFilter;
	private var selected_recipe			: SAlchemyRecipe;
	private var	force_show_rec_item		: bool;
	private var in_selection_menu		: bool;
	private var ing_panel_active		: bool;
	private var ing_buy_modifier		: bool;
	private var ing_category			: name;
	private var read_only_menu			: bool;
	private var using_controller		: bool;
	private var using_fire				: bool;
	private var grid_idx				: int;

	default DATA_BINDING_NAME_SUBLIST		= "crafting.sublist.items";
	default DATA_BINDING_NAME_DESCRIPTION	= "alchemy.item.description";


	event  OnConfigUI()
	{
		super.OnConfigUI();
		theInput.RegisterListener(this, 'OnIngredientChangeRequest', 'IngredientChangeRequest');
		theInput.RegisterListener(this, 'OnHighlightRequest', 'IngredientSelectionRequest');
		theInput.RegisterListener(this, 'OnSubstanceFilterIncrement', 'SubstanceFilterIncrement');
		theInput.RegisterListener(this, 'OnSubstanceFilterDecrement', 'SubstanceFilterDecrement');
		theInput.RegisterListener(this, 'OnModifierKeyPressed', 'ModifierKeyPressed');
		f_SetCraftingEnabled = m_flashModule.GetMemberFlashFunction("setCraftingEnabled");
		f_SetCraftedItem = m_flashModule.GetMemberFlashFunction("setCraftedItem");
		f_SetRecipePin = m_flashModule.GetMemberFlashFunction("setPinnedRecipe");
		f_HideContent = m_flashModule.GetMemberFlashFunction("hideContent");
		f_SetFilters = m_flashModule.GetMemberFlashFunction("SetFiltersValue");
		f_SetCraftingEnabled.InvokeSelfOneArg(FlashArgBool(true) );
		f_SetRecipePin.InvokeSelfOneArg(FlashArgUInt(NameToFlashUInt(theGame.GetGuiManager().PinnedCraftingRecipe) ) );
		m_fxSetTooltipState.InvokeSelfTwoArgs(FlashArgBool(thePlayer.upscaledTooltipState), FlashArgBool(true) );
		read_only_menu = !theGame.alchexts.IsValidAlchemyState(thePlayer.GetCurrentStateName() );
		using_fire = theGame.alchexts.GetNearbyFireSource(theGame.alchexts.fire_src == 1, true) ||
			theGame.GetGuiManager().GetCommonMenu().IsLockedInMenu();
		alchexts = theGame.alchexts;
		df_mngr = theGame.GetDefinitionsManager();
		player_inv_cmpnt = new W3GuiPlayerInventoryComponent in this;
		player_inv = thePlayer.GetInventory();
		player_inv_cmpnt.Initialize(player_inv);
		ing_mngr = alchexts.ing_mngr;
		original_ingredients = new IngredientList in this;
		m_initialSelectionsToIgnore = 2;
		using_controller = !thePlayer.IsPCModeEnabled();
		alchexts.GetRecipes(recipe_list);
		BackupIngrList();
		AdjustInitialIngrQuantity();
		ProcessRecipes();
		VerifyFilters();
		DrawFiltersLabel();
		DrawRecipesList();
		InitializeAlchemist();
		SelectFirstModule();
	}


	event OnCategoryOpened(categoryName : name, opened : bool) {}
	event OnShowCraftedItemTooltip(tag : name) {}
	event OnEntryRead(tag : name) {}
	event OnEntryPress(tag : name) {}
	function PlayOpenSoundEvent() {}
	protected function HandleMenuLoaded() : void {}


	event OnClosingMenu()
	{
		super.OnClosingMenu();
		theGame.GetGuiManager().SetLastOpenedCommonMenuName(GetMenuName() );
		theInput.UnregisterListener(this, 'IngredientChangeRequest');
		theInput.UnregisterListener(this, 'IngredientSelectionRequest');
		theInput.UnregisterListener(this, 'SubstanceFilterIncrement');
		theInput.UnregisterListener(this, 'SubstanceFilterDecrement');
		theInput.UnregisterListener(this, 'ModifierKeyPressed');
		alchexts.OnAlchemyMenuClosed();
	}


	event OnCloseMenu()
	{
		var commonMenu : CR4CommonMenu;

		commonMenu = (CR4CommonMenu)m_parentMenu;
		if(commonMenu)
			commonMenu.ChildRequestCloseMenu();
		theSound.SoundEvent('gui_global_quit');
		CloseMenu();
	}


	event OnStartCrafting()
	{
		OnPlaySoundEvent("gui_alchemy_brew");
	}


	event OnCraftItem(tag : name)
	{	
		if (tag)
		{	CreateItem();
			SelectFirstModule();
			m_fxShowSecondaryModulesSFF.InvokeSelfOneArg(FlashArgBool(true) );
		}
	}


	event OnCraftingFiltersChanged(standard, primary, composite : bool)
	{
		filters.standard = standard;
		filters.primary = primary;
		filters.composite = composite;
		switch (filters.substance[filters.idx])
		{	case 'composite':
				filters.albedo = composite;
				filters.rubedo = composite;
				filters.nigredo = composite;
			break ;
			case 'albedo':
				filters.albedo = composite;
				filters.rubedo = false;
				filters.nigredo = false;
			break ;
			case 'rubedo':
				filters.albedo = false;
				filters.rubedo = composite;
				filters.nigredo = false;
			break ;
			case 'nigredo':
				filters.albedo = false;
				filters.rubedo = false;
				filters.nigredo = composite;
			break ;
		}
	}


	event OnSubstanceFilterIncrement(action : SInputAction)
	{
		if (!in_selection_menu && IsReleased(action) )
			OnSubstanceFilterChanged(1);
	}


	event OnSubstanceFilterDecrement(action : SInputAction)
	{
		if (!in_selection_menu && IsReleased(action) )
			OnSubstanceFilterChanged(-1);
	}


	event OnSubstanceFilterChanged(direction : int) : void
	{	
		if (filters.composite)
		{	filters.idx = (filters.idx + direction) & 3;
			showNotification(GetLocStringByKeyExt("spectre_" + NameToString(filters.substance[filters.idx]) ) );
			DrawFiltersLabel();
		}
		else showNotification(GetLocStringByKeyExt("spectre_filter_disabled") );
		
	}


	event OnModifierKeyPressed(action : SInputAction)
	{
		ing_buy_modifier = IsPressed(action);
	}


	event OnChangePinnedRecipe(tag : name)
	{
		if (tag)
			showNotification(GetLocStringByKeyExt("panel_shop_pinned_recipe_action") );
		theGame.GetGuiManager().SetPinnedCraftingRecipe(tag);
	}


	event OnHighlightRequest(action : SInputAction)
	{
		if (in_selection_menu)
			return (false);
		if (ing_panel_active && IsReleased(action, true) )
			ShowIngredientDescription(guiIngList[grid_idx]);
	}


	event OnModuleSelected(moduleID : int, moduleBindingName : string)
	{
		ing_panel_active = (moduleID == 1);
		if (!ing_panel_active && (bool)selected_recipe.recipeName)
			ShowResultingItemDescription(selected_recipe.status == EAE_NoException);
	}


	event OnEntrySelected(tag : name)
	{
		var uiState : W3TutorialManagerUIHandlerStateAlchemy;

		if ((bool)tag && tag == selected_recipe.recipeName)
			return (false);
		if (tag)
		{	f_HideContent.InvokeSelfOneArg(FlashArgBool(true) );
			selected_recipe = recipe_list[GetRecipeIdx(tag)];
			CreateUIRecipeData(selected_recipe);
			DrawGridIngredientData();
			ShowResultingItemDescription(selected_recipe.status == EAE_NoException);
		}
		else
		{	selected_recipe.recipeName = '';
			f_HideContent.InvokeSelfOneArg(FlashArgBool(false) );
		}
		if (ShouldProcessTutorial('TutorialAlchemySelectRecipe') )
		{	uiState = (W3TutorialManagerUIHandlerStateAlchemy)theGame.GetTutorialSystem().uiHandler.GetCurrentState();
			if (uiState)
				uiState.SelectedRecipe(tag, true);
		}
	}


	event OnGetItemData(idx : int, compareItemType : int)
	{
		var itemNameString 		: string;
		var alchemy_stats		: string;
		var resultData 			: CScriptedFlashObject;
		var vendorItemId		: SItemUniqueId;
		var vendorItems			: array< SItemUniqueId >;
		var vendorPrice			: int;
		var itemName 			: name;

		idx -= 1;
		grid_idx = idx;
		if (force_show_rec_item)
		{	force_show_rec_item = false;
			return (false);
		}
		if (using_controller)
			OnHighlightRequest(SInputAction('', 0, 0) );
		itemName = guiIngList[idx];
		itemNameString = df_mngr.GetItemLocalisationKeyName(itemName);
		itemNameString = GetLocStringByKeyExt(itemNameString);
		resultData = m_flashValueStorage.CreateTempFlashObject();
		resultData.SetMemberFlashString("ItemName", itemNameString);
		alchemy_stats = ing_mngr.GetIngredientDescription(itemName);
		if (StrLen(alchemy_stats) )
			alchemy_stats = " - " + alchemy_stats;
		resultData.SetMemberFlashString("ItemType", GetItemCategoryLocalisedString
			(df_mngr.GetItemCategory(itemName) ) + alchemy_stats);
		if (alchemist_inv)
		{	vendorItems = alchemist_inv.GetItemsByName(itemName);
			if (vendorItems.Size() > 0)
			{	vendorItemId = vendorItems[0];
				vendorPrice = alchemist_inv.GetItemPriceModified(vendorItemId, false);
				resultData.SetMemberFlashNumber("vendorQuantity", alchemist_inv.GetItemQuantity(vendorItemId) );
				resultData.SetMemberFlashNumber("vendorPrice", vendorPrice);
				resultData.SetMemberFlashString("vendorInfoText", GetLocStringByKeyExt
					("panel_inventory_quantity_popup_buy") + " (" + vendorPrice + ")");
			}
		}
		m_flashValueStorage.SetFlashObject("context.tooltip.data", resultData);
	}


	event OnIngredientChangeRequest(action : SInputAction)
	{
		var ingredient	: name = guiIngList[grid_idx];
		var forbidden	: bool;

		if (IsReleased(action) && ing_panel_active && !in_selection_menu && (!alchemist || !ing_buy_modifier) )
		{	ing_category = ing_mngr.GetIngredientCategory(ingredient, cat_archetype);
			switch (selected_recipe.cookedItemType)
			{	case EACIT_MutagenPotion:
					forbidden = (ing_mngr.IsMonsterMutagen(ingredient) );
				break ;
				case EACIT_MutagenFused:
					forbidden = ing_mngr.IsPlainMutagen(ingredient) 
					&& StrContains(selected_recipe.cookedItemName, "Greater" );
				break ;
				case EACIT_MutagenTrans:
					forbidden = ing_mngr.IsPlainMutagen(ingredient)
					&& !StrContains(selected_recipe.cookedItemName, "Lesser" );
				break ;
				case EACIT_Potion:
					forbidden = StrContains(selected_recipe.recipeName, "Pheromone") && 
						(StrContains(ingredient, "Nekker") ||
						StrContains(ingredient, "Drowner") ||
						StrContains(ingredient, "Bear") );
				break ;
			}
			if ((bool)ing_category && !forbidden)
				OpenSelectionMenu();
			else showNotification(GetLocStringByKeyExt('spectre_noingredient') );
		}
	}


	event OnIngredientChanged(new_ingredient : name)
	{
		var status		: EAlchemyExceptions;
		var substance	: name;
		var level		: int;

		if (new_ingredient)
		{	ReplaceIngredient(grid_idx, new_ingredient);
			level = selected_recipe.level;
			substance = selected_recipe.cookedItemSubstance;
			status = EvalRecipe(selected_recipe);
			PromoteResultingItem(selected_recipe);
			if (status == EAE_NoException)
				ShowResultingItemDescription(true);
			else
			{	ShowIngredientDescription(new_ingredient);
				ToggleCraftButton(false);
			}
			if (status != selected_recipe.status || level != selected_recipe.level
			|| substance != selected_recipe.cookedItemSubstance)
			{	selected_recipe.status = status;
				recipe_list[GetRecipeIdx(selected_recipe.recipeName)] = selected_recipe;
				DrawRecipesList();
			}
		}
		in_selection_menu = false;
	}


	event OnBuyIngredient(item : int, isLastItem : bool) : void
	{
		var vendorItems	: array< SItemUniqueId >;
		var itemName	: name;

		if (alchemist_inv && ing_buy_modifier)
		{	itemName = guiIngList[item - 1];
			vendorItems = alchemist_inv.GetItemsByName(itemName);
			if(vendorItems.Size() > 0)
			{	BuyIngredient(vendorItems[0], 1, isLastItem);
				OnPlaySoundEvent("gui_inventory_buy");
			}
		}
	}


	private function BuyIngredient(itemId : SItemUniqueId, quantity : int, isLastItem : bool) : void
	{
		var dummy		: SItemUniqueId; //beware of optional out, it will cause memory corruption if omitted.
		var commonMenu 	: CR4CommonMenu;
		var notifText	: string;

		if(alchemist_inv_cmpnt.GiveItem(itemId, player_inv_cmpnt, quantity, dummy) )
		{	notifText = GetLocStringByKeyExt("panel_blacksmith_items_added") + ": " +
				GetLocStringByKeyExt(alchemist_inv.GetItemLocalizedNameByUniqueID(itemId) ) + " x " + quantity;
			if (isLastItem)
			{	DrawRecipesList(true);
				selected_recipe.status = recipe_list[GetRecipeIdx(selected_recipe.recipeName)].status;
			}
		}
		else notifText = GetLocStringByKeyExt("panel_shop_notification_not_enough_money");
		showNotification(notifText);
		UpdateMerchantData(alchemist);
		commonMenu = (CR4CommonMenu)m_parentMenu;
		commonMenu.UpdateItemsCounter();
		commonMenu.UpdatePlayerOrens();
		if (selected_recipe.recipeName)
		{	DrawGridIngredientData();
			ToggleCraftButton(selected_recipe.status == EAE_NoException);
		}
	}
	
	
	private function BackupIngrList() : void
	{
		var idx, recipes : int;

		for (recipes = recipe_list.Size(); idx < recipes; idx += 1)
			original_ingredients.AddNew(idx, recipe_list[idx].requiredIngredients);
	}

	
	private function AdjustInitialIngrQuantity() : void
	{
		var ingredients			: array<SItemParts>;
		var i, idx, quantity	: int;

		for (idx = recipe_list.Size() - 1; idx >= 0; idx -= 1)
		{	ingredients = recipe_list[idx].requiredIngredients;
			for (i = ingredients.Size() - 1; i >= 0; i -= 1)
			{	quantity = GetAdjustedIngrQuantity(ingredients[i].itemName, 0, 0, ingredients[i].quantity);
				if (quantity == ingredients[i].quantity)
					continue ;
				recipe_list[idx].requiredIngredients[i].quantity = quantity;
			}
		}
	}


	private function GetAdjustedIngrQuantity
	(ingredient : name, recipe_idx, ing_idx : int, optional given_qnt : int) : int
	{
		var quantity : int;

		if (!given_qnt)
			quantity = original_ingredients.GetIngCount(recipe_idx, ing_idx);
		else quantity = given_qnt;
		switch(ing_mngr.GetIngredientCategory(ingredient, cat_phenotype) )
		{	case 'spectre_primary':
			case 'spectre_top':
				quantity = (int)((float)quantity * 0.33f + 0.5f);
			break ;
			case 'spectre_high':
			case 'spectre_rich':
				quantity = (int)((float)quantity * 0.66f + 0.5f) * (int)(bool)StrCmp(ingredient, 'Soltis Vodka');
			break ;
			case 'spectre_poor':
				quantity = (int)((float)quantity * 1.33f + 0.5f);
			break ;
			default:
				return (quantity);
		}
		return (quantity + (int)!quantity);
	}


	private function ReplaceIngredient(gridpos : int, ingredient : name) : void
	{
		var ingredient_lst	: CScriptedFlashArray;
		var i				: int;

		if (gridpos >= 0)
		{	for (i = recipe_list.Size() - 1; i >= 0; i -= 1)
			{	if (recipe_list[i].recipeName != selected_recipe.recipeName)
					continue ;
				selected_recipe.requiredIngredients[gridpos].itemName = ingredient;
				selected_recipe.requiredIngredients[gridpos].quantity = GetAdjustedIngrQuantity(ingredient, i, gridpos);
				recipe_list[i].requiredIngredients = selected_recipe.requiredIngredients;
				break;
			}
			CreateUIRecipeData(selected_recipe);
			ingredient_lst = CreateItems(guiIngList);
			if (ingredient_lst)
				m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, ingredient_lst);
		}
	}


	private function DrawGridIngredientData() : void
	{
		var itemsFlashArray	: CScriptedFlashArray;

		itemsFlashArray = CreateItems(guiIngList);
		if (itemsFlashArray)
			m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME_SUBLIST, itemsFlashArray);
	}


	private function ShowIngredientDescription(ingredient : name) : void
	{	
		var descriptions_array	: CScriptedFlashArray;
		var ingredient_info	: CScriptedFlashObject;
		var description_obj : CScriptedFlashObject;
		var ingredient_name, description_line, substance : string;
		var uses, left : int;
		var has_substance : bool = true;
		
		switch (ing_mngr.GetIngredientCategory(ingredient, cat_composite) )
		{	case 'spectre_albedo':
				substance = GetLocStringByKeyExt("spectre_dominance") + " " + GetLocStringByKeyExt("spectre_albedo");
				description_line = GetLocStringByKeyExt("spectre_effect_descr1");
			break ;
			case 'spectre_rubedo':
				substance = GetLocStringByKeyExt("spectre_dominance") + " " + GetLocStringByKeyExt("spectre_rubedo");
				description_line = GetLocStringByKeyExt("spectre_effect_descr2");
			break ;
			case 'spectre_nigredo':
				substance = GetLocStringByKeyExt("spectre_dominance") + " " + GetLocStringByKeyExt("spectre_nigredo");
				description_line = GetLocStringByKeyExt("spectre_effect_descr3");
			break ;
			default:
				has_substance = false;
		}
		ingredient_info = m_flashValueStorage.CreateTempFlashObject();
		if (has_substance)
		{	descriptions_array = ingredient_info.CreateFlashArray();
			description_obj = ingredient_info.CreateFlashObject();
			description_obj.SetMemberFlashString("name", GetLocStringByKeyExt("spectre_effect_descr_p1") + " " +
				description_line + " " + GetLocStringByKeyExt("spectre_effect_descr_p2") );
			description_obj.SetMemberFlashString("value", "-");
			descriptions_array.PushBackFlashObject(description_obj);
			ingredient_info.SetMemberFlashString("type", substance);
			ingredient_info.SetMemberFlashArray("attributesList", descriptions_array);
		}
		ingredient_name = df_mngr.GetItemLocalisationKeyName(ingredient);
		ingredient_name = GetLocStringByKeyExt(ingredient_name);
		ingredient_info.SetMemberFlashString("itemName", ingredient_name);
		description_line = ing_mngr.GetIngredientDescription(ingredient);
		if (alchexts.GetIsReusableIngredient(ingredient, uses, left) &&
			thePlayer.inv.GetItemQuantity(thePlayer.inv.GetItemId(ingredient) ) )
				description_line += "<br>" + GetLocStringByKeyExt("spectre_uses") + ": " + left + " / " + uses;
		ingredient_info.SetMemberFlashString("itemDescription",  description_line);
		m_flashValueStorage.SetFlashObject("alchemy.menu.crafted.item.tooltip", ingredient_info);
	}


	private function ProcessRecipes() : void
	{
		var recipe	: SAlchemyRecipe;
		var i		: int;
		
		for (;i < recipe_list.Size(); i += 1)
		{	recipe = recipe_list[i];
			recipe.cookedItemQuantity = GetRecipeItemsInInventory(recipe);
			recipe.status = EvalRecipe(recipe);
			recipe.typeName = recipe.cookedItemName;
			CreateUIRecipeData(recipe);
			PromoteResultingItem(recipe);
			recipe_list[i] = recipe;
			if (recipe.cookedItemType != EACIT_Substance)
				continue ;
			if (alchexts.GetIsPrimarySubsRecipe(recipe.recipeName) > -1)
			{	recipe_list[i].cookedItemIconPath = ResolveIconPath(recipe.cookedItemName);
				continue ;
			}
			if (alchexts.GetIsMutagenRecipe(recipe.recipeName) > -1)
				recipe.cookedItemType = EACIT_MutagenFused;
			else if (StrContains(recipe.recipeName, "mutagen") )
				recipe.cookedItemType = EACIT_MutagenTrans;
			else recipe.cookedItemType = EACIT_Other;
			recipe_list[i].cookedItemType = recipe.cookedItemType;
		}
	}


	private function DrawRecipesList(optional update_stats : bool)
	{
		var flash_array	: CScriptedFlashArray = m_flashValueStorage.CreateTempFlashArray();
		var flashobj 	: CScriptedFlashObject;
		var recipe		: SAlchemyRecipe;
		var title		: string;
		var header		: string;
		var color		: string;
		var i, recipes	: int;

		recipes = recipe_list.Size();
		for (i = 0; i < recipes; i+= 1)
		{	recipe = recipe_list[i];
			player_inv.GetItemQualityFromName(recipe.cookedItemName, recipe.level, recipe.level);
			title = GetLocStringByKeyExt(df_mngr.GetItemLocalisationKeyName(recipe.typeName) );
			flashobj = m_flashValueStorage.CreateTempFlashObject();
			switch (recipe.cookedItemType)
			{	case EACIT_Substance: header = GetLocStringByKeyExt("spectre_category_substance"); break ;
				case EACIT_MutagenFused: header = GetLocStringByKeyExt("spectre_category_fusion"); break ;
				case EACIT_MutagenTrans: header = GetLocStringByKeyExt("spectre_category_transmutation"); break ;
				case EACIT_Other: header = GetLocStringByKeyExt("spectre_category_other"); break ;
				case EACIT_Potion:
					GetSecondarySubsColor(recipe.cookedItemSubstance, color);
				//[[fallthrough]]
				case EACIT_Oil:
				case EACIT_Bomb:
					switch (recipe_list[i].level)
					{	default: title += color + " (Level 1) </font>"; break;
						case 1: title += color + " (Level 1) </font>"; break;
						case 2:	title += color + " (Level 2) </font>"; break;
						case 3:	title += color + " (Level 3) </font>"; break;
					}
				default:
					header = GetLocStringByKeyExt(AlchemyCookedItemTypeToLocKey(recipe.cookedItemType) );
				break ;
			}
			if (update_stats)
			{	recipe.cookedItemQuantity = GetRecipeItemsInInventory(recipe);
				recipe_list[i].cookedItemQuantity = recipe.cookedItemQuantity;
				recipe.status = EvalRecipe(recipe);
				recipe_list[i].status = recipe.status;
			}
			if (recipe.cookedItemQuantity > 0)
				title += "<font color='#4d4d4d'> | </font><font color='#a48539'>" + recipe.cookedItemQuantity + "</font>";
			flashobj.SetMemberFlashString("label", title);
			flashobj.SetMemberFlashInt("rarity", recipe.level);
			flashobj.SetMemberFlashString("dropDownLabel", header);
			flashobj.SetMemberFlashUInt("tag", NameToFlashUInt(recipe.recipeName) );
			flashobj.SetMemberFlashString("dropDownIcon", "icons/monsters/ICO_MonsterDefault.png");
			flashobj.SetMemberFlashBool("dropDownOpened", recipe.cookedItemType == selected_recipe.cookedItemType);
			flashobj.SetMemberFlashUInt("dropDownTag", NameToFlashUInt(AlchemyCookedItemTypeEnumToName(recipe.cookedItemType) ) );
			flashobj.SetMemberFlashString("iconPath", recipe.cookedItemIconPath);
			flashobj.SetMemberFlashString("cantCookReason", GetLocStringByKey(AlchemyExceptionToString(recipe.status) ) );
			flashobj.SetMemberFlashInt("canCookStatus", recipe.status);
			flashobj.SetMemberFlashInt("canCookStatusForFilter", 4);
			flash_array.PushBackFlashObject(flashobj);
		}
		m_flashValueStorage.SetFlashArray(DATA_BINDING_NAME, flash_array);
	}


	private function EvalRecipe(recipe : SAlchemyRecipe) : EAlchemyExceptions
	{
		var count		: int = alchexts.GetCookedItemLimit(recipe.cookedItemType);
		var i, j		: int;
		var ingredient	: name;

		if (read_only_menu)
			return (EAE_Preparations);
		if (count && recipe.cookedItemQuantity > count)
			return (EAE_CannotCookMore);
		if ((!using_fire && alchexts.fire_src && thePlayer.GetCurrentStateName() != 'PlayerDialogScene')
		&& !alchexts.using_alchemy_table)
			return (EAE_CookNotAllowed);
		for (i = recipe.requiredIngredients.Size() - 1; i >= 0; i -= 1)
		{	count = recipe.requiredIngredients[i].quantity;
			ingredient = recipe.requiredIngredients[i].itemName;
			for (j = 0; j < i; j += 1)
				if (recipe.requiredIngredients[j].itemName == ingredient)
					count += recipe.requiredIngredients[j].quantity;
			if (count > thePlayer.inv.GetItemQuantityByName(ingredient) )
				return (EAE_NotEnoughIngredients);
		}
		return (EAE_NoException);
	}


	private function CreateUIRecipeData(recipe : SAlchemyRecipe) : void
	{
		var idx, total : int;

		guiIngList.Clear();
		for (total = recipe.requiredIngredients.Size(); idx < total; idx += 1)
			guiIngList.PushBack(recipe.requiredIngredients[idx].itemName);
	}


	private function GetRecipeIdx(recipe : name) : int
	{
		var i : int = recipe_list.Size();

		while (i)
		{	i -= 1;
			if (recipe_list[i].recipeName != recipe)
				continue ;
			return (i);
		}
		return (-1);
	}


	private function GetRecipeItemsInInventory(recipe : SAlchemyRecipe) : int
	{
		var itemname		: string;
		var items			: array<name>;
		var i, len, count 	: int;

		switch (recipe.cookedItemType)
		{	case EACIT_Potion:
				return (GetInventoryPotionCount(recipe.cookedItemName) );
			case EACIT_Bomb:
				items = df_mngr.GetItemsWithTag('Petard');
			break ;
			case EACIT_Oil:
				items = df_mngr.GetItemsWithTag('SilverOil');
				ArrayOfNamesAppendUnique(items, df_mngr.GetItemsWithTag('SteelOil') );
			break ;
			case EACIT_Alcohol:
				if (StrContains(recipe.cookedItemName, 'White Gull') )
					return (GetInventoryPotionCount(recipe.cookedItemName) +
						thePlayer.inv.GetItemQuantity(thePlayer.inv.GetItemId('White Gull 1') ) );
			//[[fallthrough]]
			default:
				if (df_mngr.IsItemSingletonItem(recipe.cookedItemName) )
					return thePlayer.inv.SingletonItemGetAmmo(thePlayer.inv.GetItemId(recipe.cookedItemName) );
				return (thePlayer.inv.GetItemQuantity(thePlayer.inv.GetItemId(recipe.cookedItemName) ) );
		}
		itemname = NameToString(recipe.cookedItemName);
		for (len = StrLen(itemname); i < len; i += 1)
		{	if (StringToInt(StrRight(itemname, i) ) )
			{	itemname = StrReplace(itemname, StrRight(itemname, i), "");
				break ;
			}
		}
		for (i = 0, len = items.Size(); i < len; i += 1)
		{	if (StrFindFirst(items[i], itemname) < 0)
				continue ;
			count += thePlayer.inv.SingletonItemGetAmmo(thePlayer.inv.GetItemId(items[i]) );
		}
		return (count);
	}


	private function GetInventoryPotionCount(potion : name) : int
	{
		var potions		: array<name>;
		var pot_name	: string;
		var count		: int;
		var i	 		: int;

		pot_name = NameToString(potion);
		pot_name = StrReplace(pot_name, " Albedo", "");
		pot_name = StrReplace(pot_name, " Rubedo", "");
		pot_name = StrReplace(pot_name, " Nigredo", "");
		if (StringToInt(StrRight(pot_name, 1) ) )
			pot_name = StrReplace(pot_name, StrRight(pot_name, 1), "");
		potions = df_mngr.GetItemsWithTag('Potion');
		for (i = potions.Size() - 1; i >= 0; i -= 1)
		{	if (StrFindFirst(potions[i], pot_name) < 0)
				continue ;
			count += thePlayer.inv.SingletonItemGetAmmo(thePlayer.inv.GetItemId(potions[i]) );
		}
		return (count);
	}


	public function FillItemInformation(flashObject : CScriptedFlashObject, index : int) : void
	{
		var ingredient : name = guiIngList[index];

		flashObject.SetMemberFlashInt("id", index + 1);
		flashObject.SetMemberFlashInt("quantity", player_inv.GetItemQuantityByName(guiIngList[index]) );
		flashObject.SetMemberFlashString("iconPath", ResolveIconPath(ingredient) );
		flashObject.SetMemberFlashInt("gridPosition", index);
		flashObject.SetMemberFlashInt("gridSize", 1);
		flashObject.SetMemberFlashInt("slotType", 1);
		if (alchemist_inv)
			flashObject.SetMemberFlashInt("vendorQuantity", alchemist_inv.GetItemQuantityByName(ingredient) );
		flashObject.SetMemberFlashInt("reqQuantity", selected_recipe.requiredIngredients[index].quantity);
	}


	private function PromoteResultingItem(out recipe : SAlchemyRecipe) : void
	{
		var items		: array<name>;
		var item_name	: string;
		var item_lvl	: string;
		var substance	: name;
		var potency		: int;
		var idx			: int;

		item_name = NameToString(recipe.cookedItemName);
		switch (recipe.cookedItemType)
		{	case EACIT_Potion:
			case EACIT_Alcohol:
				if (StrEndsWith(item_name, " Albedo") )
					item_name = StrReplace(item_name, " Albedo", "");
				else if (StrEndsWith(item_name, " Rubedo") )
					item_name = StrReplace(item_name, " Rubedo", "");
				else if (StrEndsWith(item_name, " Nigredo") )
					item_name = StrReplace(item_name, " Nigredo", "");
			//[[fallthrough]]
			case EACIT_Oil:
			case EACIT_Bomb:
			break ;
			default:
				return ;
		}
		item_lvl = StrRight(item_name, 1);
		if (!StringToInt(item_lvl) )
			return ;
		potency = GetResultingPotencyLevel(recipe.cookedItemType);
		item_name = StrReplace(item_name, item_lvl, IntToString(potency) );
		substance = GetDominantSubstance();
		if (substance)
			item_name += " " + NameToString(substance);
		else if (!StrCmp(item_name, NameToString(recipe.cookedItemName) ) )
			return ;
		else substance = 'SingletonItem';
		items = df_mngr.GetItemsWithTag(substance);
		for (idx = items.Size() - 1; idx >= 0; idx -= 1)
		{	if (NameToString(items[idx]) != item_name)
				continue ;
			recipe.level = potency;
			recipe.cookedItemName = items[idx];
			recipe.cookedItemSubstance = substance;
			break ;
		}
	}


	private function ShowResultingItemDescription(craftable : bool) : void
	{
		var flashobj		: CScriptedFlashObject;
		var tooltip_obj		: CScriptedFlashObject;
		var attribute_list	: CScriptedFlashArray;
		var attributes		: array<SAttributeTooltip>;
		var item			: name = selected_recipe.cookedItemName;
		var color			: string;
		var description		: string;
		var value 			: float;
		var idx, substance	: int;

		force_show_rec_item = ing_panel_active;
		flashobj = m_flashValueStorage.CreateTempFlashObject();
		player_inv_cmpnt.GetCraftedItemInfo(item, flashobj);
		if (selected_recipe.cookedItemType == EACIT_Potion || selected_recipe.cookedItemType == EACIT_Alcohol)
		{	substance = GetSecondarySubsColor(selected_recipe.cookedItemSubstance, color);
			if (substance)
			{	description = flashobj.GetMemberFlashString("itemDescription") + "<br><br>"
					+ GetLocStringByKey("spectre_dominance");
				switch (substance)
				{	case 3:	description += " " + color + GetLocStringByKey("spectre_nigredo") + "</font>."; break ;
					case 2:	description += " " + color + GetLocStringByKey("spectre_rubedo") + "</font>."; break ;
					case 1:	description += " " + color + GetLocStringByKey("spectre_albedo") + "</font>."; break ;
				}
				flashobj.SetMemberFlashString("itemDescription", description);
			}
		}
		attribute_list = flashobj.CreateFlashArray();
		alchexts.GetItemStatsForAlchemyMenu(item, attributes);
		for (idx = attributes.Size() -1; idx >= 0; idx -= 1)
		{		value = (attributes[idx].value);
				switch (attributes[idx].originName)
				{	case 'air':
						attributes[idx].attributeName = GetLocStringByKey('panel_hud_breath');
					break ;
					case 'burning_DoT_damage_resistance_perc':
						attributes[idx].attributeName = GetLocStringById(456498);
					break ;
					case 'bleeding_DoT_damage_resistance_perc':
						attributes[idx].attributeName = GetLocStringById(174273);
					break ;
					case 'duration':
						if (df_mngr.ItemHasTag(item, 'Potion') )
							value = (alchexts.CalculatePotionDuration(,
								selected_recipe.cookedItemType == EACIT_MutagenPotion, item, value) );
						description = GetLocStringByKeyExt("per_second");
					break ;
					case 'focus':
					case 'focus_on_drink':
						attributes[idx].attributeName = GetLocStringByKey('focus');
					break ;
					case 'healingRatio':
						attributes[idx].attributeName = GetLocStringById(593502);
					break ;
					case 'healthReductionPerc':
						attributes[idx].attributeName = GetLocStringById(368908);
					break ;
					case 'hpPercDamageBonusPerHit':
						attributes[idx].attributeName = GetLocStringById(1070900);
					break ;
					case 'max_hp_perc_trigger':
						attributes[idx].attributeName = GetLocStringById(1070909);
					break ;
					case 'poison_DoT_damage_resistance_perc':
						attributes[idx].attributeName = GetLocStringById(174271);
					break ;
					case 'resistGainRate':
						attributes[idx].attributeName = GetLocStringById(1046653);
					break ;
					case 'returned_damage':
						attributes[idx].attributeName = GetLocStringByKey('attribute_name_return_damage');
					break ;
					case 'slow_motion':
						attributes[idx].attributeName = GetLocStringByKey('attribute_name_SlowdownEffect');
					break ;
					case 'staminaCostPerc':
						attributes[idx].attributeName = GetLocStringById(174112);
					break ;
					case 'toxicity':
					case 'toxicity_offset':
						value = alchexts.CalculatePotionToxicity(, item, value);
					break ;
					case 'vitalityCombatRegen':
						attributes[idx].attributeName = GetLocStringByKey('panel_common_statistics_tooltip_incombat_regen');
					break ;
					default:
						if (StrFindFirst(attributes[idx].originName, "max_stack") >= 0)
							attributes[idx].attributeName = GetLocStringById(1070917);
						else if (!StrLen(attributes[idx].attributeName) )
							continue ;
					break ;
				}
				tooltip_obj = flashobj.CreateFlashObject();
				if (attributes[idx].percentageValue)
					tooltip_obj.SetMemberFlashString("value", NoTrailZeros(NonZeroRound(value * 100) ) + "%");
				else tooltip_obj.SetMemberFlashString("value", NoTrailZeros(NonZeroRound(value) ) + description);
				tooltip_obj.SetMemberFlashString("id", attributes[idx].originName);
				tooltip_obj.SetMemberFlashString("name", attributes[idx].attributeName);
				tooltip_obj.SetMemberFlashString("color", attributes[idx].attributeColor);
				attribute_list.PushBackFlashObject(tooltip_obj);
				description = "";
		}
		flashobj.SetMemberFlashArray("attributesList", attribute_list);
		m_flashValueStorage.SetFlashObject("alchemy.menu.crafted.item.tooltip", flashobj);
		f_SetCraftedItem.InvokeSelfSixArgs(FlashArgUInt(NameToFlashUInt(selected_recipe.recipeName) ),
			FlashArgString(GetLocStringByKeyExt(player_inv.GetItemLocalizedNameByName(item) ) ),
			FlashArgString(ResolveIconPath(item) ),	FlashArgBool(craftable), FlashArgInt(1), FlashArgString("") );
	}


	private function CreateItem()
	{
		var item, bonus_item	: string;
		var created				: int;

		if(selected_recipe.status == EAE_NoException)
		{	GetWitcherPlayer().StartInvUpdateTransaction();
			bonus_item = CreateItemFromRecipe(selected_recipe, created);
			if (StrLen(bonus_item) )
				bonus_item = "<br>" + GetLocStringByKeyExt("spectre_side_effect_decr") + " " + bonus_item;
			bonus_item = " (" + created + ") " + bonus_item;
			DrawRecipesList(true);
			DrawGridIngredientData();
			selected_recipe = recipe_list[GetRecipeIdx(selected_recipe.recipeName)];
			ShowResultingItemDescription(selected_recipe.status == EAE_NoException);
			item = GetLocStringByKeyExt(df_mngr.GetItemLocalisationKeyName(selected_recipe.cookedItemName) );
			showNotification(GetLocStringByKeyExt("panel_crafting_successfully_crafted") + ": " + item + bonus_item);
			OnPlaySoundEvent("gui_crafting_craft_item_complete");
			GetWitcherPlayer().FinishInvUpdateTransaction();
		}
		else
		{	showNotification(GetLocStringByKeyExt(AlchemyExceptionToString(selected_recipe.status) ) );
			OnPlaySoundEvent("gui_global_denied");
		}
		if (ShouldProcessTutorial('TutorialAlchemyCook') )
			BypassTutorial(selected_recipe, created);
	}


	private function CreateItemFromRecipe(recipe : SAlchemyRecipe, out quantity : int) : string
	{
		var dm							: CDefinitionsManagerAccessor = theGame.GetDefinitionsManager();
		var ids							: array<SItemUniqueId>;
		var player						: W3PlayerWitcher;
		var config						: SpectreAlchemyExtensions = alchexts;
		var cook_bonus					: string;
		var ingredient					: name;
		var i, ing_quantity, bottles	: int;
		var is_distilling				: bool;

		player = GetWitcherPlayer();
		quantity = config.cooked_quantity + (int)config.using_alchemy_table;
		switch(recipe.cookedItemType)
		{	case EACIT_Bomb:
				quantity += player.GetSkillLevel(S_Alchemy_s08);
			break ;
			case EACIT_Substance:
				if (config.GetIsPrimarySubsRecipe(recipe.recipeName) > -1)
				{	quantity = (int)((quantity + (RandRangeF(0.8, 0.08f) * config.min_primary_ingredients / 1.618f) )
						* config.yield_modifier + .5f);
					cook_bonus = ProcessSideEffects(recipe);
					is_distilling = true;
				}
			break ;
			case EACIT_Potion:
			case EACIT_Alcohol:
			case EACIT_MutagenPotion:
			case EACIT_Oil:
			break ;
			default:
			break ;
		}
		if (config.time_based_alchemy && player.GetCurrentStateName() == 'AlchemyBrewing')
			((W3PlayerWitcherStateAlchemyBrewing)player.GetCurrentState() ).AddBrewTime(
				(config.distillation_time * (int)is_distilling + (int)!is_distilling * config.alchemy_time_cost) );
		for (i = recipe.requiredIngredients.Size() - 1; i >= 0 ; i -= 1)
		{	ingredient = recipe.requiredIngredients[i].itemName;
			if(!dm.IsItemSingletonItem(ingredient) )
			{	if (StrFindFirst(recipe.recipeName, "White Gull") > -1 && ingredient == 'Alcohest')
					recipe.requiredIngredients[i].quantity *= config.alcohol_uses;
				ing_quantity = config.UpdateIngredientUses(ingredient, recipe.requiredIngredients[i].quantity);
				player.inv.RemoveItemByName(ingredient, ing_quantity);
				bottles += ((int)ing_mngr.IsSpirit(ingredient) * ing_quantity);
			}
			else
			{	ids = thePlayer.inv.GetItemsIds(ingredient);
				player.inv.SingletonItemRemoveAmmo(ids[0], recipe.requiredIngredients[i].quantity);
			}
		}
		if ((bottles || is_distilling) && config.bottle_recycling)
			player.inv.AddAnItem('Empty bottle', bottles + (int)is_distilling);
		if (dm.IsItemSingletonItem(recipe.cookedItemName) )
		{	ids = player.inv.GetItemsIds(recipe.cookedItemName);
			i = quantity;
			if (!ids.Size() )
			{	ids = player.inv.AddAnItem(recipe.cookedItemName);
				i -= 1;
			}
			player.inv.SetItemModifierInt(ids[0],'ammo_current', Max(1, player.inv.SingletonItemGetAmmo(ids[0]) + i) );
			theGame.GetGlobalEventsManager().OnScriptedEvent(SEC_OnAmmoChanged);
			if (player.inv.ItemHasTag(ids[0], 'NoShow') )
				player.inv.RemoveItemTag(ids[0], 'NoShow');
		}
		else player.inv.AddAnItem(recipe.cookedItemName, quantity);
		theTelemetry.LogWithLabelAndValue(TE_ITEM_COOKED, recipe.cookedItemName, quantity);
		return (cook_bonus);
	}


	private function ProcessSideEffects(recipe : SAlchemyRecipe) : string
	{	
		var received	: string;
		var item		: name;
		var idx, count	: int;

		idx = RandRange(4, 1) * (int)(RandRange(100) < alchexts.abltymgr.GetMutagenDiscoveryChance() );
		switch(idx)
		{	case 1:
				item = 'Lesser mutagen red';
			break;
			case 2:
				item = 'Lesser mutagen green';
			break;
			case 3:
				item = 'Lesser mutagen blue';
			break;
			default:
			break ;
		}
		thePlayer.inv.AddAnItem(item, 1);
		received = item;
		item = GetDominantSubstance();
		if (item)
		{	thePlayer.inv.AddAnItem(item, 1);
			idx = recipe.requiredIngredients.Size();
			while (idx)
			{	idx -= 1;
				if (ing_mngr.IsBase(recipe.requiredIngredients[idx].itemName) ||
					ing_mngr.IsContainer(recipe.requiredIngredients[idx].itemName) )
						continue ;
				count += recipe.requiredIngredients[idx].quantity;
			}
			count = (int)(count * RandRangeF(0.50f, 0.25f) );
			thePlayer.inv.AddAnItem(item, count);
			received += " " + item + " (" + count + ")";
		}
		return (StrReplace(received, "None", "") );
	}


	private function BypassTutorial(recipe : SAlchemyRecipe, created : int) : void
	{	//TODO: create a proper tutorial explaining the mod mechanics, ingredient swaping, etc.
		var tutorial : CScriptableState = theGame.GetTutorialSystem().uiHandler.GetCurrentState();

		if (tutorial)
		{	if ((W3TutorialManagerUIHandlerStateAlchemy)tutorial)
			{	((W3TutorialManagerUIHandlerStateAlchemy)tutorial).CookedItem(recipe.recipeName);
				if (FactsQuerySum("tut_forced_preparation") && StrContains(recipe.recipeName, "Recipe for Thunderbolt")
				&& thePlayer.inv.SingletonItemGetAmmo(thePlayer.inv.GetItemId('Thunderbolt 1') ) <= 0)
				{	recipe.cookedItemName = 'Thunderbolt 1';
					CreateItemFromRecipe(recipe, created);
				}
			}
			else if((W3TutorialManagerUIHandlerStateAlchemyMutagens)tutorial)
				((W3TutorialManagerUIHandlerStateAlchemyMutagens)tutorial).CookedItem(recipe.recipeName);
		}
	}


	private function GetDominantSubstance() : name
	{	
		var ingredients	: array<name> = guiIngList;
		var substance	: name;
		var previous	: name;
		var idx			: int;

		for (idx = ingredients.Size() - 1; idx >= 0; idx -= 1)
		{	if (ing_mngr.IsBase(ingredients[idx]) || ing_mngr.IsContainer(ingredients[idx]) )
				continue ;
			substance = ing_mngr.GetIngredientCategory(ingredients[idx], cat_composite);
			if (!((bool)substance) || ((bool)previous && substance != previous) )
				return ('');
			previous = substance;
		}
		switch (substance)
		{	case 'spectre_nigredo':
				return ('Nigredo');
			case 'spectre_rubedo':
				return ('Rubedo');
			case 'spectre_albedo':
				return ('Albedo');
			default:
				return ('');
		}
	}


	private function GetSecondarySubsColor(substance : name, out color : string) : int
	{
		switch (substance)
		{	case 'Albedo':
				color = "<font color='#e0e0e0'>";
				return (1);
			case 'Rubedo':
				color = "<font color='#C52C34'>";
				return(2);
			case 'Nigredo':
				color = "<font color='#4F4F4F'>";
				return(3);
			default:
				color = "<font>";
				return (0);
		}
	}


	private function GetResultingPotencyLevel(_type : EAlchemyCookedItemType) : int
	{
		var idx, common, rich, primary	: int;
		var basequality					: int;
		var ingredient					: name;
		var ingredients					: array<name> = guiIngList;

		if (_type != EACIT_Potion && _type != EACIT_Oil && _type != EACIT_Bomb)
			return (1);
		for (idx = ingredients.Size() - 1; idx >= 0; idx -= 1)
		{	ingredient = ingredients[idx];
			if (!((bool)ing_mngr.GetIngredientCategory(ingredient, cat_substance) ||
				(bool)ing_mngr.GetIngredientCategory(ingredient, cat_base) ) )
					continue ;
			switch (ing_mngr.GetIngredientCategory(ingredient, cat_phenotype) )
			{	case 'spectre_top':
					basequality |= 3;
					continue ;
				case 'spectre_high':
					basequality |= 2;
					continue ;
				case 'spectre_primary':
					primary += 1;
				break ;
				case 'spectre_rich':
					rich += 1;
				break ;
				default:
					common += 1;
			}
		}
		switch (basequality)
		{	case 3:
				if (primary && !(common || rich) )
					return (3);
				return (1 + (int)(primary + rich > common) );
			case 2:
				return (1 + (int)(!common && (primary || rich) ) );
			default:
				return (1);
		}
	}


	private function VerifyFilters() : void //default values for names aren't initialized correctly in some cases.
	{
		if (!filters.substance.Size() )
		{	filters.substance.PushBack('composite');
			filters.substance.PushBack('albedo');
			filters.substance.PushBack('rubedo');
			filters.substance.PushBack('nigredo');
		}
	}


	private function ApplyFilters(out blacklist : array<name>, out whitelist : array<name>, category : name) : void
	{
		blacklist.PushBack(selected_recipe.cookedItemName);
		switch (category)
		{	case 'spectre_mutagen_red':
			case 'spectre_mutagen_green':
			case 'spectre_mutagen_blue':
				if (selected_recipe.cookedItemType == EACIT_MutagenPotion)
					whitelist.PushBack('plain_mutagen');
			//[[fallthrough]]
			case 'spectre_catalyst':
			case 'spectre_solvent':
			case 'spectre_spirit':
				switch (ing_mngr.GetIngredientCategory(original_ingredients.GetIngName
				(GetRecipeIdx(selected_recipe.recipeName), grid_idx), cat_phenotype) )
				{	case 'spectre_top':
						blacklist.PushBack('spectre_high');
						blacklist.PushBack('spectre_standard');
					break ;
					case 'spectre_high':
						blacklist.PushBack('spectre_standard');
					break ;
					default:
					break ;
				}
			//[[fallthrough]]
			case 'spectre_container':
			return ;
		}
		if (filters.standard)
		{	if (!filters.primary)
				blacklist.PushBack('spectre_primary');
			if (!filters.albedo)
				blacklist.PushBack('spectre_albedo');
			if (!filters.rubedo)
				blacklist.PushBack('spectre_rubedo');
			if (!filters.nigredo)
				blacklist.PushBack('spectre_nigredo');
		}
		else
		{	if (filters.primary)
				whitelist.PushBack('spectre_primary');
			if (filters.albedo)
				whitelist.PushBack('spectre_albedo');
			if (filters.rubedo)
				whitelist.PushBack('spectre_rubedo');
			if (filters.nigredo)
				whitelist.PushBack('spectre_nigredo');
			if (!whitelist.Size() )
				whitelist.PushBack('none');
		}
	}


	private function DrawFiltersLabel() : void
	{
		f_SetFilters.InvokeSelfSixArgs
		(	FlashArgString(GetLocStringByKeyExt("spectre_standard") ), FlashArgBool(filters.standard),
			FlashArgString(GetLocStringByKeyExt("spectre_filter_primary") ), FlashArgBool(filters.primary),
			FlashArgString(GetLocStringByKeyExt("spectre_" + NameToString(filters.substance[filters.idx]) ) ),
				FlashArgBool(filters.composite)
		);
	}


	private function ResolveIconPath(item : name) : string
	{
		if (!alchexts.mod_icons)
			return (df_mngr.GetItemIconPath(item) );
		switch (item)
		{	case 'Aether':
				return ("icons/inventory/aether.xbm");
			case 'Rebis':
				return ("icons/inventory/rebis.xbm");
			case 'Quebrith':
				return ("icons/inventory/quebrith.xbm");
			case 'Vitriol':
				return ("icons/inventory/vitriol.xbm");
			case 'Hydragenum':
				return ("icons/inventory/hydragenum.xbm");
			case 'Vermilion':
				return ("icons/inventory/vermilion.xbm");
			default:
				return (df_mngr.GetItemIconPath(item) );
		}
	}


	private function OpenSelectionMenu() : void
	{
		var menu	: W3ItemSelectionPopupData;
		var frame	: W3PopupData; 

		in_selection_menu = true;
		frame = new W3PopupData in theGame.GetGuiManager();
		menu = new W3ItemSelectionPopupData in theGame.GetGuiManager();
		menu.category = ing_category;
		menu.selectionMode = EISPM_Ingredients;
		ApplyFilters(menu.filterForbiddenTagsList, menu.filterTagsList, ing_category);
		menu.menuCallBack = this;
		menu.frame = frame;
		RequestSubMenu('PopupMenu', frame);
		theGame.RequestPopup('ItemSelectionPopup', menu);
	}


	private function ToggleCraftButton(on : bool) : void
	{
		f_SetCraftedItem.InvokeSelfSixArgs
		(	FlashArgUInt(NameToFlashUInt(selected_recipe.recipeName) ),
			FlashArgString(""), FlashArgString(ResolveIconPath(selected_recipe.cookedItemName) ),
			FlashArgBool(on), FlashArgInt(1), FlashArgString("")
		);
	}


	private function InitializeAlchemist() : void
	{
		var l_obj		 		: IScriptable;
		var l_initData			: W3InventoryInitData;
		var l_merchantComponent	: W3MerchantComponent;

		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
			alchemist = (CNewNPC)l_initData.containerNPC;
		else alchemist = (CNewNPC)l_obj;
		if (alchemist)
		{	l_merchantComponent = (W3MerchantComponent)alchemist.GetComponentByClassName('W3MerchantComponent');
			if (l_merchantComponent.GetMapPinType() == 'Herbalist' || l_merchantComponent.GetMapPinType() == 'Alchemic')
			{	alchemist_inv = alchemist.GetInventory();
				UpdateMerchantData(alchemist);
				alchemist_inv_cmpnt = new W3GuiShopInventoryComponent in this;
				alchemist_inv_cmpnt.Initialize(alchemist_inv);
			}
		}
	}


	private function UpdateMerchantData(targetNpc : CNewNPC) : void
	{
		var l_merchantData	: CScriptedFlashObject;

		l_merchantData = m_flashValueStorage.CreateTempFlashObject();
		GetNpcInfo((CGameplayEntity)targetNpc, l_merchantData);
		m_flashValueStorage.SetFlashObject("crafting.merchant.info", l_merchantData);
	}


	public function IsInShop() : bool
	{
		var l_obj		: IScriptable;
		var l_initData	: W3InventoryInitData;
		var npc			: CNewNPC;

		l_obj = GetMenuInitData();
		l_initData = (W3InventoryInitData)l_obj;
		if (l_initData)
			npc = (CNewNPC)l_initData.containerNPC;
		else npc = (CNewNPC)l_obj;
		return (npc);
	}
}

struct S_Ingredient
{
	var ingredients		: array<SItemParts>;
}

struct S_IngredientFilter
{
	var idx				: int;
	var albedo			: bool; default albedo = true;
	var rubedo			: bool; default rubedo = true;
	var nigredo			: bool; default nigredo = true;
	var primary			: bool; default primary = true;
	var composite		: bool; default composite = true;
	var standard		: bool; default standard = true;
	const var substance	: array<name>; default substance = {'composite', 'albedo', 'rubedo', 'nigredo'};
}

class IngredientList
{
	private var recipes	: array<S_Ingredient>;

	public function GetIngCount(recipe, ingredient : int) : int
	{
		if (recipe > -1 && ingredient > -1)
			return (recipes[recipe].ingredients[ingredient].quantity);
		return (-1);
	}

	public function GetIngName(recipe, ingredient : int) : name
	{
		if (recipe > -1 && ingredient > -1)
			return (recipes[recipe].ingredients[ingredient].itemName);
		return ('None');
	}

	public function AddNew(recipe : int, ingredients : array<SItemParts>)
	{
		var size		: int = recipes.Size();
		var idx, count	: int;

		if (recipe > -1)
		{	while (recipe >= size)
			{	size = (32 * (int)(!size) ) + (size * 2);
				recipes.Resize(size);
			}
			for (count = ingredients.Size(); idx < count; idx += 1)
				recipes[recipe].ingredients.PushBack(ingredients[idx]);
		}
	}
}

enum E_IngNomenclature
{	cat_phenotype,
	cat_substance,
	cat_composite,
	cat_base,
	cat_archetype
}

struct S_ToxicityData
{
	var duration		: float;
	var degeneration	: float;
}

struct S_ReusableIngredient
{
	var left	: int;
	var uses	: int;
	var id		: name;
}

struct S_SpawnArea
{
	var signature	: array<int>;
	var area		: EAreaName;
	var resetcount	: int;
}

struct S_spectrePersistenData
{
	var reusables	: array<S_ReusableIngredient>;
	var areas		: array<S_SpawnArea>;
}

struct S_HerbSpawnSettings
{
	var min_s	: int; default min_s = 4;
	var max_s	: int; default max_s = 16;
	var min_y	: int; default min_y = 3;
	var max_y	: int; default max_y = 7;
	var chance	: int; default chance = 8;
}

class ExtendedPotionData extends W3BuffCustomParams
{
	var effectType 				: EEffectType;
	var buffSpecificParams		: W3PotionParams;
	var creator 				: CGameplayEntity;
	var itemid					: SItemUniqueId;
	var sourceName				: string;
	var customAbilityName		: name;
	var itemName				: name;
	var substance				: name;
	var duration				: float;
	var toxicity				: float;
}

class W3Effect_AlbedoDominance extends CBaseGameplayEffect
{
	default effectType = EET_AlbedoDominance;
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
}

class W3Effect_NigredoDominance extends CBaseGameplayEffect
{
	default effectType = EET_NigredoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;
	
	
	public function Init(params : SEffectInitInfo)
	{	
		attributeName = PowerStatEnumToName(CPS_AttackPower);
		super.Init(params);
	}
}

class W3Effect_PotionDigestion extends CBaseGameplayEffect
{
	default effectType = EET_PotionDigestion;
	default isPositive = false;
	default isNeutral = true;
	default isNegative = false;
	private var potion						: ExtendedPotionData;
	private var time_active					: float;
	public var adjusted_toxicity			: float;
	private const var MIN_DIGESTION_TIME	: float; default MIN_DIGESTION_TIME = 0.5f;


	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{	
		var tox_modifier	: float = theGame.alchexts.whoney_tox_base;
		var player			: W3PlayerWitcher = GetWitcherPlayer();

		potion = (ExtendedPotionData)customParams;
		switch (potion.effectType)
		{	case EET_WhiteHoney:
				tox_modifier *= (1 + StringToInt(StrRight(potion.itemName, 1) ) );
				potion.toxicity = tox_modifier * player.GetStat(BCS_Toxicity) * -1;
				this.timeLeft = MaxF(MIN_DIGESTION_TIME, this.timeLeft * (1.25f - tox_modifier) );
				this.duration = this.timeLeft;
			break ;
			case EET_WhiteRaffardDecoction:
				this.timeLeft = MaxF(MIN_DIGESTION_TIME, this.timeLeft * 0.125f);
				this.duration = this.timeLeft;
			break ;
		}
		adjusted_toxicity = potion.toxicity / this.duration;
		if (player.GetBuff(EET_AlbedoDominance) )
			adjusted_toxicity *= 0.8f;
		super.OnEffectAdded(customParams);
	}

	event OnEffectRemoved()
	{
		var player			: W3PlayerWitcher = GetWitcherPlayer();
		var toxicity_effect	: CBaseGameplayEffect = player.GetBuff(EET_Toxicity);
		var effects			: SCustomEffectParams;

		if (this.timeLeft <= 0) //otherwise something removed the potion before digesting it.
		{	effects.effectType = potion.effectType;
			effects.creator = player;
			effects.sourceName = potion.sourceName;
			effects.duration = potion.duration;
			effects.customAbilityName = potion.customAbilityName;
			effects.buffSpecificParams = potion.buffSpecificParams;
			if (effects.effectType != EET_WhiteHoney)
			{	player.AddEffectCustom(effects);
				theGame.alchexts.AddSecondarySubstanceEffects(potion.substance, potion.duration);
				if (toxicity_effect)
					((spectreToxicityEffect)toxicity_effect).SetEffectData(potion.toxicity, potion.duration);
			}
			else thePlayer.RemoveAllPotionEffects();
		}
		if (potion.buffSpecificParams)
			delete potion.buffSpecificParams;
		delete potion;
		super.OnEffectRemoved();
	}

	event OnUpdate(time : float)
	{
		if (time > this.timeLeft)
			time = this.duration - time_active;
		effectManager.CacheStatUpdate(BCS_Toxicity, adjusted_toxicity * time);
		time_active += time;
		super.OnUpdate(time);
	}

}

class spectreToxicityEffect extends W3Effect_Toxicity
{
	private var lvl1, lvl2, lvl3	: float;
	private var fx_update_time		: float;
	private var elapsed 			: float;
	private var cached				: float;
	private var toxdata				: array<S_ToxicityData>;
	private var player				: W3PlayerWitcher;
	private var alchext				: SpectreAlchemyExtensions;
	private var fxplaying			: int;



	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		super.OnEffectAdded(customParams);
		if ( ((W3PlayerWitcher)target) )
		{	player = GetWitcherPlayer();
			alchext = theGame.alchexts;
			if (target.GetStat(BCS_Toxicity) > alchext.alt_degen_threshold)
				switchCameraEffect = !isPlayingCameraEffect;
			else switchCameraEffect = isPlayingCameraEffect;
			if (!(lvl1 + lvl2 + lvl3) )
			{	lvl1 = 0.25;
				lvl2 = 0.50;
				lvl3 = 0.75;
			}
		}
	}


	event OnUpdate(dt : float)
	{
		var effect		: int;
		var is_active	: bool;
		var degenrate	: float; //You're such a degenrate!
		var toxicity	: float;
		var dmg			: float;

		super.OnUpdate(dt);
		elapsed += dt;
		if (elapsed < alchext.TOX_UPDATE_INTERVAL)
			return (false);
		else is_active = UpdateEffectDuration(elapsed, degenrate);
		toxicity = target.GetStat(BCS_Toxicity) / target.GetStatMax(BCS_Toxicity);
		if (fx_update_time <= 0)
		{	effect = (int)(toxicity >= lvl1) + (int)(toxicity >= lvl2) + (int)(toxicity >= lvl3) + ((int)(toxicity < cached) * 4);
			if (effect != fxplaying && !target.IsEffectActive('invisible') )
			{	switch (effect)
				{	case 0:	PlayHeadEffect('toxic_000_025'); break;
					case 1:	PlayHeadEffect('toxic_025_050'); break;
					case 2:	PlayHeadEffect('toxic_050_075'); break;
					case 3: PlayHeadEffect('toxic_075_100'); break;
					case 4: PlayHeadEffect('toxic_025_000'); break; //Visually, 025_000 does nothing. Leaving it as other mods may improve it. 
					case 5: PlayHeadEffect('toxic_050_025'); break;
					case 6: PlayHeadEffect('toxic_075_050'); break;
					case 7: PlayHeadEffect('toxic_100_075'); break;
				}
				fxplaying = effect;
			}
			cached = toxicity;
			fx_update_time = 8; //ensures a smother transition by ingorning brief 'peaks' into other thresholds.
			switchCameraEffect = (!isPlayingCameraEffect && toxicity > alchext.alt_degen_threshold) ||
				(toxicity < alchext.alt_degen_threshold && isPlayingCameraEffect);
		}
		else fx_update_time -= elapsed;
		dmg = PowF(toxicity, 3) * 0.0384f * target.GetStatMax(BCS_Vitality) * alchext.toxicity_dmg_modifier * elapsed;
		switch (thePlayer.GetCurrentStateName() )
		{	default:
				if (!theGame.GetGameCamera().HasTag('co_meditation') )
					break ;
			case 'Meditation':
			case 'MeditationWaiting':
			case 'W3EEMeditation':
			case 'AlchemyBrewing':
				dmg *= 0.75f;
				degenrate *= 3.14159f;
			break ;
		}
		effectManager.CacheDamage(theGame.params.DAMAGE_NAME_DIRECT, dmg, NULL, this, elapsed, true, CPS_Undefined, false);
		if (is_active)
		{	if (alchext.combat_degeneration && target.IsInCombat() )
				degenrate *= alchext.combat_degen_rate;
			else if (toxicity > alchext.alt_degen_threshold)
				degenrate *= alchext.alt_degen_rate;
			else degenrate *= alchext.degeneration_rate;
			degenrate = -1 * elapsed * degenrate * alchext.toxicity_degen_modifier;
		}	
		else degenrate = (-1 * elapsed * 0.1f * target.GetStatMax(BCS_Toxicity) * alchext.residual_degen_rate *
			(float)!effectManager.HasEffect(EET_PotionDigestion) ) * alchext.toxicity_degen_modifier;
		effectManager.CacheStatUpdate(BCS_Toxicity, degenrate);
		elapsed = 0;
	}


	public function SetToxThresholds(l1, l2, l3 : float)
	{
		lvl1 = l1;
		lvl2 = l2;
		lvl3 = l3;
	}


	public function SetEffectData(amount, duration : float) : void
	{
		toxdata.PushBack(S_ToxicityData(duration, amount / duration) );
	}

	private function UpdateEffectDuration(elapsed_time : float, out degeneration : float) : bool
	{
		var idx : int;
	
		for (;idx < toxdata.Size(); idx += 1)
		{	toxdata[idx].duration -= elapsed_time;
			if (toxdata[idx].duration >= 0)
			{	degeneration += toxdata[idx].degeneration;
				continue ;
			}
			toxdata.Erase(idx);
		}
		return ((bool)degeneration);
	}
}

class W3Effect_RubedoDominance extends CBaseGameplayEffect
{
	private const var healpercent : float;
	
	default healpercent = 0.0132f;
	default effectType = EET_RubedoDominance;	
	default isPositive = true;
	default isNeutral = false;
	default isNegative = false;	
	
	event OnUpdate(dt : float)
	{
		var heal : float =
			MaxF(16, (thePlayer.GetStatMax(BCS_Vitality) - thePlayer.GetStat(BCS_Vitality) ) * healpercent) * dt;

		effectManager.CacheStatUpdate(BCS_Vitality, heal);
		super.OnUpdate(dt);
	}

}

function spectreGetCustomAardAttackRangeEnt() : W3AardEntity 
{
    var aardEnt: W3AardEntity;
    var template : CEntityTemplate;
    var tags: array<CName>;

    aardEnt = (W3AardEntity)theGame.GetEntityByTag('spectreCustomAardRangeHack');

    if (!aardEnt) 
	{
        template = (CEntityTemplate)LoadResource("dlc\dlc_spectre\data\gameplay\entities\acs_pc_aard_attack_range_hack.w2ent", true);

        tags.PushBack('spectreCustomAardRangeHack');

        aardEnt = (W3AardEntity) theGame.CreateEntity( template, thePlayer.GetWorldPosition() + Vector(0,0,-500), , , , , PM_Persist, tags);
    }

    return aardEnt;
}