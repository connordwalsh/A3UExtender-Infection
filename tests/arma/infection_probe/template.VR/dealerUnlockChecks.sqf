// Actual native trader, stock, market action and campaign fields; no connected buyer.
private _before=entities [[],[],true,false];private _groupsBefore=+allGroups;
private _simpleBefore=allSimpleObjects [];
sidesX=[true] call A3A_fnc_createNamespace;
private _source="a3i_dealer_source";respawnTeamPlayer="a3i_dealer_hq";
createMarker [_source,[6000,6000,0]];createMarker [respawnTeamPlayer,[5000,5000,0]];
controlsX=[_source];airportsX=[];milbases=[];outposts=[];seaports=[];factories=[];resourcesX=[];
sidesX setVariable [_source,west];distanceMission=3000;hcArray=[];
isTraderQuestAssigned=false;isTraderQuestCompleted=false;disableTrader=false;
A3A_Reb_template="Vanilla_NATO";A3A_enabledDLC=[];vanillaArmsDealer=true;A3A_factionEquipFlags=[];
jna_dataList=[];for "_i" from 0 to 63 do {jna_dataList pushBack []};
traderObjects=[];traderX=objNull;traderPosition=[];
A3A_tasksData=[];A3A_activeTasks=[];A3A_taskCount=0;A3I_test_originals=[];A3I_test_markerUpdates=[];A3I_test_dealerMarketCalls=[];
private _wait={params ["_condition",["_seconds",20]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 0.05;call _condition || {diag_tickTime>_until}};call _condition};
private _saved=A3A_faction_occ;A3A_faction_occ=createHashMap;
[_source] call A3A_fnc_ENC_Trader;
["dealer_native_delegation",A3I_test_originals isEqualTo [["originalENCTrader",[_source]]]] call _check;
A3A_faction_occ=_saved;A3I_test_originals=[];
["dealer_no_startup_unlock",!isTraderQuestCompleted && {isNull traderX}] call _check;
disableTrader=true;[_source] call A3A_fnc_ENC_Trader;sleep 0.5;
["dealer_disabled_no_spawn",!isTraderQuestCompleted && {isNull traderX} && {!isTraderQuestAssigned}] call _check;
disableTrader=false;isTraderQuestAssigned=true;
["missing_source"] call A3A_fnc_ENC_Trader;sleep 0.5;
["dealer_invalid_source_releases_lock",!isTraderQuestAssigned && {isNull traderX} && {!isTraderQuestCompleted}] call _check;
[_source] remoteExecCall ["A3I_fnc_unlockDealer",2];sleep 0.2;
["dealer_remote_worker_refused",isNull traderX && {!isTraderQuestCompleted}] call _check;
private _failureBefore=entities [[],[],true,false];
_source setMarkerShape "RECTANGLE";_source setMarkerSize [worldSize,worldSize];outposts=[_source];
isTraderQuestAssigned=true;private _failedStart=diag_tickTime;
[_source] call A3A_fnc_ENC_Trader;
[{!isTraderQuestAssigned},20] call _wait;
["dealer_no_safe_position_retries",!isTraderQuestAssigned && {isNull traderX} && {!isTraderQuestCompleted}
    && {entities [[],[],true,false]-_failureBefore isEqualTo []}
    && {diag_tickTime-_failedStart<20},[diag_tickTime-_failedStart]] call _check;
_source setMarkerShape "ICON";_source setMarkerSize [1,1];outposts=[];
// Exercise the real normal-trigger preparer and the scheduler override together.
[] call SCRT_fnc_trader_prepareTraderQuest;
[_source] call A3A_fnc_ENC_Trader;
[{isTraderQuestCompleted},30] call _wait;
["dealer_native_trigger_unlocks",isTraderQuestCompleted && {!isNull traderX} && {alive traderX}] call _check;
["dealer_no_intro_task",A3A_tasksData isEqualTo [] && {A3A_activeTasks isEqualTo []}
    && {A3A_taskCount==0} && {!("TraderMarkerVague" in allMapMarkers)}] call _check;
["dealer_native_stock",count (traderX getVariable ["HALs_store_trader_stocks",[]])>0
    && {"vanilla" in (traderX getVariable ["HALs_store_trader_type",[]])}] call _check;
[{A3I_test_dealerMarketCalls isNotEqualTo []},3] call _wait;
["dealer_market_dispatch",A3I_test_dealerMarketCalls isEqualTo [[[traderX],true,2]]] call _check;
["dealer_save_fields",count traderPosition>=2 && {traderMarker=="TraderMarker"}
    && {getMarkerPos traderMarker distance2D traderPosition<1} && {!isTraderQuestAssigned}
    && {sidesX getVariable [traderMarker,sideUnknown]==teamPlayer}] call _check;
["dealer_native_scene",count traderObjects>=8 && {side group traderX==civilian}] call _check;
private _first=traderX;private _objects=+traderObjects;
[_source] call A3A_fnc_ENC_Trader;
[[_source],"A3A_fnc_ENC_Trader"] call A3A_fnc_scheduler;
[] call SCRT_fnc_trader_prepareTraderQuest;sleep 0.5;
["dealer_duplicate_no_scene",traderX isEqualTo _first && {traderObjects isEqualTo _objects}
    && {count ((allUnits-_before) select {typeOf _x=="C_Nikos"})==1}] call _check;
["dealer_server_owned",local traderX && {owner traderX==2}] call _check;
["dealer_worker_retired",isNil "A3I_dealerUnlockHandle"] call _check;
["dealer_endpoint_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> "ENC_Trader" >> "file")
    == "\x\a3i\addons\core\overrides\fn_ENC_Trader.sqf"] call _check;
private _traderGroup=group traderX;
{ {deleteVehicle _x} forEach attachedObjects _x;deleteVehicle _x } forEach (traderObjects+[traderX]);
deleteGroup _traderGroup;deleteVehicle sidesX;
{deleteMarker _x} forEach [_source,respawnTeamPlayer,"TraderMarker"];
sleep 1;
["dealer_fixture_cleanup",entities [[],[],true,false]-_before isEqualTo []
    && {allGroups-_groupsBefore isEqualTo []} && {allSimpleObjects []-_simpleBefore isEqualTo []}] call _check;
traderX=objNull;traderObjects=[];traderPosition=[];isTraderQuestCompleted=false;isTraderQuestAssigned=false;
