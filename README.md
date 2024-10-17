# Spectre
Next Gen Game Overhaul With Ghost Mode Characteristics

## Installation
- Drag and drop folders into TW3 installation folder.
 - Remove `mod_EH_Shared_Imports` if `modSharedImports` already exists.
- Run https://www.nexusmods.com/witcher3/mods/7171 for mod menu.

Copy the following keybinds configuration at the beginning of the "input.settings" file, located in your
documents\The Witcher 3 folder:

--- copy below this line----

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

--- copy above this line----

Failure to do this step will prevent you from correctly interacting with Alchemy.
Important: It may be necessary to set the "Read Only" attribute of the file after copying, to prevent the game
from overwriting the changes made.

The above keybinds will correlate to these buttons/actions in-game:
(M & Keyboard) : (Controller)
	L				L2 + R3		-> Tap to enter meditation position.
	L				L2 + R3		-> Hold ~0.5 seconds and release to enter the meditation position AND build a fire.
	L				R3			-> while on the meditation position, tap to enter the alchemy menu.
	L				R3			-> while on the meditation position, hold to stand up.
	Space			R2			-> while on the meditation position, hold to accelerate time.
	R mouse			Digit Up	-> while in the alchemy menu, opens the menu to choose another ingredient.
	L mouse						-> while in the alchemy menu, click on an ingredient to display its information.
	Shift						-> Hold while using the R Mouse/Y button when at an alchemist to buy an ingredient.
	Dot				R2			-> Tap inside the alchemy menu to only show ingredients of a particular secondary substance.
	Comma			L2			-> Same as above, but goes to the previous substance.
Note:
	-If using Steam with a controller, it may be necessary to disable Steam's controller emulation when running the game.
	-These controls are just suggestions, you can always change them if you know the key/button codes.

Note: When toggling the option, it may be necessary to use the Enter key or equivalent controller button, seeing as how
the mouse seems not to work reliably for the last entry in a menu (some bizarre game issue). If successful, the option will
be visibly toggled "On" and, upon quitting the menu, a "mod removed" message will be shown.
Simply removing the mod without following these steps in order, will result in an entirely broken skill system.
