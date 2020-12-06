;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname SS2AOP_VaultTecTools:Fragments:Terminals:Settings_SubMenu_ExpRestroom Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
ManagementQuest.ToggleSettings_RecInt01_NoLock()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
ManagementQuest.ToggleSettings_RecInt01_NoLock()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
ManagementQuest.ToggleSettings_RecInt01_UseCWSS()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
ManagementQuest.ToggleSettings_RecInt01_UseCWSS()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SS2AOP_VaultTecTools:ManagementQuestScript Property ManagementQuest Auto Const Mandatory
