Scriptname SS2AOP_VaultTecTools:ComInt01_NukaWorldDisplayScript extends ObjectReference

Static Property NukaWorldOnly_Static Auto Const Mandatory
Keyword Property kwLinkParent Auto Const Mandatory

ObjectReference staticReF = none

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	CheckIfCanReplace()

	RegisterForRemoteEvent(Game.GetPlayer(), "OnPlayerLoadGame")
EndFunction

; incase DLC is removed after static has spawned
Event Actor.OnPlayerLoadGame(Actor akActorRef)
	CheckIfCanReplace()
EndEvent

Function CheckIfCanReplace()
	if !Self.IsDeleted() && !Self.IsDestroyed()
		if Game.IsPluginInstalled("DLCNukaWorld.esm")
			if !staticRef && Self.IsEnabled()
				staticReF = Self.PlaceAtMe(NukaWorldOnly_Static, 1, false, true, true)
				Self.Disable()
				staticReF.SetLinkedRef((Self as ObjectReference), kwLinkParent)
				staticReF.Enable(false)
			endIf
		else
			CleanRef()
			if !Self.IsDisabled()
				Self.Enable(false)
			endIf
		endIf
	endIf
EndFunction

Function CleanRef()
	if staticReF
		staticReF.Disable()
		staticReF.Delete()
		staticReF = none
	endIf
	SS2AOP_VaultTecTools:SamutzLibrary.CleanUpChildSpawns((Self as ObjectReference), kwLinkParent)
EndFunction

Function Delete()
	CleanRef()
	Self.UnregisterForAllRemoteEvents() 
	Parent.Delete()
EndFunction
