Scriptname SV88:SlidingDoorAliasScript extends RefCollectionAlias

Import SV88:SamutzLibrary

Group AutoCloseDoor
	GlobalVariable Property AutoCloseDoors Auto Const Mandatory
	GlobalVariable Property AutoCloseDoorsOpenedByPlayer Auto Const Mandatory
	GlobalVariable Property UseCityManagerDoorSetting Auto Const Mandatory
	GlobalVariable Property AutoOpenDoorsInWorkshopMode Auto Const Mandatory
	Keyword Property WorkshopKeyword Auto Const Mandatory
	SV88:SlidingDoorQuestScript Property DoorManager Auto Const Mandatory
EndGroup

ObjectReference workshopRef = none
bool bEventRegistered = false
Var[] emptyParams

Function CloseDoor(ObjectReference akSenderRef, ObjectReference akActionRef)
	if UseCityManagerDoorSetting.GetValue() == 1.0 && AutoCloseDoors.GetValue() == 1.0 && ((akActionRef == Game.GetPlayer() && AutoCloseDoorsOpenedByPlayer.GetValue() == 1.0) || akActionRef != Game.GetPlayer())
		if !DoorManager.bWorkshopModeEnabled ; check before waiting so we don't hold up the script for 5 seconds
			Utility.Wait(5.0)
			if !DoorManager.bWorkshopModeEnabled ; check one more time to make sure workshop mode wasn't enabled during wait
				while akSenderRef.GetOpenState() != 3
					akSenderRef.SetOpen(false)
					Utility.Wait(1)
				endWhile
			endIf
		endIf
	endIf
EndFunction

Event OnOpen(ObjectReference akSenderRef, ObjectReference akActionRef)
	if !DoorManager.bWorkshopModeEnabled
		var[] params = new var[2]
		params[0] = akSenderRef
		params[1] = akActionRef
		Self.CallFunctionNoWait("CloseDoor", params)
	endIf
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akSenderRef, ObjectReference akActionRef)
	Self.RemoveRef(akSenderRef)
EndEvent
