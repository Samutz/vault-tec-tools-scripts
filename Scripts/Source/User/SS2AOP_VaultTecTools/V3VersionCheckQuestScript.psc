Scriptname SS2AOP_VaultTecTools:V3VersionCheckQuestScript extends Quest

Group Controllers
	GlobalVariable Property CurrentVersion Auto Const Mandatory
	GlobalVariable Property CurrentVersionV3 Auto Const Mandatory
	Message Property VersionMismatchMessage Auto Const Mandatory
EndGroup

Actor PlayerRef
string LogName = "VTT2_V3VersionCheck"

Event OnQuestInit()
	Debug.OpenUserLog(LogName)
	Debug.TraceUser(LogName, "VTT2_V3VersionCheck Started")
	PlayerRef = Game.GetPlayer()
    Startup()
	RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
EndEvent

Event Actor.OnPlayerLoadGame(Actor akActorRef)
	Debug.OpenUserLog(LogName)
    Startup()
EndEvent

Function Startup()
    Debug.TraceUser(LogName, "SS2AOP_VaultTecTools2.esp is installed, checking versions...")
    Debug.TraceUser(LogName, "  SS2AOP_VaultTecTools.esp version: "+CurrentVersionV3.GetValue())
    Debug.TraceUser(LogName, "  SS2AOP_VaultTecTools2.esp version: "+CurrentVersion.GetValue())

    if CurrentVersionV3 == none || CurrentVersionV3.GetValue() != CurrentVersion.GetValue()
        Debug.TraceUser(LogName, "  One of the plugins is out of date")
        int iResponse = VersionMismatchMessage.Show()
        if iResponse == 0
            Game.QuitToMainMenu()
        endIf
    endif
EndFunction