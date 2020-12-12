Scriptname SS2AOP_VaultTecTools:SamutzLibrary Const

ObjectReference Function GetParentPlot(ObjectReference selfRef, Keyword kPlotSpawned) Global
	ObjectReference plotRef = None
	int retry = 0
	while !(plotRef as bool) && retry < 10
		plotRef = selfRef.GetLinkedRef(kPlotSpawned) as ObjectReference
		Utility.Wait(1)
		retry += 1
	endWhile
	return plotRef
EndFunction

ObjectReference Function PlaceRelativeToMe(ObjectReference selfRef, Form baseForm, float fPosOffX = 0.0, float fPosOffY = 0.0, float fPosOffZ = 0.0, float fRotOffX = 0.0, float fRotOffY = 0.0, float fRotOffZ = 0.0, float fScale = 1.0) Global
	ObjectReference spawnedRef = selfRef.PlaceAtMe(baseForm, 1, false, true, true)
	spawnedRef.SetScale(fScale)
	float[] fPosOff = new float[3]
	float[] fRotOff = new float[3]
	fPosOff[0] = fPosOffX
	fPosOff[1] = fPosOffY
	fPosOff[2] = fPosOffZ
	fRotOff[0] = fRotOffX
	fRotOff[1] = fRotOffY
	fRotOff[2] = fRotOffZ
	SS2AOP_VaultTecTools:CobbLibraryRotations.MoveObjectRelativeToObject(spawnedRef, selfRef, fPosOff, fRotOff)
	return spawnedRef
EndFunction

ObjectReference[] Function CleanUpChildSpawns(ObjectReference parentRef, Keyword kwLinkParent) Global
	ObjectReference[] spawns = parentRef.GetLinkedRefChildren(kwLinkParent)
	int i = 0
	while i < spawns.length
		spawns[i].Disable(false)
		spawns[i].Delete()
		i += 1
	endWhile
EndFunction

workshopscript Function GetNearestWorkshop(ObjectReference akObjectRef, Keyword WorkshopKeyword) Global
    If (!akObjectRef)
        return None
    EndIf
    workshopscript NearestWorkshop = None
    ObjectReference[] WorkshopsNearby = akObjectRef.FindAllReferencesWithKeyword(WorkshopKeyword as Form, 10000)
    int I = 0
    While (I < WorkshopsNearby.length)
        If (NearestWorkshop)
            If (WorkshopsNearby[I].GetDistance(akObjectRef) < NearestWorkshop.GetDistance(akObjectRef))
                NearestWorkshop = WorkshopsNearby[I] as workshopscript
            EndIf
        Else
            NearestWorkshop = WorkshopsNearby[I] as workshopscript
        EndIf
        I += 1
    EndWhile
    return NearestWorkshop
EndFunction
