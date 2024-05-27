Scriptname SS2AOP_VaultTecTools:RecInt01_TerminalScript extends ObjectReference 

WorkshopFramework:Library:DataStructures:WorldObject[] Property StallActivators Auto Const Mandatory
{ ALWAYS SET: fExtraDataFlag = stall width, fPosY = -126, fPosX = 144, fAngleZ = 90 }
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none

bool Property bEnabled = false Auto Hidden

int[] iCounts = none

Event OnActivate(ObjectReference akBruh)
	UpdateCounts()
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true

		if iCounts.length != StallActivators.length + 1
			iCounts = new int[StallActivators.length + 1]
		endIf

		if !IsDeleted() && !IsDestroyed() 
			plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
			SetActorRefOwner(Game.GetPlayer())

			UpdateCounts()
			
			if iCounts[0] == 0
				AddStall(0)
				AddStall(0)
			endIf
		endIf
	endIf
EndFunction

Function AddStall(int iType = 0)
	if (plotLinkHolder.kPlotRef as bool)
		UpdateCounts()

		int iCurrentCount = iCounts[0]
		float fPosYDefault = StallActivators[iType].fPosY ; should be -126 for recint01

		int i = 0
		while i < StallActivators.length
			StallActivators[iType].fPosY += ((iCounts[i + 1] as float) * StallActivators[i].fExtraDataFlag)
			i += 1
		endWhile
		StallActivators[iType].fPosY += (StallActivators[iType].fExtraDataFlag / 2.0) ; add half width of spawn object

		plotLinkHolder.kPlotRef.SpawnStageItem(StallActivators[iType], plotLinkHolder.kWorkshopRef, (plotLinkHolder.kPlotRef as ObjectReference))

		StallActivators[iType].fPosY = fPosYDefault

		; wait for counts to update before allowing another action
		while iCurrentCount == iCounts[0] && DummyGV.GetValue() == iCurrentCount as float
			UpdateCounts()
			Utility.Wait(1)
		endWhile
	endIf
EndFunction

Function RemoveStall()
	UpdateCounts()

	int iCurrentCount = iCounts[0]

	if iCounts[0] > 0
		ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
		int i = plotSpawns.Length - 1
		int iRemovedCount = 0
		while (i > -1 && iRemovedCount < 1) ; going backwards in the spawns to get the last added stall
			if StallActivators.FindStruct("ObjectForm", plotSpawns[i].GetBaseObject()) > -1
				plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
				plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
				iRemovedCount += 1
			endIf
			i -= 1
		endWhile

		; wait for counts to update before allowing another action
		while iCounts[0] == iCurrentCount && DummyGV.GetValue() == iCurrentCount as float
			UpdateCounts()
			Utility.Wait(1)
		endWhile
	endIf
EndFunction

Function RemoveAllStalls()
	UpdateCounts()

	if iCounts[0] > 0
		ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
		int i = plotSpawns.Length - 1
		while i > -1 ; going backwards in the spawns to get the last added stall
			if StallActivators.FindStruct("ObjectForm", plotSpawns[i].GetBaseObject()) > -1
				plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
				plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
			endIf
			i -= 1
		endWhile

		; wait for counts to update before allowing another action
		while iCounts[0] > 0 && DummyGV.GetValue() > 0.0
			UpdateCounts()
			Utility.Wait(1)
		endWhile
	endIf
EndFunction

Function UpdateCounts(bool bDebug = false)
	iCounts = new int[StallActivators.length + 1]

	ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
	int i = 0
	while i < plotSpawns.length
		int index = StallActivators.FindStruct("ObjectForm", plotSpawns[i].GetBaseObject())
		if index > -1
			iCounts[index+1] += 1
			iCounts[0] += 1
		endIf
		i += 1
	endWhile

	DummyGV.SetValue(iCounts[0] as float)

	if bDebug
		string sResult = ""
		string sType = ""
		i = 1
		while i < iCounts.length
			sType = StallActivators[i-1].ObjectForm.CallFunction("GetName", none) ; F4SE function
			if sType == ""
				sType = "Type " + (i-1)
			endIf
			sResult = sResult + sType + ": " + iCounts[i] + "\n"
			i += 1
		endWhile
		Debug.MessageBox(sResult + "Total: " + iCounts[0])
	endIf
EndFunction

Function Cleanup()
	RemoveAllStalls()
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction