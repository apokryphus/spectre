![spectre](https://github.com/user-attachments/assets/f348e704-7525-457a-8164-e32809758585)
Next gen overhaul built upon concepts and design choices of Ghost Mode and Alchemy. 

## Installation
### Manual Installation
- Click on this [link (CLICK ME)](https://github.com/apokryphus/spectre/releases/latest).
- Download the zip file. 
- First link under `Assets`. 
- Do not download the source code.
- Drag and drop all 3 folders in the zip file (dlc, mods, and bin) into your Witcher 3 installation folder.
- Check the files ```bin\config\r4game\user_config_matrix\pc\dx11filelist.txt``` and ```bin\config\r4game\user_config_matrix\pc\dx12filelist.txt```
- Add `000Spectre.xml;` to the very bottom of both files if it does not exist. 

### Post-Installation
- Remove `mod_EH_Shared_Imports` if `modSharedImports` already exists.
- Use [this (CLICK ME)](https://www.nexusmods.com/witcher3/mods/7171) for the mod menu.
- Copy the following keybinds configuration and paste them at the beginning of the `input.settings` file, located in your
`Documents\The Witcher 3` folder:

```
[Exploration]
IK_L=(Action=MeditationRequest)
IK_Pad_RightThumb=(Action=MeditationRequest)
IK_L=(Action=ExitMedState,State=Duration,IdleTime=0.5)
IK_Pad_RightThumb=(Action=ExitMedState,State=Duration,IdleTime=0.5)
IK_Space=(Action=MoveTimeFoward)
IK_Pad_RightTrigger=(Action=MoveTimeFoward)
IK_LShift=(Action=ModifierKeyPressed)
IK_Pad_LeftTrigger=(Action=ModifierKeyPressed)
IK_Pad_RightThumb=(Action=PanelAlch)

[EMPTY_CONTEXT]
IK_LShift=(Action=ModifierKeyPressed)
IK_Period=(Action=SubstanceFilterIncrement)
IK_Comma=(Action=SubstanceFilterDecrement)
IK_Pad_RightTrigger=(Action=SubstanceFilterIncrement)
IK_Pad_LeftTrigger=(Action=SubstanceFilterDecrement)
IK_RightMouse=(Action=IngredientChangeRequest)
IK_Pad_DigitUp=(Action=IngredientChangeRequest)
IK_LeftMouse=(Action=IngredientSelectionRequest)

[Horse]
IK_E=(Action=Ignite)
IK_E=(Action=Extinguish)
IK_E=(Action=PlaceTrophy)
IK_E=(Action=HideIn)
IK_E=(Action=DisposePaint)
IK_E=(Action=TakePaintPurple)
IK_E=(Action=TakePaintYellow)
IK_E=(Action=TakePaintRed)
IK_E=(Action=TakePaintBlue)
IK_E=(Action=TakePaintGreen)
IK_E=(Action=Look)
IK_E=(Action=PlaceBeans)
IK_E=(Action=PlaceLure)
IK_E=(Action=GiveAlms)
IK_E=(Action=PlaceSword)
IK_E=(Action=PlaceArmor)
IK_E=(Action=HangPainting)
IK_E=(Action=PlaceTribute)
IK_E=(Action=KneelDown)
IK_E=(Action=CutRope)
IK_E=(Action=Touch)
IK_E=(Action=Debung)
IK_E=(Action=PutBack)
IK_E=(Action=BurnBody)
IK_E=(Action=WineSlot)
IK_E=(Action=PlaceBottle)
IK_E=(Action=SitAndWait)
IK_E=(Action=HideBible)
IK_E=(Action=CallJohnny)
IK_E=(Action=Interaction)
IK_E=(Action=PullAxe)
IK_E=(Action=Read)
IK_E=(Action=UseItem)
IK_E=(Action=UnblockGate)
IK_E=(Action=Free)
IK_E=(Action=Grab)
IK_E=(Action=PlaceOffering)
IK_E=(Action=Drink)
IK_E=(Action=PlaceHerbs)
IK_E=(Action=GatherBrushwood)
IK_E=(Action=Disarm)
IK_E=(Action=Arm)
IK_E=(Action=PrayForStorm)
IK_E=(Action=PrayForSun)
IK_E=(Action=Destroy)
IK_E=(Action=Locked)
IK_E=(Action=Pull)
IK_E=(Action=Push)
IK_E=(Action=Take)
IK_E=(Action=Unlock)
IK_E=(Action=Lock)
IK_E=(Action=Close)
IK_E=(Action=Open)
IK_E=(Action=Finish)
IK_E=(Action=UseDevice)
IK_E=(Action=Use)
IK_E=(Action=InteractHold,State=Duration,IdleTime=0.1)
IK_E=(Action=Interact)
IK_E=(Action=Container)
IK_E=(Action=Stash)
IK_E=(Action=Talk)
IK_E=(Action=MountHorse)
IK_E=(Action=EnterBoatFromSwimming)
IK_E=(Action=EnterBoat)
IK_E=(Action=Examine)
IK_E=(Action=GatherHerbs)
IK_E=(Action=FastTravel)
IK_E=(Action=Unequip)
IK_E=(Action=Spare)
IK_E=(Action=Knock)
IK_E=(Action=SitDown)
IK_E=(Action=PlaceCrystal)
IK_E=(Action=PlaceOilLamp)
IK_E=(Action=PickOilLamp)
IK_Pad_A_CROSS=(Action=Ignite)
IK_Pad_A_CROSS=(Action=Extinguish)
IK_Pad_A_CROSS=(Action=PlaceTrophy)
IK_Pad_A_CROSS=(Action=HideIn)
IK_Pad_A_CROSS=(Action=DisposePaint)
IK_Pad_A_CROSS=(Action=TakePaintPurple)
IK_Pad_A_CROSS=(Action=TakePaintYellow)
IK_Pad_A_CROSS=(Action=TakePaintRed)
IK_Pad_A_CROSS=(Action=TakePaintBlue)
IK_Pad_A_CROSS=(Action=TakePaintGreen)
IK_Pad_A_CROSS=(Action=Look)
IK_Pad_A_CROSS=(Action=PlaceBeans)
IK_Pad_A_CROSS=(Action=PlaceLure)
IK_Pad_A_CROSS=(Action=GiveAlms)
IK_Pad_A_CROSS=(Action=PlaceSword)
IK_Pad_A_CROSS=(Action=PlaceArmor)
IK_Pad_A_CROSS=(Action=HangPainting)
IK_Pad_A_CROSS=(Action=PlaceTribute)
IK_Pad_A_CROSS=(Action=KneelDown)
IK_Pad_A_CROSS=(Action=CutRope)
IK_Pad_A_CROSS=(Action=Touch)
IK_Pad_A_CROSS=(Action=Debung)
IK_Pad_A_CROSS=(Action=PutBack)
IK_Pad_A_CROSS=(Action=BurnBody)
IK_Pad_A_CROSS=(Action=WineSlot)
IK_Pad_A_CROSS=(Action=PlaceBottle)
IK_Pad_A_CROSS=(Action=SitAndWait)
IK_Pad_A_CROSS=(Action=HideBible)
IK_Pad_A_CROSS=(Action=CallJohnny)
IK_Pad_A_CROSS=(Action=Interaction)
IK_Pad_A_CROSS=(Action=PullAxe)
IK_Pad_A_CROSS=(Action=Read)
IK_Pad_A_CROSS=(Action=UseItem)
IK_Pad_A_CROSS=(Action=UnblockGate)
IK_Pad_A_CROSS=(Action=Free)
IK_Pad_A_CROSS=(Action=Grab)
IK_Pad_A_CROSS=(Action=PlaceOffering)
IK_Pad_A_CROSS=(Action=Drink)
IK_Pad_A_CROSS=(Action=PlaceHerbs)
IK_Pad_A_CROSS=(Action=GatherBrushwood)
IK_Pad_A_CROSS=(Action=Disarm)
IK_Pad_A_CROSS=(Action=Arm)
IK_Pad_A_CROSS=(Action=PrayForStorm)
IK_Pad_A_CROSS=(Action=PrayForSun)
IK_Pad_A_CROSS=(Action=Destroy)
IK_Pad_A_CROSS=(Action=Locked)
IK_Pad_A_CROSS=(Action=Pull)
IK_Pad_A_CROSS=(Action=Push)
IK_Pad_A_CROSS=(Action=Take)
IK_Pad_A_CROSS=(Action=Unlock)
IK_Pad_A_CROSS=(Action=Lock)
IK_Pad_A_CROSS=(Action=Close)
IK_Pad_A_CROSS=(Action=Open)
IK_Pad_A_CROSS=(Action=UseDevice)
IK_Pad_A_CROSS=(Action=Use)
IK_Pad_A_CROSS=(Action=InteractHold,State=Duration,IdleTime=0.2)
IK_Pad_A_CROSS=(Action=Interact)
IK_Pad_A_CROSS=(Action=Container)
IK_Pad_A_CROSS=(Action=Stash)
IK_Pad_A_CROSS=(Action=Talk)
IK_Pad_A_CROSS=(Action=MountHorse)
IK_Pad_A_CROSS=(Action=EnterBoatFromSwimming)
IK_Pad_A_CROSS=(Action=EnterBoat)
IK_Pad_A_CROSS=(Action=Examine)
IK_Pad_A_CROSS=(Action=GatherHerbs)
IK_Pad_A_CROSS=(Action=FastTravel)
IK_Pad_A_CROSS=(Action=Unequip)
IK_Pad_A_CROSS=(Action=Knock)
IK_Pad_A_CROSS=(Action=SitDown)
IK_Pad_A_CROSS=(Action=PlaceCrystal)
IK_Pad_A_CROSS=(Action=PlaceOilLamp)
IK_Pad_A_CROSS=(Action=PickOilLamp)
IK_Pad_RightTrigger=(Action=Spare)
```
- Failure to do this step will prevent you from correctly interacting with Alchemy and looting on horse.
- Important: It may be necessary to set the "Read Only" attribute of the file after copying, to prevent the game
from overwriting the changes made.

The above keybinds will correlate to these buttons/actions in-game:

(M & Keyboard)    |   (Controller)

	L				L2 + R3		-> Tap to enter meditation position.
	L				L2 + R3		-> Hold ~0.5 seconds and release to enter the meditation position AND build a fire.
	L				R3			-> while on the meditation position, tap to enter the alchemy menu.
	L				R3			-> while on the meditation position, hold to stand up.
	Space			R2			-> while on the meditation position, hold to accelerate time.
	R mouse		Digit Up	        -> while in the alchemy menu, opens the menu to choose another ingredient.
	L mouse				        -> while in the alchemy menu, click on an ingredient to display its information.
	Shift						-> Hold while using the R Mouse/Y button when at an alchemist to buy an ingredient.
	Dot				R2			-> Tap inside the alchemy menu to only show ingredients of a particular secondary substance.
	Comma			L2			-> Same as above, but goes to the previous substance.

Note:

- If using Steam with a controller, it may be necessary to disable Steam's controller emulation when running the game.
- These controls are just suggestions, you can always change them if you know the key/button codes.
