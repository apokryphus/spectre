function spectreGetVersion() : float
{
	return 0.08;
}

function spectreVersionControl(): float
{
	var conf: CInGameConfigWrapper;
	var configValue :float;
	var configValueString : string;

	conf = theGame.GetInGameConfigWrapper();
	
	configValueString = conf.GetVarValue('spectreMainOptions', 'spectreVersionControl');
	
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
	var conf: CInGameConfigWrapper;
	var configValue :int;
	var configValueString : string;
	
	conf = theGame.GetInGameConfigWrapper();
	
	configValueString = conf.GetVarValue('spectreMainOptions', 'spectreInit');

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

function spectreInstantCastingAllowed() : bool
{
	return theGame.params.GetInstantCasting();
}

function spectreTestCastSignHold() : bool
{
	if( theInput.GetActionValue( 'CastSignHold' ) > 0.f )
		return true;
	if( spectreInstantCastingAllowed() )
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

exec function spectrespectreFixQuestItems()
{
	spectreFixQuestItems();
}

function spectreFixQuestItems()
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