;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname SS2AOP_VaultTecTools:Fragments:Terminals:Settings_SubMenu_SummonSettlers Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
if SummonManager.IsRunning()
    SummonManager.Stop()
endIf
SummonManager.Start()
SummonManager.StartListener(0, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
if SummonManager.IsRunning()
    SummonManager.Stop()
endIf
SummonManager.Start()
SummonManager.StartListener(1, akTerminalRef)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

SS2AOP_VaultTecTools:SummonManagerQuestScript Property SummonManager Auto Const Mandatory
