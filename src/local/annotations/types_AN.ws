@replaceMethod function ModifyHitSeverityReaction(target : CActor, type : EHitReactionType) : EHitReactionType
{
    return type;
}

function ModifyHitSeverityReactionFromDamage( out damageData : W3DamageAction )
{
	var healthPrc, damage, capsuleHeight : float;
	var type : EHitReactionType;
	var severityReduction : int;
	var actorVictim : CActor;
	var npcVictim : CNewNPC;
	var attackAction : W3Action_Attack;
	
	if( damageData.IsDoTDamage() )
		return;
		
	attackAction = (W3Action_Attack)damageData;
	
	if( attackAction && ( attackAction.IsParried() || attackAction.IsCountered() || attackAction.WasDodged() ) )
		return;
	
	actorVictim = (CActor)damageData.victim;
	
	if( !actorVictim )
		return;
		
	npcVictim = (CNewNPC)actorVictim;
	
	if(npcVictim && npcVictim.IsFlying())
	{
		return;
	}

	if(actorVictim.UsesEssence() && damageData.processedDmg.essenceDamage < 1)
	{
		damageData.processedDmg.essenceDamage = 0;
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
		return;
	}
	
	if(actorVictim.UsesVitality() && damageData.processedDmg.vitalityDamage < 1)
	{
		damageData.processedDmg.vitalityDamage = 0;
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
		return;
	}

	if(actorVictim.HasAbility('mon_golem_base'))
	{
		damageData.SetHitReactionType(EHRT_None);
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
		return;
	}
	
	capsuleHeight = actorVictim.GetCapsuleHeight();

	if(damageData.IsActionMelee() && capsuleHeight <= 2.0f)
		return;

	type = damageData.GetHitReactionType();
	
	if(actorVictim.UsesEssence())
		damage = damageData.processedDmg.essenceDamage;
	else
		damage = damageData.processedDmg.vitalityDamage;
	
	healthPrc = damage / actorVictim.GetMaxHealth() * 100;
	
	healthPrc /= 1 + MaxF(0, capsuleHeight - 2);
	
	if( healthPrc < 1 )
		severityReduction = 2;
	else if( healthPrc < 3 )
		severityReduction = 1;

	type = ModifySeverity( type, severityReduction );

	if(type != damageData.GetHitReactionType())
		damageData.SetHitReactionType(type);
	if(type == EHRT_None)
		damageData.SetHitAnimationPlayType(EAHA_ForceNo);
}

function ModifySeverity(type : EHitReactionType, severityReduction : int) : EHitReactionType
{
	var severity : int;

	if(severityReduction == 0)
		return type;
		
	switch(type)
	{
		case EHRT_Reflect :
			return type;
		case EHRT_Igni :
		case EHRT_Heavy :
			severity = 2;
			break;
		case EHRT_Light :
		case EHRT_LightClose :
			severity = 1; 
			break;
		default :
			severity = 0;
			break;
	}
	
 
	severity = Clamp(severity - severityReduction, 0, 2);
 
	
	switch(severity)
	{
		case 2:		return EHRT_Heavy;
		case 1:		return EHRT_Light;
		default :	return EHRT_None;
	}
}

function GetHitSeverityFromDamageData( damageData : W3DamageAction ) : int
{
	var healthPrc, damage, capsuleHeight : float;
	var actorVictim : CActor;

	if( damageData.IsDoTDamage() && (CBaseGameplayEffect)damageData.causer || !damageData.DealtDamage() )
		return 0;
		
	actorVictim = (CActor)damageData.victim;
	
	if(actorVictim.UsesEssence())
		damage = damageData.processedDmg.essenceDamage;
	else
		damage = damageData.processedDmg.vitalityDamage;
	
	healthPrc = damage / actorVictim.GetMaxHealth() * 100;
	
	capsuleHeight = actorVictim.GetCapsuleHeight();
	
	healthPrc /= 1 + MaxF(0, capsuleHeight - 2);
	
	if(healthPrc < 5)
		return 0;
	if(healthPrc < 10)
		return 1;
	if(healthPrc < 15)
		return 2;
	if(healthPrc < 20)
		return 3;
	return 4;
}

@replaceMethod function MonsterCategoryToCriticalChanceBonus(type : EMonsterCategory) : name
{
    switch(type)
	{
		case MC_Beast :				return 'vsBeast_critical_hit_chance';
		case MC_Cursed :			return 'vsCursed_critical_hit_chance';
		case MC_Draconide :			return 'vsDraconide_critical_hit_chance';
		case MC_Human :				return 'vsHuman_critical_hit_chance';
		case MC_Hybrid :			return 'vsHybrid_critical_hit_chance';
		case MC_Insectoid :			return 'vsInsectoid_critical_hit_chance';
		case MC_Magicals :			return 'vsMagicals_critical_hit_chance';
		case MC_Necrophage :		return 'vsNecrophage_critical_hit_chance';
		case MC_Relic :				return 'vsRelic_critical_hit_chance';
		case MC_Specter :			return 'vsSpecter_critical_hit_chance';
		case MC_Troll :				return 'vsOgre_critical_hit_chance';
		case MC_Vampire :			return 'vsVampire_critical_hit_chance';
		
		default :				return '';
	}
}

@replaceMethod function MonsterCategoryToCriticalDamageBonus(type : EMonsterCategory) : name
{
    switch(type)
	{
		case MC_Beast :				return 'vsBeast_critical_hit_damage_bonus';
		case MC_Cursed :			return 'vsCursed_critical_hit_damage_bonus';
		case MC_Draconide :			return 'vsDraconide_critical_hit_damage_bonus';
		case MC_Human :				return 'vsHuman_critical_hit_damage_bonus';
		case MC_Hybrid :			return 'vsHybrid_critical_hit_damage_bonus';
		case MC_Insectoid :			return 'vsInsectoid_critical_hit_damage_bonus';
		case MC_Magicals :			return 'vsMagicals_critical_hit_damage_bonus';
		case MC_Necrophage :		return 'vsNecrophage_critical_hit_damage_bonus';
		case MC_Relic :				return 'vsRelic_critical_hit_damage_bonus';
		case MC_Specter :			return 'vsSpecter_critical_hit_damage_bonus';
		case MC_Troll :				return 'vsOgre_critical_hit_damage_bonus';
		case MC_Vampire :			return 'vsVampire_critical_hit_damage_bonus';
		
		default :				return '';
	}
}

@replaceMethod function MonsterCategoryToResistReduction(type : EMonsterCategory) : name
{
	switch(type)
	{
		case MC_Beast :				return 'vsBeast_resist_reduction';
		case MC_Cursed :			return 'vsCursed_resist_reduction';
		case MC_Draconide :			return 'vsDraconide_resist_reduction';
		case MC_Human :				return 'vsHuman_resist_reduction';
		case MC_Hybrid :			return 'vsHybrid_resist_reduction';
		case MC_Insectoid :			return 'vsInsectoid_resist_reduction';
		case MC_Magicals :			return 'vsMagicals_resist_reduction';
		case MC_Necrophage :		return 'vsNecrophage_resist_reduction';
		case MC_Relic :				return 'vsRelic_resist_reduction';
		case MC_Specter :			return 'vsSpecter_resist_reduction';
		case MC_Troll :				return 'vsOgre_resist_reduction';
		case MC_Vampire :			return 'vsVampire_resist_reduction';
		
		default :				return '';
	}
}