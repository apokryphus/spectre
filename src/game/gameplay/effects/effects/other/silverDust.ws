/***********************************************************************/
/** 	© 2015 CD PROJEKT S.A. All rights reserved.
/** 	THE WITCHER® is a trademark of CD PROJEKT S. A.
/** 	The Witcher game is based on the prose of Andrzej Sapkowski.
/***********************************************************************/



class W3Effect_SilverDust extends CBaseGameplayEffect
{
	default isPositive = false;
	default isNeutral = false;
	default isNegative = true;
	default effectType = EET_SilverDust;
	
	event OnEffectAdded(optional customParams : W3BuffCustomParams)
	{
		if(target == thePlayer) //modSpectre
		{
			target.RemoveBuff(EET_SilverDust);
		}
	
		super.OnEffectAdded(customParams);
		
		
		target.PauseEffects(EET_AutoEssenceRegen, 'silver_dust');
		
		BlockAbilities(true);
	}
	
	event OnEffectRemoved()
	{	
		
		target.ResumeEffects(EET_AutoEssenceRegen, 'silver_dust');
		
		BlockAbilities(false);
		
		super.OnEffectRemoved();
	}
	
	private final function BlockAbilities(block : bool)
	{
		var ret : bool;
		
		ret = target.BlockAbility('EssenceRegen', block) || ret;
		ret = target.BlockAbility('Doppelganger', block) || ret;
		ret = target.BlockAbility('MistCharge', block) || ret;
		ret = target.BlockAbility('ShadowForm', block) || ret;
		ret = target.BlockAbility('MistForm', block) || ret;
		ret = target.BlockAbility('Flashstep', block) || ret;
		ret = target.BlockAbility('Shapeshifter', block) || ret;
		ret = target.BlockAbility('Swarms', block) || ret;
		ret = target.BlockAbility('Teleport', block) || ret;
		ret = target.BlockAbility('FullMoon', block) || ret;
		
		if(block && ret)
		{
			target.PlayEffect('transformation_block');
		}
		else if(!block)
		{
			target.StopEffect('transformation_block');
		}
	}
}