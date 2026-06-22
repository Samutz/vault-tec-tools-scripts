Scriptname SS2AOP_VaultTecTools:MannequinFurnitureScript extends ObjectReference

ActorBase Property actorMannequin Auto Const Mandatory
Outfit Property ofOutfit Auto Const
bool Property bSetHeadtracking = true Auto Const
bool Property bSnapIntoInteraction = true Auto Const

bool bEnabled = false
Actor akMannequin

Event OnLoad()
    if akMannequin && bEnabled
        if akMannequin.WaitFor3DLoad()
            ResetMannequin()
            StartTimer(3, 0)
        else
            Cleanup()
        endIf
    endIf
EndEvent

Event OnTimer(int iTimerID)
    if iTimerID == 0
        ResetMannequin()
    endIf
EndEvent

Function ResetMannequin()
    if ofOutfit != none
        akMannequin.SetOutfit(ofOutfit)
    endIf
    akMannequin.SetHeadTracking(bSetHeadtracking)
    akMannequin.BlockActivation(true, false)
    akMannequin.SetGhost(true)
    akMannequin.SetScale(Self.GetScale())
    SetActorRefOwner(akMannequin)
    akMannequin.SetRestrained(true)
    if bSnapIntoInteraction
        akMannequin.SnapIntoInteraction(Self)
        akMannequin.SetRestrained(true)
    endIf
EndFunction

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true

        akMannequin = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, actorMannequin) as Actor
        akMannequin.Enable(false)
        
        if akMannequin.WaitFor3DLoad()
            ResetMannequin()
            StartTimer(3, 0)
        else
            Cleanup()
        endIf
    endIf
EndFunction

Function Cleanup()
    akMannequin.Disable(false)
    akMannequin.Delete()
    bEnabled = false
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

Function DeleteWhenAble()
	Cleanup()
	Parent.DeleteWhenAble()
EndFunction