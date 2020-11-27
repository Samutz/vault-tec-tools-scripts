Scriptname SV88:RecInt01_TerminalScript extends ObjectReference 

Import SV88:SamutzLibrary

Activator Property StallToiletActivator Auto Const Mandatory
Activator Property StallShowerActivator Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
Keyword Property kgSim_PlotSpawnedMultiStage Auto Const Mandatory
ActorValue Property WaterAV Auto Const Mandatory
ActorValue Property NegativeWaterAV Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory

ObjectReference plotRef = none
ObjectReference[] StallRefs = none
int iNumStalls = 0

Event OnActivate(ObjectReference akBruh)
	DummyGV.SetValue(iNumStalls as float)
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	if !StallRefs
		StallRefs = new ObjectReference[0]
	endIf
	
	if !Self.IsDeleted() && !Self.IsDestroyed() 
		plotRef = SV88:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned, kgSim_PlotSpawnedMultiStage)
		Self.SetActorRefOwner(Game.GetPlayer())
		
		if iNumStalls == 0
			Self.AddStall()
			Self.AddStall()
			
			Self.UpdateWaterUsage()
		endIf
	endIf
EndFunction

Function AddStall(int iType = 0)
	if (plotRef as bool)
		Activator spawnObject = none
		
		if iType == 1
			spawnObject = StallShowerActivator
		else
			spawnObject = StallToiletActivator
		endif
		
		float rowDistance = (iNumStalls * 126) + -63 ; distance from plot center
		ObjectReference newStall = SV88:SamutzLibrary.PlaceRelativeToMe(plotRef, spawnObject, 144, rowDistance, 0, 0, 0, 90)
		StallRefs.Add(newStall)
		newStall.Enable(false)
		newStall.SetLinkedRef((plotRef as ObjectReference), kgSim_PlotSpawnedMultiStage)
		iNumStalls += 1
		DummyGV.SetValue(iNumStalls as float)
		Self.UpdateWaterUsage()
	endIf
EndFunction

Function RemoveStall()
	if iNumStalls > 0
		StallRefs[StallRefs.length - 1].Disable(false)
		StallRefs[StallRefs.length - 1].Delete()
		StallRefs.RemoveLast()
		iNumStalls -= 1
		DummyGV.SetValue(iNumStalls as float)
		Self.UpdateWaterUsage()
	endIf
EndFunction

Function RemoveAllStalls()
	int i = 0
	while i < StallRefs.length
		StallRefs[i].Disable(false)
		StallRefs[i].Delete()
		i += 1
	endWhile
	StallRefs.Clear()
	iNumStalls = 0
	DummyGV.SetValue(iNumStalls as float)
	Self.UpdateWaterUsage()
EndFunction

Function UpdateWaterUsage()
	if plotRef
		int iWaterMod = 0-iNumStalls
		if iWaterMod < 0
			Self.SetValue(NegativeWaterAV, iWaterMod)
		else
			Self.SetValue(WaterAV, iWaterMod)
		endIf
		(plotRef.CastAs("SimSettlements:SimPlot")).CallFunction("UpdateSettlementModifierData", new var[7])
	endIf
EndFunction

Function Cleanup()
	Self.RemoveAllStalls()
	plotRef = none
EndFunction

Function Delete()
	Self.Cleanup()
	Parent.Delete()
EndFunction

