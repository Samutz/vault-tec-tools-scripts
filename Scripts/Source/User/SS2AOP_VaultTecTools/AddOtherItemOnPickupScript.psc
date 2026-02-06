Scriptname SS2AOP_VaultTecTools:AddOtherItemOnPickupScript extends ObjectReference
{mainly to add holotape on featured item pickup because holotape cannot be tagged directly as a featured item}

Form Property ItemToAdd Auto Const Mandatory

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
    if akNewContainer == Game.GetPlayer()
        Game.GetPlayer().AddItem(ItemToAdd)
    endif
EndEvent