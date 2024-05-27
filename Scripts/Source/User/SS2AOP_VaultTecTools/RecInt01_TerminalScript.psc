Scriptname SS2AOP_VaultTecTools:RecInt01_TerminalScript extends ObjectReference 

WorkshopFramework:Library:DataStructures:WorldObject[] Property StallActivators Auto Const Mandatory
{ ALWAYS SET: fExtraDataFlag = stall width, fPosY = -126, fPosX = 144, fAngleZ = 90 }
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none

bool Property bEnabled = false Auto Hidden

int[] iCounts = none

Event OnActivate(ObjectReference akBruh)
	DummyGV.SetValue(iCounts[0] as float)
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true

		iCounts = new int[StallActivators.length + 1]

		if !IsDeleted() && !IsDestroyed() 
			plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
			SetActorRefOwner(Game.GetPlayer())
			
			if iCounts[0] == 0
				AddStall(0)
				AddStall(0)
			endIf
		endIf
	endIf
EndFunction

Function AddStall(int iType = 0)
	if (plotLinkHolder.kPlotRef as bool)
		float fPosYDefault = StallActivators[iType].fPosY ; should be -126 for recint01

		int i = 0
		while i < StallActivators.length
			StallActivators[iType].fPosY += ((iCounts[i + 1] as float) * StallActivators[i].fExtraDataFlag)
			i += 1
		endWhile
		StallActivators[iType].fPosY += (StallActivators[iType].fExtraDataFlag / 2.0) ; add half width of spawn object

		plotLinkHolder.kPlotRef.SpawnStageItem(StallActivators[iType], plotLinkHolder.kWorkshopRef, (plotLinkHolder.kPlotRef as ObjectReference))

		StallActivators[iType].fPosY = fPosYDefault

		iCounts[0] += 1
		iCounts[iType+1] += 1
		DummyGV.SetValue(iCounts[0] as float)
	endIf
EndFunction

Function RemoveStall()
	if iCounts[0] > 0
		ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
		int i = plotSpawns.Length - 1
		int iRemovedCount = 0
		while (i > -1 && iRemovedCount < 1) ; going backwards in the spawns to get the last added stall
			int iType = StallActivators.FindStruct("ObjectForm", plotSpawns[i].GetBaseObject())
			if iType > -1
				plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
				plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
				iRemovedCount += 1
			endIf
			iCounts[0] -= 1
			iCounts[iType+1] -= 1
			DummyGV.SetValue(iCounts[0] as float)
			i -= 1
		endWhile
	endIf
EndFunction

Function RemoveAllStalls()
	if iCounts[0] > 0
		ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
		int i = plotSpawns.Length - 1
		while i > -1
			if StallActivators.FindStruct("ObjectForm", plotSpawns[i].GetBaseObject()) > -1
				plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
				plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
			endIf
			i -= 1
		endWhile
	endIf
	iCounts = new int[StallActivators.length + 1]
	DummyGV.SetValue(iCounts[0] as float)
EndFunction

Function Cleanup()
	RemoveAllStalls()
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction