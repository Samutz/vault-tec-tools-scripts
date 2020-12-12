Scriptname SS2AOP_VaultTecTools:RecInt00_TerminalScript extends ObjectReference 

Form Property furnDeskBase Auto Const Mandatory
WorkshopFramework:Library:DataStructures:WorldObject[] Property DeskRow Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none
int iNumRows = 0

Event OnActivate(ObjectReference akBruh)
	DummyGV.SetValue(iNumRows as float)
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
	if !IsDeleted() && !IsDestroyed() 
		plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
		SetActorRefOwner(Game.GetPlayer())
	endIf
EndFunction

Function AddDeskRow()
	if (plotLinkHolder.kPlotRef as bool)
		int i = 0
		while i < DeskRow.length
			DeskRow[i].fPosX = (iNumRows * -100) - 200 ; distance from plot center
			i += 1
		endWhile
		plotLinkHolder.kPlotRef.SpawnStageItemBatch(DeskRow, plotLinkHolder.kWorkshopRef, (plotLinkHolder.kPlotRef as ObjectReference))
		iNumRows += 1
		DummyGV.SetValue(iNumRows as float)
	endIf
EndFunction

Function AddMultipleRows(int count = 1)
	int i = 0
	while i < count
		AddDeskRow()
		i += 1
	endWhile
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function RemoveDeskRow()
	ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
	int i = plotSpawns.Length - 1
	int deskCount = 0
	while (i > -1 && deskCount < 3)
		if plotSpawns[i].GetBaseObject() == furnDeskBase as Form
			plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
			plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
			deskCount += 1
		endIf
		i -= 1
	endWhile
	iNumRows -= 1
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function RemoveAllDesks()
	while iNumRows > 0
		RemoveDeskRow()
	endWhile
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function Cleanup()
	RemoveAllDesks()
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

