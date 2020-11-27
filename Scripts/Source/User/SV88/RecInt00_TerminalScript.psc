Scriptname SV88:RecInt00_TerminalScript extends ObjectReference 

Import SV88:SamutzLibrary

Form Property furnDeskBase Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
Keyword Property kgSim_PlotSpawnedMultiStage Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory

ObjectReference plotRef = none
ObjectReference[] furnDeskRefs = none
int iNumRows = 0

Event OnActivate(ObjectReference akBruh)
	DummyGV.SetValue(iNumRows as float)
EndEvent

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	furnDeskRefs = new ObjectReference[0]
	
	if !Self.IsDeleted() && !Self.IsDestroyed() 
		plotRef = SV88:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned, kgSim_PlotSpawnedMultiStage)
		Self.SetActorRefOwner(Game.GetPlayer())
	endIf
EndFunction

Function AddDeskRow()
	if (plotRef as bool)
		float rowDistance = (iNumRows * -100) - 200 ; distance from plot center
		float colSpacing = 150
		ObjectReference newDesk1 = SV88:SamutzLibrary.PlaceRelativeToMe(plotRef, furnDeskBase, rowDistance, 0, 0, 0, 0, 270)
		ObjectReference newDesk2 = SV88:SamutzLibrary.PlaceRelativeToMe(plotRef, furnDeskBase, rowDistance, colSpacing, 0, 0, 0, 270)
		ObjectReference newDesk3 = SV88:SamutzLibrary.PlaceRelativeToMe(plotRef, furnDeskBase, rowDistance, (0-colSpacing), 0, 0, 0, 270)
		furnDeskRefs.Add(newDesk1)
		furnDeskRefs.Add(newDesk2)
		furnDeskRefs.Add(newDesk3)
		newDesk1.Enable(false)
		newDesk2.Enable(false)
		newDesk3.Enable(false)
		newDesk1.SetLinkedRef((plotRef as ObjectReference), kgSim_PlotSpawnedMultiStage)
		newDesk2.SetLinkedRef((plotRef as ObjectReference), kgSim_PlotSpawnedMultiStage)
		newDesk3.SetLinkedRef((plotRef as ObjectReference), kgSim_PlotSpawnedMultiStage)
		iNumRows += 1
		DummyGV.SetValue(iNumRows as float)
	endIf
EndFunction

Function AddMultipleRows(int count = 1)
	int i = 0
	while i < count
		Self.AddDeskRow()
		i += 1
	endWhile
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function RemoveDeskRow()
	if iNumRows > 0 && (plotRef as bool)
		furnDeskRefs[furnDeskRefs.length - 1].Disable(false)
		furnDeskRefs[furnDeskRefs.length - 2].Disable(false)
		furnDeskRefs[furnDeskRefs.length - 3].Disable(false)
		furnDeskRefs[furnDeskRefs.length - 1].Delete()
		furnDeskRefs[furnDeskRefs.length - 2].Delete()
		furnDeskRefs[furnDeskRefs.length - 3].Delete()
		furnDeskRefs.RemoveLast()
		furnDeskRefs.RemoveLast()
		furnDeskRefs.RemoveLast()
		iNumRows -= 1
	endIf
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function RemoveAllDesks()
	int i = 0
	while i < furnDeskRefs.length
		furnDeskRefs[i].Disable(false)
		furnDeskRefs[i].Delete()
		i += 1
	endWhile
	furnDeskRefs.Clear()
	iNumRows = 0
	DummyGV.SetValue(iNumRows as float)
EndFunction

Function Cleanup()
	Self.RemoveAllDesks()
	plotRef = none
EndFunction

Function Delete()
	Self.Cleanup()
	Parent.Delete()
EndFunction

