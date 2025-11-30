Scriptname SS2AOP_VaultTecTools:MannequinActorScript extends Actor

bool Property bSetHeadtracking = true Auto Const

bool bEnabled = false

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("AsyncEnable", none)
EndFunction

Function AsyncEnable()
    if !bEnabled
        bEnabled = true

        SetHeadTracking(bSetHeadtracking)
        SetRestrained(true)
        BlockActivation(true, false)
        SetGhost(true)
    endIf
EndFunction

Function Cleanup()
    Disable(false)
    Delete()
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction

Function DeleteWhenAble()
	Cleanup()
	Parent.DeleteWhenAble()
EndFunction