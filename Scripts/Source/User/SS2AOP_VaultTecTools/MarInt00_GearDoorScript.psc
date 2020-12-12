Scriptname SS2AOP_VaultTecTools:MarInt00_GearDoorScript extends ObjectReference

string Property sAnim = "ActivateDoor" Auto const

; 0 = closed, 1 = opening, 2 = open, 3 = closing
int Property iDoorState = 0 Auto hidden

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	if !IsDeleted() && !IsDestroyed() 
		iDoorState = 0
	endIf
EndFunction

Function Delete()
	iDoorState = 0
	Parent.Delete()
EndFunction

Event OnActivate(ObjectReference akActionRef)
	if IsEnabled() && !IsDeleted() && !IsDestroyed() 
		if iDoorState == 0
			PlayAnimation(sAnim)
			iDoorState = 1
			Utility.Wait(10)
			iDoorState = 2
		elseif iDoorState == 2
			PlayAnimation(sAnim)
			iDoorState = 3
			Utility.Wait(10)
			iDoorState = 0
		endIf
	endIf
EndEvent
