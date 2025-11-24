Scriptname SS2AOP_VaultTecTools:SynthMannequinScript extends ObjectReference

ActorBase Property actorMannequin Auto Mandatory
Outfit Property ofOutfit Auto

bool bEnabled = false
Actor akMannequin

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true

        akMannequin = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, actorMannequin) as Actor
        
        if ofOutfit != none
            akMannequin.SetOutfit(ofOutfit)
        endIf
        akMannequin.Enable(false)
        akMannequin.SetHeadTracking(false)
        akMannequin.SetRestrained(true)
        akMannequin.BlockActivation(true, false)
        akMannequin.SetGhost(true)

        SetActorRefOwner(akMannequin)

        while !akMannequin.Is3DLoaded()
            Utility.Wait(0.1)
        endWhile

        akMannequin.SnapIntoInteraction(Self)
    endIf
EndFunction

Function Cleanup()
    akMannequin.Disable(false)
    akMannequin.Delete()
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

Function DeleteWhenAble()
	Cleanup()
	Parent.DeleteWhenAble()
EndFunction