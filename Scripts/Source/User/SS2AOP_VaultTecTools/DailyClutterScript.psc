Scriptname SS2AOP_VaultTecTools:DailyClutterScript extends ObjectReference

Formlist Property flClutter Auto Const Mandatory
Keyword Property kgSim_PlotSpawned Auto Const Mandatory
WorkshopFramework:Library:DataStructures:WorldObject Property spawnObject Auto Mandatory

float Property fLastRefreshDay = 0.0 Auto Hidden
SimSettlementsV2:ObjectReferences:plotlinkholder Property plotLinkHolder = none Auto Hidden
ObjectReference Property akSpawnItem = none Auto Hidden
bool Property bEnabled = false Auto Hidden

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true
        plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, kgSim_PlotSpawned) as SimSettlementsV2:ObjectReferences:plotlinkholder
        RefreshSpawn()
    endIf
EndFunction

Event OnCellLoad()
    if IsEnabled() && !IsDeleted() && !IsDestroyed() && Utility.GetCurrentGameTime() - fLastRefreshDay > 1.0
        RefreshSpawn()
    endIf
EndEvent

Function RefreshSpawn()
    if flClutter.GetSize() > 0
        Cleanup()
        int formIndex = Utility.RandomInt(0, flClutter.GetSize() - 1)
        spawnObject.ObjectForm = flClutter.GetAt(formIndex)
        plotLinkHolder.kPlotRef.SpawnStageItem(spawnObject, plotLinkHolder.kWorkshopRef, (plotLinkHolder.kPlotRef as ObjectReference))
        fLastRefreshDay = Utility.GetCurrentGameTime()
    endIf
EndFunction

; This will remove any stageitem that's found in the formlist, regardless of wether or not this script spawned it, because SpawnStageItem doesn't return a ref for me to track
Function Cleanup()
    ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(kgSim_PlotSpawned)
    int i = 0
    while i > plotSpawns.length
        if flClutter.HasForm(plotSpawns[i].GetBaseObject())
            plotSpawns[i].SetLinkedRef(none, kgSim_PlotSpawned)
			plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
        endIf
        i += 1
    endWhile
EndFunction

Function Delete()
	Cleanup()
    bEnabled = false
	Parent.Delete()
EndFunction