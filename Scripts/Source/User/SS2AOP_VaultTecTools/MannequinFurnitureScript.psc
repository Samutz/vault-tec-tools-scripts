Scriptname SS2AOP_VaultTecTools:MannequinFurnitureScript extends ObjectReference

ActorBase Property actorMannequin Auto Const Mandatory
Outfit Property ofOutfit Auto Const
bool Property bSetHeadtracking = true Auto Const

bool bEnabled = false
Actor akMannequin

Event OnLoad()
    if akMannequin
        ResetMannequin()
    endIf
EndEvent

Function ResetMannequin()
    if ofOutfit != none
        akMannequin.SetOutfit(ofOutfit)
    endIf
    akMannequin.Enable(false)
    akMannequin.SetHeadTracking(bSetHeadtracking)
    akMannequin.SetRestrained(true)
    akMannequin.BlockActivation(true, false)
    akMannequin.SetGhost(true)
    akMannequin.SetScale(Self.GetScale())

    SetActorRefOwner(akMannequin)

    while !akMannequin.Is3DLoaded()
        Utility.Wait(0.1)
    endWhile

    akMannequin.SnapIntoInteraction(Self)
EndFunction

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true
        akMannequin = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, actorMannequin) as Actor
        ResetMannequin()
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