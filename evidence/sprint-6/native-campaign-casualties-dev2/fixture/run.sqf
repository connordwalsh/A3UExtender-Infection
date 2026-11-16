// Real Redux mission and native campaign startup/save/load; no contract endpoint overrides.
if (!isDedicated || {toLower worldName != "chernarusredux"}) exitWith {};
private _phase=call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\phase.sqf";
private _failed=[];private _count=0;
private _check={params ["_name","_passed",["_details",[]]];_count=_count+1;
    if (!_passed) then {_failed pushBack _name};
    diag_log format ["[INFECTION_CAMPAIGN] %1",["check",_name,_passed,_details]]};
private _finish={diag_log format ["[INFECTION_CAMPAIGN] %1",["complete",_phase,_count,_failed]]};
private _wait={params ["_condition",["_seconds",600]];private _end=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_end}};call _condition};
diag_log format ["[INFECTION_CAMPAIGN] %1",["start",_phase,worldName,productVersion,systemTimeUTC]];
private _background=[{missionNamespace getVariable ["A3A_backgroundInitDone",false]}] call _wait;
["background_ready",_background] call _check;
if (!_background) exitWith {call _finish};
// Check before JNA startup can clear or replace the HQ inventory itself.
private _hqCargo=[getWeaponCargo boxX,getMagazineCargo boxX,getItemCargo boxX,getBackpackCargo boxX];
["hq_inventory_cleared",boxX getVariable ["A3URF_hqCargoCleared",false]
    && {scriptDone (boxX getVariable ["A3URF_hqCargoWorker",scriptNull])}
    && {_hqCargo isEqualTo [[[],[]],[[],[]],[[],[]],[[],[]]]}
    && {count everyContainer boxX==0},_hqCargo] call _check;
// Read-only native module state: distinguish missing-player HC from other errors.
private _hc=missionNamespace getVariable ["BIS_HC_mainscope",objNull];
diag_log format ["[INFECTION_STARTUP] %1",["native_modules",count allPlayers,
    isNull (missionNamespace getVariable ["commanderX",objNull]),
    isNull _hc,(synchronizedObjects _hc) apply {[typeOf _x,netId _x]},
    (allMissionObjects "Logic") apply {[typeOf _x,netId _x]},
    isNil "BIS_OM_SmartMarkers_logic"]];
["empty_hc_deferred",!isNull _hc && {
    !scriptDone (_hc getVariable ["A3URF_hcWorker",scriptNull])
} && {isNil {_hc getVariable "A3URF_hcNative"}} && {isNil "BIS_MARTA_mainScope"}] call _check;
private _curators=allCurators;
private _active=activatedAddons apply {toLower _x};
private _curatorAddons=if (count _curators==1) then {curatorAddons (_curators select 0) apply {toLower _x}} else {[]};
["curator_addons_preserved",count _curators==1 && {count _active>0} && {count (_active - _curatorAddons)==0},[count _active,count _curatorAddons]] call _check;
private _receipt=missionProfileNamespace getVariable ["A3I_campaignProbeReceipt",createHashMap];
private _new=_phase=="write";
private _selection=createHashMap;
if (_new) then {
    ["fresh_profile",count _receipt==0] call _check;
    if (count _receipt==0) then {
        _selection=createHashMapFromArray [
            ["startType","new"],["name","Infection isolated campaign persistence"],
            ["startPos",markerPos "Synd_HQ"],["useNewNamespace",true],
            ["factions",["A3I_Infected","Vanilla_CSAT_Temperate","Vanilla_FIA","Vanilla_Civ","Vanilla_Exegermenos"]],
            ["addonVics",[]],["DLC",[]],["params",createHashMap]
        ];
    };
} else {
    ["saved_receipt_present",count _receipt>0] call _check;
    if (count _receipt>0) then {
        private _stored=missionProfileNamespace getVariable [format ["A3A_saveData_%1",_receipt get "gameID"],createHashMap];
        _selection=createHashMapFromArray [["startType","load"],["name",_stored get "name"],
            ["gameID",_receipt get "gameID"],["serverID",false],["useNewNamespace",true],
            ["factions",_stored get "factions"],["addonVics",_stored get "addonVics"],
            ["DLC",_stored get "DLC"],["params",_stored get "params"]];
    };
};
if (count _selection==0) exitWith {call _finish};
[_selection] call A3A_fnc_startGame;
private _initialized=[{missionNamespace getVariable ["serverInitDone",false]},900] call _wait;
["campaign_initialized",_initialized,[missionNamespace getVariable ["A3A_startupState",""]]] call _check;
if (!_initialized) exitWith {call _finish};
["infection_selected",[west] call A3I_fnc_isActive] call _check;
["native_hq_ready",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
private _helicopter="O_Heli_Light_02_dynamicLoadout_F";
private _expectedQuote=[_helicopter] call A3U_fnc_blackMarketVehiclePrice;
private _actualQuote=[_helicopter] call A3A_fnc_vehiclePrice;
["black_market_only_hq_absent",isNil {server getVariable _helicopter}] call _check;
["black_market_only_native_quote",_expectedQuote>0 && {_actualQuote==_expectedQuote},[_actualQuote,_expectedQuote]] call _check;
private _parkingSites=[
    ["outpost_6","outp_6_vehicle"],["resource_1","reso_1_vehicle_1"],
    ["resource_2","reso_2_vehicle_1"],["resource_3","reso_3_vehicle_1"],
    ["resource_7","reso_7_vehicle_1"],["resource_10","reso_10_vehicle_1"]
];
private _parkingCounts=_parkingSites apply {
    _x params ["_site","_parking"];
    [_site,{(_x # 0) inArea _parking} count (spawner getVariable [_site+"_vehicle_places",[]])]
};
["redux_parking_slots",(_parkingCounts findIf {(_x # 1)!=1})==-1,[_parkingCounts]] call _check;
["redux_orphan_reconnected",!("reso_13_vehicle_1" in allMapMarkers)
    && {"reso_10_vehicle_1" in allMapMarkers}
    && {isNil {spawner getVariable "resource_13_vehicle_places"}}] call _check;
sleep 5;
if (_new) then {
    private _towns=citiesX select {sidesX getVariable [_x,sideUnknown]==west};
    private _admins=milAdministrationsX select {sidesX getVariable [_x,sideUnknown]==west};
    ["real_sites_available",count _towns>0 && {count _admins>0},[count _towns,count _admins]] call _check;
    if (count _towns>0 && {count _admins>0}) then {
        private _town=_towns # 0;private _admin=_admins # 0;
        private _role=(A3A_faction_occ get "groupPoliceTeam") # 0;
        private _townRoster=[_role,_role,_role];private _adminRoster=[_role,_role];
        garrison setVariable [_town,_townRoster,true];garrison setVariable [_admin,_adminRoster,true];
        // Controlled native unlock trigger in this isolated test campaign only.
        [respawnTeamPlayer] call A3A_fnc_ENC_Trader;
        private _unlocked=[{missionNamespace getVariable ["isTraderQuestCompleted",false]},90] call _wait;
        ["dealer_unlocked",_unlocked && {!isNull traderX}] call _check;
        _receipt=createHashMapFromArray [["gameID",A3A_saveTarget # 1],["town",_town],["admin",_admin],
            ["townRoster",_townRoster],["adminRoster",_adminRoster],["traderPosition",traderPosition],
            ["hq",getPosATL petros],["writtenUTC",systemTimeUTC]];
        // One real utility crate checks native reimbursement, not just a price getter.
        private _crateClass=A3A_faction_reb get "lootCrate";
        private _crate=createVehicle [_crateClass,(getPosATL petros) vectorAdd [4,0,0],[],0,"CAN_COLLIDE"];
        private _crateCount=count (allMissionObjects _crateClass);
        private _initialFunds=server getVariable "resourcesFIA";
        private _expectedFunds=_initialFunds+_crateCount*lootCratePrice;
        ["loot_crate_fixture",!isNull _crate && {_crateCount==1}
            && {!(missionNamespace getVariable ["isRallyPointPlaced",false])},
            [_crateCount,lootCratePrice,_initialFunds]] call _check;
        _receipt set ["expectedFunds",_expectedFunds];
        // saveLoop and all registered campaign plugin listeners run unmodified.
        private _saveHandle=[] spawn A3A_fnc_saveLoop;
        private _saved=[{scriptDone _saveHandle && {!(missionNamespace getVariable ["savingServer",true])}},180] call _wait;
        ["native_save_completed",_saved] call _check;
        private _data=missionProfileNamespace getVariable [format ["A3A_saveData_%1",A3A_saveTarget # 1],createHashMap];
        ["native_save_has_campaign",count _data>30 && {_data getOrDefault ["campaignID",""]==A3A_saveTarget # 1},[count _data]] call _check;
        ["loot_crate_refund_exact",(_data getOrDefault ["resourcesFIA",-1])==_expectedFunds
            && {(server getVariable "resourcesFIA")==_initialFunds},
            [_data getOrDefault ["resourcesFIA",-1],_expectedFunds]] call _check;
        if (_saved && {count _data>30}) then {
            missionProfileNamespace setVariable ["A3I_campaignProbeReceipt",_receipt];saveMissionProfileNamespace;
        };
        deleteVehicle _crate;
    };
} else {
    ["town_extras_restored",garrison getVariable [_receipt get "town",[]] isEqualTo (_receipt get "townRoster")] call _check;
    ["admin_extras_restored",([_receipt get "admin"] call A3I_fnc_siteExtraRoster) isEqualTo (_receipt get "adminRoster")] call _check;
    ["dealer_restored",isTraderQuestCompleted && {!isTraderQuestAssigned} && {!isNull traderX}
        && {traderPosition isEqualTo (_receipt get "traderPosition")}] call _check;
    ["hq_restored",petros distance2D (_receipt get "hq") < 5] call _check;
    ["save_identity_restored",A3A_saveTarget # 1 == _receipt get "gameID"] call _check;
    ["saved_crate_resources_restored",(server getVariable "resourcesFIA")==(_receipt get "expectedFunds"),
        [server getVariable "resourcesFIA",_receipt get "expectedFunds"]] call _check;
};
// The original helicopter error occurred after the old completion marker.
// Keep a deliberate background observation window in this expanded regression.
private _backgroundWindowStart=diag_tickTime;
sleep 75;
["background_window_completed",diag_tickTime-_backgroundWindowStart>=75,[diag_tickTime-_backgroundWindowStart]] call _check;
if (call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\site-mode.sqf") then {
    call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\sites.sqf";
};
if (call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\casualty-mode.sqf") then {
    call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\casualties.sqf";
};
call _finish;
