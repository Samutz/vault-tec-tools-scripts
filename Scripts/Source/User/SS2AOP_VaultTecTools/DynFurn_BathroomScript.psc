Scriptname SS2AOP_VaultTecTools:DynFurn_BathroomScript extends ObjectReference

Import SS2AOP_VaultTecTools:SamutzLibrary

LevelSpawnItemStruct[] Property LevelSpawnItems Auto
Keyword Property kwLinkParent Auto Const Mandatory

Struct LevelSpawnItemStruct
	Form FormToSpawn = none
	float fOffsetX = 0.0 
	float fOffsetY = 0.0 
	float fOffsetZ = 0.0 
	float fRotationX = 0.0 
	float fRotationY = 0.0 
	float fRotationZ = 0.0
	float fScale = 1.0
EndStruct

ObjectReference[] FormListSpawnRefs = none
ObjectReference[] MiscSpawnRefs = none

Function Constructed()
	if !FormListSpawnRefs
		FormListSpawnRefs = new ObjectReference[0]
	EndIf
	
	if !MiscSpawnRefs
		MiscSpawnRefs = new ObjectReference[0]
	EndIf
	
	Self.SpawnLevelItems()
	Self.RefreshFormListSpawns()
EndFunction

Function SpawnLevelItems()
	int i = 0
	while i < LevelSpawnItems.length
		if !(LevelSpawnItems[i].FormToSpawn as FormList)
			ObjectReference spawnRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, LevelSpawnItems[i].FormToSpawn, LevelSpawnItems[i].fOffsetX, LevelSpawnItems[i].fOffsetY, LevelSpawnItems[i].fOffsetZ, LevelSpawnItems[i].fRotationX, LevelSpawnItems[i].fRotationY, LevelSpawnItems[i].fRotationZ, LevelSpawnItems[i].fScale)
			MiscSpawnRefs.Add(spawnRef)
			spawnRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
			spawnRef.Enable(false)
		endIf
		i += 1
	endWhile
EndFunction

Function RefreshFormListSpawns()
	;debug.notification("RefreshFormListSpawns"+Utility.RandomInt(1000, 9999))
	int i = 0
	if FormListSpawnRefs.length > 0
		while i < FormListSpawnRefs.length
			FormListSpawnRefs[i].Disable(false)
			FormListSpawnRefs[i].Delete()
			i += 1
		endWhile
		FormListSpawnRefs.Clear()
	endIf
	i = 0
	while i < LevelSpawnItems.length
		if (LevelSpawnItems[i].FormToSpawn as FormList)
			if (LevelSpawnItems[i].FormToSpawn as FormList).GetSize() > 0
				int formIndex = Utility.RandomInt(0, (LevelSpawnItems[i].FormToSpawn as FormList).GetSize() - 1)
				Form FormToSpawn = (LevelSpawnItems[i].FormToSpawn as FormList).GetAt(formIndex) as Form
				ObjectReference spawnRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, FormToSpawn, LevelSpawnItems[i].fOffsetX, LevelSpawnItems[i].fOffsetY, LevelSpawnItems[i].fOffsetZ, LevelSpawnItems[i].fRotationX, LevelSpawnItems[i].fRotationY, LevelSpawnItems[i].fRotationZ, LevelSpawnItems[i].fScale)
				FormListSpawnRefs.Add(spawnRef)
				spawnRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
				spawnRef.Enable(false)
			endIf
		endIf
		i += 1
	endWhile
EndFunction

Function CleanUp()
	if FormListSpawnRefs.length > 0
		int i = 0
		while i < FormListSpawnRefs.length
			FormListSpawnRefs[i].Disable(false)
			FormListSpawnRefs[i].Delete()
			i += 1
		endWhile
		FormListSpawnRefs.Clear()
	endIf
	if MiscSpawnRefs.length > 0
		int i = 0
		while i < MiscSpawnRefs.length
			MiscSpawnRefs[i].Disable(false)
			MiscSpawnRefs[i].Delete()
			i += 1
		endWhile
		MiscSpawnRefs.Clear()
	endIf
	SS2AOP_VaultTecTools:SamutzLibrary.CleanUpChildSpawns((Self as ObjectReference), kwLinkParent)
EndFunction

Event OnWorkshopObjectPlaced(ObjectReference akReference)
	;debug.notification("placed")
	Self.Constructed()
EndEvent

Event OnWorkshopObjectMoved(ObjectReference akReference)
	;debug.notification("moved")
	Self.Constructed()
EndEvent

Event OnWorkshopObjectDestroyed(ObjectReference akReference)
	Self.Cleanup()
EndEvent

Event OnWorkshopObjectGrabbed(ObjectReference akReference)
	Self.Cleanup()
EndEvent

Event OnCellLoad()
	if Self.IsEnabled() && !Self.IsDeleted() && !Self.IsDestroyed()
		Self.RefreshFormListSpawns()
	endIf
EndEvent

Function Delete()
	Self.Cleanup()
	Parent.Delete()
EndFunction
