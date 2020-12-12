Scriptname SS2AOP_VaultTecTools:RecInt01_StallScript extends ObjectReference

LevelSpawnItemStruct[] Property LevelSpawnItems Auto
Keyword Property kwLinkParent Auto Const Mandatory

Group Sounds
	Sound Property FurnitureInUseSound Auto Const
	{Should be looping sound}
	Sound Property FurnitureExitSound Auto Const
EndGroup

Group GlobalVariable
	GlobalVariable Property PluginInstalled_CWSS Auto Const
	GlobalVariable Property Settings_RecInt01_NoLock Auto Const
	GlobalVariable Property Settings_RecInt01_UseCWSS Auto Const
EndGroup

Struct LevelSpawnItemStruct
	int iType = 0
	{0 = clutter, 1 = furniture, 2 = door}
	Form FormToSpawn = none
	int iCWSSForm = 0
	float fOffsetX = 0.0 
	float fOffsetY = 0.0 
	float fOffsetZ = 0.0 
	float fRotationX = 0.0 
	float fRotationY = 0.0 
	float fRotationZ = 0.0
	float fScale = 1.0
EndStruct

ObjectReference[] LevelSpawnRefs = none

ObjectReference StallFurniture = none
ObjectReference StallDoor = none
bool bIsCWSS = false

int iFurnitureInUseSound = 0
int iFurnitureExitSound = 0

Function Enable(bool abFade = false)
	Parent.Enable(abFade)
	
	if !LevelSpawnRefs
		LevelSpawnRefs = new ObjectReference[0]
	EndIf
	
	SpawnLevelItems()
	
	if (StallFurniture as bool)
		RegisterForRemoteEvent(StallFurniture, "OnActivate")
		RegisterForRemoteEvent(StallFurniture, "OnExitFurniture")
	endIf
	
	if (StallDoor as bool)
		StallDoor.SetOpen(true)
	endIf
EndFunction

Function SpawnLevelItems()
	int i = 0
	while i < LevelSpawnItems.length
		Form formToSpawn = LevelSpawnItems[i].FormToSpawn
		; CWSS
		if LevelSpawnItems[i].iCWSSForm > 0 && PluginInstalled_CWSS.GetValue() == 1.0 && Settings_RecInt01_UseCWSS.GetValue() == 1.0
			formToSpawn = Game.GetFormFromFile(LevelSpawnItems[i].iCWSSForm, "CWSS Redux.esp")
			if formToSpawn
				bIsCWSS = true
				LevelSpawnItems[i].fOffsetZ = 0
			else
				formToSpawn = LevelSpawnItems[i].FormToSpawn
			endIf
		endIf
		
		if !bIsCWSS || (bIsCWSS && LevelSpawnItems[i].iType != 3)
			ObjectReference spawnRef = SS2AOP_VaultTecTools:SamutzLibrary.PlaceRelativeToMe(Self, formToSpawn, LevelSpawnItems[i].fOffsetX, LevelSpawnItems[i].fOffsetY, LevelSpawnItems[i].fOffsetZ, LevelSpawnItems[i].fRotationX, LevelSpawnItems[i].fRotationY, LevelSpawnItems[i].fRotationZ, LevelSpawnItems[i].fScale)
			LevelSpawnRefs.Add(spawnRef)
			spawnRef.SetLinkedRef((Self as ObjectReference), kwLinkParent)
			
			if LevelSpawnItems[i].iType == 1
				StallFurniture = spawnRef
			elseif LevelSpawnItems[i].iType == 2
				StallDoor = spawnRef
			endIf
			
			spawnRef.Enable(false)
			
			if LevelSpawnItems[i].iCWSSForm > 0
				StallFurniture.OnWorkshopObjectPlaced(StallFurniture)
			endIf
		endIf
		
		i += 1
	endWhile
EndFunction

Event ObjectReference.OnActivate(ObjectReference akSender, ObjectReference akActionRef)
	if akSender == StallFurniture && StallFurniture.IsFurnitureInUse(true)
		CallFunctionNoWait("PlayOnActivateSound", new var[0])
		if StallDoor
			StallDoor.SetOpen(false)
			if Settings_RecInt01_NoLock.GetValue() != 1.0
				StallDoor.SetLockLevel(251)
				StallDoor.Lock(true)
			endIf
		endIf
	endIf
EndEvent

Event ObjectReference.OnExitFurniture(ObjectReference akSender, ObjectReference akActionRef)
	if akSender == StallFurniture
		CallFunctionNoWait("PlayOnExitFurnitureSound", new var[0])
		if StallDoor
			StallDoor.SetOpen(true)
			StallDoor.SetLockLevel(0)
			StallDoor.Lock(false)
		endIf
	endIf
EndEvent

Event OnLoad()
	StartTimer(3.0)
EndEvent

Event OnTimer(Int aiTimerID)
	if StallFurniture
		if StallFurniture.IsFurnitureInUse(true)
			CallFunctionNoWait("PlayOnActivateSound", new var[0])
			if StallDoor
				StallDoor.SetOpen(false)
				if Settings_RecInt01_NoLock.GetValue() != 1.0
					StallDoor.SetLockLevel(251)
					StallDoor.Lock(true)
				endIf
			endIf
		else
			ClearFurnInUse()
		endIf
	endIf
EndEvent

Event OnUnload()
	ClearFurnInUse()
EndEvent

Function PlayOnActivateSound()
	if !bIsCWSS
		Utility.Wait(3)
		if !iFurnitureInUseSound && FurnitureInUseSound
			iFurnitureInUseSound = FurnitureInUseSound.Play(StallFurniture)
			float i = 0.0
			while i < 1 && iFurnitureInUseSound
				Sound.SetInstanceVolume(iFurnitureInUseSound, i)
				i += 0.1
				Utility.Wait(0.1)
			endWhile
		endIf
	endIf
EndFunction

Function PlayOnExitFurnitureSound()
	if !bIsCWSS
		if iFurnitureInUseSound
			float i = 1.0
			while i > 0 && iFurnitureInUseSound
				Sound.SetInstanceVolume(iFurnitureInUseSound, i)
				i -= 0.1
				Utility.Wait(0.1)
			endWhile
			Sound.StopInstance(iFurnitureInUseSound)
			iFurnitureInUseSound = 0
		endIf
		if FurnitureExitSound
			iFurnitureExitSound = FurnitureExitSound.Play(StallFurniture)
			float i = 0.0
			while i < 1 && iFurnitureExitSound
				Sound.SetInstanceVolume(iFurnitureExitSound, i)
				i += 0.1
				Utility.Wait(0.1)
			endWhile
			Utility.Wait(3)
			while i > 0 && iFurnitureExitSound
				Sound.SetInstanceVolume(iFurnitureExitSound, i)
				i -= 0.1
				Utility.Wait(0.1)
			endWhile
			Sound.StopInstance(iFurnitureExitSound) 
			iFurnitureExitSound = 0
		endIf
	endIf
EndFunction

Function ClearFurnInUse()
	if iFurnitureInUseSound
		Sound.StopInstance(iFurnitureInUseSound)
		iFurnitureInUseSound = 0
	endIf
	if iFurnitureExitSound
		Sound.StopInstance(iFurnitureExitSound)
		iFurnitureInUseSound = 0
	endIf
	if StallDoor
		StallDoor.SetOpen(true)
		StallDoor.SetLockLevel(0)
		StallDoor.Lock(false)
	endIf
EndFunction

Function Cleanup()
	if bIsCWSS
		StallFurniture.OnWorkshopObjectDestroyed(StallFurniture)
	endIf
	int i = 0
	while i < LevelSpawnRefs.length
		LevelSpawnRefs[i].Disable(false)
		LevelSpawnRefs[i].Delete()
		LevelSpawnRefs[i] = none
		i += 1
	endWhile
	LevelSpawnRefs.Clear()
	StallFurniture = none
	StallDoor = none
	bIsCWSS = false
	UnregisterForAllRemoteEvents()
	if iFurnitureInUseSound
		Sound.StopInstance(iFurnitureInUseSound)
		iFurnitureInUseSound = 0
	endIf
	if iFurnitureExitSound
		Sound.StopInstance(iFurnitureExitSound)
		iFurnitureInUseSound = 0
	endIf
	SS2AOP_VaultTecTools:SamutzLibrary.CleanUpChildSpawns((Self as ObjectReference), kwLinkParent)
EndFunction

Function Delete()
	Cleanup()
	Parent.Delete()
EndFunction 