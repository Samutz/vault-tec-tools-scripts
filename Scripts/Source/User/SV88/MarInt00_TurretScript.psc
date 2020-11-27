Scriptname SV88:MarInt00_TurretScript extends Actor

Import SV88:SamutzLibrary

Keyword Property kwDoor Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
Keyword Property kgSim_PlotSpawnedMultiStage Auto Const Mandatory
GlobalVariable Property AutomateDoorSetting Auto Const Mandatory

SV88:MarInt00_GearDoorScript aDoorRef = none

Bool bIsMoved = false

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	if !Self.IsDeleted() && !Self.IsDestroyed() 
		int retry = 0
		while !bIsMoved && retry < 5
			bIsMoved = Self.FixRotation()
			retry += 5
		endWhile
		
		ObjectReference plotRef = SV88:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned, kgSim_PlotSpawnedMultiStage)
		ObjectReference[] plotSpawns = SV88:SamutzLibrary.GetAllPlotSpawns(plotRef, kgSim_PlotSpawned, kgSim_PlotSpawnedMultiStage)

		int i = 0
		while i < plotSpawns.length && !(aDoorRef as bool)
			if plotSpawns[i].HasKeyword(kwDoor)
				aDoorRef = plotSpawns[i] as SV88:MarInt00_GearDoorScript
			endIf
			i += 1
		endWhile
		
		CheckCombatState(Self.GetCombatState())
	endIf
EndFunction

Function Delete()
	bIsMoved = false
	aDoorRef = none
	Parent.Delete()
EndFunction

Event OnCellLoad()
	bIsMoved = false
	Self.FixRotation()
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if (aDoorRef as bool) && Self.IsEnabled() && !Self.IsDeleted() && !Self.IsDestroyed() 
		CheckCombatState(aeCombatState)
		; check again after 10 secs in case combatstate changed during door animation
		Utility.Wait(10)
		CheckCombatState(Self.GetCombatState())
	endIf
EndEvent

Function CheckCombatState(int aeCombatState)
	if (aDoorRef as bool) && AutomateDoorSetting.GetValue() == 1.0
		if aeCombatState==1 && aDoorRef.iDoorState==2
			aDoorRef.Activate(Self)
		elseif aeCombatState==0 && aDoorRef.iDoorState==0
			aDoorRef.Activate(Self)
		endIf
	endIf
EndFunction

bool Function FixRotation()
	if(Self.is3dLoaded() && Self.isEnabled())
		Utility.Wait(3)
		Float[] CurrentPosition = new Float[3]
		Float[] CurrentRotation = new Float[3]
							
		CurrentPosition[0] = Self.GetPositionX()
		CurrentPosition[1] = Self.GetPositionY()
		CurrentPosition[2] = Self.GetPositionZ()
		CurrentRotation[0] = Self.GetAngleX()
		CurrentRotation[1] = Self.GetAngleY()
		CurrentRotation[2] = Self.GetAngleZ()
		
		; Get absolute position
		Float[] OffsetPosition = new Float[3]
		Float[] OffsetRotation = new Float[3]
		OffsetPosition[0] = 0.0
		OffsetPosition[1] = 0.0
		OffsetPosition[2] = 0.0
		OffsetRotation[0] = 90.0
		OffsetRotation[1] = -90.0
		OffsetRotation[2] = 0
		
		Float[] TargetCoordinates = AutoBuilder:CobbLibraryRotations.GetCoordinatesRelativeToBase(CurrentPosition, CurrentRotation, OffsetPosition, OffsetRotation)

		if TargetCoordinates[3] < -89.0 && TargetCoordinates[3] > -91.0 ; Not always exactly -90
			TargetCoordinates[5] += 180.0
		endIf
		if TargetCoordinates[3] < 1.0 && TargetCoordinates[3] > -1.0 ; Not always exactly 0
			TargetCoordinates[5] += 90.0
		endIf
		Self.TranslateTo(TargetCoordinates[0], TargetCoordinates[1], TargetCoordinates[2], TargetCoordinates[3], TargetCoordinates[4], TargetCoordinates[5], 500.0)
		bIsMoved = true
	endif
	return bIsMoved
EndFunction
