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
        // saveLoop and all registered campaign plugin listeners run unmodified.
        private _saveHandle=[] spawn A3A_fnc_saveLoop;
        private _saved=[{scriptDone _saveHandle && {!(missionNamespace getVariable ["savingServer",true])}},180] call _wait;
        ["native_save_completed",_saved] call _check;
        private _data=missionProfileNamespace getVariable [format ["A3A_saveData_%1",A3A_saveTarget # 1],createHashMap];
        ["native_save_has_campaign",count _data>30 && {_data getOrDefault ["campaignID",""]==A3A_saveTarget # 1},[count _data]] call _check;
        if (_saved && {count _data>30}) then {
            missionProfileNamespace setVariable ["A3I_campaignProbeReceipt",_receipt];saveMissionProfileNamespace;
        };
    };
} else {
    ["town_extras_restored",garrison getVariable [_receipt get "town",[]] isEqualTo (_receipt get "townRoster")] call _check;
    ["admin_extras_restored",([_receipt get "admin"] call A3I_fnc_siteExtraRoster) isEqualTo (_receipt get "adminRoster")] call _check;
    ["dealer_restored",isTraderQuestCompleted && {!isTraderQuestAssigned} && {!isNull traderX}
        && {traderPosition isEqualTo (_receipt get "traderPosition")}] call _check;
    ["hq_restored",petros distance2D (_receipt get "hq") < 5] call _check;
    ["save_identity_restored",A3A_saveTarget # 1 == _receipt get "gameID"] call _check;
};
call _finish;
