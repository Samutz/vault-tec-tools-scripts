Scriptname SS2AOP_VaultTecTools:MarInt00_PlacementHelperScript extends ObjectReference

WorkshopFramework:Library:DataStructures:WorldObject Property PlotWorldObject Auto Const Mandatory
simsettlementsv2:weapons:buildingplan Property AssignedPlan Auto Const Mandatory

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	SimSettlementsV2:ObjectReferences:SimPlot plotRef = WorkshopFramework:WSFW_API.CreateSettlementObject(PlotWorldObject, akReference as WorkshopScript, Self) as SimSettlementsV2:ObjectReferences:SimPlot
	if plotRef
		plotRef.AssignBuildingPlan(AssignedPlan)
		plotRef.bPlayerSelectedPlanManually = true
	endIf
	Disable(false)
	Delete()
EndEvent

