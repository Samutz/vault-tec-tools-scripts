Scriptname SV88:MarInt00_PlacementHelperScript extends ObjectReference

Import SV88:SamutzLibrary

Activator Property kgSIM_MartialPlot_Interior Auto Const Mandatory
MiscObject Property SV88_MarInt00_Plan Auto Const Mandatory
WorkshopParentScript Property WorkshopParent Auto Const mandatory

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	WorkshopObjectScript plotRef = SV88:SamutzLibrary.PlaceRelativeToMe(Self, kgSIM_MartialPlot_Interior, -8, -128, 6.75, 0, 0, 0, 1.0) as WorkshopObjectScript
	if plotRef
		plotRef.Enable(false)
		;/
		This didn't work, but I'm leaving it in case I decide to revisit it in the future
		
		; wait 15 seconds for initialization
		int i = 0
		while !(plotRef.CastAs("AutoBuilder:AutoBuildPlot")).GetPropertyValue("bInitializationComplete") && i < 15
			Utility.Wait(1)
			i += 0
		endWhile
		
		if (plotRef.CastAs("AutoBuilder:AutoBuildPlot")).GetPropertyValue("bInitializationComplete")
		
			(plotRef.CastAs("AutoBuilder:AutoBuildPlot")).SetPropertyValue("bLockedBuildingPlan", false)
		
			Var[] params = new Var[3]
			params[0] = SV88_MarInt00_Plan.CastAs("autobuilder:autobuildbuildingplan")
			params[1] = false as bool
			params[2] = true as bool
			(plotRef.CastAs("AutoBuilder:AutoBuildPlot")).CallFunction("AssignBuildingPlan", params)
			
			(plotRef.CastAs("AutoBuilder:AutoBuildPlot")).SetPropertyValue("bObjectExists", true)
			(plotRef.CastAs("AutoBuilder:AutoBuildPlot")).SetPropertyValue("bInitialPlacementComplete", false)
			
			(plotRef.CastAs("AutoBuilder:AutoBuildPlot")).CallFunction("HandleInitialModelCreation", new var[0])
		else
			debug.messagebox("An error occurred the the building plan could not be automatically selected. You may need to use the ASAM sensor to select it manually.")
		endIf
		/;
	else
		debug.messagebox("An error occurred the the plot could not be placed. You may need to manually place it.")
	endIf
	
	Self.Disable(false)
	Self.Delete()
EndEvent

