Scriptname SS2AOP_VaultTecTools:DynFurnScript extends ObjectReference

Group DynamicFurniture
	StaticSpawnItemsStruct[] Property StaticSpawnItems Auto Const
	DynamicSpawnItemsStruct[] Property DynamicSpawnItems Auto
	Keyword Property kwLinkDynamicItems Auto Const Mandatory
	Keyword Property kwLinkStaticItems Auto Const Mandatory
EndGroup

Struct StaticSpawnItemsStruct
	Form SpawnItem
	float fOffsetX = 0.0
	float fOffsetY = 0.0
	float fOffsetZ = 0.0
	float fRotationX = 0.0
	float fRotationY = 0.0
	float fRotationZ = 0.0
	float fScale = 1.0
EndStruct

Struct DynamicSpawnItemsStruct
	int iMarkerNumber = 0
	Form SpawnItem
	float fOffsetX = 0.0 
	float fOffsetY = 0.0 
	float fOffsetZ = 0.0 
	float fRotationX = 0.0 
	float fRotationY = 0.0 
	float fRotationZ = 0.0
	float fScale = 1.0
	ObjectReference akSpawnedItem = none
	{ DO NOT USE }
EndStruct

bool bCleaning = false
bool bSpawningStaticItems = false
bool bCheckingSpawnsNeeded = false
bool bCheckingSpawnsNeedCleaning = false
bool bWorkshopObjectPlaced = true

Function SpawnDynamicItems(int iMarkerNumber)
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		int i = DynamicSpawnItems.FindStruct("iMarkerNumber", iMarkerNumber)
		Form formToSpawn = none
		int formIndex = -1
		while i > -1
			if DynamicSpawnItems[i].akSpawnedItem == none
				if DynamicSpawnItems[i].SpawnItem as FormList
					if (DynamicSpawnItems[i].SpawnItem as FormList).GetSize() > 0
						formIndex = Utility.RandomInt(0, (DynamicSpawnItems[i].SpawnItem as FormList).GetSize() - 1)
						formToSpawn = (DynamicSpawnItems[i].SpawnItem as FormList).GetAt(formIndex)
					endIf
				else
					formToSpawn = DynamicSpawnItems[i].SpawnItem
				endIf
				if formToSpawn
					DynamicSpawnItems[i].akSpawnedItem = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, formToSpawn, DynamicSpawnItems[i].fOffsetX, DynamicSpawnItems[i].fOffsetY, DynamicSpawnItems[i].fOffsetZ, DynamicSpawnItems[i].fRotationX, DynamicSpawnItems[i].fRotationY, DynamicSpawnItems[i].fRotationZ, DynamicSpawnItems[i].fScale)
					var[] args = new var[1]
					args[0] = true
					DynamicSpawnItems[i].akSpawnedItem.CallFunctionNoWait("Enable", args)
					DynamicSpawnItems[i].akSpawnedItem.SetLinkedRef((Self as ObjectReference), kwLinkDynamicItems)
				endIf
			endIf
			i = DynamicSpawnItems.FindStruct("iMarkerNumber", iMarkerNumber, i+1)
		endWhile
	endIf
EndFunction

Function SpawnStaticItems()
	if IsEnabled() && !IsDeleted() && !IsDestroyed() && !bSpawningStaticItems
		bSpawningStaticItems = true

		int i = 0
		while i < StaticSpawnItems.length
			Form formToSpawn = none
			if StaticSpawnItems[i].SpawnItem as FormList
				if (StaticSpawnItems[i].SpawnItem as FormList).GetSize() > 0
					int formIndex = Utility.RandomInt(0, (StaticSpawnItems[i].SpawnItem as FormList).GetSize() - 1)
					formToSpawn = (StaticSpawnItems[i].SpawnItem as FormList).GetAt(formIndex)
				endIf
			else
				formToSpawn = StaticSpawnItems[i].SpawnItem
			endIf
			if formToSpawn
				ObjectReference akNewSpawnItem = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, formToSpawn, StaticSpawnItems[i].fOffsetX, StaticSpawnItems[i].fOffsetY, StaticSpawnItems[i].fOffsetZ, StaticSpawnItems[i].fRotationX, StaticSpawnItems[i].fRotationY, StaticSpawnItems[i].fRotationZ, StaticSpawnItems[i].fScale)
				var[] args = new var[1]
				args[0] = true
				akNewSpawnItem.CallFunctionNoWait("Enable", args)
				akNewSpawnItem.SetLinkedRef((Self as ObjectReference), kwLinkStaticItems)
			endIf
			i += 1
		endWhile

		bSpawningStaticItems = false
	endIf
EndFunction

Function RemoveDynamicSpawns(int iMarkerNumber)
	int i = DynamicSpawnItems.FindStruct("iMarkerNumber", iMarkerNumber)
	while i > -1
		DynamicSpawnItems[i].akSpawnedItem.Disable(false)
		DynamicSpawnItems[i].akSpawnedItem.Delete()
		DynamicSpawnItems[i].akSpawnedItem = none
		i = DynamicSpawnItems.FindStruct("iMarkerNumber", iMarkerNumber, i + 1)
	endWhile
EndFunction

Function Cleanup()
	if !bCleaning
		bCleaning = true

		int i = 0
		while i < DynamicSpawnItems.length
			DynamicSpawnItems[i].akSpawnedItem.Disable(false)
			DynamicSpawnItems[i].akSpawnedItem.Delete()
			DynamicSpawnItems[i].akSpawnedItem = none
			i += 1
		endWhile

		ObjectReference[] spawns = GetLinkedRefChildren(kwLinkStaticItems)
		i = 0
		while i < spawns.length
			spawns[i].Disable(false)
			spawns[i].Delete()
			i += 1
		endWhile

		bCleaning = false
	endIf
EndFunction

Function CheckIfNeedsDynamicSpawns()
	if !bCheckingSpawnsNeeded
		bCheckingSpawnsNeeded = true

		int i = 0
		while i < DynamicSpawnItems.length
			if IsFurnitureMarkerInUse(DynamicSpawnItems[i].iMarkerNumber, true)
				SpawnDynamicItems(DynamicSpawnItems[i].iMarkerNumber)
			endIf
			i += 1
		endWhile
		bCheckingSpawnsNeeded = false
	endIf
EndFunction

Function CheckIfNeedsDynamicSpawnsCleaned()
	if !bCheckingSpawnsNeedCleaning
		bCheckingSpawnsNeedCleaning = true

		int i = 0
		while i < DynamicSpawnItems.length 
			var[] args = new var[1]
			args[0] = DynamicSpawnItems[i].iMarkerNumber
			CallFunctionNoWait("CheckMarker", args)
			i += 1
		endWhile

		bCheckingSpawnsNeedCleaning = false
	endIf
EndFunction

Function CheckMarker(int iMarker)
	int retry = 0
	bool bDynamic = true
	while bDynamic && retry < 15
		Utility.Wait(1)
		bDynamic = IsFurnitureMarkerInUse(iMarker, true)
		if !bDynamic
			RemoveDynamicSpawns(iMarker)
		endIf
		retry += 1
	endWhile
EndFunction

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	CallFunctionNoWait("SpawnStaticItems", none)
EndFunction

Event OnActivate(ObjectReference akActionRef)
	CheckIfNeedsDynamicSpawns()
EndEvent

; Furniture remains marked as in-use until exit animation finishes, so this will retry up to 15 seconds to remove the food
Event OnExitFurniture(ObjectReference akReference)
	CallFunctionNoWait("CheckIfNeedsDynamicSpawnsCleaned", none)
EndEvent

Event OnLoad()
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		if !bWorkshopObjectPlaced
			CheckIfNeedsDynamicSpawns()
		endIf
		bWorkshopObjectPlaced = false
		CallFunctionNoWait("CheckIfNeedsDynamicSpawnsCleaned", none)
	endIf
EndEvent

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	SpawnStaticItems()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	Cleanup()
	SpawnStaticItems()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	Cleanup()
EndEvent

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	Cleanup()
EndEvent

Function Disable(bool abFade = false)
	Cleanup()
	Parent.Disable(abFade)
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction