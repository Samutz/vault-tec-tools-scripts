ScriptName SS2AOP_VaultTecTools:RecInt10_ProjectorScript Extends ObjectReference

Keyword Property SS2_Link_StageItem Auto Const Mandatory

Group SlideProperties
    Light[] Property Slides Auto Const
    Float Property iTimeBetweenSlides = 5.0 Auto Const
    WorkshopFramework:Library:DataStructures:WorldObject Property woTemplate Auto
EndGroup

Group SoundProperties collapsedonref
    Sound Property OBJProjectorRunLPM Auto Const
    Sound Property OBJProjectorNext Auto Const
EndGroup

bool Property bEnabled = false Auto Hidden
bool Property bPowered = false Auto Hidden

SimSettlementsV2:ObjectReferences:plotlinkholder plotLinkHolder = none
int iCurrentSlide = -1
int iSoundLooping
int iUpdateTimer = 100

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true

		if !IsDeleted() && !IsDestroyed() 
			plotLinkHolder = SS2AOP_VaultTecTools:SamutzLibrary.GetParentPlot(Self, SS2_Link_StageItem) as SimSettlementsV2:ObjectReferences:plotlinkholder
            iSoundLooping = OBJProjectorRunLPM.Play(Self)

            RegisterForRemoteEvent(plotLinkHolder.kPlotRef, "OnPowerOn")
			RegisterForRemoteEvent(plotLinkHolder.kPlotRef, "OnPowerOff")

            bPowered = plotLinkHolder.kPlotRef.IsPowered()
            if bPowered
                PowerOn()
            endIf
		endIf
	endIf
EndFunction

Function NextSlide()
    if Is3DLoaded()
        ClearSlide()

        iCurrentSlide += 1
        if !Slides[iCurrentSlide]
            iCurrentSlide = 0
        endIf

        if Slides[iCurrentSlide]
            OBJProjectorNext.play(Self)
            woTemplate.ObjectForm = Slides[iCurrentSlide]
            plotLinkHolder.kPlotRef.SpawnStageItem(woTemplate, plotLinkHolder.kWorkshopRef, (plotLinkHolder.kPlotRef as ObjectReference))
            StartTimer(iTimeBetweenSlides, iUpdateTimer)
        endIf
    endIf
EndFunction

Event OnTimer(Int aiTimerID)
    if aiTimerID == iUpdateTimer && Is3DLoaded()
        NextSlide()
    endIf
EndEvent

Function ClearSlide()
    ObjectReference[] plotSpawns = plotLinkHolder.GetLinkedRefChildren(SS2_Link_StageItem)
    int i = plotSpawns.Length - 1
    while i > -1
        if Slides.Find(plotSpawns[i].GetBaseObject() as Light) > -1
            plotSpawns[i].SetLinkedRef(none, SS2_Link_StageItem)
            plotLinkHolder.kPlotRef.ScrapObject(plotSpawns[i], false)
        endIf
        i -= 1
    endWhile
EndFunction

Function PowerOn()
    NextSlide()
EndFunction

Function PowerOff()
    ClearSlide()
    Sound.StopInstance(iSoundLooping)
    CancelTimer(iUpdateTimer)
EndFunction

Function Cleanup()
    PowerOff()
	UnregisterForRemoteEvent(plotLinkHolder.kPlotRef, "OnPowerOn")
	UnregisterForRemoteEvent(plotLinkHolder.kPlotRef, "OnPowerOff")
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

Function DeleteWhenAble()
	Cleanup()
	Parent.DeleteWhenAble()
EndFunction

Function Disable(bool abFade = false)
	Cleanup()
	Parent.Disable(abFade)
EndFunction

Event ObjectReference.OnPowerOn(ObjectReference akSender, ObjectReference akPowerGenerator)
	bPowered = true
	PowerOn()
EndEvent

Event ObjectReference.OnPowerOff(ObjectReference akSender)
	bPowered = false
	PowerOff()
EndEvent

Event OnLoad()
    if bPowered
        PowerOn()
    endIf
EndEvent

Event OnUnload()
    PowerOff()
EndEvent