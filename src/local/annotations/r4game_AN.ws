@addMethod(CR4Game) function spectreUserSettingsScaling() 
{
	var i : int;
	var all : array<CActor>;
	
	all = GetActorsInRange(thePlayer, 10000.f, 10000, '', true);
	for(i = 0; i < all.Size(); i += 1)
	{
		if((CNewNPC)all[i])
			((CNewNPC)all[i]).ResetLevel();
	}
}

@addMethod(CR4Game) function spectreUserSettingsQuestLevels()
{
	LoadQuestLevels( "gameplay\globals\quest_levels.csv" );
	if(theGame.GetDLCManager().IsEP1Enabled())
		LoadQuestLevels( "dlc\ep1\data\gameplay\globals\quest_levels.csv" );
	if(theGame.GetDLCManager().IsEP2Enabled())
		LoadQuestLevels( "dlc\bob\data\gameplay\globals\quest_levels.csv" );
}

@addMethod(CR4Game) function spectreUserSettingsGameplay()
{
	params.spectreResetCachedValuesGameplay();
	spectreUpdateRegenEffects();
}

@wrapMethod(CR4Game) function LoadQuestLevels( filePath: string ) : void
{
	var index : int;	
	
	if(false) 
	{
		wrappedMethod(filePath);
	}
	
	if( theGame.params.GetNoQuestLevels() )
	{
		questLevelsFilePaths.Clear();
		questLevelsContainer.Clear();
		return;
	}
	
	index = questLevelsFilePaths.FindFirst( filePath );		
	if( index == -1 )
	{		
		questLevelsFilePaths.PushBack( filePath );	
		questLevelsContainer.PushBack( LoadCSV( filePath ) ); 
	}
}

@wrapMethod(CR4Game) function OnGiveReward( target : CEntity, rewardName : name, rewrd : SReward )
{
	var i 						: int;
	var itemCount				: int;
	var gameplayEntity 			: CGameplayEntity;
	var inv		 				: CInventoryComponent;
	var goldMultiplier			: float;
	var itemMultiplier			: float;
	var itemsCount				: int;
	var ids						: array<SItemUniqueId>;
	var itemCategory 			: name;
	var moneyWon				: int;
	var rewardMultData			: SRewardMultiplier;
	var lvlDiff					: int;
	var playerLevel, rewardLevel: int;
	var expModifier				: float;
	var expPoints				: int;
	
	if(false) 
	{
		wrappedMethod(target, rewardName, rewrd);
	}
	
	if ( target == thePlayer )
	{
		if ( rewrd.experience > 0 && GetWitcherPlayer())
		{
			expModifier = 1.f;
			playerLevel = thePlayer.GetLevel();

			if(FactsQuerySum("NewGamePlus") > 0) 
				playerLevel -= params.GetNewGamePlusLevel();
			if(theGame.params.GetNoQuestLevels()) 
				rewardLevel = 0;
			else
				rewardLevel = rewrd.level;
			if(theGame.params.GetFixedExp() == false && rewardLevel > 0) 
			{
				lvlDiff = rewardLevel - playerLevel; 

				expModifier += lvlDiff * theGame.params.LEVEL_DIFF_XP_MOD;

				expModifier = ClampF(expModifier, 0, theGame.params.MAX_XP_MOD);
	
			}

			expPoints = RoundMath(rewrd.experience * expGlobalMod_quests * expModifier);

			expPoints = Max(5, expPoints);

			if( theGame.params.GetQuestExpModifier() != 0 )
				expPoints = RoundMath(expPoints * (1 + theGame.params.GetQuestExpModifier()));
			GetWitcherPlayer().AddPoints(EExperiencePoint, expPoints, true);
		}
   
		if ( rewrd.achievement > 0 )
		{
			theGame.GetGamerProfile().AddAchievement( rewrd.achievement );
		}
	}
	
	gameplayEntity = (CGameplayEntity)target;
	if ( gameplayEntity )
	{
		inv = gameplayEntity.GetInventory();
		if ( inv )
		{
			rewardMultData = thePlayer.GetRewardMultiplierData( rewardName );

			if( rewardMultData.isItemMultiplier )
			{
				goldMultiplier = 1.0;
				itemMultiplier = rewardMultData.rewardMultiplier;
			}
			else
			{
				goldMultiplier = rewardMultData.rewardMultiplier;
				itemMultiplier = 1.0;
			}
			
			if ( rewrd.gold > 0 )
			{
				inv.AddMoney( (int)(rewrd.gold * goldMultiplier) );
				thePlayer.RemoveRewardMultiplier(rewardName);		
				if( target == thePlayer )
				{
					moneyWon = (int)(rewrd.gold * goldMultiplier);
					
					if ( moneyWon > 0 )
						thePlayer.DisplayItemRewardNotification('Crowns', moneyWon );
				}
			}
			
			for ( i = 0; i < rewrd.items.Size(); i += 1 )
			{
				itemsCount = RoundF( rewrd.items[ i ].amount * itemMultiplier );
				
				if( itemsCount > 0 )
				{
					ids = inv.AddAnItem( rewrd.items[ i ].item, itemsCount );
					
					for ( itemCount = 0; itemCount < ids.Size(); itemCount += 1 )
					{
						
						if ( inv.ItemHasTag( ids[i], 'Autogen' ) && GetWitcherPlayer().GetLevel() - 1 > 1 )
						{ 
							inv.GenerateItemLevel( ids[i], true );
						}
					}
					
					itemCategory = inv.GetItemCategory( ids[0] );
					if ( itemCategory == 'alchemy_recipe' ||  itemCategory == 'crafting_schematic' )
					{
						inv.ReadSchematicsAndRecipes( ids[0] );
					}						
					
					if(target == thePlayer)
					{
						
						if( !inv.ItemHasTag( ids[0], 'GwintCard') )
						{
							thePlayer.DisplayItemRewardNotification(rewrd.items[ i ].item, RoundF( rewrd.items[ i ].amount * itemMultiplier ) );
						}
					}
				}
			}
		}
	}
}

@wrapMethod(CR4Game) function GetSpawnDifficultyMode() : EDifficultyMode
{
	if(false) 
	{
		wrappedMethod();
	}
	
	return GetDifficultyMode();
}