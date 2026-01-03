Scriptname SS2AOP_VaultTecTools:RecInt01_TerminalScript extends ObjectReference 

WorkshopFramework:Library:DataStructures:WorldObject[] Property StallActivators Auto Const Mandatory
{ ALWAYS SET: fExtraDataFlag = stall width, fPosY = -126, fPosX = 144, fAngleZ = 90 }
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory
ActorValue Property StallCountAV Auto Mandatory
ActorValue Property StallDataAV Auto Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none

bool Property bEnabled = false Auto Hidden

int[] iCounts = none
int[] iStallData = none

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
		iStallData = new int[0]

		if !IsDeleted() && !IsDestroyed() 
			plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
			SetActorRefOwner(Game.GetPlayer())

			AddStallsFromDataAV()
			
			if iCounts[0] == 0
				AddStall(3)
				AddStall(0)
				AddStall(0)
			endIf
		endIf
	endIf
EndFunction

Function AddStallsFromDataAV()
	int[] iRestoreData = SS2AOP_VaultTecTools:SamutzLibrary.DecodeBase4(plotLinkHolder.kPlotRef.GetValue(StallDataAV) as int, plotLinkHolder.kPlotRef.GetValue(StallCountAV) as int)
	int i = 0
	;Debug.MessageBox("restore data: "+iRestoreData+" | restore count: "+iRestoreData.Length)
	while i < iRestoreData.Length
		AddStall(iRestoreData[i])
		i += 1
	endWhile
EndFunction

Function UpdateAVs()
	; trim array to 12, since storing this array as a AV float is limited to the engine's max float size
	int[] iStallDataTrimmed = iStallData
	while iStallDataTrimmed.Length > 12
		iStallDataTrimmed.RemoveLast()
	endWhile

	;Debug.MessageBox("update data: "+SS2AOP_VaultTecTools:SamutzLibrary.EncodeBase4(iStallDataTrimmed)+" | update count: "+iStallDataTrimmed.Length)
	float fStallData = SS2AOP_VaultTecTools:SamutzLibrary.EncodeBase4(iStallDataTrimmed) as float
	float fStallCount = iStallDataTrimmed.Length as float
	;Debug.MessageBox("float data: "+fStallData+" | float count: "+fStallCount)
	plotLinkHolder.kPlotRef.SetValue(StallDataAV, fStallData)
	plotLinkHolder.kPlotRef.SetValue(StallCountAV, fStallCount)
	;Debug.MessageBox("updated data: "+(plotLinkHolder.kPlotRef.GetValue(StallDataAV))+" | updated count: "+(plotLinkHolder.kPlotRef.GetValue(StallCountAV)))
	;Utility.Wait(1)
EndFunction

;/
iTypes:
	0 = stall toilet
	1 = shower stall
	2 = urinal
	3 = sink
/;

Function AddStall(int iType = 0)
	if (plotLinkHolder.kPlotRef as bool) && (StallActivators[iType] as bool)
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
		iStallData.Add(iType)
		UpdateAVs()
	endIf
EndFunction

Function RemoveStall(bool bUpdateAVs = true)
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
			if bUpdateAVs
				iStallData.RemoveLast()
				UpdateAVs()
			endIf
		endWhile
	endIf
EndFunction

Function RemoveAllStalls(bool bUpdateAVs = true)
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
	if bUpdateAVs
		iStallData.Clear()
		UpdateAVs()
	endIf
EndFunction

Function Cleanup()
	RemoveAllStalls(false)
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

Function DeleteWhenAble()
	Cleanup()
	Parent.DeleteWhenAble()
EndFunction