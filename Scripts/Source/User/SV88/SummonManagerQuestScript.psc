Scriptname SV88:SummonManagerQuestScript extends Quest

Group Controllers
	GlobalVariable Property CurrentVersion Auto Const Mandatory
	{ Holds the current version of the files, used with local property InstalledVersion to determine what changes to apply }
	RefCollectionAlias Property SummonedSettlersAlias Auto Const Mandatory
	RefCollectionAlias Property SummonedSettlers_NoPackageAlias Auto Const Mandatory
	WorkshopParentScript Property WorkshopParent Auto Const Mandatory
	ReferenceAlias Property WorkshopAlias Auto Const Mandatory
	ReferenceAlias Property PlayerAlias Auto Const Mandatory
EndGroup

Group Messages
	Message Property ExitPipboyMessage Auto Const Mandatory
	Message Property NoSettlementWarning Auto Const Mandatory
	Message Property NoMatchWarning Auto Const Mandatory
EndGroup

Group ConditionalStuff
	FormList Property Pipboys Auto Const Mandatory
	FormList Property VaultSuits Auto Const Mandatory
EndGroup

bool Property SummoningInProgress = false Auto Hidden
float Property InstalledVersion = 0.0 Auto Hidden ; Version control

ObjectReference playerRef = None
InputEnableLayer myLayer = none

bool bMenuCloseEventRegistered = false
int iSummonCondition = -1

Event OnQuestInit()
	;debug.notification("summon manager started")
	if(InstalledVersion < CurrentVersion.GetValue())
		if(InstalledVersion > 0)
			InstallModChanges()
		else
			InstalledVersion = CurrentVersion.GetValue()
		endif
	endif
	playerRef = Game.GetPlayer()
	PlayerAlias.ForceRefTo(playerRef)
	RegisterForRemoteEvent(playerRef as Actor, "OnLocationChange")
	
	myLayer = InputEnableLayer.Create()
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if asMenuName == "PipboyMenu" || asMenuName == "TerminalMenu"
        if !abOpening && iSummonCondition > -1
			UnregisterForAllMenuOpenCloseEvents()
			Self.SummonBy()
        endif
    endif
endEvent 

Function StartListener(int iThisSummonCondition, ObjectReference akTerminalRef)
	ObjectReference ClosestWorkshop = WorkshopAlias.GetRef()
	if ClosestWorkshop
		if akTerminalRef
			RegisterForMenuOpenCloseEvent("TerminalMenu")
		else
			RegisterForMenuOpenCloseEvent("PipboyMenu")
		endIf
		ExitPipboyMessage.Show()
		iSummonCondition = iThisSummonCondition
	else
		NoSettlementWarning.Show()
		Self.Stop()
	endIf
EndFunction

Function SummonBy()
	ObjectReference ClosestWorkshop = WorkshopAlias.GetRef()
	Actor[] workshopNPCs = WorkshopParent.GetWorkshopActors(ClosestWorkshop as WorkshopScript) as Actor[]
	
	if workshopNPCs.length > 0
		SummoningInProgress = true

		Game.FadeOutGame(True, True, 0, 1, True)
		Debug.SetGodMode(true)
		Debug.EnableAI(false)
		myLayer.DisablePlayerControls()
		
		int i = 0
		while i < workshopNPCs.Length
			bool bDoSummon = true
			int j = 0
			
			;/ TODO: filter out non-humans /;
			
			if iSummonCondition == 0 ; no pipboy
				while j < Pipboys.GetSize() && bDoSummon
					if workshopNPCs[i].IsEquipped(Pipboys.GetAt(j))
						bDoSummon = false
					endIf
					j += 1
				endWhile
			elseif iSummonCondition == 1 ; no vault suit
				while j < VaultSuits.GetSize() && bDoSummon
					if workshopNPCs[i].IsEquipped(VaultSuits.GetAt(j))
						bDoSummon = false
					endIf
					j += 1
				endWhile
			endIf
			
			if bDoSummon
				workshopNPCs[i].MoveTo(playerRef)
				workshopNPCs[i].MoveToNearestNavmeshLocation()
				SummonedSettlersAlias.AddRef(workshopNPCs[i] as ObjectReference)
			endIf
			i += 1
		endWhile
		
		SummonedSettlersAlias.EvaluateAll()
		;debug.notification("after while loop count: "+SummonedSettlersAlias.GetCount())
		SummoningInProgress = false
		
		Game.FadeOutGame(false, True, 0, 1, True)
		myLayer.EnablePlayerControls()
		Debug.SetGodMode(false)
		Debug.EnableAI(true)
		
		if SummonedSettlersAlias.GetCount() > 0
			Self.StartTimer(60)
		else
			NoMatchWarning.Show()
			Self.Stop()
		endIf
	else
		NoMatchWarning.Show()
		Self.Stop()
	endIf
EndFunction

Function Stop()
	;debug.notification("summon manager shutting down")
	if SummoningInProgress
		Game.FadeOutGame(false, True, 0, 1, True)
		myLayer.EnablePlayerControls()
		Debug.SetGodMode(false)
		Debug.EnableAI(true)
	endIf
	
	SummoningInProgress = false
	bMenuCloseEventRegistered = false
	iSummonCondition = -1
	
	SummonedSettlers_NoPackageAlias.AddRefCollection(SummonedSettlersAlias)
	SummonedSettlersAlias.RemoveAll()
	SummonedSettlers_NoPackageAlias.EvaluateAll()
	SummonedSettlers_NoPackageAlias.RemoveAll()
	
	UnregisterForAllRemoteEvents()
	
	;debug.notification("summon manager stopped")
	Parent.Stop()
EndFunction

Event Actor.OnLocationChange(Actor akSender, Location akOldLoc, Location akNewLoc)
	;debug.notification("OnLocationChange")
	Self.Stop()
EndEvent

Event OnTimer(int iTimerId)
	;debug.notification("OnTimer() count: "+SummonedSettlersAlias.GetCount())
	Self.Stop()
EndEvent

Function InstallModChanges()
	; Make changes here - use format if(InstalledVersion < X.X) do something endif 

	; Once complete, flag our version as up to date
	InstalledVersion = CurrentVersion.GetValue()
EndFunction
