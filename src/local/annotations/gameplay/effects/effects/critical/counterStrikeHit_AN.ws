@wrapMethod(W3Effect_CounterStrikeHit) function CacheSettings()
{
	if(false) 
	{
		wrappedMethod();
	}
	
	super.CacheSettings();
	
	blockedActions.PushBack(EIAB_Roll);
	blockedActions.PushBack(EIAB_RunAndSprint);
	blockedActions.PushBack(EIAB_Dodge);
	blockedActions.PushBack(EIAB_Sprint);

	blockedActions.PushBack(EIAB_Signs);
	blockedActions.PushBack(EIAB_DrawWeapon);
	blockedActions.PushBack(EIAB_CallHorse);
	blockedActions.PushBack(EIAB_Movement);
	blockedActions.PushBack(EIAB_Fists);
	blockedActions.PushBack(EIAB_Jump);
	
	blockedActions.PushBack(EIAB_ThrowBomb);
	blockedActions.PushBack(EIAB_Crossbow);
	blockedActions.PushBack(EIAB_UsableItem);
	blockedActions.PushBack(EIAB_SwordAttack);
	blockedActions.PushBack(EIAB_Parry);
	
	blockedActions.PushBack(EIAB_Explorations);
	blockedActions.PushBack(EIAB_Counter);
	blockedActions.PushBack(EIAB_LightAttacks);
	blockedActions.PushBack(EIAB_HeavyAttacks);
	blockedActions.PushBack(EIAB_SpecialAttackLight);
	blockedActions.PushBack(EIAB_SpecialAttackHeavy);
	blockedActions.PushBack(EIAB_QuickSlots);
}