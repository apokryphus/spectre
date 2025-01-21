@wrapMethod(W3ReplacerCiri) function OnSpawned( spawnData : SEntitySpawnData )
{
	var hud 															: CR4ScriptedHud;
	var moduleMinimap, moduleQuest 										: CR4HudModuleBase;

	wrappedMethod(spawnData);

	theGame.GetInGameConfigWrapper().SetVarValue('Hud', 'Minimap2Module', "true");

	theGame.GetInGameConfigWrapper().SetVarValue('Hud', 'QuestsModule', "true");

	hud = (CR4ScriptedHud)theGame.GetHud();

	moduleMinimap = (CR4HudModuleBase)hud.GetHudModule("Minimap2Module");

	moduleMinimap.SetEnabled(true);

	moduleQuest = (CR4HudModuleBase)hud.GetHudModule("QuestsModule");

	moduleQuest.SetEnabled(true);

	hud.UpdateHUD();

	thePlayer.inv.AddAnItem('Wolfsbane', 12);

	thePlayer.inv.AddAnItem('Fools parsley leaves', 12);
}