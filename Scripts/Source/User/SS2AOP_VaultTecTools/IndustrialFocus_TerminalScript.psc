Scriptname SS2AOP_VaultTecTools:IndustrialFocus_TerminalScript extends ObjectReference 

Keyword Property kgSim_PlotSpawned Auto Const Mandatory
GlobalVariable Property DummyGV Auto Const Mandatory
ActorValue Property FocusAV Auto Mandatory

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none

bool Property bEnabled = false Auto Hidden

Event OnActivate(ObjectReference akBruh)
	if plotLinkHolder == none
		plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
	endIf
	DummyGV.SetValue(plotLinkHolder.kPlotRef.GetValue(FocusAV))
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
			plotLinkHolder.kPlotRef.UpdateWorkshopResources()
		endIf
	endIf
EndFunction

Function SetFocus(float fNewFocus)
	plotLinkHolder.kPlotRef.SetValue(FocusAV, fNewFocus)
	DummyGV.SetValue(fNewFocus)
	plotLinkHolder.kPlotRef.UpdateWorkshopResources()
EndFunction