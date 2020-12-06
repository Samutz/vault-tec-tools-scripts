;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname SS2AOP_VaultTecTools:Fragments:Terminals:RecInt00_DeskTerminal Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SS2AOP_VaultTecTools:RecInt00_TerminalScript).AddDeskRow()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SS2AOP_VaultTecTools:RecInt00_TerminalScript).RemoveDeskRow()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SS2AOP_VaultTecTools:RecInt00_TerminalScript).AddMultipleRows(3)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SS2AOP_VaultTecTools:RecInt00_TerminalScript).RemoveAllDesks()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
