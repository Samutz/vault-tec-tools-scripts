Scriptname SS2AOP_VaultTecTools:RecInt00_TerminalScript extends ObjectReference 

Form Property furnDeskBase Auto Const Mandatory
WorkshopFramework:Library:DataStructures:WorldObject[] Property DeskRow Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory
ActorValue Property DeskRowsAV Auto Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none
int iNumRows = 0

bool Property bEnabled = false Auto Hidden

Event OnLoad()
	; handle upgrade from 2.x to 3.0
	if plotLinkHolder.kPlotRef != none
		int iRowsFromAV = plotLinkHolder.kPlotRef.GetValue(DeskRowsAV) as int
		if iNumRows > iRowsFromAV
			plotLinkHolder.kPlotRef.SetValue(DeskRowsAV, iNumRows as float)
		endIf
	endIf
EndEvent

Event OnActivate(ObjectReference akBruh)
	DummyGV.SetValue(iNumRows as float)
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
	if !bEnabled
        bEnabled = true

		if !IsDeleted() && !IsDestroyed() 
			plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
			SetActorRefOwner(Game.GetPlayer())

			int iRowsFromAV = plotLinkHolder.kPlotRef.GetValue(DeskRowsAV) as int
			if iRowsFromAV > 0 && iNumRows == 0
				AddMultipleRows(iRowsFromAV)
			endIf
		endIf
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
		plotLinkHolder.kPlotRef.SetValue(DeskRowsAV, iNumRows as float)
		DummyGV.SetValue(iNumRows as float)
	endIf
EndFunction

Function AddMultipleRows(int count = 1)
	int iStartCount = GetActualDeskCount()
	int i = 0
	while i < count
		AddDeskRow()
		; ensure desks are grouped together in stage spawns before continuing
		int iTargetCount = iStartCount + ((3 * i) + 3)
		while GetActualDeskCount() != iTargetCount
			Utility.Wait(0.1)
		endWhile
		i += 1
	endWhile
	DummyGV.SetValue(iNumRows as float)
EndFunction

int Function GetActualDeskCount()
	ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
	int i = plotSpawns.Length - 1
	int deskCount = 0
	while i > -1
		if plotSpawns[i].GetBaseObject() == furnDeskBase as Form
			deskCount += 1
		endIf
		i -= 1
	endWhile
	return deskCount
EndFunction

Function RemoveDeskRow(bool bUpdateAV = true)
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
	if bUpdateAV
		plotLinkHolder.kPlotRef.SetValue(DeskRowsAV, iNumRows as float)
	endIf
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function RemoveAllDesks(bool bUpdateAV = true)
	while iNumRows > 0
		RemoveDeskRow(bUpdateAV)
	endWhile
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function Cleanup()
	RemoveAllDesks(false)
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

Function DeleteWhenAble()
	Cleanup()
	Parent.DeleteWhenAble()
EndFunction
