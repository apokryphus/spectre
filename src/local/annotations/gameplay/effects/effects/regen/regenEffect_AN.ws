@wrapMethod(W3RegenEffect) function OnUpdate(dt : float)
{
	var regenPoints : float;
	var canRegen : bool;
	var hpRegenPauseBuff : W3Effect_DoTHPRegenReduce;
	var pauseRegenVal, armorModVal : SAbilityAttributeValue;
	var baseStaminaRegenVal : float;
	
	if(false) 
	{
		wrappedMethod(dt);
	}
	
	super.OnUpdate(dt);
	
	if(stat == BCS_Vitality 
	&& isOnPlayer 
	&& target == GetWitcherPlayer() 
	&& GetWitcherPlayer().HasRunewordActive('Runeword 4 _Stats')
	&& !effectManager.HasEffect(EET_AutoVitalityRegen)
	&& !effectManager.HasEffect(EET_AutoStaminaRegen)
	&& !effectManager.HasEffect(EET_AutoEssenceRegen)
	&& !effectManager.HasEffect(EET_AutoMoraleRegen)
	&& !effectManager.HasEffect(EET_AutoAirRegen)
	&& !effectManager.HasEffect(EET_AutoPanicRegen)
	&& !effectManager.HasEffect(EET_AutoSwimmingStaminaRegen)
	)
	{
		canRegen = true;
	}
	else
	{
		canRegen = (target.GetStatPercents(stat) < 1);
	}
	
	if(canRegen)
	{
		
		regenPoints = effectValue.valueAdditive + effectValue.valueMultiplicative * target.GetStatMax(stat);
		
		if(theGame.params.IsArmorRegenPenaltyEnabled())
		{
			if (isOnPlayer && regenStat == CRS_Stamina && attributeName == RegenStatEnumToName(regenStat) && GetWitcherPlayer())
			{
				baseStaminaRegenVal = GetWitcherPlayer().CalculatedArmorStaminaRegenBonus();
				
				regenPoints *= 1 + baseStaminaRegenVal;
			}
		}
		
		if(!(isOnPlayer && target.HasBuff(EET_UndyingSkillImmortal)))
		{
			if(regenStat == CRS_Vitality || regenStat == CRS_Essence)
			{
				hpRegenPauseBuff = (W3Effect_DoTHPRegenReduce)target.GetBuff(EET_DoTHPRegenReduce);
				if(hpRegenPauseBuff)
				{
					pauseRegenVal = hpRegenPauseBuff.GetEffectValue();
					regenPoints = MaxF(0, regenPoints * (1 - pauseRegenVal.valueMultiplicative) - pauseRegenVal.valueAdditive);
				}
			}
		}
		
		if( regenPoints > 0 )
			effectManager.CacheStatUpdate(stat, regenPoints * dt);
	}
}	