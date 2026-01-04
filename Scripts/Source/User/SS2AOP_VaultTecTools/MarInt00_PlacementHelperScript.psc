Scriptname SS2AOP_VaultTecTools:MarInt00_PlacementHelperScript extends ObjectReference

WorkshopFramework:Library:DataStructures:WorldObject Property PlotWorldObject Auto Const Mandatory
Form Property AssignedPlanWeapon Auto Const Mandatory

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	if AssignedPlanWeapon
		SimSettlementsV2:ObjectReferences:SimPlot plotRef = WorkshopFramework:WSFW_API.CreateSettlementObject(PlotWorldObject, akReference as WorkshopScript, Self) as SimSettlementsV2:ObjectReferences:SimPlot
		plotRef.ForcedPlan = AssignedPlanWeapon
		WorkshopFramework:WSFW_API.RemoveSettlementObject(Self as ObjectReference)
		if ( WorkshopFramework:WSFW_API.IsF4SERunning() )
			plotRef.CallFunction("TransmitConnectedPower", none)
		endif
	endIf
EndEvent