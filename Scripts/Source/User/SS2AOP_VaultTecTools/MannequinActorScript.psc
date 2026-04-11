Scriptname SS2AOP_VaultTecTools:MannequinActorScript extends Actor

bool Property bSetHeadtracking = true Auto Const

bool bEnabled = false

Event OnLoad()
    ; replaced in 3.1 with furniture mannequins
    Cleanup()
EndEvent

Function Enable(bool abFade = false)
EndFunction

Function AsyncEnable()
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