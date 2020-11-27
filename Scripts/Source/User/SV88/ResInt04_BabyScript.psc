Scriptname SV88:ResInt04_BabyScript extends ObjectReference Const

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	if !Self.IsDeleted() && !Self.IsDestroyed()
		RegisterForHitEvent(Self, Game.GetPlayer())
	endIf
EndFunction

Function Delete()
	UnregisterForAllHitEvents(Self)
	Parent.Delete()
EndFunction

Event OnHit(ObjectReference akTarget, ObjectReference akAggressor, Form akSource, Projectile akProjectile, bool abPowerAttack, bool abSneakAttack, bool abBashAttack, bool abHitBlocked, string apMaterial)
	Debug.SetGodMode(false)
	Game.GetPlayer().Kill(Game.GetPlayer())
EndEvent

