// Isolated native field/plugin serialization across process restart, not full saveLoop/loadServer acceptance.
#include "\x\a3a\addons\core\script_component.hpp"
private _before=entities [[],[],true,false];private _simpleBefore=allSimpleObjects [];private _groupsBefore=+allGroups;
private _admin="a3i_disk_admin";private _town="a3i_disk_town";
sidesX=[true] call A3A_fnc_createNamespace;garrison=[true] call A3A_fnc_createNamespace;
{createMarker [_x,[4000,4000,0]];sidesX setVariable [_x,west]} forEach [_admin,_town];
milAdministrationsX=[_admin];citiesX=[_town];
private _roles=keys (A3A_faction_occ get "loadouts");_roles sort true;
private _role="loadouts_occ_"+(_roles # 0);
private _townRoster=[_role,_role,_role];private _adminRoster=[_role,_role];
A3A_faction_inv=createHashMap;A3A_faction_reb=createHashMap;A3A_faction_civ=createHashMap;
call A3I_fnc_registerPersistence;
A3A_saveTarget=[false,"infection-disk-v2",worldName];
A3A_saveDataHM=nil;
private _saveKey="A3A_saveData_infection-disk-v2";
private _dealerPos=[5000,5000,0];
if (_suite=="persistencewrite") then {
    private _fresh=isNil {missionProfileNamespace getVariable _saveKey};
    ["disk_write_fresh",_fresh] call _check;
    if (_fresh) then {
        garrison setVariable [_admin,_adminRoster];garrison setVariable [_town,_townRoster];
        private _plugins=createHashMapFromArray [["other_plugin",["retained",17]]];
        [CBA_EVENT_SERVER_GAME_SAVE,[_plugins]] call A3A_fnc_triggerLocalEvent;
        ["disk_write_plugin_rows",(_plugins getOrDefault ["A3I_administrationExtras",[]]) isEqualTo [1,[[_admin,_adminRoster]]]] call _check;
        _plugins=compileFinal _plugins; // Match native saveLoop read-only plugin payload.
        A3A_saveDataHM=createHashMap;
        { _x call A3A_fnc_setStatVariable } forEach [
            ["saveDataPlugins",_plugins],["garrison",[[_town,_townRoster]]],
            ["isTraderQuestAssigned",false],["isTraderQuestCompleted",true],["traderPosition",_dealerPos],
            ["antennas",[[6000,6000,0]]],["A3I_diskWrittenUTC",systemTimeUTC]
        ];
        ["disk_write_native_store",count A3A_saveDataHM==7 && {A3A_saveDataHM get "garrison" isEqualTo [[_town,_townRoster]]},[keys A3A_saveDataHM]] call _check;
        // Same single-hashmap namespace layout used at the end of native saveLoop.
        missionProfileNamespace setVariable [_saveKey,A3A_saveDataHM];A3A_saveDataHM=nil;
        ["A3I_diskComplete",true] call A3A_fnc_writebackSaveVar;
        ["disk_write_saved",["A3I_diskComplete"] call A3A_fnc_returnSavedStat,[systemTimeUTC]] call _check;
    };
} else {
    private _stored=missionProfileNamespace getVariable [_saveKey,createHashMap];
    private _present=count _stored>0 && {_stored getOrDefault ["A3I_diskComplete",false]};
    ["disk_read_present",_present,[_stored getOrDefault ["A3I_diskWrittenUTC",[]],systemTimeUTC]] call _check;
    if (_present) then {
        private _plugins=["saveDataPlugins"] call A3A_fnc_returnSavedStat;
        if (_plugins isEqualType []) then {_plugins=createHashMapFromArray _plugins};
        ["disk_read_plugin_rows",(_plugins getOrDefault ["A3I_administrationExtras",[]]) isEqualTo [1,[[_admin,_adminRoster]]]
            && {_plugins getOrDefault ["other_plugin",[]] isEqualTo ["retained",17]}] call _check;
        // Match loadServer order: plugin event before native garrison field restoration.
        [CBA_EVENT_SERVER_GAME_LOAD,[_plugins]] call A3A_fnc_triggerLocalEvent;
        ["garrison"] call A3A_fnc_getStatVariable;
        ["disk_read_town_roster",garrison getVariable [_town,[]] isEqualTo _townRoster] call _check;
        ["disk_read_admin_roster",([_admin] call A3I_fnc_siteExtraRoster) isEqualTo _adminRoster] call _check;
        [CBA_EVENT_SERVER_GAME_LOAD,[_plugins]] call A3A_fnc_triggerLocalEvent;
        ["disk_read_no_duplicates",([_admin] call A3I_fnc_siteExtraRoster) isEqualTo _adminRoster] call _check;
        isTraderQuestAssigned=true;isTraderQuestCompleted=false;
        {[_x] call A3A_fnc_getStatVariable} forEach ["isTraderQuestAssigned","isTraderQuestCompleted"];
        ["disk_read_dealer_flags",!isTraderQuestAssigned && {isTraderQuestCompleted}] call _check;
        disableTrader=false;
        A3A_Reb_template="Vanilla_NATO";A3A_enabledDLC=[];vanillaArmsDealer=true;A3A_factionEquipFlags=[];
        jna_dataList=[];for "_i" from 0 to 63 do {jna_dataList pushBack []};
        traderObjects=[];traderX=objNull;traderPosition=[];A3I_test_dealerMarketCalls=[];
        ["traderPosition"] call A3A_fnc_getStatVariable;
        ["disk_read_dealer_recreated",!isNull traderX && {alive traderX} && {traderPosition isEqualTo _dealerPos}
            && {traderX distance2D _dealerPos < 5}] call _check;
        ["disk_read_other_fields",(["antennas"] call A3A_fnc_returnSavedStat) isEqualTo [[6000,6000,0]]] call _check;
    };
};
{deleteVehicle _x} forEach ((entities [[],[],true,false]) - _before);
{deleteVehicle _x} forEach ((allSimpleObjects []) - _simpleBefore);
{deleteGroup _x} forEach (allGroups - _groupsBefore);
{deleteMarker _x} forEach [_admin,_town];sleep 1;
if (_suite=="persistenceread") then {
    ["disk_read_cleanup",((entities [[],[],true,false]) - _before) isEqualTo []
        && {((allSimpleObjects []) - _simpleBefore) isEqualTo []}] call _check;
};
