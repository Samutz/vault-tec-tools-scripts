Scriptname SS2AOP_VaultTecTools:MarInt00_GearDoorScript extends ObjectReference

string Property sAnim = "ActivateDoor" Auto const
Message Property PowerReqMessage Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory

; 0 = closed, 1 = opening, 2 = open, 3 = closing
int Property iDoorState = 0 Auto hidden
bool Property bPowered = false Auto Hidden
ObjectReference Property plotRef = none Auto Hidden

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
	if !IsDeleted() && !IsDestroyed()
		iDoorState = 0
	endIf

	plotRef = (SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:PlotLinkHolder).kPlotRef
	bPowered = plotRef.IsPowered()

	RegisterForRemoteEvent(plotRef, "OnPowerOn")
	RegisterForRemoteEvent(plotRef, "OnPowerOff")
EndFunction

Function Delete()
	iDoorState = 0
	UnregisterForRemoteEvent(plotRef, "OnPowerOn")
	UnregisterForRemoteEvent(plotRef, "OnPowerOff")
	Parent.Delete()
EndFunction

Event OnActivate(ObjectReference akActionRef)
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		if bPowered
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
		else
			if akActionRef == Game.GetPlayer()
				PowerReqMessage.Show()
			endIf
		endIf
	endIf
EndEvent

Event ObjectReference.OnPowerOn(ObjectReference akSender, ObjectReference akPowerGenerator)
	bPowered = true
EndEvent

Event ObjectReference.OnPowerOff(ObjectReference akSender)
	bPowered = false
EndEvent