Scriptname SV88:SlidingDoorQuestScript extends Quest

Group Controllers
	GlobalVariable Property CurrentVersion Auto Const Mandatory
	{ Holds the current version of the files, used with local property InstalledVersion to determine what changes to apply }
EndGroup

FormList Property SlidingDoorsList Auto Const Mandatory
RefCollectionAlias Property SlidingDoorAlias Auto Const Mandatory
RefCollectionAlias Property LoadedWorkshopAlias Auto Const Mandatory
GlobalVariable Property AutoOpenDoorsInWorkshopMode Auto Const Mandatory
Keyword Property WorkshopKeyword Auto Const Mandatory

float Property InstalledVersion = 0.0 Auto Hidden ; Version control

bool Property bWorkshopModeEnabled = false Auto Hidden

Event OnQuestInit()
	if(InstalledVersion < CurrentVersion.GetValue())
		if(InstalledVersion > 0)
			InstallModChanges()
		else
			InstalledVersion = CurrentVersion.GetValue()
		endif
	endif
	
	RegisterForRemoteEvent(LoadedWorkshopAlias, "OnWorkshopObjectPlaced")
	RegisterForRemoteEvent(LoadedWorkshopAlias, "OnWorkshopObjectMoved")
	RegisterForRemoteEvent(LoadedWorkshopAlias, "OnWorkshopMode")
EndEvent

Event OnQuestShutdown()
	UnregisterForAllRemoteEvents()
EndEvent

Event RefCollectionAlias.OnWorkshopObjectPlaced(RefCollectionAlias akSenderAlias, ObjectReference akSenderRef, ObjectReference akObject)
	if SlidingDoorsList.HasForm(akObject.GetBaseObject())
		SlidingDoorAlias.AddRef(akObject)
		bWorkshopModeEnabled = true
		if AutoOpenDoorsInWorkshopMode.GetValue() == 1.0
			akObject.SetOpen(true)
		endIf
	endIf
EndEvent

Event RefCollectionAlias.OnWorkshopObjectMoved(RefCollectionAlias akSenderAlias, ObjectReference akSenderRef, ObjectReference akObject)
	if SlidingDoorsList.HasForm(akObject.GetBaseObject())
		SlidingDoorAlias.AddRef(akObject)
		bWorkshopModeEnabled = true
		if AutoOpenDoorsInWorkshopMode.GetValue() == 1.0
			akObject.SetOpen(true)
		endIf
	endIf
EndEvent

Event RefCollectionAlias.OnWorkshopMode(RefCollectionAlias akSenderAlias, ObjectReference akSenderRef, bool bStarted)
	int i = 0
	if bStarted 
		bWorkshopModeEnabled = true
		i = 0
		while i < SlidingDoorAlias.GetCount() && AutoOpenDoorsInWorkshopMode.GetValue() == 1.0 && bWorkshopModeEnabled
			SlidingDoorAlias.GetAt(i).SetOpen(true)
			i += 1
		endWhile
	else
		bWorkshopModeEnabled = false
		i = 0
		while i < SlidingDoorAlias.GetCount() && AutoOpenDoorsInWorkshopMode.GetValue() == 1.0 && !bWorkshopModeEnabled
			SlidingDoorAlias.GetAt(i).SetOpen(false)
			i += 1
		endWhile
	endIf
EndEvent

Function GetWorkshopCount()
	debug.messagebox("LoadedWorkshopAlias count = "+LoadedWorkshopAlias.GetCount())
EndFunction

Function GetDoorCount()
	debug.messagebox("SlidingDoorAlias count = "+SlidingDoorAlias.GetCount())
EndFunction

Function InstallModChanges()
	; Make changes here - use format if(InstalledVersion < X.X) do something endif 

	; Once complete, flag our version as up to date
	InstalledVersion = CurrentVersion.GetValue()
EndFunction
