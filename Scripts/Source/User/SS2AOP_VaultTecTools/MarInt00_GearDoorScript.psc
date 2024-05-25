Scriptname SS2AOP_VaultTecTools:MarInt00_GearDoorScript extends ObjectReference

string Property sAnim = "ActivateDoor" Auto const
Message Property PowerReqMessage Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
Message Property ConfirmPlotMove Auto Const Mandatory

; 0 = closed, 1 = opening, 2 = open, 3 = closing
int Property iDoorState = 0 Auto hidden
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
			iDoorState = 0
		endIf

		plotRef = (SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:PlotLinkHolder).kPlotRef
		bPowered = plotRef.IsPowered()

		RegisterForRemoteEvent(plotRef, "OnPowerOn")
		RegisterForRemoteEvent(plotRef, "OnPowerOff")
	endIf
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

Event OnWorkshopObjectMoved(ObjectReference akReference)
	int answer = ConfirmPlotMove.Show()
	if answer == 1 ; yes
		Float[] OriginalPosition = new Float[3]
		Float[] OriginalRotation = new Float[3]
		OriginalPosition[0] = GetPositionX()
		OriginalPosition[1] = GetPositionY()
		OriginalPosition[2] = GetPositionZ()
		OriginalRotation[0] = GetAngleX()
		OriginalRotation[1] = GetAngleY()
		OriginalRotation[2] = GetAngleZ()

		Float[] OffsetPosition = new Float[3]
		Float[] OffsetRotation = new Float[3]
		OffsetPosition[0] = -8.0
		OffsetPosition[1] = -128.0
		OffsetPosition[2] = 6.75
		OffsetRotation[0] = 0.0
		OffsetRotation[1] = 0.0
		OffsetRotation[2] = 180.0

		Float[] TargetCoordinates = WorkshopFramework:Library:ThirdParty:Cobb:CobbLibraryRotations.GetCoordinatesRelativeToBase(OriginalPosition, OriginalRotation, OffsetPosition, OffsetRotation)
		plotRef.TranslateTo(TargetCoordinates[0], TargetCoordinates[1], TargetCoordinates[2], TargetCoordinates[3], TargetCoordinates[4], TargetCoordinates[5], 500.0)

		plotRef.OnWorkshopObjectMoved(akReference)
	endIf
EndEvent