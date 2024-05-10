Scriptname SS2AOP_VaultTecTools:MarInt00_PlacementHelperScript extends ObjectReference

WorkshopFramework:Library:DataStructures:WorldObject Property PlotWorldObject Auto Const Mandatory
Form Property AssignedPlanWeapon Auto Const Mandatory

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	simsettlementsv2:weapons:buildingplan AssignedPlan = AssignedPlanWeapon as simsettlementsv2:weapons:buildingplan
	SimSettlementsV2:ObjectReferences:SimPlot plotRef = WorkshopFramework:WSFW_API.CreateSettlementObject(PlotWorldObject, akReference as WorkshopScript, Self) as SimSettlementsV2:ObjectReferences:SimPlot
	if plotRef
		plotRef.AssignBuildingPlan(AssignedPlan)
		plotRef.bPlayerSelectedPlanManually = true
	endIf
	Disable(false)
	Delete()
EndEvent

