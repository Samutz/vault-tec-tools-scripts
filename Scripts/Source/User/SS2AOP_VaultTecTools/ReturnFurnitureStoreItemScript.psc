ScriptName SS2AOP_VaultTecTools:ReturnFurnitureStoreItemScript Extends ObjectReference

MiscObject Property FurnStoreItemMiscItem Auto Const Mandatory

Event OnWorkshopObjectDestroyed(ObjectReference akActionRef)
    Actor PlayerRef = Game.GetPlayer()
    WorkshopScript kCurrentWorkshop = akActionRef as WorkshopScript
    ;Debug.Trace("[SS2AOP_VaultTecTools:ReturnFurnitureStoreItemScript]")
    ;Debug.Trace("  kCurrentWorkshop: "+kCurrentWorkshop)
    ;Debug.Trace("  kCurrentWorkshop.OwnedByPlayer: "+kCurrentWorkshop.OwnedByPlayer)
    ;Debug.Trace("  PlayerRef.IsWithinBuildableArea(kCurrentWorkshop): "+PlayerRef.IsWithinBuildableArea(kCurrentWorkshop))
    ;Debug.Trace("  kCurrentWorkshop.UFO4P_InWorkshopMode: "+kCurrentWorkshop.UFO4P_InWorkshopMode)
    ; give to player if they are present and in workshop mode, otherwise give to workshop inventory
    if kCurrentWorkshop.OwnedByPlayer && PlayerRef.IsWithinBuildableArea(kCurrentWorkshop) && kCurrentWorkshop.UFO4P_InWorkshopMode
        ;Debug.Trace("  returned to player: true")
        PlayerRef.AddItem(FurnStoreItemMiscItem, 1, false)
    else
        ;Debug.Trace("  returned to player: false")
        kCurrentWorkshop.AddItem(FurnStoreItemMiscItem, 1, true)
    endif
EndEvent