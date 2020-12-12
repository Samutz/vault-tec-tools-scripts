Scriptname SS2AOP_VaultTecTools:RecInt00_SchoolDeskScript extends ObjectReference

Static Property NavcutStatic Auto Const
FormList Property flCommonClutterObjs Auto Const Mandatory
FormList Property flRareClutterObjs Auto Const Mandatory
Keyword Property kwLinkParent Auto Const Mandatory

ObjectReference clutterRef = none
ObjectReference navcutRef = none

Function SpawnClutter()
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		if (clutterRef as bool)
			Cleanup(true, false)
		endIf
		if flCommonClutterObjs.GetSize() > 0 && !(clutterRef as bool) 
			FormList randomFormList = flCommonClutterObjs
			int doFormList = Utility.RandomInt(1, 100)
			if doFormList == 1 && flRareClutterObjs.GetSize() > 0 ; 1% chance to spawn rare clutter
				randomFormList = flRareClutterObjs
			endIf
			int formIndex = Utility.RandomInt(0, randomFormList.GetSize() - 1)
			Form formToSpawn = randomFormList.GetAt(formIndex)
			clutterRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, formToSpawn, 0, -16.2851, 58.6000, 7, 0, 180)
			clutterRef.Enable(true)
			;clutterRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
		endIf
	endIf
EndFunction

Function SpawnNavcut()
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		if !(navcutRef as bool) && (NavcutStatic as bool)
			navcutRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, NavcutStatic)
			navcutRef.Enable(false)
			;navcutRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
			;debug.notification("navcut spawned")
		endIf
	endIf
EndFunction

Function Cleanup(bool bCleanClutter, bool bCleanNavcut)
	if clutterRef != none && bCleanClutter
		clutterRef.Disable(true)
		clutterRef.Delete()
		clutterRef = none
	endIf
	debug.trace("RecInt00_SchoolDeskScript: checking for navcutRef")
	if navcutRef != none && bCleanNavcut
		debug.trace("RecInt00_SchoolDeskScript: navcutRef found, cleaning...")
		navcutRef.Disable(false)
		debug.trace("RecInt00_SchoolDeskScript: navcutRef disabled")
		navcutRef.Delete()
		debug.trace("RecInt00_SchoolDeskScript: navcutRef deleted")
		navcutRef = none
		debug.trace("RecInt00_SchoolDeskScript: navcutRef none'd")
	endIf
	if bCleanClutter && bCleanNavcut
		SS2AOP_VaultTecTools:SamutzLibrary.CleanUpChildSpawns((Self as ObjectReference), kwLinkParent)
	endIf
EndFunction

Event OnLoad()
	Cleanup(true, false)
	SpawnNavcut()
EndEvent

Event OnActivate(ObjectReference akActionRef)
	if IsFurnitureInUse(true)
		SpawnClutter()
	endIf
EndEvent

Event OnExitFurniture(ObjectReference akReference)
	Cleanup(true, false)
EndEvent

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	Cleanup(true, false)
	SpawnNavcut()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	Cleanup(true, false)
	SpawnNavcut()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	Cleanup(true, true)
EndEvent

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	Cleanup(true, true)
EndEvent

Event OnUnload()
	Cleanup(true, false)
EndEvent

Event OnReset()
	Cleanup(true, false)
EndEvent

Function Delete()
	Cleanup(true, true)
	Parent.Delete()
EndFunction
