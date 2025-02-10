objectdef obj_Configuration_SpiderTankReps inherits obj_Configuration_Base
{
	method Initialize()
	{
		This[parent]:Initialize["SpiderTankReps"]
	}

	method Set_Default_Values()
	{
		This.ConfigRef:AddSetting[ReservedTargetLocks, 2]
		This.ConfigRef:AddSetting[RepShieldThreshold, 50]
		This.ConfigRef:AddSetting[RepArmorThreshold, 80]
		This.ConfigRef:AddSetting[StopRepShieldThreshold, 90]
		This.ConfigRef:AddSetting[StopRepArmorThreshold, 99]
		This.ConfigRef:AddSetting[CapOutThreshold, 30]
		This.ConfigRef:AddSetting[LogLevelBar, LOG_INFO]
	}
	
	Setting(int, ReservedTargetLocks, SetReservedTargetLocks)
	Setting(int, RepShieldThreshold, SetRepShieldThreshold)
	Setting(int, StopRepShieldThreshold, SetRepShieldThreshold)
	Setting(int, RepArmorThreshold, SetRepArmorThreshold)
	Setting(int, StopRepArmorThreshold, SetRepArmorThreshold)
	Setting(int, CapOutThreshold, SetCapOutThreshold)
	Setting(int, LogLevelBar, SetLogLevelBar)
}

objectdef obj_SpiderTankReps inherits obj_StateQueue
{
	; Avoid name conflict with common config.
	variable obj_Configuration_SpiderTankReps Config

	; This is all of our sqlite variables
	variable sqlitedb SpiderTankData
	; This will be our query 
	variable sqlitequery sortedList

	variable bool IsOtherPilotsDetected = FALSE

	variable bool BotRunningFlag = FALSE
	
	;What reps we got
	variable bool WeArmorRep
	variable bool WeShieldRep
	
	;How many things can we target
	variable int MaxTarget = ${MyShip.MaxLockedTargets}

	variable int64 MyRepTarget = 0
	
	variable obj_TargetList PCs
	variable obj_TargetList NPCs
	variable collection:int AttackTimestamp

	method Initialize()
	{
		This[parent]:Initialize

		DynamicAddMiniMode("SpiderTankReps", "SpiderTankReps")
		This.PulseFrequency:Set[500]

		This.NonGameTiedPulse:Set[TRUE]
		
		; Create or connect to our database. 
		SpiderTankData:Set[${SQLite.OpenDB["${Me.Name}SpiderTankData","${Script.CurrentDirectory}/Data/${Me.Name}SpiderTankData.sqlite3"]}]
		SpiderTankData:ExecDML["PRAGMA journal_mode=WAL;"]
		SpiderTankData:ExecDML["PRAGMA main.mmap_size=64000000"]
		SpiderTankData:ExecDML["PRAGMA main.cache_size=-64000;"]
		SpiderTankData:ExecDML["PRAGMA synchronous = normal;"]
		SpiderTankData:ExecDML["PRAGMA temp_store = memory;"]
		; Create our table in the database if it doesn't exist
		if !${SpiderTankData.TableExists["fleetList"]}
		{
			echo DEBUG - SpiderTankReps - Creating fleetList Table
			SpiderTankData:ExecDML["create table fleetList (CharID INTEGER PRIMARY KEY, CharName TEXT, ThreatLevel INTEGER, LastUpdate INTEGER, UpdateType TEXT);"]
		}
		if ${SpiderTankData.TableExists["fleetList"]}
		{
			echo DEBUG - SpiderTankReps - fleetList Table Exists - Check if we are in the file
			SpiderTankData:ExecDML["insert or ignore into fleetList (CharID, CharName, ThreatLevel, LastUpdate, UpdateType) values (${Me.ID}, "${Me.Name.ReplaceSubstring[','']}", 0, "${Time.Timestamp}", "initial");"]
		}

		; We need to create a list of participants.
		LavishScript:RegisterEvent[SR_Participants]
		Event[SR_Participants]:AttachAtom[This:ParticipantRecorder]
		
		This.LogLevelBar:Set[${Config.LogLevelBar}]
	}

	method Start()
	{
		AttackTimestamp:Clear

		if ${This.IsIdle}
		{
			This:LogInfo["Starting"]
			This:QueueState["SpiderTankReps"]
		}
	}
	
	method Stop()
	{
		This:Clear
	}

	method Shutdown()
	{
		SpiderTankData:ExecDML["drop table fleetList;"]
		SpiderTankData:ExecDML["Vacuum;"]	
		SpiderTankData:Close
		This:Clear
	}
	
	method ParticipantRecorder(int ParticipantID)
	{
		if ${SpiderTankData.TableExists["fleetList"]}
		{
			variable string pname = ${Entity[CharID == ${ParticipantID}].Name.ReplaceSubstring[','']}
			echo ["insert into fleetList (CharID, CharName, ThreatLevel, LastUpdate, UpdateType) values (${ParticipantID}, ${pname}, 0, ${Time.Timestamp}, initial);"]
			SpiderTankData:ExecDML["insert or ignore into fleetList (CharID, CharName, ThreatLevel, LastUpdate, UpdateType) values (${ParticipantID}, "${pname}", 0, "${Time.Timestamp}", "initial");"]

		}
	}
	
	method DetermineRepType()
	{
		if ${Ship.ModuleList_ArmorProjectors.Count} > 0
		{
			WeArmorRep:Set[TRUE]
		}
		if ${Ship.ModuleList_ShieldTransporters.Count} > 0
		{
			WeShieldRep:Set[TRUE]
		}
		
	}
	
	method ParticipantTrigger()
	{
		relay all "Event[SR_Participants]:Execute[${Me.CharID}]"
	}
	
	member:int TargetCount()
	{
		return ${Math.Calc[${Me.TargetCount} + ${Me.TargetingCount} + ${Config.ReservedTargetLocks}]}
	}

	; Lock and rep the person below us in the list of participants, if we are the last row then we need to get the first row and lock and rep that person
	method LockAndRepNext()
	{
		This:LogInfo["LockAndRepNext: Start"]
		; Ensure our fleetList table exists
		if (!${SpiderTankData.TableExists["fleetList"]})
		{
			This:LogInfo["fleetList table not found"]
			return
		}
		This:LogInfo["LockAndRepNext: table exists lets go!"]
		; Attempt to get the next row after our own character 
		variable sqlitequery nextRowQuery
		nextRowQuery:Set[${SpiderTankData.ExecQuery["SELECT * FROM fleetList WHERE CharID > ${Me.ID} ORDER BY CharID ASC LIMIT 1;"]}]
		This:LogInfo["LockAndRepNext: nextRowQuery.NumRows = ${nextRowQuery.NumRows}"]
		if ((${nextRowQuery.NumRows} != NULL) && ${nextRowQuery.NumRows.Equal[1]} && !${nextRowQuery.GetFieldValue["CharID"].Equal[${Me.ID}]})
		{
			; We found a row with a CharID greater than ours
			MyRepTarget:Set[${nextRowQuery.GetFieldValue["CharID"]}]
			This:LogInfo["LockAndRepNext: Next row after our character is ${MyRepTarget}"]
		}
		else
		{
			; Our character is the last row – wrap around and select the first row.
			variable sqlitequery firstRowQuery
			firstRowQuery:Set[${SpiderTankData.ExecQuery["SELECT * FROM fleetList ORDER BY CharID ASC LIMIT 1;"]}]
			This:LogInfo["LockAndRepNext: firstRowQuery.NumRows = ${firstRowQuery.NumRows}"]
			if ((${firstRowQuery.NumRows} != NULL) && ${firstRowQuery.NumRows.Equal[1]} && !${firstRowQuery.GetFieldValue["CharID"].Equal[${Me.ID}]})
			{
				MyRepTarget:Set[${firstRowQuery.GetFieldValue["CharID"]}]
				This:LogInfo["LockAndRepNext: We are the last row, wrapping to first row. Target is ${MyRepTarget}"]
			}
			else
			{
				This:LogInfo["LockAndRepNext: No rows found in fleetList"]
			}
			firstRowQuery:Finalize
		}
		nextRowQuery:Finalize

		; Lock our rep target and start repping them
		This:LogInfo["LockAndRepNext: is our rep target set? ${MyRepTarget}"]
		if ${MyRepTarget} != 0
		{
			This:LogInfo["LockAndRepNext: MyRepTarget is locked? ". ${Entity[CharID == ${MyRepTarget}].IsLockedTarget} . " & BeingTargeted? " . ${Entity[CharID == ${MyRepTarget}].BeingTargeted}]
			if (!${Entity[CharID == ${MyRepTarget}].IsLockedTarget} && !${Entity[CharID == ${MyRepTarget}].BeingTargeted})
			{
				Entity[CharID == ${MyRepTarget}]:LockTarget
				This:LogInfo["Locking target:  ${MyRepTarget}"]
			}

			; Activate shield rep if we have them
			if (${Entity[CharID == ${MyRepTarget}].IsLockedTarget} && ${WeShieldRep})
			{
				Ship.ModuleList_ShieldTransporters:ActivateAll[${Entity[CharID == ${MyRepTarget}]}]
				Ship.ModuleList_EnergyTransfer:ActivateAll[${Entity[CharID == ${MyRepTarget}]}]
				This:LogInfo["Activating shield rep on: ${MyRepTarget}"]
			}

			; Activate armor rep if we have them
			if (${Entity[CharID == ${MyRepTarget}].IsLockedTarget} && ${WeArmorRep})
			{
				Ship.ModuleList_ArmorProjectors:ActivateAll[${Entity[CharID == ${MyRepTarget}]}]
				Ship.ModuleList_EnergyTransfer:ActivateAll[${Entity[CharID == ${MyRepTarget}]}]
				This:LogInfo["Activating armor rep on: ${MyRepTarget}"]
			}
		}

		sortedList:Finalize
	}
	; Not currently being used, will use later.
	method RepDeactivation()
	{
		variable index:entity StopRepHelper
		variable iterator StopRepHelper2
		
		EVE:QueryEntities[StopRepHelper, "IsLockedTarget = 1"]
		if ${StopRepHelper.Used} > 0
		StopRepHelper:GetIterator[StopRepHelper2]
		if ${StopRepHelper2:First(exists)}
		{
			do
			{
				if ${Ship.ModuleList_ArmorProjectors.ActiveCount} > 0
				{
					if ${MyShip.CapacitorPct.Int} < ${Config.CapOutThreshold}
					{
						Ship.ModuleList_ArmorProjectors:DeactivateAll
					}
					if ${StopRepHelper2.Value.ArmorPct} > ${Config.StopRepArmorThreshold}
					{
						Ship.ModuleList_ArmorProjectors:DeactivateOn[${StopRepHelper2.Value.ID}]
					}
				}
				if ${Ship.ModuleList_ShieldTransporters.ActiveCount} > 0
				{
					if ${MyShip.CapacitorPct.Int} < ${Config.CapOutThreshold}
					{
						Ship.ModuleList_ArmorProjectors:DeactivateAll			
					}
					if ${StopRepHelper2.Value.ShieldPct} > ${Config.StopRepShieldThreshold}
					{
						Ship.ModuleList_ArmorProjectors:DeactivateOn[${StopRepHelper2.Value.ID}]
					}
				}
			}
			while ${StopRepHelper2:Next(exists)}
		}
	}
	member:bool SpiderTankReps()
	{
		if ${Me.InStation}
		{
			return FALSE
		}

		; While currently jumping, Me.InSpace is false and status numbers will be null.
		if !${Client.InSpace}
		{
			This:LogDebug["Not in space, jumping?"]
			return FALSE
		}
		if ${MyShip.ToEntity.Mode} == MOVE_WARPING
		{
			return FALSE
		}
		This:ParticipantTrigger
		This:DetermineRepType
		This:LockAndRepNext
		
		return FALSE
	}
}