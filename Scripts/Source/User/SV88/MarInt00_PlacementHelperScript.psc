Scriptname SV88:MarInt00_PlacementHelperScript extends ObjectReference

Import SV88:SamutzLibrary

Activator Property kgSIM_MartialPlot_Interior Auto Const Mandatory
SimSettlements:SimBuildingPlan Property SV88_MarInt00_Plan_GearDoor Auto Const Mandatory
Keyword Property WorkshopItemKeyword Auto Const Mandatory

Event OnWorkshopObjectPlaced(ObjectReference kWorkshopRef)
	SimSettlements:SimPlot plotRef = SV88:SamutzLibrary.PlaceRelativeToMe(Self, kgSIM_MartialPlot_Interior, -8, -128, 6.75, 0, 0, 0, 1.0) as SimSettlements:SimPlot
	if plotRef
		(plotRef as ObjectReference).Enable(false)
		(plotRef as ObjectReference).OnWorkshopObjectPlaced(kWorkshopRef)
		kWorkshopRef.OnWorkshopObjectPlaced(plotRef)
		(plotRef as ObjectReference).SetLinkedRef(kWorkshopRef, WorkshopItemKeyword)
		plotRef.AssignBuildingPlan((SV88_MarInt00_Plan_GearDoor as autobuilder:autobuildbuildingplan), false, false)
		plotRef.bPlayerSelectedBuildingPlan = true
	else
		debug.messagebox("An error occurred the the plot could not be placed. You may need to manually place it.")
	endIf
	
	Self.Disable(false)
	Self.Delete()
EndEvent

