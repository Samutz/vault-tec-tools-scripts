Scriptname SS2AOP_VaultTecTools:MarInt00_PlacementHelperScript extends ObjectReference

Import SS2AOP_VaultTecTools:SamutzLibrary

WorkshopFramework:Library:DataStructures:WorldObject Property PlotWorldObject Auto Const Mandatory
simsettlementsv2:weapons:buildingplan Property AssignedPlan Auto Const Mandatory

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	ObjectReference plotRef = WorkshopFramework:WSFW_API.CreateSettlementObject(PlotWorldObject, akReference as WorkshopScript, Self)
	if plotRef
		(plotRef as SimSettlementsV2:ObjectReferences:SimPlot).AssignBuildingPlan(AssignedPlan)
		(plotRef as SimSettlementsV2:ObjectReferences:SimPlot).bPlayerSelectedPlanManually = true
	endIf
	Self.Disable(false)
	Self.Delete()
EndEvent

