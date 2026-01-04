Scriptname SS2AOP_VaultTecTools:PowerInteriorPlotsQuestScript extends Quest

import WSFWIdentifier

WorkshopFramework:MainQuest Property WSFW_Main Auto Const Mandatory
ActorValue Property WorkshopSnapTransmitsPower Auto Const Mandatory
Keyword Property SS2_PlotSize_Int Auto Const Mandatory
Keyword Property SS2_Tag_Plot Auto Const Mandatory
GlobalVariable Property VTT2_Settings_EnableInteriorSnapPower Auto Mandatory

Actor PlayerRef
string sLogName = "VTT2_PowerInteriorPlotsQuestScript"

; ---------------------------------------------
; Events --------------------------------------
; ---------------------------------------------
Event OnQuestInit()
	Debug.OpenUserLog(sLogName)
	Debug.TraceUser(sLogName, "PowerInteriorPlotsQuest Started")
	PlayerRef = Game.GetPlayer()
	StartUp()
	RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
EndEvent

Event Actor.OnPlayerLoadGame(Actor akActorRef)
	Debug.OpenUserLog(sLogName)
	StartUp()
EndEvent

Function StartUp()
    Debug.TraceUser(sLogName, "StartUp()")
	RegisterForCustomEvent(WSFW_Main, "PlayerEnteredSettlement")

    ; PlayerEnteredSettlement doesn't fire if save loads already in a settlement
    WorkshopScript akNearestWorkshopRef = WorkshopFramework:WSFW_API.GetNearestWorkshop(PlayerRef)
    if WSFW_Main.IsWithinBuildableAreaEX(PlayerRef, akNearestWorkshopRef)
        RegisterWorkshopEvents(akNearestWorkshopRef as ObjectReference)
    endIf
EndFunction

Event WorkshopFramework:MainQuest.PlayerEnteredSettlement(WorkshopFramework:MainQuest akSender, var[] kArgs)
    RegisterWorkshopEvents(kArgs[0] as ObjectReference)
EndEvent

Function RegisterWorkshopEvents(ObjectReference akWorkshopRef)
	RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectPlaced")
	RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectMoved")
	RegisterForRemoteEvent(akWorkshopRef, "OnWorkshopObjectGrabbed")
EndFunction

Event ObjectReference.OnWorkshopObjectPlaced(ObjectReference akSender, ObjectReference akPlot)
    AddPowerAV(akPlot, akSender)
EndEvent
Event ObjectReference.OnWorkshopObjectMoved(ObjectReference akSender, ObjectReference akPlot)
    AddPowerAV(akPlot, akSender)
EndEvent
Event ObjectReference.OnWorkshopObjectGrabbed(ObjectReference akSender, ObjectReference akPlot)
    AddPowerAV(akPlot, akSender)
EndEvent

Function AddPowerAV(ObjectReference akPlotRef, ObjectReference akWorkshopRef)
    ;Debug.TraceUser(sLogName, "AddPowerAV()")
    ;Debug.TraceUser(sLogName, "  akSender: "+akPlotRef)
    ;Debug.TraceUser(sLogName, "  akPlot: "+akWorkshopRef)
    if !akPlotRef.HasKeyword(SS2_PlotSize_Int) || !akPlotRef.HasKeyword(SS2_Tag_Plot) ; object is not interior plot
        ;Debug.TraceUser(sLogName, " Failed keyword check")
        return
    endIf
    if VTT2_Settings_EnableInteriorSnapPower.GetValue() != 1.0 ; setting not enabled
        ;Debug.TraceUser(sLogName, " Failed setting check")
        return
    endIf
    if akPlotRef.GetValue(WorkshopSnapTransmitsPower) == 1.0 ; object already has av or f4se plugin not available
        ;Debug.TraceUser(sLogName, " Failed AV check")
        return
    endIf
    if !IsPowerGridToolsRunning(akWorkshopRef) ; object already has av or f4se plugin not available
        ;Debug.TraceUser(sLogName, " Failed F4SE plugin check")
        return
    endIf
    akPlotRef.SetValue(WorkshopSnapTransmitsPower, 1)
    WSFW_Main.F4SEManager.TransmitConnectedPower(akPlotRef)
EndFunction

bool Function IsPowerGridToolsRunning(ObjectReference akWorkshop)
	PowerGridStatistics stats = CheckAndFixPowerGrid(akWorkshop, 0)
    if stats != none
        return true
    endif
    return false
EndFunction