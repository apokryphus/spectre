@addField(CActor)
var bWasCountered				: bool;	

@addField(CActor)
var lastAttackTime				: float;	

@addField(CActor)
var isFocusGainPaused			: bool;	

@wrapMethod(CActor) function GetTotalWeaponDamage(weaponId : SItemUniqueId, damageTypeName : name, crossbowId : SItemUniqueId) : float
{
	var weaponDamage : SAbilityAttributeValue;
	var i : int;
	var inv : CInventoryComponent;
	var damage : float;
	
	if(false) 
	{
		wrappedMethod(weaponId, damageTypeName, crossbowId);
	}
	
	inv = GetInventory();

	weaponDamage = inv.GetItemAttributeValue(weaponId, damageTypeName);

	weaponDamage.valueMultiplicative = 1.0;

	damage = CalculateAttributeValue(weaponDamage);
	
	return damage;		
}

@wrapMethod(CActor) function IsHuman() : bool
{
	var monsterCategory : EMonsterCategory;
	var temp2 : name;
	var temp3, temp4, canBeTargeted : bool;
	
	if(false) 
	{
		wrappedMethod();
	}
	
	if ( cachedIsHuman != -1 )
		return cachedIsHuman > 0;
	
	theGame.GetMonsterParamsForActor(this, monsterCategory, temp2, temp3, canBeTargeted, temp4);
	
	if ( monsterCategory == MC_Human || HasTag( 'ethereal' ) || HasAbility( 'ConHumanoidMonster' ) )
		cachedIsHuman = 1;
	else
		cachedIsHuman = 0;
	
	return cachedIsHuman;
}

@addField(CActor)
var cachedIsBeast : int;

@addMethod(CActor) function spectreIsBeast() : bool
{
	var monsterCategory : EMonsterCategory;
	var tmpName : name;
	var tmpBool : bool;
	
	if ( cachedIsBeast != -1 )
		return cachedIsBeast > 0;
	
	theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	
	if ( monsterCategory == MC_Beast )
		cachedIsBeast = 1;
	else
		cachedIsBeast = 0;
	
	return cachedIsBeast;
}

@addField(CActor)
var cachedIsSpecter : int;

@addMethod(CActor) function spectreIsSpecter() : bool
{
	var monsterCategory : EMonsterCategory;
	var tmpName : name;
	var tmpBool : bool;
	
	if ( cachedIsSpecter != -1 )
		return cachedIsSpecter > 0;
	
	theGame.GetMonsterParamsForActor(this, monsterCategory, tmpName, tmpBool, tmpBool, tmpBool);
	
	if ( monsterCategory == MC_Specter )
		cachedIsSpecter = 1;
	else
		cachedIsSpecter = 0;
	
	return cachedIsSpecter;
}

@replaceMethod(CActor) function HasStaminaToParry( attActionName : name, optional mult : float ) : bool
{
	return HasStaminaToUseAction( ESAT_Parry, '', 0, mult );
}

@addMethod(CActor) function HasStaminaToCounter( attActionName : name, optional mult : float ) : bool
{
	return HasStaminaToUseAction( ESAT_Counterattack, '', 0, mult );
}

@addMethod(CActor) function WasCountered() : bool
{
	return bWasCountered;
}

@addMethod(CActor) function SetWasCountered(counter : bool)
{
	bWasCountered = counter;
	if(bWasCountered)
		AddTimer('ResetWasCountered', 3.0, , , , , true);
	else
		RemoveTimer('ResetWasCountered');
}

@addMethod(CActor) timer function ResetWasCountered(dt : float, id : int)
{
	bWasCountered = false;
}

@addMethod(CActor) function IsFocusGainPaused() : bool
{
	return isFocusGainPaused;
}

@addMethod(CActor) function PauseFocusGain(val : bool)
{
	isFocusGainPaused = val;
}

@addMethod(CActor) timer function ResumeFocusGain(delta : float, id : int)
{
	isFocusGainPaused = false;
	RemoveTimer('ResumeFocusGain');
}

@wrapMethod( CActor ) function OnTakeDamage( action : W3DamageAction )
{
	var playerAttacker : CPlayer;
	var attackName : name;
	var animatedComponent : CAnimatedComponent;
	var buff : W3Effect_Frozen;
	var buffs : array<CBaseGameplayEffect>;
	var i : int;
	var mutagen : CBaseGameplayEffect;
	var min, max : SAbilityAttributeValue;
	var lifeLeech, health, stamina : float;
	var wasAlive : bool;
	var hudModuleDamageType : EFloatingValueType;
	var dontShowDamage : bool;
	var cost, addDamage : float;
	
	if(false) 
	{
		wrappedMethod(action);
	}

	playerAttacker = (CPlayer)action.attacker;
	wasAlive = IsAlive();

	buffs = GetBuffs(EET_Frozen);
	for(i=0; i<buffs.Size(); i+=1)
	{
		buff = (W3Effect_Frozen)buffs[i];
		if(buff.KillOnHit())
		{
			action.processedDmg.vitalityDamage = GetStatMax(BCS_Vitality);
			action.processedDmg.essenceDamage = GetStatMax(BCS_Essence);
			if ( action.attacker == thePlayer )
			{
				ShowFloatingValue(EFVT_InstantDeath, 0, false);
			}
			break;
		}
	}

	if(HasAbility('LastBreath') && action.GetWasFrozen())
	{
		if(action.processedDmg.vitalityDamage > 0 && UsesVitality())
		{
			if(GetStat(BCS_Vitality) - action.processedDmg.vitalityDamage <= 0)
				AddTag('ExplodeNoDamage');
		}
		else if(action.processedDmg.essenceDamage > 0 && UsesEssence())
		{
			if(GetStat(BCS_Essence) - action.processedDmg.essenceDamage <= 0)
				AddTag('ExplodeNoDamage');
		}
	}

	if(!action.GetIgnoreImmortalityMode())
	{
		if( IsImmortal() )
		{
			if( theGame.CanLog() )
			{
				LogDMHits("CActor.OnTakeDamage: victim is Immortal, clamping damage", action );
			}
			action.processedDmg.vitalityDamage = ClampF(action.processedDmg.vitalityDamage, 0, GetStat(BCS_Vitality) - 1);
			action.processedDmg.essenceDamage  = ClampF(action.processedDmg.essenceDamage, 0, GetStat(BCS_Essence) - 1);
		}
	}

	if(((CActor)action.attacker) && action.DealsAnyDamage() )
		((CActor)action.attacker).SignalGameplayEventParamObject( 'DamageInstigated', action );

	if(action.processedDmg.vitalityDamage > 0 && UsesVitality())
	{
		if(this.HasAlternateQuen() && this.HasTag('mq1060_witcher'))
		{
			dontShowDamage = true;
		}
		else
		{
			if(!action.GetMutation5Triggered())
			{
				DrainVitality(action.processedDmg.vitalityDamage);
			}

			action.SetDealtDamage();
		}
	}
	if(action.processedDmg.essenceDamage > 0 && UsesEssence())
	{
		DrainEssence(action.processedDmg.essenceDamage);
		action.SetDealtDamage();
	}
	if(action.processedDmg.moraleDamage > 0)
		DrainMorale(action.processedDmg.moraleDamage);
	if(action.processedDmg.staminaDamage > 0)
		DrainStamina(ESAT_FixedValue, action.processedDmg.staminaDamage, 0);
		

	ShouldAttachArrowToPlayer( action );


	if( ((action.attacker && action.attacker == thePlayer) || (CBaseGameplayEffect)action.causer) && !action.GetUnderwaterDisplayDamageHack() )
	{
		if(action.GetInstantKillFloater())
		{
			hudModuleDamageType = EFVT_InstantDeath;
		}
		else if(action.IsCriticalHit())
		{
			hudModuleDamageType = EFVT_Critical;
		}
		else if(action.IsDoTDamage())
		{
			hudModuleDamageType = EFVT_DoT;
		}
		else
		{
			hudModuleDamageType = EFVT_None;
		}			

		
		if(!dontShowDamage)
			ShowFloatingValue(hudModuleDamageType, action.GetDamageDealt(), (hudModuleDamageType == EFVT_DoT) );
	}


	if(action.attacker && !action.IsDoTDamage() && wasAlive && action.GetDTCount() > 0 && !action.GetUnderwaterDisplayDamageHack())
	{
		theGame.witcherLog.CacheCombatDamageMessage(action.attacker, this, action.GetDamageDealt());
		theGame.witcherLog.AddCombatDamageMessage(action.DealtDamage());
	}
		

	if(playerAttacker)
	{
		if (thePlayer.HasBuff(EET_Mutagen07))
		{
			mutagen = thePlayer.GetBuff(EET_Mutagen07);
			theGame.GetDefinitionsManager().GetAbilityAttributeValue(mutagen.GetAbilityName(), 'lifeLeech', min, max);
			lifeLeech = CalculateAttributeValue(GetAttributeRandomizedValue(min, max));
			if (UsesVitality())
				lifeLeech = lifeLeech * action.processedDmg.vitalityDamage;
			else if (UsesEssence())
				lifeLeech = lifeLeech * action.processedDmg.essenceDamage;
			else
				lifeLeech = 0;
			
			thePlayer.GainStat(BCS_Vitality, lifeLeech);
		}

		if((W3Action_Attack)action && thePlayer.inv.GetItemName(((W3Action_Attack)action).GetWeaponId()) == 'PC Caretaker Shovel')
		{
			lifeLeech = CalculateAttributeValue(thePlayer.inv.GetItemAttributeValue(((W3Action_Attack)action).GetWeaponId() ,'lifesteal'));
			if(UsesVitality())
				lifeLeech *= action.processedDmg.vitalityDamage;
			else if (UsesEssence())
				lifeLeech *= action.processedDmg.essenceDamage;
			else
				lifeLeech = 0;
				
			if(lifeLeech > 0)
			{
				thePlayer.inv.PlayItemEffect(((W3Action_Attack)action).GetWeaponId(), 'stab_attack');
				thePlayer.PlayEffect('drain_energy_caretaker_shovel');
				thePlayer.GainStat(BCS_Vitality, lifeLeech);
			}
		}

		if( ((W3PlayerWitcher)thePlayer).IsSetBonusActive( EISB_Vampire ) && !((W3PlayerWitcher)thePlayer).IsInFistFight() )
		{
			if( action.DealsAnyDamage() && !action.IsDoTDamage() )
				((W3PlayerWitcher)thePlayer).VampiricSetAbilityRegeneration();
		}
	}


	if(playerAttacker && action.IsActionMelee())
	{
		attackName = ((W3Action_Attack)action).GetAttackName();

		if(thePlayer.HasBuff(EET_Mutagen04) && action.DealsAnyDamage() && action.IsActionMelee())
		{
			if(thePlayer.IsDoingSpecialAttack(true))
				cost = thePlayer.GetSpecialAttackTimeRatio() * thePlayer.GetStatMax(BCS_Stamina);
			else if(thePlayer.IsDoingSpecialAttack(false))
				cost = GetWitcherPlayer().GetWhirlStaminaCost(0.25);
			else if(thePlayer.IsHeavyAttack(attackName))
				cost = thePlayer.GetStaminaActionCost(ESAT_HeavyAttack);
			else
				cost = thePlayer.GetStaminaActionCost(ESAT_LightAttack);
			health = ((W3Mutagen04_Effect)thePlayer.GetBuff(EET_Mutagen04)).GetHealthReductionPrc(cost);
			if(UsesVitality())
			{
				health *= GetStat(BCS_Vitality);
				DrainVitality(health);
			}
			else if(UsesEssence())
			{
				health *= GetStat(BCS_Essence);
				DrainEssence(health);
			}
			else
				health = 0;
			
			if(health > 0)
				action.SetDealtDamage();
			
			addDamage = health;

		}
	}

	if(HasBuff(EET_Mutagen16))
	{
		((W3Mutagen16_Effect)GetBuff(EET_Mutagen16)).Mutagen16ModifyHitAnim(action);
	}


	if( !IsAlive() )
	{
		
		
		
		
		
		
		OnDeath( action );
	}

	else if(!(action.IsDoTDamage() && (CBaseGameplayEffect)action.causer))
	{
		if(!HasTag('HideHealthBarModule'))
			DrainStamina(ESAT_FixedValue, 0.0, 1.0 * GetHitSeverityFromDamageData(action) / 4.0);
	}

	SignalGameplayDamageEvent('DamageTaken', action );
}

@wrapMethod( CActor ) function IncHitCounter()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	hitCounter += 1;
	totalHitCounter += 1;
	AddTimer('ResetHitCounter',2.5,false);
}

@wrapMethod( CActor ) function IncDefendCounter()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	defendCounter += 1;
	totalDefendCounter += 1;
	AddTimer('ResetDefendCounter',2.5,false);
}

@wrapMethod( CActor ) function IsImmuneToBuff(effect : EEffectType) : bool
{
	var immunes : CBuffImmunity;
	var i : int;
	var potion, positive, neutral, negative, immobilize, confuse, damage : bool;
	var criticalStatesToResist, resistCriticalStateChance, resistCriticalStateMultiplier : float;
	var mac : CMovingAgentComponent;
		
	if(false) 
	{
		wrappedMethod(effect);
	}
	
	if(effect == EET_Mutation7Debuff)
		return false;

	if(effect == EET_WhirlCooldown || effect == EET_RendCooldown || effect == EET_AardCooldown || effect == EET_IgniCooldown || effect == EET_YrdenCooldown || effect == EET_QuenCooldown || effect == EET_AxiiCooldown)
		return false;
	
	mac = GetMovingAgentComponent();
	
	if ( mac && mac.IsEntityRepresentationForced() == 512 && !IsUsingVehicle() ) 
	{
		if( effect != EET_Snowstorm && effect != EET_SnowstormQ403 )
			return false;
	}
	
	if ( IsCriticalEffectType( effect ) && HasAbility( 'ResistCriticalStates' ) )
	{
		criticalStatesToResist = CalculateAttributeValue( GetAttributeValue( 'critical_states_to_raise_guard' ) );
		resistCriticalStateChance = CalculateAttributeValue( GetAttributeValue( 'resist_critical_state_chance' ) );
		resistCriticalStateMultiplier = CalculateAttributeValue( GetAttributeValue( 'resist_critical_state_chance_mult_per_hit' ) );
		
		criticalStateCounter = GetCriticalStateCounter();
		resistCriticalStateChance += criticalStateCounter * resistCriticalStateMultiplier;
		
		if ( criticalStateCounter >= criticalStatesToResist )
		{
			if( resistCriticalStateChance > RandRangeF( 1, 0 ) )
			{
				return true;
			}
		}
	}
	
	for(i=0; i<buffImmunities.Size(); i+=1)
	{
		if(buffImmunities[i].buffType == effect)
			return true;
	}
	
	for(i=0; i<buffRemovedImmunities.Size(); i+=1)
	{
		if(buffRemovedImmunities[i].buffType == effect)
			return false;
	}
	
	immunes = theGame.GetBuffImmunitiesForActor(this);
	if(immunes.immunityTo.Contains(effect))
		return true;
	
	theGame.effectMgr.GetEffectTypeFlags(effect, potion, positive, neutral, negative, immobilize, confuse, damage);
	if( (potion && immunes.potion) || (positive && immunes.positive) || (neutral && immunes.neutral) || (negative && ( isImmuneToNegativeBuffs || immunes.negative ) ) || (immobilize && immunes.immobilize) || (confuse && immunes.confuse) || (damage && immunes.damage) )
		return true;
		
	return false;
}

@wrapMethod( CActor ) function IsImmuneToBuff(effect : EEffectType) : bool
{
	var immunes : CBuffImmunity;
	var i : int;
	var potion, positive, neutral, negative, immobilize, confuse, damage : bool;
	var criticalStatesToResist, resistCriticalStateChance, resistCriticalStateMultiplier : float;
	var mac : CMovingAgentComponent;
	
	if(false) 
	{
		wrappedMethod(effect);
	}
	
	if(effect == EET_Mutation7Debuff)
		return false;

	if(effect == EET_WhirlCooldown || effect == EET_RendCooldown || effect == EET_AardCooldown || effect == EET_IgniCooldown || effect == EET_YrdenCooldown || effect == EET_QuenCooldown || effect == EET_AxiiCooldown)
		return false;
	
	mac = GetMovingAgentComponent();
	
	if ( mac && mac.IsEntityRepresentationForced() == 512 && !IsUsingVehicle() ) 
	{
		if( effect != EET_Snowstorm && effect != EET_SnowstormQ403 )
			return false;
	}
	
	if ( IsCriticalEffectType( effect ) && HasAbility( 'ResistCriticalStates' ) )
	{
		criticalStatesToResist = CalculateAttributeValue( GetAttributeValue( 'critical_states_to_raise_guard' ) );
		resistCriticalStateChance = CalculateAttributeValue( GetAttributeValue( 'resist_critical_state_chance' ) );
		resistCriticalStateMultiplier = CalculateAttributeValue( GetAttributeValue( 'resist_critical_state_chance_mult_per_hit' ) );
		
		criticalStateCounter = GetCriticalStateCounter();
		resistCriticalStateChance += criticalStateCounter * resistCriticalStateMultiplier;
		
		if ( criticalStateCounter >= criticalStatesToResist )
		{
			if( resistCriticalStateChance > RandRangeF( 1, 0 ) )
			{
				return true;
			}
		}
	}
	
	for(i=0; i<buffImmunities.Size(); i+=1)
	{
		if(buffImmunities[i].buffType == effect)
			return true;
	}
	
	for(i=0; i<buffRemovedImmunities.Size(); i+=1)
	{
		if(buffRemovedImmunities[i].buffType == effect)
			return false;
	}
	
	immunes = theGame.GetBuffImmunitiesForActor(this);
	if(immunes.immunityTo.Contains(effect))
		return true;
	
	theGame.effectMgr.GetEffectTypeFlags(effect, potion, positive, neutral, negative, immobilize, confuse, damage);
	if( (potion && immunes.potion) || (positive && immunes.positive) || (neutral && immunes.neutral) || (negative && ( isImmuneToNegativeBuffs || immunes.negative ) ) || (immobilize && immunes.immobilize) || (confuse && immunes.confuse) || (damage && immunes.damage) )
		return true;
		
	return false;
}

@wrapMethod( CActor ) function AddBuffImmunity_AllNegative(source : name, removeIfPresent : bool)
{
	var i, size : int;
	var potion, positive, neutral, negative, immobilize, confuse, damage : bool;
	
	if(false) 
	{
		wrappedMethod(source, removeIfPresent);
	}
	
	isImmuneToNegativeBuffs = true;
	
	size = (int)EET_EffectTypesSize;
	
	for( i=0; i<size; i+=1 )
	{
		if(i == (int)EET_Mutation7Debuff)
			continue;

		if(i == (int)EET_WhirlCooldown || i == (int)EET_RendCooldown || i == (int)EET_AardCooldown || i == (int)EET_IgniCooldown || i == (int)EET_YrdenCooldown || i == (int)EET_QuenCooldown || i == (int)EET_AxiiCooldown)
			continue;
	
		theGame.effectMgr.GetEffectTypeFlags(i, potion, positive, neutral, negative, immobilize, confuse, damage);
	
		if( negative )
			AddBuffImmunity(i, source, removeIfPresent);
	}
}

@wrapMethod( CActor ) function RemoveBuffImmunity_AllNegative(optional source : name)
{
	var i, size : int;
	var potion, positive, neutral, negative, immobilize, confuse, damage : bool;
	
	if(false) 
	{
		wrappedMethod(source);
	}
	
	isImmuneToNegativeBuffs = false;
	
	size = (int)EET_EffectTypesSize;
	
	for( i=0; i<size; i+=1 )
	{
		theGame.effectMgr.GetEffectTypeFlags(i, potion, positive, neutral, negative, immobilize, confuse, damage);
	
		if( negative )
			RemoveBuffImmunity(i, source);
	}
}

@addMethod(CActor) timer function RemoveGoldenOriolePoisonImmunity(time : float, id : int)
{
	RemoveBuffImmunity(EET_Poison, 'GoldenOrioleTempPoisonImmunity');
	RemoveBuffImmunity(EET_PoisonCritical, 'GoldenOrioleTempPoisonImmunity');
}

@wrapMethod( CActor ) function TestParryAndCounter(data : CPreAttackEventData, weaponId : SItemUniqueId, out parried : bool, out countered : bool) : array<CActor>
{
	var actor : CActor;
	var i : int;
	var parryInfo : SParryInfo;
	var parriedBy : array<CActor>;
	var npc : CNewNPC;
	var playerTarget : CR4Player;
	var levelDiff : int;
	var chanceToFailParry : float;
	
	if(false) 
	{
		wrappedMethod(data, weaponId, parried, countered);
	}
	
	SetDebugAttackRange(data.rangeName);
	RemoveTimer('PostAttackDebugRangeClear');		
	
	
	for(i=hitTargets.Size()-1; i>=0; i-=1)
	{
		actor = (CActor)hitTargets[i];
		if(!actor)
			continue;				
		
		parryInfo = ProcessParryInfo(this, actor, data.swingType, data.swingDir, attackActionName, weaponId, data.Can_Parry_Attack );
		playerTarget = (CR4Player)hitTargets[i];
		parried = false;
		countered = false;
		
		if( FactsQuerySum( "tut_fight_start" ) > 0 || actor.HasAbility( 'IgnoreLevelDiffForParryTest' ) )
			levelDiff = 0;
		else
			levelDiff = GetLevel() - actor.GetLevel();
		
		if( thePlayer.IsInFistFightMiniGame() || (!playerTarget || playerTarget.IsActionAllowed(EIAB_Counter)) )
			countered = actor.PerformCounterCheck(parryInfo);
			
		if(!countered)
		{
			if( thePlayer.IsInFistFightMiniGame() || (!playerTarget || playerTarget.IsActionAllowed(EIAB_Parry)) )
			{
				parried = actor.PerformParryCheck(parryInfo);
			}
		}
		else if(playerTarget)
		{
			FactsAdd("ach_counter", 1, 4 );
			theGame.GetGamerProfile().CheckLearningTheRopes();
		}
			
		
														
		
		
		if(countered || parried)
		{
			
			actor.SetDetailedHitReaction(data.swingType, data.swingDir);

			if ( theGame.CanLog() )
			{			
				
				LogAttackRangesDebug("");
				if(countered)
				{
					LogDMHits("Attack countered by <<" + actor + ">>");
					LogAttackRangesDebug("Attack countered by <<" + actor + ">>");
				}
				else if(parried)
				{
					LogDMHits("Attack parried by <<" + actor + ">>");
					LogAttackRangesDebug("Attack parried by <<" + actor + ">>");
				}
			}
		
			parriedBy.PushBack(actor);
		}
	}
	
	return parriedBy;
}

@wrapMethod( CActor ) function DoAttack(animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float)
{
	var i : int;		
	var weaponEntity : CItemEntity;
	var phantomWeapon : W3Effect_PhantomWeapon;
		
	if(false) 
	{
		wrappedMethod(animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime);
	}
	
	weaponEntity = GetInventory().GetItemEntityUnsafe(weaponId);
	
	phantomStrike = false;
	phantomWeapon = (W3Effect_PhantomWeapon)GetBuff( EET_PhantomWeapon );
	if( GetInventory().ItemHasTag( weaponId, 'PhantomWeapon' ) && IsHeavyAttack( attackActionName ) )
	{
		if( this == thePlayer )
		{
			if(phantomWeapon && phantomWeapon.IsWeaponCharged())
			{
				phantomStrike = true;
			}
		}
		else
		{
			phantomStrike = true;
		}
	}
	
	for(i=0; i<hitTargets.Size(); i+=1)
	{				
		Attack(hitTargets[i], animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity);
	}
	
	if(  phantomStrike )
	{
		AddTimer('PhantomWeapon', 0.0);
		phantomWeaponHitTime = hitTime + 0.0;
		phantomWeaponAnimData = animData;
		phantomWeaponWeaponId = weaponId;
		phantomWeaponParried = parried;
		phantomWeaponCountered = countered;
		phantomWeaponParriedBy = parriedBy;
		phantomWeaponAttackAnimationName = attackAnimationName;
		phantomWeaponHitTargets = hitTargets;
	}
	else
	{
		attackActionName = '';
	}
	
	hitTargets.Clear();
	AddTimer('PostAttackDebugRangeClear', 1);	
}

@wrapMethod( CActor ) function PhantomWeapon(dt : float, id : int)
{
	var i : int;		
	var weaponEntity : CItemEntity;

	if(false) 
	{
		wrappedMethod(dt, id);
	}
	
	weaponEntity = GetInventory().GetItemEntityUnsafe(phantomWeaponWeaponId);

	if( this == thePlayer )
	{
		AddAbility( 'ForceDismemberment' );
	}
	
	AddTimer('PostAttackDebugRangeClear', 1);
	attackActionName = '';
}

@wrapMethod( CActor ) function PrepareAttackAction( hitTarget : CGameplayEntity, animData : CPreAttackEventData, weaponId : SItemUniqueId, parried : bool, countered : bool, parriedBy : array<CActor>, attackAnimationName : name, hitTime : float, weaponEntity : CItemEntity, out attackAction : W3Action_Attack) : bool
{
	var actor : CActor;
	var npc : CNewNPC;
	var canDodge : bool;
	var attackSrc : string;
	
	if(false) 
	{
		wrappedMethod( hitTarget, animData, weaponId, parried, countered, parriedBy, attackAnimationName, hitTime, weaponEntity, attackAction);
	}
	
	if(!hitTarget)
		return false;
		
	attackAction = new W3Action_Attack in theGame.damageMgr;
	
	if ( animData.hitFX == 'basedOnWeapon' )
		ChangeHitFxBasedOnWeapon(animData, weaponId);
	
	if ( phantomStrike )
	{
		canDodge = false;
		attackSrc = "PhantomWeapon";
	}
	else
	{
		canDodge = animData.canBeDodged;
		attackSrc = GetName();
	}
		
	attackAction.Init( this, hitTarget, NULL, weaponId, animData.attackName, attackSrc, animData.hitReactionType, animData.Can_Parry_Attack, canDodge, attackActionName, animData.swingType, animData.swingDir, true, false, false, false, animData.hitFX, animData.hitBackFX, animData.hitParriedFX, animData.hitBackParriedFX);
	
	attackAction.SetAttackAnimName(attackAnimationName);
	attackAction.SetHitTime(hitTime);
	attackAction.SetWeaponEntity(weaponEntity);
	attackAction.SetWeaponSlot(animData.weaponSlot);
	attackAction.SetSoundAttackType(animData.soundAttackType);
	
	actor = (CActor)hitTarget;
	
	if(actor && parriedBy.Contains(actor))
	{
		if(parried)
		{
			attackAction.SetIsParried(true);
			SignalGameplayEvent('AttackParried');
		}
		else if(countered)
		{
			attackAction.SetIsCountered(true);
			SignalGameplayEvent('AttackCountered');
		}
	}
	
	if ( attackAction.IsParried() && attackAction.attacker.HasAbility('ReflectOnBeingParried') )
	{
		((CActor)attackAction.attacker).SetCanPlayHitAnim( true );
		ReactToReflectedAttack(attackAction.victim);
	}
	
	
	if(phantomStrike)
	{
		attackAction.SetIsParried(false);
		attackAction.SetHitAnimationPlayType(EAHA_ForceNo);
		
		if( attackAction.attacker == thePlayer )
		{
			npc = (CNewNPC)attackAction.victim;
			if( npc && npc.IsShielded( thePlayer ) )
				npc.ProcessShieldDestruction();
			attackAction.AddEffectInfo( EET_Stagger );
		}
		else
		{
			if( parried )
			{				
				attackAction.AddEffectInfo( EET_Stagger );
				attackAction.ClearDamage();
			}
			else if( !parried && !countered )
			{
				attackAction.AddEffectInfo( EET_Knockdown );
			}
		}
	}
	
	return true;
}

@addMethod(CActor) function DodgeDamage(out damageData : W3DamageAction)
{
	if(this != thePlayer && IsCurrentlyDodging() && damageData.CanBeDodged() &&
		( VecDistanceSquared(this.GetWorldPosition(),damageData.attacker.GetWorldPosition()) > 1.7
			|| this.HasAbility( 'IgnoreDodgeMinimumDistance' ) ))
	{
		if ( theGame.CanLog() )
		{
			LogDMHits("Non-player character dodge - no damage dealt", damageData);
		}

		//damageData.SetWasDodged();
		//damageData.SetAllProcessedDamageAs(0);
		//damageData.ClearEffects();

		if (this.UsesVitality())
		{
			damageData.processedDmg.vitalityDamage -= damageData.processedDmg.vitalityDamage * 0.5;
		}
		else if (this.UsesEssence())
		{
			damageData.processedDmg.essenceDamage -= damageData.processedDmg.essenceDamage * 0.5;
		}

		damageData.SetHitAnimationPlayType(EAHA_ForceYes);
	}
}

@wrapMethod( CActor ) function ReduceDamage( out damageData : W3DamageAction )
{
	var actorAttacker 			: CActor;
	var id 						: SItemUniqueId;
	var attackAction 			: W3Action_Attack;
	var arrStr 					: array<string>;
	var l_percAboutToBeRemoved 	: float;
	var l_healthPerc			: float;
	var l_threshold				: float;
	var l_maxPercLossAllowed	: float;
	var l_maxDamageAllowed		: float;
	var l_maxHealth, mult		: float;
	var l_actorTarget			: CActor;
	var canLog					: bool;
	var hitsToKill				: SAbilityAttributeValue;
	var thisNPC					: CNewNPC;
	var minDamage				: float;
	var i						: int;
	var dmgTypes 				: array< SRawDamage >;
	var mutagen28dmgMult		: float;
	var maxAllowedDmg, minAllowedDmg, dmg : float;
	
	if(false) 
	{
		wrappedMethod( damageData );
	}
	
	canLog = theGame.CanLog();
		
	actorAttacker = (CActor)damageData.attacker;
	
	if(damageData.IsActionRanged() && damageData.attacker == thePlayer && (W3BoltProjectile)(damageData.causer) )
	{
		if(UsesEssence() && damageData.processedDmg.essenceDamage < 1)
		{
			damageData.processedDmg.essenceDamage = 1;
				
			if ( canLog )
			{
				LogDMHits("CActor.ReduceDamage: victim would take no damage but it's a bolt so we deal 1 pt of damage", damageData );
			}
		}
		else if(UsesVitality() && damageData.processedDmg.vitalityDamage < 1)
		{
			damageData.processedDmg.vitalityDamage = 1;
			
			if ( canLog )
			{
				LogDMHits("CActor.ReduceDamage: victim would take no damage but it's a bolt so we deal 1 pt of damage", damageData );
			}
		}
	}
	
	
	ModifyHitSeverityReactionFromDamage( damageData );
	
	thisNPC = (CNewNPC)this;
	if( thisNPC && damageData.attacker == thePlayer && !HasBuff(EET_AxiiGuardMe) &&
		( GetAttitudeBetween( this, thePlayer ) == AIA_Friendly ||
		( GetAttitudeBetween( this, thePlayer ) == AIA_Neutral && thisNPC.GetNPCType() == ENGT_Guard ) ) )
	{
		if ( canLog )
		{
			LogDMHits("Player attacked friendly or neutral community npc - no damage dealt", damageData);
		}
		damageData.SetAllProcessedDamageAs(0);
		damageData.ClearEffects();
		return;
	}
	
	
	if(damageData.IsActionMelee() && HasAbility( 'ReflectMeleeAttacks' ) )
	{
		if ( canLog )
		{
			LogDMHits("CActor.ReduceDamage: victim is heavily armored and attacker bounces of his armor", damageData );
		}
		damageData.SetAllProcessedDamageAs(0);
		((CActor)damageData.attacker).ReactToReflectedAttack( this );
		damageData.ClearEffects();
		return;
	}
	
	if(damageData.IsActionMelee() && HasAbility( 'CannotBeAttackedFromAllSides' ) )
	{
		if ( canLog )
		{
			LogDMHits("CActor.ReduceDamage: victim attacked from behind and immune to this type of strike - no damage will be done", damageData );
		}
		damageData.SetAllProcessedDamageAs(0);
		((CActor)damageData.attacker).ReactToReflectedAttack( this );
		damageData.ClearEffects();
		return;
	}
	
	
	if(damageData.IsActionMelee() && HasAbility( 'CannotBeAttackedFromBehind' ) && IsAttackerAtBack(damageData.attacker) )
	{
		if ( canLog )
		{
			LogDMHits("CActor.ReduceDamage: victim attacked from behind and immune to this type of strike - no damage will be done", damageData );
		}
		damageData.SetAllProcessedDamageAs(0);
		((CActor)damageData.attacker).ReactToReflectedAttack( this );
		damageData.ClearEffects();
		return;
	}

	
	if(this != thePlayer && FactsDoesExist("debug_fact_weak"))
	{
		if ( canLog )
		{
			LogDMHits("CActor.ReduceDamage: using 'weak' cheat - all damage set to 0.001", damageData );
		}
		damageData.processedDmg.essenceDamage = MinF(0.001, damageData.processedDmg.essenceDamage);
		damageData.processedDmg.vitalityDamage = MinF(0.001, damageData.processedDmg.vitalityDamage);
		damageData.processedDmg.staminaDamage = MinF(0.001, damageData.processedDmg.staminaDamage);
		damageData.processedDmg.moraleDamage = MinF(0.001, damageData.processedDmg.moraleDamage);
	}
	

	if(damageData.IsParryStagger())
	{
		mult = 1 - theGame.params.PARRY_STAGGER_REDUCE_DAMAGE;
		
		if(this == thePlayer && thePlayer.CanUseSkill(S_Sword_s10))
			mult -= CalculateAttributeValue(thePlayer.GetSkillAttributeValue(S_Sword_s10, 's10_damage_reduction', false, false)) * thePlayer.GetSkillLevel(S_Sword_s10);
		
		mult = ClampF(mult, 0, 1);

		if( FactsQuerySum( "modSpectre_debug_reduce_damage" ) > 0 )
		{
			theGame.witcherLog.AddMessage("Stagger-Parry, reducing damage by " + NoTrailZeros((1-mult)*100) + "%");
		}
	
		damageData.MultiplyAllDamageBy(mult);
		
		if ( canLog )
		{
			LogDMHits("Stagger-Parry, reducing damage by " + NoTrailZeros((1-mult)*100) + "%");
		}
	}
	else
	{
		
		attackAction = (W3Action_Attack)damageData;
		if(attackAction && damageData.IsActionMelee() && (attackAction.IsParried() || attackAction.IsCountered()))
		{
			arrStr.PushBack(GetDisplayName());
			if(attackAction.IsParried())
			{
				if ( canLog )
				{
					LogDMHits("Attack parried - no damage", damageData);
				}
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_parries", , , arrStr), attackAction.attacker, this);
			}
			else
			{
				if ( canLog )
				{			
					LogDMHits("Attack countered - no damage", damageData);
				}
				theGame.witcherLog.AddCombatMessage(GetLocStringByKeyExtWithParams("hud_combat_log_counters", , , arrStr), attackAction.attacker, this);
			}
			
			damageData.SetAllProcessedDamageAs(0);
			return;
		}
	}
	

	if((CPlayer)actorAttacker && !((CPlayer)damageData.victim) && FactsQuerySum('player_is_the_boss') > 0)
	{
		if ( canLog )
		{			
			LogDMHits("Using 'like a boss' cheat - damage set to 40% of targets MAX health", damageData);
		}
		damageData.processedDmg.vitalityDamage = GetStatMax(BCS_Vitality) / 2.5;		
		damageData.processedDmg.essenceDamage = GetStatMax(BCS_Essence) / 2.5;		
	}	
	
	if(attackAction && actorAttacker == thePlayer && thePlayer.inv.IsItemBolt(attackAction.GetWeaponId()) )		
	{
		if(thePlayer.IsOnBoat())
		{
			hitsToKill = GetAttributeValue('extraDamageWhenPlayerOnBoat');
			if(hitsToKill.valueAdditive > 0)
			{
				damageData.processedDmg.vitalityDamage = CeilF(GetStatMax(BCS_Vitality) / hitsToKill.valueAdditive);	
				damageData.processedDmg.essenceDamage = CeilF(GetStatMax(BCS_Essence) / hitsToKill.valueAdditive);		
				
				if(theGame.CanLog())
				{
					LogDMHits("Target is getting killed by " + NoTrailZeros(hitsToKill.valueAdditive) + " hits when being shot from boat by default bolts", damageData);
					LogDMHits("Final hacked damage is now, vit: " + NoTrailZeros(damageData.processedDmg.vitalityDamage) + ", ess: " + NoTrailZeros(damageData.processedDmg.essenceDamage), damageData);
				}
			}
		}
	}		
	
	if( HasAbility( 'ShadowFormActive' ) )
	{
		if(actorAttacker == thePlayer && thePlayer.HasBuff(EET_Mutagen28))
		{
			mutagen28dmgMult = ((W3Mutagen28_Effect)thePlayer.GetBuff(EET_Mutagen28)).GetDmgMultiplier();
		}
		else
		{
			mutagen28dmgMult = 0.1f;
			damageData.SetCanPlayHitParticle( false );
		}
		if ( canLog )
		{
			LogDMHits("CActor.ReduceDamage: victim has ShadowFormActive ability - damage reduced to a percentage of base", damageData );
		}
		damageData.processedDmg.vitalityDamage *= mutagen28dmgMult;
		damageData.processedDmg.essenceDamage *= mutagen28dmgMult;
		theGame.witcherLog.CombatMessageAddGlobalDamageMult(mutagen28dmgMult);
	}
	if( actorAttacker.HasAbility( 'ShadowFormActive' ) )
	{
		if(this == thePlayer && HasBuff(EET_Mutagen28))
		{
			mutagen28dmgMult = ((W3Mutagen28_Effect)thePlayer.GetBuff(EET_Mutagen28)).GetDmgReduction();
			damageData.processedDmg.vitalityDamage *= mutagen28dmgMult;
			damageData.processedDmg.essenceDamage *= mutagen28dmgMult;
		}
	}
	
	if( HasAbility( 'LastBreath' ) && !damageData.GetWasFrozen() )
	{
		l_threshold 	= CalculateAttributeValue( GetAttributeValue('lastbreath_threshold') );
		if( l_threshold == 0 ) l_threshold = 0.25f;
		l_healthPerc 	= GetHealthPercents();
		
		
		if( theGame.GetEngineTimeAsSeconds() - lastBreathTime < 1 )
		{
			if( damageData.processedDmg.vitalityDamage > 0 ) 	damageData.processedDmg.vitalityDamage 	= 0;
			if( damageData.processedDmg.essenceDamage > 0 ) 	damageData.processedDmg.essenceDamage 	= 0;
			
			if ( canLog )
			{
				LogDMHits("CActor.ReduceDamage: victim just activated LastBreath ability - reducing damage" );
			}
		}
		else if( l_healthPerc > l_threshold )
		{
			l_maxHealth 			= GetMaxHealth();
			l_percAboutToBeRemoved 	= MaxF( damageData.processedDmg.vitalityDamage, damageData.processedDmg.essenceDamage ) / l_maxHealth;
			
			l_maxPercLossAllowed 	= l_healthPerc - l_threshold;
			
			if( l_percAboutToBeRemoved > l_maxPercLossAllowed )
			{
				
				l_maxDamageAllowed = l_maxPercLossAllowed * l_maxHealth;
				if( damageData.processedDmg.vitalityDamage > 0 ) 	damageData.processedDmg.vitalityDamage 	= l_maxDamageAllowed;
				if( damageData.processedDmg.essenceDamage > 0 ) 	damageData.processedDmg.essenceDamage 	= l_maxDamageAllowed;
				if ( canLog )
				{
					LogDMHits("CActor.ReduceDamage: victim has LastBreath ability - reducing damage", damageData );
				}
				
				SignalGameplayEvent('LastBreath');
				lastBreathTime = theGame.GetEngineTimeAsSeconds();					
				DisableHitAnimFor( 1 );
			}
		}
	}
	
	if( this != thePlayer && GetAttitudeBetween(this, thePlayer) == AIA_Friendly && GetAttitudeBetween(actorAttacker, thePlayer) == AIA_Hostile )
	{
		if( HasBuff( EET_AxiiGuardMe ) )
		{
			maxAllowedDmg = MaxF(20, 0.15 * GetMaxHealth());
			minAllowedDmg = MaxF(10, 0.10 * GetMaxHealth());
		}
		else
		{
			maxAllowedDmg = MaxF(20, 0.02 * GetMaxHealth());
			minAllowedDmg = MaxF(10, 0.01 * GetMaxHealth());
		}

		dmg = RandRangeF(maxAllowedDmg, minAllowedDmg);
		damageData.processedDmg.vitalityDamage = dmg;
		damageData.processedDmg.essenceDamage = dmg;
	}
		
	if(!damageData.GetIgnoreImmortalityMode())
	{
		if( IsInvulnerable() )
		{
			if ( canLog )
			{
				LogDMHits("CActor.ReduceDamage: victim Invulnerable - no damage will be dealt", damageData );
			}
			damageData.SetAllProcessedDamageAs(0);

		}
	}
}

@addMethod(CActor) function GetDelaySinceLastAttack() : float
{
	return theGame.GetEngineTimeAsSeconds() - lastAttackTime;
}

@addField(CActor) 
var shouldWaitForStaminaRegen : bool;

@addMethod(CActor) function CheckShouldWaitForStaminaRegen()
{
	if(GetStatPercents(BCS_Stamina) < 0.1 && !shouldWaitForStaminaRegen)
		shouldWaitForStaminaRegen = true;
	if(GetStatPercents(BCS_Stamina) > 0.334 && shouldWaitForStaminaRegen)
		shouldWaitForStaminaRegen = false;
}

@wrapMethod(CActor) function OnProcessActionPost(action : W3DamageAction)
{
	wrappedMethod(action);
		
	lastAttackTime = theGame.GetEngineTimeAsSeconds();
}

@wrapMethod(CActor) function IsHuge() : bool
{
	if(false) 
	{
		wrappedMethod();
	}
	
	return (GetCapsuleHeight() > 2.0f);
}

@addMethod(CActor) function GetCapsuleHeight() : float
{
	return ((CMovingPhysicalAgentComponent)GetMovingAgentComponent()).GetCapsuleHeight();
}