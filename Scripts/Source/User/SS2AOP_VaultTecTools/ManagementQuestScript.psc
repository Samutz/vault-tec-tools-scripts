; ---------------------------------------------
; ManagementQuestTemplate.psc - by kinggath
; ---------------------------------------------
; Reusage Rights ------------------------------
; You are free to use this script or portions of it in your own mods, provided you give me credit in your description and maintain this section of comments in any released source code (which includes the IMPORTED SCRIPT CREDIT section to give credit to anyone in the associated Import scripts below.
; 
; IMPORTED SCRIPT CREDIT
; N/A
; ---------------------------------------------
Scriptname SS2AOP_VaultTecTools:ManagementQuestScript extends Quest

; ---------------------------------------------
; Editor Properties ---------------------------
; ---------------------------------------------
Group Controllers
	GlobalVariable Property CurrentVersion Auto Const Mandatory
	{ Holds the current version of the files, used with local property InstalledVersion to determine what changes to apply }
	WorkshopFramework:Library:WorkshopMenuInjectionQuest Property SettlementMenuInjector Auto Const Mandatory
	SS2AOP_VaultTecTools:SummonManagerQuestScript Property SummonManager Auto Const Mandatory
	WorkshopParentScript Property WorkshopParent Auto Const Mandatory
	Message Property InstallVersionMessage Auto Const Mandatory
	FormList Property VaultSuitsFormList Auto Const
	WorkshopFramework:Library:MasterQuest Property SS2_Main Auto Const Mandatory
EndGroup

Group InjectionObjects
	VipAVStruct[] Property ApplyVipAVs Auto Const
	ChanceNoneByQuestStruct[] Property ChanceNoneByQuestGlobals Auto Const
	LeveledItemInjectionObject[] Property LeveledItemInjectionObjects Auto Const
	FormListInjectionObject[] Property FormListInjectionObjects Auto Const
EndGroup

Group InjectionDefinitions
	PluginDefinition[] Property PluginDefinitions Auto Const
	{filenames of optional plugins}
	LeveledItem[] Property LeveledLists Auto Const
	{LeveledItems that will have stuff injected in to them}
	FormList[] Property FormLists Auto Const
	{FormLists that will have stuff injected in to them}
EndGroup

Group Vault118_SpecialSnowflake
	int Property V118_iPluginNameIndex Auto Const
	int Property V118_iQuestRequiredFormId = 0x036763 Auto Const Hidden
	int Property V118_iVaultSuitFormId = 0x043331 Auto Const Hidden
	GlobalVariable Property V118_LLChaneNoneGlobal Auto Const
EndGroup

Group Mechanist_SpecialSnowflake
	int Property Mechanist_iPluginNameIndex Auto Const
	int Property Mechanist_iQuestRequiredFormId = 0x0010F5 Auto Const Hidden
	GlobalVariable Property Mechanist_LLChaneNoneGlobal Auto Const
EndGroup

Group Settings
	GlobalVariable Property Settings_UseCityPlannerDoorSettingGlobal Auto Const
	GlobalVariable Property Settings_OpenDoorsInWorkshopModeGlobal Auto Const
	GlobalVariable Property Settings_MarInt00_AutomateGearDoor Auto Const
	GlobalVariable Property Settings_RecInt01_NoLock Auto Const
	GlobalVariable Property Settings_RecInt01_UseCWSS Auto Const
EndGroup

; ---------------------------------------------
; Dynamic Properties --------------------------
; ---------------------------------------------
Float Property InstalledVersion = 0.0 Auto Hidden ; Version control

; ---------------------------------------------
; Structs -------------------------------------
; ---------------------------------------------
Struct LeveledItemInjectionObject
	int iFormId
	{base form ID in decimal}
	Form LocalForm
	{form from this plugin}
	int iPluginNameIndex = -1
	{match a defined plugin name}
	int iLeveledItemIndex = -1
	{match a defined LeveledItem}
	int iFormLevel = 1
	{same as item level in a normal LeveledItem record}
	int iFormCount = 1
	{same as item count in a normal LeveledItem record}
EndStruct

Struct FormListInjectionObject
	int iFormId
	{base form ID in decimal}
	Form LocalForm
	{form from this plugin}
	int iPluginNameIndex = -1
	{match a defined plugin name}
	int iFormListIndex = -1
	{match a defined LeveledItem}
EndStruct

Struct VipAVStruct
	ObjectReference targetRef
	{actor reference to apply AV to}
	ActorValue AV
	{AV to apply to actor}
	float fValue = 1.0
	{AV to apply}
EndStruct

Struct ChanceNoneByQuestStruct
	int iVaultNo
	{Vault Number}
	Quest QuestToCheck
	{quest to check for completion}
	GlobalVariable GlobalToSet
	{global to change if quest is completed}
	float fValue = 0.0
	{value to set if quest is done}
EndStruct

Struct PluginDefinition
	string sName
	{plugin name}
	GlobalVariable SetGV
	{Set this globalvar to 1.0 if installed, else 0.0}
	bool bInstalled = false
	{DO NOT USE}
EndStruct

; ---------------------------------------------
; Variables -----------------------------------
; ---------------------------------------------
Actor PlayerRef
bool bEditLock = false ; Thread-safety
bool bPluginRefresh = false
string LogName = "VTT2_ManagementQuestScript"

; ---------------------------------------------
; Events --------------------------------------
; ---------------------------------------------
Event OnQuestInit()
	Debug.OpenUserLog(LogName)
	Debug.TraceUser(LogName, "ManagementQuest Started")
	PlayerRef = Game.GetPlayer()
	Self.CheckForSSInstall()
	RegisterForRemoteEvent(PlayerRef, "OnPlayerLoadGame")
EndEvent

Event Actor.OnPlayerLoadGame(Actor akActorRef)
	Debug.OpenUserLog(LogName)
	Self.CheckForSSInstall()
EndEvent

Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if asMenuName == "PipboyMenu"
        if !abOpening
			Self.CheckForSSInstall()
        endif
    endif
endEvent 

Event RefCollectionAlias.OnCellLoad(RefCollectionAlias akSenderAlias, ObjectReference akSenderRef)
	if akSenderRef.IsOwnedBy(PlayerRef)
		Self.StartTimer(3, 0)
	endIf
EndEvent

Event OnTimer(int iTimerId)
	if iTimerId == 0
		Self.CheckMenuInjector()
	endIf
EndEvent

; ---------------------------------------------
; Methods -------------------------------------
; ---------------------------------------------
Function CheckForSSInstall()
	UnregisterForMenuOpenCloseEvent("PipboyMenu")
	if SS2_Main.bQuestStartupsComplete == true
		Startup()
	else
		RegisterForMenuOpenCloseEvent("PipboyMenu")
		Debug.TraceUser(LogName, "City Manager not initialized, listening for PipboyMenu close event")
	endIf
EndFunction

Function Startup()
	bEditLock = false ; Make sure this never gets stuck permanently
	
	Self.CheckPlugins()
	
	if InstalledVersion < CurrentVersion.GetValue()
		Debug.TraceUser(LogName, "Starting upgrade from "+InstalledVersion+" to "+CurrentVersion.GetValue())
		Self.InstallModChanges()
		
		; always refresh injections on upgrade incase of changes
		Self.ApplyAVs()
		Self.InjectDLCObjects()
		Debug.TraceUser(LogName, "Completed upgrade to "+CurrentVersion.GetValue())
	elseif bPluginRefresh
		Debug.TraceUser(LogName, "Plugin install status has changed, refreshing injections")
		Self.ApplyAVs()
		Self.InjectDLCObjects()
		Debug.TraceUser(LogName, "Finished refreshing injections")
	endif
	
	bPluginRefresh = false
	
	; always check this because quest may be completed at any time
	Self.CheckChanceNoneQuests()
	
	; reload door manager in case loading in to a workshop
	Self.CheckMenuInjector()
	UnregisterForRemoteEvent(WorkshopParent.WorkshopsCollection, "OnCellLoad") ; redo this on every save load incase of new workshops
	RegisterForRemoteEvent(WorkshopParent.WorkshopsCollection, "OnCellLoad")
EndFunction

Function CheckMenuInjector()
	if !SettlementMenuInjector.IsRunning()
		Debug.TraceUser(LogName, "Starting SettlementMenuInjector")
		SettlementMenuInjector.Start()
	endIf
EndFunction

Function CheckPlugins()
	int i = 0 
	while i < PluginDefinitions.length
		if PluginDefinitions[i].bInstalled != Game.IsPluginInstalled(PluginDefinitions[i].sName)
			bPluginRefresh = true
		endIf
		PluginDefinitions[i].bInstalled = Game.IsPluginInstalled(PluginDefinitions[i].sName)
		if PluginDefinitions[i].SetGV
			if PluginDefinitions[i].bInstalled
				PluginDefinitions[i].SetGV.SetValue(1.0)
			else
				PluginDefinitions[i].SetGV.SetValue(0.0)
			endIf
		endIf
		Debug.TraceUser(LogName, "Plugin "+PluginDefinitions[i].sName+" installed: "+PluginDefinitions[i].bInstalled)
		i += 1
	endWhile
EndFunction

Function RefreshAll()
	; mostly for command line use
	Debug.TraceUser(LogName, "RefreshAll() called")
	Self.CheckPlugins()
	Self.ApplyAVs()
	Self.CheckChanceNoneQuests()
	Self.InjectDLCObjects()
EndFunction

Function ApplyAVs()
	; apply AVs to references so we can use them as VIPs on plots
	int i = 0
	while i < ApplyVipAVs.length
		if ApplyVipAVs[i].targetRef && ApplyVipAVs[i].AV
			if ApplyVipAVs[i].targetRef.GetValue(ApplyVipAVs[i].AV) != ApplyVipAVs[i].fValue
				ApplyVipAVs[i].targetRef.SetValue(ApplyVipAVs[i].AV, ApplyVipAVs[i].fValue)
			endIf
		endIf
		i += 1
	endWhile
EndFunction

Function CheckChanceNoneQuests()
	; set chancenone globals for leveled lists based on quest completion
	int i = 0
	while i < ChanceNoneByQuestGlobals.length
		if ChanceNoneByQuestGlobals[i].QuestToCheck && ChanceNoneByQuestGlobals[i].QuestToCheck.IsCompleted()
			ChanceNoneByQuestGlobals[i].GlobalToSet.SetValue(ChanceNoneByQuestGlobals[i].fValue)
		endIf
		i += 1
	endWhile
	
	VaultSuitsFormList.Revert() ; used by both sections below
	
	; Vault 118 Stuff
	if PluginDefinitions[V118_iPluginNameIndex].bInstalled
	
		Form vaultSuit = Game.GetFormFromFile(V118_iVaultSuitFormId, PluginDefinitions[V118_iPluginNameIndex].sName) as Form
		VaultSuitsFormList.AddForm(vaultSuit)
		
		if V118_iQuestRequiredFormId && V118_LLChaneNoneGlobal
			Quest questRequired = Game.GetFormFromFile(V118_iQuestRequiredFormId, PluginDefinitions[V118_iPluginNameIndex].sName) as Quest
			if questRequired
				if questRequired.IsCompleted()
					V118_LLChaneNoneGlobal.SetValue(0.0)
				endIf
			endIf
		endIf
	endIf
	
	; Vault M Stuff
	if Mechanist_iPluginNameIndex
		if PluginDefinitions[Mechanist_iPluginNameIndex].bInstalled
			if Mechanist_iQuestRequiredFormId && Mechanist_LLChaneNoneGlobal
				Quest questRequired = Game.GetFormFromFile(Mechanist_iQuestRequiredFormId, PluginDefinitions[Mechanist_iPluginNameIndex].sName) as Quest
				if questRequired
					if questRequired.IsCompleted()
						Mechanist_LLChaneNoneGlobal.SetValue(0.0)
					endIf
				endIf
			endIf
		endIf
	endIf
EndFunction

Function InjectDLCObjects()
	; clean lists incase of injection changes or DLC removal
	int i = 0
	while i < LeveledLists.length
		LeveledLists[i].Revert()
		i += 1
	endWhile
	
	i = 0
	while i < FormLists.length
		FormLists[i].Revert()
		i += 1
	endWhile
	
	; inject lists with DLC/mod items
	i = 0
	while i < LeveledItemInjectionObjects.length
		int p = LeveledItemInjectionObjects[i].iPluginNameIndex
		int l = LeveledItemInjectionObjects[i].iLeveledItemIndex
		if PluginDefinitions[p].bInstalled && LeveledLists[l] 
			if LeveledItemInjectionObjects[i].iFormId
				Form injectForm = Game.GetFormFromFile(LeveledItemInjectionObjects[i].iFormId, PluginDefinitions[p].sName) as Form
				if injectForm
					LeveledLists[l].AddForm(injectForm, LeveledItemInjectionObjects[i].iFormLevel, LeveledItemInjectionObjects[i].iFormCount)
				endIf
			endif
			if LeveledItemInjectionObjects[i].LocalForm
				LeveledLists[l].AddForm(LeveledItemInjectionObjects[i].LocalForm, LeveledItemInjectionObjects[i].iFormLevel, LeveledItemInjectionObjects[i].iFormCount)
			endIf
		endIf
		i += 1
	endWhile
	
	i = 0
	while i < FormListInjectionObjects.length
		int p = FormListInjectionObjects[i].iPluginNameIndex
		int l = FormListInjectionObjects[i].iFormListIndex
		if PluginDefinitions[p].bInstalled && FormLists[l] 
			if FormListInjectionObjects[i].iFormId
				Form injectForm = Game.GetFormFromFile(FormListInjectionObjects[i].iFormId, PluginDefinitions[p].sName) as Form
				if injectForm
					FormLists[l].AddForm(injectForm)
				endIf
			endif
			if FormListInjectionObjects[i].LocalForm
				FormLists[l].AddForm(FormListInjectionObjects[i].LocalForm)
			endIf
		endIf
		i += 1
	endWhile
EndFunction

;/
	HOLOTAPE FUNCTIONS
/;
Function ToggleSettings_UseCityPlannerDoorSetting()
	Self.ToggleGlobal(Settings_UseCityPlannerDoorSettingGlobal)
EndFunction

Function ToggleSettings_OpenDoorsInWorkshopMode()
	Self.ToggleGlobal(Settings_OpenDoorsInWorkshopModeGlobal)
EndFunction

Function ToggleSettings_MarInt00_AutomateGearDoor()
	Self.ToggleGlobal(Settings_MarInt00_AutomateGearDoor)
EndFunction

Function ToggleSettings_RecInt01_NoLock()
	Self.ToggleGlobal(Settings_RecInt01_NoLock)
EndFunction

Function ToggleSettings_RecInt01_UseCWSS()
	Self.ToggleGlobal(Settings_RecInt01_UseCWSS)
EndFunction

Function ToggleGlobal(GlobalVariable GlobalVar)
	if GlobalVar.GetValue() != 1.0
		GlobalVar.SetValue(1.0)
	else
		GlobalVar.SetValue(0.0)
	endIf
EndFunction

Function UnlockVaultSuitGlobal(int iVaultNo)
	int i = ChanceNoneByQuestGlobals.FindStruct("iVaultNo", iVaultNo)
	if i > -1
		ChanceNoneByQuestGlobals[i].GlobalToSet.SetValue(ChanceNoneByQuestGlobals[i].fValue)
	endIf
EndFunction

;/
	MESSAGE HANDLING
/;
 

Function InstallModChanges()
	; Make changes here - use format if(InstalledVersion < X.X) do something endif 
		
	; Once complete, flag our version as up to date
	InstalledVersion = CurrentVersion.GetValue()
	InstallVersionMessage.Show(InstalledVersion)
EndFunction

; Utility function to wait for edit lock
; Increase wait time while more threads are in here
; Get an edit lock only for non-time-critical functions.
int iEditLockCount = 1
Function GetEditLock()
	iEditLockCount += 1
	While (bEditLock)
		Utility.Wait(0.1 * iEditLockCount)
	EndWhile
	bEditLock = true
	iEditLockCount -= 1
EndFunction
