Scriptname SS2AOP_VaultTecTools:AnimatedObjectSpawner extends ObjectReference

import WorkshopFramework:Library:ThirdParty:Cobb:CobbLibraryRotations
import SimSettlementsV2:UtilityFunctions

Struct TransitionPhase
	Float fOffsetX = 0.0
	Float fOffsetY = 0.0
	Float fOffsetZ = 0.0
	Float fAngleOffsetX = 0.0
	Float fAngleOffsetY = 0.0
	Float fAngleOffsetZ = 0.0
	Float fSpeed = 0.0
	Float fHavokPause = 0.0
	{ Seconds to allow havok to take over temporarily }
	Bool bDoNotRotate = false
	{ If set to true, the objects rotation at this phase will be maintained }
EndStruct

Struct InTransitionObject
	ObjectReference kObjectRef
	Int iPhase
EndStruct

Float Property fInitialMovementDelay = 0.0 Auto Const
{ Seconds to delay before starting the initial movement }
Form Property ObjectToAnimate Auto Const
{ Form to create and animate along transition phases, if a FormList, one will be picked at random }
Int Property iTotalObjects = -1 Auto Const
{ The number of objects to create before stopping, -1 = continue creating objects forever }
Float Property fPauseBetweenObjects = 1.0 Auto Const
{ Time to wait between spawning objects }
Bool Property bWaitUntilTransitionCompletes = false Auto Const
{ If set to true, a new object will not be created until the previous one finishes all transition phases }
Int Property iEndPositionObjectCount = 3 Auto Const
{ Total number of objects to allow to reach the final transition before deleting the first one. }
TransitionPhase[] Property Phases Auto Const
{ The first entry will be the starting position, the object(s) will then be animated from position to position. Objects must have moveable collision to animate correctly. }
Bool Property bPlotSpawned = true Auto Const
{ If used as part of a stage item spawn, set this to true to assume phase coordinates are from the center of a plot }


Keyword LinkedStageItemKeyword


; Hard limits to prevent object count from getting out of hand
Int iObjectHardCap = 100 
Float fMinPause = 0.25


InTransitionObject[] InTransitionObjects
ObjectReference[] TransistionedObjects

Int iSpawnedObjects = 0
Bool bFirstLoad = true


Int SpawnObjectTimerID = 0

Float[] SpawnerPosition
Float[] SpawnerRotation
Float[] PlotOffsets

SimSettlementsV2:ObjectReferences:SimPlot kPlotRef

State Paused
	Function SpawnObject()
	EndFunction
	
	Function AdvancePhase(ObjectReference akMoveMe, Int iPhase)
	EndFunction
	
	Event OnTimer(Int aiTimerID)
	EndEvent
EndState

Event OnInit()
	InTransitionObjects = new InTransitionObject[0]
	TransistionedObjects = new ObjectReference[0]
	
	LinkedStageItemKeyword = Game.GetFormFromFile(0x000149FE, GetPluginName()) as Keyword
EndEvent

Event OnLoad()
	; Clean up any objects in the vicinity - the game engine will sometimes fail to do so and the player can be left with a mess.
	ObjectReference[] spawns = Self.FindAllReferencesOfType(ObjectToAnimate, 384.0)
	
	if(spawns.Length)
		int i = 0
		
		while(i < spawns.Length)
			spawns[i].Disable()
			spawns[i].Delete()
			
			i += 1
		endWhile
		
		spawns = None
	endif
	
	if(isDeleted())
		return
	endif
	
	Bool bInitialWaitComplete = false
	InTransitionObjects = new InTransitionObject[0]
	TransistionedObjects = new ObjectReference[0]
	
	if(bPlotSpawned)
		if( ! kPlotRef)
			Utility.Wait(2.0)
			bInitialWaitComplete = true ; No need to pause again during bFirstLoad setup
			kPlotRef = GetLinkedPlot(Self, LinkedStageItemKeyword)
		endif
		
		if(kPlotRef)
			PlotOffsets = kPlotRef.GetCurrentLevelPlan().PositionOffsets
		endif
	endif
	
	if(bFirstLoad)
		bFirstLoad = false
		ObjectReference placeholder
		SpawnerPosition = new Float[3]
		SpawnerRotation = new Float[3]
				
		if(bPlotSpawned)
			if( ! bInitialWaitComplete)
				Utility.Wait(2.0) 
			endif
			
			SpawnerPosition[0] = kPlotRef.X
			SpawnerPosition[1] = kPlotRef.Y
			SpawnerPosition[2] = kPlotRef.Z
			
			SpawnerRotation[0] = kPlotRef.GetAngleX()
			SpawnerRotation[1] = kPlotRef.GetAngleY()
			SpawnerRotation[2] = kPlotRef.GetAngleZ()	
		else
			SpawnerPosition[0] = Self.X
			SpawnerPosition[1] = Self.Y
			SpawnerPosition[2] = Self.Z
			
			SpawnerRotation[0] = Self.GetAngleX()
			SpawnerRotation[1] = Self.GetAngleY()
			SpawnerRotation[2] = Self.GetAngleZ()	
		endif				
	endif
	
	StartTimer(0.0, SpawnObjectTimerID)
EndEvent

Event OnUnload()
	Cleanup()
EndEvent

Event OnTimer(Int aiTimerID)
	if(aiTimerID == SpawnObjectTimerID)
		SpawnObject()
		if( ! bWaitUntilTransitionCompletes && iTotalObjects == -1 || iSpawnedObjects < iTotalObjects)
			; Prep another spawn
			Float fPause = fPauseBetweenObjects
			if(fPause < fMinPause)
				fPause = fMinPause
			endif
			
			StartTimer(fPause, SpawnObjectTimerID)
		endif
	endif
EndEvent

Event ObjectReference.OnTranslationAlmostComplete(ObjectReference akTranslatedRef)
	; Find translated ref in InTransitionObjects
	Int index = InTransitionObjects.FindStruct("kObjectRef", akTranslatedRef)
	
	if(index < 0)
		; Object missing from our stucture - just unregister for the event and return as we have no data to process further
		UnregisterForRemoteEvent(akTranslatedRef, "OnTranslationAlmostComplete")
		return
	endif
	
	InTransitionObject thisObject = InTransitionObjects[index]
	
	; If phase < phases.length, start next transition
	if(thisObject.iPhase < Phases.Length-1)
		if(Phases[thisObject.iPhase].fHavokPause > 0)
			akTranslatedRef.SetMotionType(Motion_Dynamic)
			Utility.Wait(Phases[thisObject.iPhase].fHavokPause)
			akTranslatedRef.SetMotionType(Motion_Keyframed, true)
		endif
		
		AdvancePhase(thisObject.kObjectRef, thisObject.iPhase + 1)
	else
		akTranslatedRef.SetMotionType(Motion_Dynamic)
		InTransitionObjects.Remove(index)
		UnregisterForRemoteEvent(akTranslatedRef, "OnTranslationAlmostComplete")
		TransistionedObjects.Add(akTranslatedRef)
		
		if(TransistionedObjects.Length > iEndPositionObjectCount || TransistionedObjects.Length > iObjectHardCap)
			; Remove oldest entry
			TransistionedObjects[0].Disable()
			TransistionedObjects[0].Delete()
			TransistionedObjects.Remove(0)
		endif
		
		if(bWaitUntilTransitionCompletes)
			StartTimer(0.0, SpawnObjectTimerID)
		endif
	endif
EndEvent

Event ObjectReference.OnContainerChanged(ObjectReference akItemRef, ObjectReference akNewContainer, ObjectReference akOldContainer)
	; Object was looted or moved to a container, remove from arrays
	Int index = InTransitionObjects.FindStruct("kObjectRef", akItemRef)
	if(index > -1)
		InTransitionObjects.Remove(index)
	endif
	
	index = TransistionedObjects.Find(akItemRef)
	if(index > -1)
		TransistionedObjects.Remove(index)
	endif
	
	UnregisterForRemoteEvent(akItemRef, "OnContainerChanged")
EndEvent


Event ObjectReference.OnLoad(ObjectReference akLoadedRef)
	akLoadedRef.SetMotionType(Motion_Keyframed, true)
	UnregisterForRemoteEvent(akLoadedRef, "OnLoad")
EndEvent


Form Function GetObjectForm()
	Form spawnMe = ObjectToAnimate
	FormList asFormList = ObjectToAnimate as FormList
	
	if(asFormList)
		spawnMe = asFormList.GetAt(Utility.RandomInt(0, asFormList.GetSize() - 1))
	endif
	
	return spawnMe
EndFunction

Function SpawnObject()
	if( ! Is3DLoaded() || IsDeleted() || IsDisabled())
		; Something prevented OnUnload from firing, or spawner was already removed
		Cleanup()
		return
	endif
	
	Form spawnMe = GetObjectForm()
	
	if(spawnMe)
		ObjectReference spawn = PlaceAtMe(spawnMe) 
		RegisterForRemoteEvent(spawn, "OnLoad")
		if(spawn)
			iSpawnedObjects += 1
			
			spawn.SetMotionType(Motion_Keyframed, true)
			spawn.MoveToMyEditorLocation()
			
			RegisterForRemoteEvent(spawn, "OnTranslationAlmostComplete")
			RegisterForRemoteEvent(spawn, "OnContainerChanged")
			
			Utility.Wait(fInitialMovementDelay)
			AdvancePhase(spawn, 0)
		endif
	endif
EndFunction


Function AdvancePhase(ObjectReference akMoveMe, Int iPhase)
	if(IsDeleted() || IsDisabled() || ! Phases || iPhase > Phases.Length - 1 || ! Phases[iPhase] || ! Is3DLoaded())
		return
	endif
	
	; Update transition array
	Int index = -1
	if(InTransitionObjects)
		index = InTransitionObjects.FindStruct("kObjectRef", akMoveMe)
	endif
	
	if(index > -1)
		InTransitionObjects[index].iPhase = iPhase
	else
		; Add to InTransitionObjects array			
		InTransitionObject ito = new InTransitionObject
	
		ito.kObjectRef = akMoveMe
		ito.iPhase = iPhase
	
		InTransitionObjects.Add(ito)	
	endif
	
	; Get absolute position
	Float[] OffsetPosition = new Float[3]
	Float[] OffsetRotation = new Float[3]
	OffsetPosition[0] = Phases[iPhase].fOffsetX
	OffsetPosition[1] = Phases[iPhase].fOffsetY
	OffsetPosition[2] = Phases[iPhase].fOffsetZ
	OffsetRotation[0] = Phases[iPhase].fAngleOffsetX
	OffsetRotation[1] = Phases[iPhase].fAngleOffsetY
	OffsetRotation[2] = Phases[iPhase].fAngleOffsetZ
	
	if(bPlotSpawned && kPlotRef && PlotOffsets.Length > 0)
		; Check for plot offset
		if(PlotOffsets.Length >= 3)
			OffsetPosition[0] += PlotOffsets[0]
			OffsetPosition[1] += PlotOffsets[1]
			OffsetPosition[2] += PlotOffsets[2]
		endif
			
		if(PlotOffsets.Length >= 6)
			OffsetRotation[0] += PlotOffsets[3]
			OffsetRotation[1] += PlotOffsets[4]
			OffsetRotation[2] += PlotOffsets[5]
		endif
	endif
	
	Float[] TargetCoordinates = GetCoordinatesRelativeToBase(SpawnerPosition, SpawnerRotation, OffsetPosition, OffsetRotation)
	
	if(Phases[iPhase].bDoNotRotate)
		TargetCoordinates[3] = akMoveMe.GetAngleX()
		TargetCoordinates[4] = akMoveMe.GetAngleY()
		TargetCoordinates[5] = akMoveMe.GetAngleZ()
	endif
	
	; Start translation
	akMoveMe.TranslateTo(TargetCoordinates[0], TargetCoordinates[1], TargetCoordinates[2], TargetCoordinates[3], TargetCoordinates[4], TargetCoordinates[5], Phases[iPhase].fSpeed)
EndFunction


Function Cleanup()
	GoToState("Paused") ; Prevent additional translations or object creation
	
	CancelTimer(SpawnObjectTimerID)
	
	int i = 0
	
	if(InTransitionObjects.Length)
		while(i < InTransitionObjects.Length)
			UnregisterForRemoteEvent(InTransitionObjects[i].kObjectRef, "OnTranslationAlmostComplete")
			UnregisterForRemoteEvent(InTransitionObjects[i].kObjectRef, "OnContainerChanged")
			UnregisterForRemoteEvent(InTransitionObjects[i].kObjectRef, "OnLoad")
			
			InTransitionObjects[i].kObjectRef.Delete()
			
			i += 1
		endWhile
	endif

	i = 0
	
	if(TransistionedObjects.Length)
		while(i < TransistionedObjects.Length)
			UnregisterForRemoteEvent(TransistionedObjects[i], "OnTranslationAlmostComplete")
			UnregisterForRemoteEvent(TransistionedObjects[i], "OnContainerChanged")
			UnregisterForRemoteEvent(TransistionedObjects[i], "OnLoad")
			
			TransistionedObjects[i].Delete()
			
			i += 1
		endWhile
	endif
	
	InTransitionObjects = None
	TransistionedObjects = None
	iSpawnedObjects = 0
	
	GoToState("")
EndFunction


Function Delete()
	Cleanup()
	
	kPlotRef = None
	
	Parent.Delete()
EndFunction