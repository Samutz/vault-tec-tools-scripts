;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname SV88:Fragments:Terminals:RecInt01_ConfigTerminal Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SV88:RecInt01_TerminalScript).AddStall(0)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SV88:RecInt01_TerminalScript).RemoveStall()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SV88:RecInt01_TerminalScript).AddStall(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
(akTerminalRef as SV88:RecInt01_TerminalScript).RemoveAllStalls()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
