Scriptname SS2AOP_VaultTecTools:MarInt00_TurretScript extends workshopobjectactorscript

import SS2AOP_VaultTecTools:SamutzLibrary

Keyword Property kwDoor Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property AutomateDoorSetting Auto Const Mandatory

SS2AOP_VaultTecTools:MarInt00_GearDoorScript aDoorRef = none

bool Property bPowered = false Auto Hidden
ObjectReference Property plotRef = none Auto Hidden

bool Property bEnabled = false Auto Hidden

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true
		
		if !IsDeleted() && !IsDestroyed()
			
			ObjectReference plotHolderRef = GetParentPlot(Self, kgSim_PlotSpawned) 
			plotRef = plotHolderRef.GetPropertyValue("kPlotRef") as ObjectReference
			ObjectReference[] plotSpawns = plotHolderRef.GetLinkedRefChildren(kgSim_PlotSpawned)
			
			CallFunctionNoWait("FixRotation", none)

			bPowered = plotRef.IsPowered()
			SetUnconscious(!bPowered)

			RegisterForRemoteEvent(plotRef, "OnPowerOn")
			RegisterForRemoteEvent(plotRef, "OnPowerOff")

			int i = 0
			while i < plotSpawns.length && !(aDoorRef as bool)
				if plotSpawns[i].HasKeyword(kwDoor)
					aDoorRef = plotSpawns[i] as SS2AOP_VaultTecTools:MarInt00_GearDoorScript
				endIf
				i += 1
			endWhile

			CheckCombatState(GetCombatState())
		endIf
	endIf
EndFunction

Bool Function IsAssigned()
	return plotRef.GetPropertyValue("PrimaryOwner") as bool
EndFunction

Function GetAssigned()
	Debug.Notification("Assigned: "+IsAssigned())
EndFunction

Function Delete()
	aDoorRef = none
	UnregisterForRemoteEvent(plotRef, "OnPowerOn")
	UnregisterForRemoteEvent(plotRef, "OnPowerOff")
	Parent.Delete()
EndFunction

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if (aDoorRef as bool) && IsEnabled() && !IsDeleted() && !IsDestroyed()
		CheckCombatState(aeCombatState)
	endIf
	; check again after 10 secs in case combatstate changed during door animation
	Utility.Wait(10)
	if (aDoorRef as bool) && IsEnabled() && !IsDeleted() && !IsDestroyed()
		CheckCombatState(aeCombatState)
	endIf
EndEvent

Function CheckCombatState(int aeCombatState)
	if (aDoorRef as bool) && AutomateDoorSetting.GetValue() == 1.0 && !IsUnconscious() && IsAssigned()
		if aeCombatState==1 && aDoorRef.iDoorState==2
			aDoorRef.Activate(Self)
		elseif aeCombatState==0 && aDoorRef.iDoorState==0
			aDoorRef.Activate(Self)
		endIf
	endIf
EndFunction

bool Function FixRotation()
	if(is3dLoaded() && isEnabled())
        TranslateTo(GetPositionX(), GetPositionY(), GetPositionZ(), plotRef.GetAngleX() + 90.0, plotRef.GetAngleY() + 90.0, plotRef.GetAngleZ() + 0.0, 500.0)
	endif
EndFunction

Event ObjectReference.OnPowerOn(ObjectReference akSender, ObjectReference akPowerGenerator)
	bPowered = true
	SetUnconscious(!bPowered)
EndEvent

Event ObjectReference.OnPowerOff(ObjectReference akSender)
	bPowered = false
	SetUnconscious(!bPowered)
EndEvent