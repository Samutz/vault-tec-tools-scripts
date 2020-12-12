Scriptname SS2AOP_VaultTecTools:RecInt01_TerminalScript extends ObjectReference 

WorkshopFramework:Library:DataStructures:WorldObject Property StallToiletActivator Auto Const Mandatory
WorkshopFramework:Library:DataStructures:WorldObject Property StallShowerActivator Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none
int iNumStalls = 0

Event OnActivate(ObjectReference akBruh)
	DummyGV.SetValue(iNumStalls as float)
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
	if !IsDeleted() && !IsDestroyed() 
		plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
		SetActorRefOwner(Game.GetPlayer())
		
		if iNumStalls == 0
			AddStall()
			AddStall()
		endIf
	endIf
EndFunction

Function AddStall(int iType = 0)
	if (plotLinkHolder.kPlotRef as bool)
		WorkshopFramework:Library:DataStructures:WorldObject spawnObject = none
		
		if iType == 0
			spawnObject = StallToiletActivator
		elseif iType == 1
			spawnObject = StallShowerActivator
		endif
		
		spawnObject.fPosY = (iNumStalls * 126) + -63 ; distance from plot center
		plotLinkHolder.kPlotRef.SpawnStageItem(spawnObject, plotLinkHolder.kWorkshopRef, (plotLinkHolder.kPlotRef as ObjectReference))
		iNumStalls += 1
		DummyGV.SetValue(iNumStalls as float)
	endIf
EndFunction

Function RemoveStall()
	if iNumStalls > 0
		ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
		int i = plotSpawns.Length - 1
		int stallCount = 0
		while (i > -1 && stallCount < 1)
			Form baseForm = plotSpawns[i].GetBaseObject()
			if baseForm == StallToiletActivator.ObjectForm || baseForm == StallShowerActivator.ObjectForm
				plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
				plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
				stallCount += 1
			endIf
			i -= 1
		endWhile
		iNumStalls -= 1
		DummyGV.SetValue(iNumStalls as float)
	endIf
EndFunction

Function RemoveAllStalls()
	while iNumStalls > 0
		RemoveStall()
	endWhile
	DummyGV.SetValue(iNumStalls as float)
EndFunction

Function Cleanup()
	RemoveAllStalls()
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

