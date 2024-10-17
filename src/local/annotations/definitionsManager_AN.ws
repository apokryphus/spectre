@wrapMethod( CDefinitionsManagerAccessor ) function GetItemLevelFromName( itemName : name ) : int
{
	var itemCategory : name;
	var itemAttributes : array<SAbilityAttributeValue>;
	var min, max : SAbilityAttributeValue;
	var isWitcherGear : bool;
	var isRelicGear : bool;
	var level, baseLevel : int;
	var quality : int; 
	
	if (false)
	{
		wrappedMethod(itemName); 
	}
	
	isWitcherGear = false;
	isRelicGear = false;
	
	GetItemAttributeValueNoRandom(itemName, false, 'quality', min, max );
	
	if ( min.valueAdditive == 5) isWitcherGear = true;
	if ( min.valueAdditive == 4) isRelicGear = true;
	
	quality = RoundMath( min.valueAdditive ); 
	
	itemCategory = GetItemCategory(itemName);
	
	switch(itemCategory)
	{
		case 'armor' :
		case 'boots' : 
		case 'gloves' :
		case 'pants' :
			GetItemAttributeValueNoRandom(itemName, false, 'armor', min, max);
			itemAttributes.PushBack( max );
			break;
			
		case 'silversword' :
			GetItemAttributeValueNoRandom(itemName, false, 'SilverDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'BludgeoningDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'RendingDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'ElementalDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'FireDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'PiercingDamage', min, max);
			itemAttributes.PushBack( max );
			break;
			
		case 'steelsword' :
			GetItemAttributeValueNoRandom(itemName, false, 'SlashingDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'BludgeoningDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'RendingDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'ElementalDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'FireDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'SilverDamage', min, max);
			itemAttributes.PushBack( max );
			GetItemAttributeValueNoRandom(itemName, false, 'PiercingDamage', min, max);
			itemAttributes.PushBack( max );
			break;
			
		case 'crossbow' :
			 GetItemAttributeValueNoRandom(itemName, false, 'attack_power', min, max);
			itemAttributes.PushBack( max );
			 break;
			 
		
		case 'bolt' :
			GetItemAttributeValueNoRandom(itemName, false, 'SilverDamage', min, max);
			itemAttributes.PushBack( max );
			break;
		
			 
		default :
			break;
	}
	
	level = theGame.params.GetItemLevel(itemCategory, itemAttributes, itemName);
	
	return level;
}

@wrapMethod( CDefinitionsManagerAccessor ) function IsItemSetItem( itemName : name ) : bool
{
	if (false)
	{
		wrappedMethod(itemName); 
	}
	
	return
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BEAR) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_GRYPHON) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_LYNX) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_WOLF) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_RED_WOLF) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_VAMPIRE ) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_VIPER) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_NETFLIX) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_KAER_MORHEN) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_BEAR_MINOR) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_GRYPHON_MINOR) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_LYNX_MINOR) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_WOLF_MINOR) ||
	ItemHasTag(itemName, theGame.params.ITEM_SET_TAG_RED_WOLF_MINOR);	
}