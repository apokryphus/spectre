@replaceMethod function fb2(optional level : int)
{
    spectreResetLevels_internal(level);
	spectreAddAutogenEquipment_internal();
}

@replaceMethod function fb3_internal(optional level :int, optional path : name, optional clearInv : bool)
{
	spectreResetLevels_internal(level);

	if(clearInv)
	{
		GetWitcherPlayer().GetInventory().RemoveAllItems();
	}	
	
	spectreAddAutogenEquipment_internal();
	
	switch ( path )
	{
		case 'sword': 	Ep1_sword(); break;
		case 'swords': 	Ep1_sword(); break;
		case 'sign': 	Ep1_signs(); break;
		case 'signs': 	Ep1_signs(); break;
		case 'alchemy': Ep1_alchemy(); break;
		case 'bombs': 	Ep1_alchemy(); break;
		case 'bomb': 	Ep1_alchemy(); break;
		case '':		Ep1_sword(); break;
		default:		Ep1_sword(); break;
	}
	
	GetWitcherPlayer().inv.AddAnItem('Greater mutagen red', 15);
	GetWitcherPlayer().inv.AddAnItem('Greater mutagen green', 15);
	GetWitcherPlayer().inv.AddAnItem('Greater mutagen blue', 15);
	GetWitcherPlayer().AddPoints(ESkillPoint, 60, true);
}