objectdef obj_Configuration_DroneControlCA inherits obj_Configuration_Base
{
	method Initialize()
	{
		This[parent]:Initialize["DroneControlCA"]
	}

	method Set_Default_Values()
	{
		This.ConfigRef:AddSetting[Sentries, FALSE]
		This.ConfigRef:AddSetting[SentryRange, 30]
		This.ConfigRef:AddSetting[MaxDroneCount, 5]
		This.ConfigRef:AddSetting[ArmorDrones, FALSE]
		This.ConfigRef:AddSetting[ShieldDrones, FALSE]
	}

	Setting(bool, Sentries, SetSentries)
	Setting(int, SentryRange, SetSentryRange)
	Setting(int, MaxDroneCount, SetDroneCount)
	Setting(bool, UseIPC, SetUseIPC)
	Setting(bool, ArmorDrones, SetArmorDrones)
	Setting(bool, ShieldDrones, SetShieldDrones)
}

objectdef obj_DroneControlCA inherits obj_StateQueue
{
	variable obj_Configuration_DroneControlCA Config
	variable obj_TargetList ActiveNPCs
	variable obj_TargetList NPC
	
	variable obj_TargetList SalvageDrone
	
	variable obj_TargetList Marshal
	variable obj_TargetList RemoteRepJerkz
	variable obj_TargetList StarvingJerks
	variable obj_TargetList Leshaks
	variable obj_TargetList Kikimoras
	variable obj_TargetList Damaviks
	variable obj_TargetList Vedmaks
	variable obj_TargetList Drekavacs
	variable obj_TargetList Cynabals
	variable obj_TargetList Dramiels
	
	variable int64 CurrentTarget = 0
	variable bool IsBusy
	variable int droneEngageRange = 60000
	variable bool RecallActive=FALSE

	method Initialize()
	{
		This[parent]:Initialize
		PulseFrequency:Set[1000]
		This.NonGameTiedPulse:Set[TRUE]
		DynamicAddMiniMode("DroneControlCA", "DroneControlCA")
		
		 Marshal.NeedUpdate:Set[FALSE]
		 RemoteRepJerkz.NeedUpdate:Set[FALSE]
		 StarvingJerks.NeedUpdate:Set[FALSE]
		 Leshaks.NeedUpdate:Set[FALSE]
		 Kikimoras.NeedUpdate:Set[FALSE]
		 Damaviks.NeedUpdate:Set[FALSE]
		 Vedmaks.NeedUpdate:Set[FALSE]
		 Drekavacs.NeedUpdate:Set[FALSE]
		 Cynabals.NeedUpdate:Set[FALSE]
		 Dramiels.NeedUpdate:Set[FALSE]
		 SalvageDrone.NeedUpdate:Set[FALSE]
	}
	
	member:bool JerkzPresent()
	{
		if ${Entity[(Group =- "Abyssal Spaceship Entities" || Group =- "Abyssal Drone Entities") && !IsMoribund && Name !~ "Vila Swarmer"](exists)}
		{
			return TRUE
		}
		else
		{
			return FALSE
		}
	}

	member:int FindBestType(int TargetGroupID)
	{
		variable string TargetClass
		variable int DroneType
		TargetClass:Set[${NPCData.NPCType[${TargetGroupID}]}]
		switch ${TargetClass}
		{
			case Frigate
				
				DroneType:Set[${Drones.Data.FindType["Fighters"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Heavy Attack Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Medium Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Light Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

			case Destroyer
				
				DroneType:Set[${Drones.Data.FindType["Fighters"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Heavy Attack Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Medium Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Light Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}
				
			case Cruiser
				
				DroneType:Set[${Drones.Data.FindType["Fighters"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Heavy Attack Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Medium Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Light Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

			case BattleCruiser
				
				DroneType:Set[${Drones.Data.FindType["Fighters"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Heavy Attack Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Medium Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Light Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}


			case Battleship

				DroneType:Set[${Drones.Data.FindType["Fighters"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Heavy Attack Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Medium Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}

				DroneType:Set[${Drones.Data.FindType["Light Scout Drones"]}]
				if ${DroneType} != -1
				{
					return ${DroneType}
				}
		}

		; Fallback for PVP
		DroneType:Set[${Drones.Data.FindType["Light Scout Drones"]}]
		if ${DroneType} != -1
		{
			return ${DroneType}
		}

		DroneType:Set[${Drones.Data.FindType["Medium Scout Drones"]}]
		if ${DroneType} != -1
		{
			return ${DroneType}
		}
	}

	member:int SentryCount()
	{
		variable iterator typeIterator
		variable string types = ""
		variable string seperator = ""

		seperator:Set[""]
		types:Set[""]
		Drones.Data.BaseRef.FindSet["Sentry Drones"]:GetSettingIterator[typeIterator]
		if ${typeIterator:First(exists)}
		{
			do
			{
				types:Concat["${seperator}TypeID = ${typeIterator.Key}"]
				seperator:Set[" || "]
			}
			while ${typeIterator:Next(exists)}
		}
		return ${Drones.ActiveDroneCount["${types}"]}
	}

	method RecallAllSentry()
	{
		variable iterator typeIterator
		variable string types = ""
		variable string seperator = ""

		seperator:Set[""]
		types:Set[""]
		Drones.Data.BaseRef.FindSet["Sentry Drones"]:GetSettingIterator[typeIterator]
		if ${typeIterator:First(exists)}
		{
			do
			{
				types:Concat["${seperator}TypeID = ${typeIterator.Key}"]
				seperator:Set[" || "]
			}
			while ${typeIterator:Next(exists)}
		}
		Drones:Recall["${types}", ${Drones.ActiveDroneCount["${types}"]}]
	}

	member:int NonSentryCount()
	{
		variable iterator typeIterator
		variable string types = ""
		variable string seperator = ""

		seperator:Set[""]
		types:Set[""]
		Drones.Data.BaseRef.FindSet["Sentry Drones"]:GetSettingIterator[typeIterator]
		if ${typeIterator:First(exists)}
		{
			do
			{
				types:Concat["${seperator}TypeID != ${typeIterator.Key}"]
				seperator:Set[" && "]
			}
			while ${typeIterator:Next(exists)}
		}
		return ${Drones.ActiveDroneCount["(ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE) && (${types})"]}
	}

	method RecallAllNonSentry()
	{
		variable iterator typeIterator
		variable string types = ""
		variable string seperator = ""

		seperator:Set[""]
		types:Set[""]
		Drones.Data.BaseRef.FindSet["Sentry Drones"]:GetSettingIterator[typeIterator]
		if ${typeIterator:First(exists)}
		{
			do
			{
				types:Concat["${seperator}TypeID != ${typeIterator.Key}"]
				seperator:Set[" && "]
			}
			while ${typeIterator:Next(exists)}
		}
		Drones:Recall["(ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE) && (${types})", ${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE && (${types})"]}]
	}

	method Start()
	{
		if ${This.IsIdle}
		{
			This:LogInfo["Starting."]
			if ${CommonConfig.Tehbot_Mode.Equal["Abyssal"]}
			{
				Dramiels.AutoLock:Set[TRUE]			
				Cynabals.AutoLock:Set[TRUE]			
				Drekavacs.AutoLock:Set[TRUE]			
				Vedmaks.AutoLock:Set[TRUE]		
				Damaviks.AutoLock:Set[TRUE]		
				Kikimoras.AutoLock:Set[TRUE]	
				Leshaks.AutoLock:Set[TRUE]			
				StarvingJerks.AutoLock:Set[TRUE]
				Marshal.AutoLock:Set[TRUE]
				RemoteRepJerkz.AutoLock:Set[TRUE]
			}
			ActiveNPCs.MaxRange:Set[${droneEngageRange}]
			variable int MaxTarget = ${MyShip.MaxLockedTargets}
			if ${Me.MaxLockedTargets} < ${MyShip.MaxLockedTargets}
				MaxTarget:Set[${Me.MaxLockedTargets}]
			MaxTarget:Dec[2]

			if !${CommonConfig.Tehbot_Mode.Equal["Mission"]}
			{
				ActiveNPCs.MinLockCount:Set[${MaxTarget}]
				ActiveNPCs.AutoLock:Set[TRUE]
			}
			else
			{
				ActiveNPCs.MinLockCount:Set[0]
				ActiveNPCs.AutoLock:Set[FALSE]			
			}
			This:QueueState["DroneControlCA"]
		}
	}

	method Stop()
	{
		This:LogInfo["Stopping."]
		Marshal.AutoLock:Set[FALSE]
		ActiveNPCs.AutoLock:Set[FALSE]
		RemoteRepJerkz.AutoLock:Set[FALSE]
		StarvingJerks.AutoLock:Set[FALSE]
		Dramiels.AutoLock:Set[FALSE]			
		Cynabals.AutoLock:Set[FALSE]			
		Drekavacs.AutoLock:Set[FALSE]			
		Vedmaks.AutoLock:Set[FALSE]		
		Damaviks.AutoLock:Set[FALSE]		
		Kikimoras.AutoLock:Set[FALSE]	
		Leshaks.AutoLock:Set[FALSE]	
		This:Clear
	}

	method Recall()
	{
		if ${This.RecallActive}
		{
			return
		}
		This.RecallActive:Set[TRUE]

		variable bool DontResume=${This.IsIdle}

		This:Clear

		if ${Drones.DronesInSpace}
		{
			Busy:SetBusy["DroneControlCA"]
			Drones:RecallAll
			This:QueueState["Idle", 2000]
			This:QueueState["RecallCheck"]
		}
		else
		{
			Busy:UnsetBusy["DroneControlCA"]
		}

		This:QueueState["Idle", 20000]
		This:QueueState["ResetRecall", 50]

		if !${DontResume}
		{
			This:QueueState["DroneControlCA"]
		}
	}

	member:bool RecallCheck()
	{
		if ${Drones.DronesInSpace}
		{
			Drones:RecallAll
			This:InsertState["RecallCheck"]
			This:InsertState["Idle", 2000]
		}
		else
		{
			Busy:UnsetBusy["DroneControlCA"]
		}
		return TRUE
	}

	member:bool ResetRecall()
	{
		This.RecallActive:Set[FALSE]
		return TRUE
	}

	method BuildActiveNPCs()
	{
		variable iterator classIterator
		variable iterator groupIterator
		variable string groups = ""
		variable string seperator = ""

		ActiveNPCs:ClearQueryString
		if ${CommonConfig.Tehbot_Mode.Equal["Abyssal"]}
		{
			Marshal:ClearQueryString
			RemoteRepJerkz:ClearQueryString
			StarvingJerks:ClearQueryString
			Dramiels:ClearQueryString
			Cynabals:ClearQueryString
			Drekavacs:ClearQueryString
			Vedmaks:ClearQueryString
			Damaviks:ClearQueryString
			Kikimoras:ClearQueryString
			Leshaks:ClearQueryString
		}
		if ${CommonConfig.Tehbot_Mode.Equal["Abyssal"]}
		{
			Dramiels:AddQueryString["Name =- \"Dramiel\" && !IsMoribund"]
			Cynabals:AddQueryString["Name =- \"Cynabal\" && !IsMoribund"]
			Drekavacs:AddQueryString["Name =- \"Drekavac\" && !IsMoribund"]
			Vedmaks:AddQueryString["Name =- \"Vedmak\" && !IsMoribund"]
			Damaviks:AddQueryString["Name =- \"Damavik\" && !IsMoribund"]
			Kikimoras:AddQueryString["Name =- \"Kikimora\" && !IsMoribund"]
			Leshaks:AddQueryString["Name =- \"Leshak\" && !IsMoribund"]	
			StarvingJerks:AddQueryString["Name =- \"Starving\" && !IsMoribund"]
			RemoteRepJerkz:AddQueryString["Name =- \"Renewing\" || Name =- \"Fieldweaver\" || Name =- \"Plateforger\" || Name =- \"Burst\"|| Name =- \"Preserver\" && !IsMoribund"]
			Marshal:AddQueryString["(TypeID == 56177 || TypeID == 56176 || TypeID == 56178) && !IsMoribund"]
		}

		variable int range = ${Math.Calc[${MyShip.MaxTargetRange} * .95]}

		if ${CommonConfig.Tehbot_Mode.Equal["Mission"]} || ${CommonConfig.Tehbot_Mode.Equal["Mining"]}
		{
			ActiveNPCs:AddTargetExceptionByPartOfName["EDENCOM"]
			ActiveNPCs:AddTargetExceptionByPartOfName["Tyrannos"]
			ActiveNPCs:AddTargetExceptionByPartOfName["Drifter"]
			ActiveNPCs:AddTargetExceptionByPartOfName["Sleeper"]	
		}
		; Add ongoing jammers.
		variable index:jammer attackers
		variable iterator attackerIterator
		Me:GetJammers[attackers]
		attackers:GetIterator[attackerIterator]
		if ${attackerIterator:First(exists)}
		do
		{
			variable index:string jams
			variable iterator jamsIterator
			attackerIterator.Value:GetJams[jams]
			jams:GetIterator[jamsIterator]
			if ${jamsIterator:First(exists)}
			{
				do
				{
					; Both scramble and disrupt
					if ${jamsIterator.Value.Lower.Find["warp"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					elseif ${jamsIterator.Value.Lower.Find["trackingdisrupt"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					elseif ${jamsIterator.Value.Lower.Find["electronic"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					; Energy drain and neutralizer
					elseif ${jamsIterator.Value.Lower.Find["energy"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					elseif ${jamsIterator.Value.Lower.Find["remotesensordamp"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					elseif ${jamsIterator.Value.Lower.Find["webify"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					elseif ${jamsIterator.Value.Lower.Find["targetpaint"]}
					{
						groups:Concat[${seperator}ID =- "${attackerIterator.Value.ID}"]
						seperator:Set[" || "]
					}
					else
					{
						This:LogInfo["Mission", "unknown EW ${jamsIterator.Value}", "r"]
					}
				}
				while ${jamsIterator:Next(exists)}
			}
		}
		while ${attackerIterator:Next(exists)}

		ActiveNPCs:AddQueryString["Distance < ${droneEngageRange} && IsNPC && !IsMoribund && (${groups})"]
		ActiveNPCs:AddQueryString["Distance < ${droneEngageRange} && IsNPC && !IsMoribund && IsWarpScramblingMe"]

		; Add potential jammers.
		seperator:Set[""]
		groups:Set[""]
		PrioritizedTargets.Scramble:GetIterator[groupIterator]
		if ${groupIterator:First(exists)}
		{
			do
			{
				groups:Concat[${seperator}Name =- "${groupIterator.Value}"]
				seperator:Set[" || "]
			}
			while ${groupIterator:Next(exists)}
		}
		ActiveNPCs:AddQueryString["Distance < ${droneEngageRange} && IsNPC && !IsMoribund && (${groups})"]

		seperator:Set[""]
		groups:Set[""]
		PrioritizedTargets.Neut:GetIterator[groupIterator]
		if ${groupIterator:First(exists)}
		{
			do
			{
				groups:Concat[${seperator}Name =- "${groupIterator.Value}"]
				seperator:Set[" || "]
			}
			while ${groupIterator:Next(exists)}
		}
		ActiveNPCs:AddQueryString["Distance < ${droneEngageRange} && IsNPC && !IsMoribund && (${groups})"]

		seperator:Set[""]
		groups:Set[""]
		PrioritizedTargets.ECM:GetIterator[groupIterator]
		if ${groupIterator:First(exists)}
		{
			do
			{
				groups:Concat[${seperator}Name =- "${groupIterator.Value}"]
				seperator:Set[" || "]
			}
			while ${groupIterator:Next(exists)}
		}
		ActiveNPCs:AddQueryString["Distance < ${droneEngageRange} && IsNPC && !IsMoribund && (${groups})"]

		NPCData.BaseRef:GetSetIterator[classIterator]
		if ${classIterator:First(exists)}
		{
			do
			{
				seperator:Set[""]
				groups:Set[""]
				classIterator.Value:GetSettingIterator[groupIterator]
				if ${groupIterator:First(exists)}
				{
					do
					{
						groups:Concat["${seperator}GroupID = ${groupIterator.Key}"]
						seperator:Set[" || "]
					}
					while ${groupIterator:Next(exists)}
				}
				ActiveNPCs:AddQueryString["Distance < ${droneEngageRange} && IsNPC && !IsMoribund && (${groups})"]
			}
			while ${classIterator:Next(exists)}
		}

		ActiveNPCs:AddAllNPCs
		
	}

	member:bool DroneControlCA()
	{
		variable index:activedrone ActiveDrones
		variable iterator DroneIterator
		variable float CurrentDroneHealth
		variable iterator DroneTypesIter
		variable int MaxDroneCount = ${Config.MaxDroneCount}
		variable string MainModeSwitch

		if !${CommonConfig.Tehbot_Mode.Equal["Mission"]}
		{
			This:BuildActiveNPCs
			MainModeSwitch:Set[ActiveNPCs]
			ActiveNPCs.MinLockCount:Set[${Config.LockCount}]
		}
		else
		{
			MainModeSwitch:Set[MissionTargetManager.DroneTargets]
		}
		
		if ${CommonConfig.Tehbot_Mode.Equal["Abyssal"]}
		{
			ActiveNPCs:RequestUpdate
			Marshal:RequestUpdate
			RemoteRepJerkz:RequestUpdate
			StarvingJerks:RequestUpdate
		}
		
		;if ${CommonConfig.Tehbot_Mode.Equal["Mission"]}
		;{
		;	ActiveNPCs:RequestUpdate
		;}
		
		if ${CommonConfig.Tehbot_Mode.Equal["Mining"]}
		{
			ActiveNPCs.MaxRange:Set[${droneEngageRange}]
			variable int MaxTarget = ${MyShip.MaxLockedTargets}
			if ${Me.MaxLockedTargets} < ${MyShip.MaxLockedTargets}
				MaxTarget:Set[${Me.MaxLockedTargets}]
			MaxTarget:Dec[2]
			ActiveNPCs:RequestUpdate
			ActiveNPCs.MinLockCount:Set[${MaxTarget}]
			ActiveNPCs.AutoLock:Set[TRUE]
		}

		if !${Client.InSpace}
		{
			return FALSE
		}
		
		if ${Mission.CurrentAgentMissionName.Find["Minesweeper"]}
		{
			return FALSE
		}
		
		if ${MaxDroneCount} > ${Me.MaxActiveDrones} && !${MyShip.ToEntity.Type.Find[Rattlesnake]} && !${MyShip.ToEntity.Type.Find[Gila]}
		{
			MaxDroneCount:Set[${Me.MaxActiveDrones}]
		}

		if ${MyShip.ToEntity.Type.Find[Rattlesnake]} || ${MyShip.ToEntity.Type.Find[Gila]}
		{
			MaxDroneCount:Set[2]
		}

		if ${Me.ToEntity.Mode} == MOVE_WARPING
		{
			if ${Drones.ActiveCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE || ToEntity.GroupID = GROUP_SALVAGE_DRONE "]} > 0
			{
				Drones:Recall["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE || ToEntity.GroupID = GROUP_SALVAGE_DRONE"]
			}
			return FALSE
		}

		if ${Drones.DronesInBay.Equal[0]} && ${Drones.DronesInSpace.Equal[0]}
		{
			Busy:UnsetBusy["DroneControlCA"]
			return FALSE
		}

		if ${IsBusy}
		{
			if ${Drones.DronesInSpace.Equal[0]}
			{
				Busy:UnsetBusy["DroneControlCA"]
				IsBusy:Set[FALSE]
			}
		}

		Me:GetActiveDrones[ActiveDrones]
		ActiveDrones:GetIterator[DroneIterator]
		if ${DroneIterator:First(exists)}
		{
			do
			{
				; If someone didn't set either of the new configs in DroneControlCA then we use the original setup for drone recalls. Alternatively, some joker checked both boxes.
				if (!${Config.ArmorDrones} && !${Config.ShieldDrones}) || ( ${Config.ArmorDrones} && ${Config.ShieldDrones} )
				{
					CurrentDroneHealth:Set[${Math.Calc[${DroneIterator.Value.ToEntity.ShieldPct.Int} + ${DroneIterator.Value.ToEntity.ArmorPct.Int} + ${DroneIterator.Value.ToEntity.StructurePct.Int}]}]
					;This is for abyss, if we've got edencom lightning blasters we need drones to ignore more damage or we will get looped.
					if ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} && ${CurrentDroneHealth} < ${Math.Calc[${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} - 30]} && \
					${Entity[Name =- "Skybreaker" || Name =- "Stormbringer" || Name =- "Thunderchild"](exists)}
					{
						;echo recalling ID ${DroneIterator.Value.ID}
						Drones:Recall["ID = ${DroneIterator.Value.ID}", 1]
					}
					if ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} && ${CurrentDroneHealth} < ${Math.Calc[${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} - 15]} && \
					!${Entity[Name =- "Skybreaker" || Name =- "Stormbringer" || Name =- "Thunderchild"](exists)}
					{
						;echo recalling ID ${DroneIterator.Value.ID}
						Drones:Recall["ID = ${DroneIterator.Value.ID}", 1]
					}
					Drones.DroneHealth:Set[${DroneIterator.Value.ID}, ${CurrentDroneHealth.Int}]
					;echo drone refreshed cached health ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]}
				}
				; We are using my new configs, this denotes we have drones that are primarily Armor HP heavy - We will mostly ignore shield damage because otherwise we will recall our drones nonstop.
				if ${Config.ArmorDrones}
				{
					CurrentDroneHealth:Set[${Math.Calc[( ${DroneIterator.Value.ToEntity.ShieldPct.Int} * 0.175 ) + ${DroneIterator.Value.ToEntity.ArmorPct.Int} + ${DroneIterator.Value.ToEntity.StructurePct.Int}]}]
					;This is for abyss, if we've got edencom lightning blasters we need drones to ignore more damage or we will get looped.
					if ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} && ${CurrentDroneHealth} < ${Math.Calc[${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} - 30]} && \
					${Entity[Name =- "Skybreaker" || Name =- "Stormbringer" || Name =- "Thunderchild"](exists)}
					{
						;echo recalling ID ${DroneIterator.Value.ID}
						Drones:Recall["ID = ${DroneIterator.Value.ID}", 1]
					}
					if ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} && ${CurrentDroneHealth} < ${Math.Calc[${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} - 15]} && \
					!${Entity[Name =- "Skybreaker" || Name =- "Stormbringer" || Name =- "Thunderchild"](exists)}
					{
						;echo recalling ID ${DroneIterator.Value.ID}
						Drones:Recall["ID = ${DroneIterator.Value.ID}", 1]
					}
					Drones.DroneHealth:Set[${DroneIterator.Value.ID}, ${CurrentDroneHealth.Int}]
					;echo drone refreshed cached health ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]}
				}
				; We are using my new configs, this denotes we have drones that are primarily Shield HP heavy - We will allow slightly more shield HP damage per loop, less recalling.
				if ${Config.ShieldDrones}
				{
					CurrentDroneHealth:Set[${Math.Calc[(${DroneIterator.Value.ToEntity.ShieldPct.Int} *1.25) + ${DroneIterator.Value.ToEntity.ArmorPct.Int} + ${DroneIterator.Value.ToEntity.StructurePct.Int}]}]
					;This is for abyss, if we've got edencom lightning blasters we need drones to ignore more damage or we will get looped.
					if ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} && ${CurrentDroneHealth} < ${Math.Calc[${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} - 30]} && \
					${Entity[Name =- "Skybreaker" || Name =- "Stormbringer" || Name =- "Thunderchild"](exists)}
					{
						;echo recalling ID ${DroneIterator.Value.ID}
						Drones:Recall["ID = ${DroneIterator.Value.ID}", 1]
					}
					if ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} && ${CurrentDroneHealth} < ${Math.Calc[${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]} - 15]} && \
					!${Entity[Name =- "Skybreaker" || Name =- "Stormbringer" || Name =- "Thunderchild"](exists)}
					{
						;echo recalling ID ${DroneIterator.Value.ID}
						Drones:Recall["ID = ${DroneIterator.Value.ID}", 1]
					}
					Drones.DroneHealth:Set[${DroneIterator.Value.ID}, ${CurrentDroneHealth.Int}]
					;echo drone refreshed cached health ${Drones.DroneHealth.Element[${DroneIterator.Value.ID}]}
				}	
			}
			while ${DroneIterator:Next(exists)}
		}


		if !${Entity[${CurrentTarget}](exists)} || ${Entity[${CurrentTarget}].IsMoribund} || (!${Entity[${CurrentTarget}].IsLockedTarget} && !${Entity[${CurrentTarget}].BeingTargeted}) || ${Entity[${CurrentTarget}].Distance} > ${droneEngageRange}
		{
			finalizedDC:Set[FALSE]
			CurrentTarget:Set[0]
		}

		variable iterator lockedTargetIterator
		variable iterator activeJammerIterator
		if !${CommonConfig.Tehbot_Mode.Equal["Mission"]}
		{
			Ship:BuildActiveJammerList
		}

		if ${CurrentTarget} != 0
		{
			

			if ${Marshal.TargetList.Used}
			{
				This:LogInfo["Debug - Marshal - DC"]
				if ${Marshal.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Marshal.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Damn Marshals"]
					finalizedDC:Set[TRUE]
				}
			}
			
			if ${RemoteRepJerkz.TargetList.Used} && !${Marshal.TargetList.Used}
			{
				This:LogInfo["Debug - RRJerks - DC"]
				if ${RemoteRepJerkz.LockedTargetList.Used}
				{
					CurrentTarget:Set[${RemoteRepJerkz.LockedTargetList.Get[1]}]
					This:LogInfo["Kill RemoteReppers"]
					finalizedDC:Set[TRUE]
				}
			}

			if ${StarvingJerks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used}
			{
				This:LogInfo["Debug - Neuting Jerks - DC"]
				if ${StarvingJerks.LockedTargetList.Used}
				{
					CurrentTarget:Set[${StarvingJerks.LockedTargetList.Get[1]}]
					This:LogInfo["Kill Neuts"]
					finalizedDC:Set[TRUE]
				}
			}				

			if ${Leshaks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used}
			{
				This:LogInfo["Debug - Leshaks - DC"]
				if ${Leshaks.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Leshaks.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Leshaks"]
					finalizedDC:Set[TRUE]
				}
			}
			
			if ${Kikimoras.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used}
			{
				This:LogInfo["Debug - Kikimoras - DC"]
				if ${Kikimoras.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Kikimoras.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Kikimoras"]
					finalizedDC:Set[TRUE]
				}
			}

			if ${Damaviks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
			!${Kikimoras.TargetList.Used}
			{
				This:LogInfo["Debug - Damaviks - DC"]
				if ${Damaviks.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Damaviks.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Damaviks"]
					finalizedDC:Set[TRUE]
				}
			}
			
			if ${Vedmaks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
			!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used}
			{
				This:LogInfo["Debug - Vedmaks - DC"]
				if ${Vedmaks.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Vedmaks.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Vedmaks"]
					finalizedDC:Set[TRUE]
				}
			}

			if ${Drekavacs.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
			!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used}
			{
				This:LogInfo["Debug - Drekavacs - DC"]
				if ${Drekavacs.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Drekavacs.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Drekavacs"]
					finalizedDC:Set[TRUE]
				}
			}			
			
			if ${Cynabals.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
			!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used} && !${Drekavacs.TargetList.Used}
			{
				This:LogInfo["Debug - Cynabals - DC"]
				if ${Cynabals.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Cynabals.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Cynabals"]
					finalizedDC:Set[TRUE]
				}
			}

			if ${Dramiels.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
			!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used} && !${Drekavacs.TargetList.Used} && !${Cynabals.TargetList.Used}
			{
				This:LogInfo["Debug - Dramiels - DC"]
				if ${Dramiels.LockedTargetList.Used}
				{
					CurrentTarget:Set[${Dramiels.LockedTargetList.Get[1]}]
					This:LogInfo["Kill The Dramiels"]
					finalizedDC:Set[TRUE]
				}
			}			
			if ${FightOrFlight.IsEngagingGankers} && !${FightOrFlight.CurrentTarget.Equal[0]} && !${FightOrFlight.CurrentTarget.Equal[${CurrentTarget}]}
			{
				CurrentTarget:Set[${FightOrFlight.CurrentTarget}]
				This:LogInfo["Switching target to ganker \ar${Entity[${CurrentTarget}].Name}"]
				finalizedDC:Set[TRUE]
			}

			if !${finalizedDC} && ${Ship.ActiveJammerList.Used}
			{
				if !${Ship.ActiveJammerSet.Contains[${CurrentTarget}]}
				{
					; Being jammed but the jammer is not the current target
					Ship.ActiveJammerList:GetIterator[activeJammerIterator]
					do
					{
						if ${Entity[${activeJammerIterator.Value}].IsLockedTarget} && ${Entity[${activeJammerIterator.Value}].Distance} < ${droneEngageRange}
						{
							CurrentTarget:Set[${activeJammerIterator.Value}]
							This:LogInfo["Switching target to activate jammer \ar${Entity[${CurrentTarget}].Name}"]
							finalizedDC:Set[TRUE]
							break
						}
					}
					while ${activeJammerIterator:Next(exists)}
				}
				else
				{
					finalizedDC:Set[TRUE]
				}
			}
			; May switch target more than once so use this flag to avoid log spamming.
			variable bool switched
			if !${finalizedDC} && !${Ship.IsHardToDealWithTarget[${CurrentTarget}]} && ${${MainModeSwitch}.LockedTargetList.Used}
			{
				; Switch to difficult target for the ship
				switched:Set[FALSE]
				${MainModeSwitch}.LockedTargetList:GetIterator[lockedTargetIterator]
				do
				{
					if ${Entity[${lockedTargetIterator.Value}].Distance} < ${droneEngageRange} && ${Ship.IsHardToDealWithTarget[${lockedTargetIterator.Value}]} && \
					(!${Ship.IsHardToDealWithTarget[${CurrentTarget}]} || ${Entity[${CurrentTarget}].Distance} > ${Entity[${lockedTargetIterator.Value}].Distance})
					{
						CurrentTarget:Set[${lockedTargetIterator.Value}]
						switched:Set[TRUE]
					}
				}
				while ${lockedTargetIterator:Next(exists)}
				if ${switched}
				{
					This:LogInfo["Switching to target skipped by ship: \ar${Entity[${CurrentTarget}].Name}"]
				}
			}
		}
		elseif ${FightOrFlight.IsEngagingGankers} && !${FightOrFlight.CurrentTarget.Equal[0]} && ${Entity[${FightOrFlight.CurrentTarget}](exists)}
		{
			CurrentTarget:Set[${FightOrFlight.CurrentTarget}]
			This:LogInfo["Engaging ganker \ar${Entity[${CurrentTarget}].Name}"]
		}
		elseif ${Marshal.TargetList.Used}
		{
			This:LogInfo["Debug - Marshal - DC"]
			if ${Marshal.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Marshal.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Damn Marshals"]
				finalizedDC:Set[TRUE]
			}
		}
		elseif ${RemoteRepJerkz.TargetList.Used} && !${Marshal.TargetList.Used} 
		{
			This:LogInfo["Debug - RRJerks - DC"]
			if ${RemoteRepJerkz.LockedTargetList.Used}
			{
				CurrentTarget:Set[${RemoteRepJerkz.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Damn Remote Reps"]
				finalizedDC:Set[TRUE]
			}
		}
		elseif ${StarvingJerks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used}
		{
			This:LogInfo["Debug - Neuting Jerks - DC"]
			if ${StarvingJerks.LockedTargetList.Used}
			{
				CurrentTarget:Set[${StarvingJerks.LockedTargetList.Get[1]}]
				This:LogInfo["Kill Neuts"]
				finalizedDC:Set[TRUE]
			}
		}	
		elseif ${Leshaks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used}
		{
			This:LogInfo["Debug - Leshaks - DC"]
			if ${Leshaks.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Leshaks.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Leshaks"]
				finalizedDC:Set[TRUE]
			}
		}
			
		elseif ${Kikimoras.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used}
		{
			This:LogInfo["Debug - Kikimoras - DC"]
			if ${Kikimoras.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Kikimoras.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Kikimoras"]
				finalizedDC:Set[TRUE]
			}
		}
		elseif ${Damaviks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
		!${Kikimoras.TargetList.Used}
		{
			This:LogInfo["Debug - Damaviks - DC"]
			if ${Damaviks.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Damaviks.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Damaviks"]
				finalizedDC:Set[TRUE]
			}
		}
			
		elseif ${Vedmaks.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
		!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used}
		{
			This:LogInfo["Debug - Vedmaks - DC"]
			if ${Vedmaks.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Vedmaks.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Vedmaks"]
				finalizedDC:Set[TRUE]
			}
		}

		elseif ${Drekavacs.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
		!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used}
		{
			This:LogInfo["Debug - Drekavacs - DC"]
			if ${Drekavacs.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Drekavacs.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Drekavacs"]
				finalizedDC:Set[TRUE]
			}
		}			
		
		elseif ${Cynabals.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
		!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used} && !${Drekavacs.TargetList.Used}
		{
			This:LogInfo["Debug - Cynabals - DC"]
			if ${Cynabals.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Cynabals.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Cynabals"]
				finalizedDC:Set[TRUE]
			}
		}

		elseif ${Dramiels.TargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
		!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used} && !${Drekavacs.TargetList.Used} && !${Cynabals.TargetList.Used}
		{
			This:LogInfo["Debug - Dramiels - DC"]
			if ${Dramiels.LockedTargetList.Used}
			{
				CurrentTarget:Set[${Dramiels.LockedTargetList.Get[1]}]
				This:LogInfo["Kill The Dramiels"]
				finalizedDC:Set[TRUE]
			}
		}

		elseif ${${MainModeSwitch}.LockedTargetList.Used} && !${Marshal.TargetList.Used} && !${RemoteRepJerkz.TargetList.Used} && !${StarvingJerks.TargetList.Used} && !${Leshaks.TargetList.Used} && \
		!${Kikimoras.TargetList.Used} && !${Damaviks.TargetList.Used} && !${Vedmaks.TargetList.Used} && !${Drekavacs.TargetList.Used} && !${Cynabals.TargetList.Used}
		{
			; Need to re-pick from locked target
			if ${Ship.ActiveJammerList.Used}
			{
				Ship.ActiveJammerList:GetIterator[activeJammerIterator]
				do
				{
					if ${Entity[${activeJammerIterator.Value}].IsLockedTarget} && ${Entity[${activeJammerIterator.Value}].Distance} < ${droneEngageRange}
					{
						CurrentTarget:Set[${activeJammerIterator.Value}]
						This:LogInfo["Targeting activate jammer \ar${Entity[${CurrentTarget}].Name}"]
						break
					}
				}
				while ${activeJammerIterator:Next(exists)}
			}

			if ${CurrentTarget} == 0
			{
				${MainModeSwitch}.LockedTargetList:GetIterator[lockedTargetIterator]
				do
				{
					if ${Entity[${lockedTargetIterator.Value}].Distance} < ${droneEngageRange} && \
					(!${Entity[${CurrentTarget}](exists)} || \
					(!${Ship.IsHardToDealWithTarget[${CurrentTarget}]} && (${Ship.IsHardToDealWithTarget[${lockedTargetIterator.Value}]} || ${Entity[${CurrentTarget}].Distance} > ${Entity[${lockedTargetIterator.Value}].Distance})))
					{
						CurrentTarget:Set[${lockedTargetIterator.Value}]
					}
				}
				while ${lockedTargetIterator:Next(exists)}
			}

			if ${CurrentTarget} != 0
			{
				This:LogInfo["Primary target: \ar${Entity[${CurrentTarget}].Name}"]
			}
		}

		; When neutral standings or worse are in local, scoop drones 
		if !${FriendlyLocal}
		{
			Busy:SetBusy["DroneControlCA"]
			Drones:RecallAll
			This:QueueState["Idle", 11000]
			This:QueueState["RecallCheck"]
		}
		
		if ${CurrentTarget} != 0
		{
			;;; MJD Inhibition signal from MissionTargetManager
			if ${MissionTargetManager.PreparingForMJD}
				return FALSE
				
			if ${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]} > 0 && \
			   ${Entity[${CurrentTarget}].Distance} < ${Me.DroneControlDistance}
			{
				;echo ${MaxDroneCount} drones engaging
				Drones:Engage["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE", ${CurrentTarget}]
				;ActiveDrone.ToEntity:EngageMyTarget
			}

			if ${MaxDroneCount} > ${Drones.ActiveDroneCount}
			{
				if ${MyShip.ToEntity.Type.Find[Rattlesnake]} || ${MyShip.ToEntity.Type.Find[Ishtar]}
				{
					Drones:Deploy["TypeID = ${Drones.Data.FindType[Heavy Attack Drones]}", ${Math.Calc[${MaxDroneCount} - ${Drones.ActiveDroneCount}]}]
				}
				if ${Entity[${CurrentTarget}].Distance} > ${Me.DroneControlDistance}
				{
					Drones:Deploy["TypeID = ${Drones.Data.FindType[Fighters]}", ${Math.Calc[${MaxDroneCount} - ${Drones.ActiveDroneCount}]}]
				}
				elseif ${Entity[${CurrentTarget}].Distance} > (${Config.SentryRange} * 1000) && ${Config.Sentries}
				{
					Drones:Deploy["TypeID = ${Drones.Data.FindType[Sentry Drones]}", ${Math.Calc[${MaxDroneCount} - ${Drones.ActiveDroneCount}]}]
				}
				else
				{
					Drones:Deploy["TypeID = ${This.FindBestType[${Entity[${CurrentTarget}].GroupID}]}", ${Math.Calc[${MaxDroneCount} - ${Drones.ActiveDroneCount}]}]
				}
				IsBusy:Set[TRUE]
				Busy:SetBusy["DroneControlCA"]
			}

			Drones:RefreshActiveTypes
		}
		; Going to be where we launch our salvage drones. Either we are in the salvage mode and there are wrecks and we have salvage drones, or we aren't and we need there to NOT be a current drone target, no pending drone targets, and then have wrecks + salvage drones.
		; Not sure if combat ships will ever be able to use this correctly the way I have things set but whatever.
		if ((((${CurrentTarget} == 0 || !${Entity[${CurrentTarget}](exists)}) && ${Mission.DroneTargets.TargetList.Used} == 0) || ${CommonConfig.Tehbot_Mode.Equal["Salvager"]}) && (${Salvage.WrecksToLock.TargetList.Used} > 0 && ${This.HaveSalvageDrones} > 0) && ${Entity[Name =- "Wreck"](exists)})
		{
			if ${MissionTargetManager.PreparingForMJD} && ((${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]} > 0) || (${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]} > 0))
			{
				This:LogInfo["Recalling Drones for MJD Use"]
				Drones:RecallAll
				return FALSE
			}
			; I don't want to issue salvage commands constantly to these things. You can make a drone salvage all in the area by telling it to salvage nothing, or telling it to salvage something that can't be salvaged.
			if ${CommonConfig.Tehbot_Mode.Equal["Salvager"]}
			{
				SalvageDrone:AddQueryString["GroupID = GROUP_SALVAGE_DRONE"]
				SalvageDrone:RequestUpdate
				SalvageDrone.MinLockCount:Set[1]
				SalvageDrone.MaxLockCount:Set[1]
				SalvageDrone.AutoLock:Set[TRUE]
			}
			if ${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]} > 0 && ${Drones.IdleDrone}
			{
				if ${SalvageDrone.LockedTargetList.Used} > 0 && ${CommonConfig.Tehbot_Mode.Equal["Salvager"]}
				{
					SalvageDrone.LockedTargetList.Get[1]:MakeActiveTarget
					Keyboard:Press[f]
				}
				; If our active target isn't a wreck, or it IS a cargo container, or we don't have one at all, we can issue the salvage command no problem.
				if (!${Me.ActiveTarget.Name.Find["Wreck"]} || !${Me.ActiveTarget(exists)} || ${Me.ActiveTarget.Name.Find["Cargo Container"]})
				{
					; Waiting on a solution from Amadeus for this. Can't tell salvage drones to engage it no work.
					;Drones:Engage["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE", ${CurrentTarget}]
					; For now we just use the keybind.
					Keyboard:Press[f]
				}
			}
			if ${MaxDroneCount} > ${Drones.ActiveDroneCount}
			{
				Drones:Deploy["GroupID = GROUP_SALVAGE_DRONE", ${Math.Calc[${MaxDroneCount} - ${Drones.ActiveDroneCount}]}]
				IsBusy:Set[TRUE]
				Busy:SetBusy["DroneControlCA"]
			}	
			Drones:RefreshActiveTypes
		}
		if ${CommonConfig.Tehbot_Mode.Equal["Abyssal"]}
		{
			if (${CurrentTarget} == 0 && ${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]} > 0) && !${This.JerkzPresent}
			{
				Drones:Recall["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]
				This:QueueState["Idle", 5000]
				This:QueueState["DroneControlCA"]
				return TRUE
			}
		}
		elseif ${CommonConfig.Tehbot_Mode.Equal["Mission"]}
		{
			if ${MissionTargetManager.PreparingForMJD} && ((${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]} > 0) || (${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]} > 0))
			{
				This:LogInfo["Recalling Drones for MJD Use"]
				Drones:RecallAll
				return FALSE
			}
			
			if ((${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]} > 0) && ${Salvage.WrecksToLock.TargetList.Used} == 0) && ${MissionTargetManager.TDBRowCount[DroneTargets]} > 0
			{
				Drones:Recall["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]
				This:QueueState["Idle", 5000]
				This:QueueState["DroneControlCA"]
				return TRUE
			}	
			if (${CurrentTarget} == 0 && ${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]} > 0) && ${MissionTargetManager.TDBRowCount[DroneTargets]} == 0
			{
				Drones:Recall["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]
				This:QueueState["Idle", 5000]
				This:QueueState["DroneControlCA"]
				return TRUE
			}		
		}
		else
		{
			if ((${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]} > 0) && ${Salvage.WrecksToLock.TargetList.Used} == 0)
			{
				Drones:Recall["ToEntity.GroupID = GROUP_SALVAGE_DRONE"]
				This:QueueState["Idle", 5000]
				This:QueueState["DroneControlCA"]
				return TRUE
			}	
			if (${CurrentTarget} == 0 && ${Drones.ActiveDroneCount["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]} > 0)
			{
				Drones:Recall["ToEntity.GroupID = GROUP_SCOUT_DRONE || ToEntity.GroupID = GROUP_COMBAT_DRONE"]
				This:QueueState["Idle", 5000]
				This:QueueState["DroneControlCA"]
				return TRUE
			}		
		}		
		return FALSE
	}
	
	; This member will return the number of Salvage Drones we have available. I don't know why I am doing an int instead of a bool.
	member:int HaveSalvageDrones()
	{
		variable index:item DronesInBay
		MyShip:GetDrones[DronesInBay]
		DronesInBay:RemoveByQuery[${LavishScript.CreateQuery["GroupID = GROUP_SALVAGE_DRONE"]}, FALSE]
		DronesInBay:Collapse[]
		return ${DronesInBay.Used}
	}
}
