ScriptName SV88:IndInt00_PowerProviderScript Extends WorkshopObjectScript

Import SV88:SamutzLibrary

Group IndInt00_PowerProviderScript
	AutoBuilder:AutoBuildParentScript Property AutoBuildParent Auto Const Mandatory
	ActorValue Property PowerGeneratedAV Auto Const Mandatory
	Keyword Property kgSim_PlotSpawned Auto Const Mandatory
	Keyword Property kgSim_PlotSpawnedMultiStage Auto Const Mandatory
	float Property fPowerPerLevel = 25.0 Auto Const Mandatory
	float Property fPowerPerLevelVault88 = 30.0 Auto Const Mandatory
	ActorValue Property IsVault88AV Auto Const Mandatory
EndGroup

float Property fFinalPowerPerLevel = 25.0 Auto Hidden

WorkshopObjectScript plotRef = none
WorkshopScript workshopRef = none
bool bPoweredOn = true
ObjectReference playerRef = none

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	playerRef = Game.GetPlayer()

	if !Self.IsDeleted() && !Self.IsDestroyed() 
		plotRef = SV88:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned, kgSim_PlotSpawnedMultiStage) as WorkshopObjectScript
		if plotRef
			fFinalPowerPerLevel = fPowerPerLevel
			if plotRef.workshopID > -1
				workshopRef = WorkshopParent.GetWorkshop(plotRef.workshopID)
				if workshopRef && workshopRef.GetValue(IsVault88AV) == 1.0
					fFinalPowerPerLevel = fPowerPerLevelVault88
				endif
			endIf
			if plotRef.HasActorRefOwner()
				Self.EnablePower(true)
			else
				Self.EnablePower(false)
			endIf
			
			int iPlotLevel = (plotRef.CastAs("AutoBuilder:AutoBuildPlot")).GetPropertyValue("CurrentLevel") as int
			;debug.messagebox("plot level = "+iPlotLevel)
			float fPowerMod = (iPlotLevel as float)*fFinalPowerPerLevel
			Self.SetValue(PowerGeneratedAV, fPowerMod)
			
			(plotRef.CastAs("SimSettlements:SimPlot")).CallFunction("UpdateSettlementModifierData", new var[7])
			
			Self.RegisterForCustomEvent(WorkshopParent, "WorkshopActorAssignedToWork")
			Self.RegisterForCustomEvent(WorkshopParent, "WorkshopActorUnassigned")
			
			Self.RegisterForCustomEvent(AutoBuildParent, "OnPlotLevelChanged")
		endIf
	endIf
EndFunction

Function EnablePower(bool bOn)
	if (bOn && !bPoweredOn) || (!bOn && bPoweredOn)
		Self.Activate(playerRef, true)
		bPoweredOn = !bPoweredOn
	endIf
EndFunction

Event WorkshopParentScript.WorkshopActorAssignedToWork(WorkshopParentScript akSender, Var[] akArgs)
	if (akArgs[0] as WorkshopObjectScript) == plotRef
		Self.EnablePower(true)
	endIf
EndEvent

Event WorkshopParentScript.WorkshopActorUnassigned(WorkshopParentScript akSender, Var[] akArgs)
	if (akArgs[0] as WorkshopObjectScript) == plotRef
		Self.EnablePower(false)
	endIf
EndEvent

Event AutoBuilder:AutoBuildParentScript.OnPlotLevelChanged(AutoBuilder:AutoBuildParentScript akSender, Var[] akArgs)
	if (akArgs[0] as WorkshopObjectScript) == plotRef
		float fPowerMod = (akArgs[2] as float)*fFinalPowerPerLevel
		Self.SetValue(PowerGeneratedAV, fPowerMod)
		
		(plotRef.CastAs("SimSettlements:SimPlot")).CallFunction("UpdateSettlementModifierData", new var[7])
	endIf
EndEvent

Function Disable(bool abFade = false)
	Self.EnablePower(false)
	Parent.Disable(abFade)
EndFunction

Function DisableNoWait(bool abFade = false)
	Self.EnablePower(false)
	Parent.DisableNoWait(abFade)
EndFunction

Function Delete()
	Self.UnregisterForAllEvents()
	plotRef = none
	
	Parent.Delete()
EndFunction
