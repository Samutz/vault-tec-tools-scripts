Scriptname SS2AOP_VaultTecTools:DynFurnScript extends ObjectReference

Group CenterPiece
	FormList Property flCenterPieces Auto Const
	float Property fCenterPieceOffsetX = 0.0 Auto Const
	float Property fCenterPieceOffsetY = 0.0  Auto Const
	float Property fCenterPieceOffsetZ = 0.0  Auto Const
	float Property fCenterPieceRotationX = 0.0  Auto Const
	float Property fCenterPieceRotationY = 0.0  Auto Const
	float Property fCenterPieceRotationZ = 0.0  Auto Const
	float Property fCenterPieceScale = 1.0  Auto Const
EndGroup

propFoodSpawnStruct[] Property FoodSpawnStructs Auto Const
Keyword Property kwLinkParent Auto Const Mandatory
Static Property NavcutStatic Auto Const

Struct propFoodSpawnStruct
	int iMarkerNumber = 0
	float fOffsetX = 0.0 
	float fOffsetY = 0.0 
	float fOffsetZ = 0.0 
	float fRotationX = 0.0 
	float fRotationY = 0.0 
	float fRotationZ = 0.0
	float fScale = 1.0
	FormList flFoodToSpawn
EndStruct

Struct refFoodSpawnStruct
	int iMarkerNumber
	ObjectReference refFoodSpawn
EndStruct

refFoodSpawnStruct[] FoodSpawnRefs = none
ObjectReference CenterPieceRef = none
ObjectReference navcutRef = none

Function SpawnFood(int iMarkerNumber)
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		int i = FoodSpawnStructs.FindStruct("iMarkerNumber", iMarkerNumber)
		if i > -1 && FoodSpawnStructs[i].flFoodToSpawn.GetSize() > 0
			int j = FoodSpawnRefs.FindStruct("iMarkerNumber", iMarkerNumber)
			if j > -1 && (!(FoodSpawnRefs[j].refFoodSpawn as bool) || ((FoodSpawnRefs[j].refFoodSpawn as bool) && FoodSpawnRefs[j].refFoodSpawn.IsDisabled()))
				int formIndex = Utility.RandomInt(0, FoodSpawnStructs[i].flFoodToSpawn.GetSize() - 1)
				Form formToSpawn = FoodSpawnStructs[i].flFoodToSpawn.GetAt(formIndex)
				FoodSpawnRefs[j].refFoodSpawn = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, formToSpawn, FoodSpawnStructs[i].fOffsetX, FoodSpawnStructs[i].fOffsetY, FoodSpawnStructs[i].fOffsetZ, FoodSpawnStructs[i].fRotationX, FoodSpawnStructs[i].fRotationY, FoodSpawnStructs[i].fRotationZ, FoodSpawnStructs[i].fScale)
				FoodSpawnRefs[j].iMarkerNumber = iMarkerNumber
				FoodSpawnRefs[j].refFoodSpawn.Enable(true)
				FoodSpawnRefs[j].refFoodSpawn.SetLinkedRef((Self as ObjectReference), kwLinkParent)
			endIf
		endIf
	endIf
EndFunction

Function SpawnCenterPiece()
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		if flCenterPieces && flCenterPieces.GetSize() > 0 && !(CenterPieceRef as bool) 
			int formIndex = Utility.RandomInt(0, flCenterPieces.GetSize() - 1)
			Form formToSpawn = flCenterPieces.GetAt(formIndex)
			CenterPieceRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, formToSpawn, fCenterPieceOffsetX, fCenterPieceOffsetY, fCenterPieceOffsetZ, fCenterPieceRotationX, fCenterPieceRotationY, fCenterPieceRotationZ, fCenterPieceScale)
			CenterPieceRef.Enable(false)
			CenterPieceRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
		endIf
		; initalize food spawns array
		if FoodSpawnRefs.length == 0
			FoodSpawnRefs = new refFoodSpawnStruct[0]
			int i = 0
			while i < FoodSpawnStructs.length
				refFoodSpawnStruct newSpawnStruct = new refFoodSpawnStruct
				newSpawnStruct.iMarkerNumber = FoodSpawnStructs[i].iMarkerNumber
				newSpawnStruct.refFoodSpawn = none
				FoodSpawnRefs.Add(newSpawnStruct)
				i += 1
			endWhile
		endIf
	endIf
EndFunction

Function RemoveFoodSpawn(int iMarkerNumber)
	int j = FoodSpawnRefs.FindStruct("iMarkerNumber", iMarkerNumber)
	if j > -1
		if (FoodSpawnRefs[j].refFoodSpawn as bool)
			FoodSpawnRefs[j].refFoodSpawn.Disable(true)
			FoodSpawnRefs[j].refFoodSpawn.Delete()
			FoodSpawnRefs[j].refFoodSpawn = none
		endIf
	endIf
EndFunction

Function Cleanup(bool bCleanCenterPiece, bool bCleanFood, bool bCleanNavcut)
	if (CenterPieceRef as bool) && bCleanCenterPiece
		CenterPieceRef.SetLinkedRef(none, none)
		CenterPieceRef.Disable(false)
		CenterPieceRef.Delete()
		CenterPieceRef = none
	endIf
	if (FoodSpawnRefs as bool) && bCleanFood
		int i = 0
		while i < FoodSpawnRefs.length
			if (FoodSpawnRefs[i].refFoodSpawn as bool)
				FoodSpawnRefs[i].refFoodSpawn.SetLinkedRef(none, none)
				FoodSpawnRefs[i].refFoodSpawn.Disable(false)
				FoodSpawnRefs[i].refFoodSpawn.Delete()
				FoodSpawnRefs[i].refFoodSpawn = none
			endIf
			i += 1
		endWhile
		FoodSpawnRefs.Clear()
	endIf
	if (navcutRef as bool) && bCleanNavcut
		navcutRef.SetLinkedRef(none, none)
		navcutRef.Disable(false)
		navcutRef.Delete()
		navcutRef = none
	endIf
	if bCleanCenterPiece && bCleanFood && bCleanNavcut
		SS2AOP_VaultTecTools:SamutzLibrary.CleanUpChildSpawns((Self as ObjectReference), kwLinkParent)
	endIf
EndFunction

Function CheckIfNeedsFood()
	int i = 0
	int j = 0
	while i < FoodSpawnStructs.length
		j = FoodSpawnRefs.FindStruct("iMarkerNumber", FoodSpawnStructs[i].iMarkerNumber)
		if IsFurnitureMarkerInUse(FoodSpawnStructs[i].iMarkerNumber, true) && !(FoodSpawnRefs[j].refFoodSpawn as bool)
			SpawnFood(FoodSpawnStructs[i].iMarkerNumber)
		endIf
		i += 1
	endWhile
EndFunction

Function CheckIfNeedsFoodCleaned()
	int i = 0
	while i < FoodSpawnStructs.length 
		int retry = 0
		bool bInUse = true
		while bInUse && retry < 15
			Utility.Wait(1)
			bInUse = IsFurnitureMarkerInUse(FoodSpawnStructs[i].iMarkerNumber, true)
			if !bInUse
				RemoveFoodSpawn(FoodSpawnStructs[i].iMarkerNumber)
			endIf
			retry += 1
		endWhile
		i += 1
	endWhile
EndFunction

Function SpawnNavcut()
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		if !(navcutRef as bool) && (NavcutStatic as bool)
			navcutRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, NavcutStatic)
			navcutRef.Enable(false)
			navcutRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
		endIf
	endIf
EndFunction

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	SpawnCenterPiece()
	SpawnNavcut()
EndFunction

Event OnActivate(ObjectReference akActionRef)
	CheckIfNeedsFood()
EndEvent

; Furniture remains marked as in-use until exit animation finishes, so this will retry up to 15 seconds to remove the food
Event OnExitFurniture(ObjectReference akReference)
	CallFunctionNoWait("CheckIfNeedsFoodCleaned", new var[0])
EndEvent

Event OnLoad()
	if IsEnabled() && !IsDeleted() && !IsDestroyed()
		CheckIfNeedsFood()
		CallFunctionNoWait("CheckIfNeedsFoodCleaned", new var[0])
	endIf
EndEvent

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	Cleanup(true, true, true)
	SpawnCenterPiece()
	SpawnNavcut()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	Cleanup(true, true, true)
	SpawnCenterPiece()
	SpawnNavcut()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	Cleanup(true, true, true)
EndEvent

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	Cleanup(true, true, true)
EndEvent

Function Delete()
	Cleanup(true, true, true)
	Parent.Delete()
EndFunction

