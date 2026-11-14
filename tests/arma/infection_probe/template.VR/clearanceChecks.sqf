// Real engine Killed/Deleted events around a controlled site record. This
// verifies the ledger contract, not Liquidation's not-yet-connected lifecycle.
private _saved = createHashMap;
{_saved set [_x,missionNamespace getVariable [_x,nil]]} forEach ["sidesX","spawner","garrison","A3I_sites"];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
A3I_sites = createHashMap;
private _marker = "a3i_clearance_fixture";
createMarker [_marker,[4000,4000,0]];
sidesX setVariable [_marker,west]; spawner setVariable [_marker,0];
garrison setVariable [_marker,[]];
private _group = createGroup [west,false];
private _actors = [];
private _worker = [] spawn {sleep 120};
private _record = createHashMapFromArray [["id",1],["kind","City"],["context","site:" + _marker],
    ["cleaned",false],["fault",""],["script",_worker],["queue",["queued"]],
    ["units",[]],["clearanceRemaining",2],["clearanceMissing",0]];
A3I_sites set [_marker,_record];
private _newUnit = {
    private _unit = _group createUnit ["B_Soldier_F",[4000,4000,0],[],0,"NONE"];
    _unit disableAI "ALL"; _actors pushBack _unit;
    [_unit,_marker,"site:" + _marker] call A3I_fnc_trackSiteDefender;
    (_record get "units") pushBack _unit;
    _unit
};
private _first = call _newUnit;
private _second = call _newUnit;
["clearance_queue_blocks",([_marker] call A3I_fnc_siteClearance) isEqualTo [false,"queued_defenders",2]] call _check;
_record set ["queue",[]];
["clearance_living_blocks",([_marker] call A3I_fnc_siteClearance) isEqualTo [false,"remaining_defenders",2]] call _check;
["clearance_duplicate_tracking_rejected",!([_first,_marker,"site:" + _marker] call A3I_fnc_trackSiteDefender)] call _check;
["Killed",_first] call A3I_fnc_siteDefenderEvent;
["clearance_direct_event_rejected",_record get "clearanceRemaining" == 2] call _check;
_first setDamage 1; sleep 0.1;
["clearance_death_counts_once",_record get "clearanceRemaining" == 1
    && {([_marker] call A3I_fnc_siteClearance) # 0 isEqualTo false}] call _check;
deleteVehicle _first; sleep 0.1;
["clearance_corpse_deletion_not_second_kill",_record get "clearanceRemaining" == 1
    && {_record get "clearanceMissing" == 0}] call _check;
_second setDamage 1; sleep 0.1;
["clearance_all_dead_ready",([_marker] call A3I_fnc_siteClearance) isEqualTo [true,"",0]] call _check;
_record set ["kind","Outpost"]; garrison setVariable [_marker,["pending_native_update"]];
["clearance_native_garrison_update_wait",([_marker] call A3I_fnc_siteClearance) isEqualTo [false,"garrison_pending",0]] call _check;
garrison setVariable [_marker,[]];
["clearance_persistent_ready",([_marker] call A3I_fnc_siteClearance) isEqualTo [true,"",0]] call _check;
_record set ["clearanceRemaining",1];
private _deletedAlive = call _newUnit;
deleteVehicle _deletedAlive; sleep 0.1;
["clearance_live_deletion_not_kill",_record get "clearanceRemaining" == 1
    && {([_marker] call A3I_fnc_siteClearance) isEqualTo [false,"missing_defender",1]}] call _check;
_record set ["clearanceMissing",0]; _record set ["kind","MilAdmin"];
private _replaced = call _newUnit;
deleteVehicle _replaced; sleep 0.1;
["clearance_admin_replacement_retains_obligation",_record get "clearanceRemaining" == 1
    && {_record get "clearanceMissing" == 0}] call _check;
private _replacement = call _newUnit;
_replacement setDamage 1; sleep 0.1;
["clearance_replacement_death_resolves",_record get "clearanceRemaining" == 0] call _check;
_record set ["kind","City"]; _record set ["clearanceRemaining",1];
private _stale = call _newUnit;
_record set ["id",2];
_stale setDamage 1; sleep 0.1;
["clearance_old_visit_event_ignored",_record get "clearanceRemaining" == 1] call _check;
private _cleanupActor = call _newUnit;
_record set ["cleaned",true]; deleteVehicle _cleanupActor; sleep 0.1;
["clearance_cleanup_does_not_mutate_ledger",_record get "clearanceRemaining" == 1 && {_record get "clearanceMissing" == 0}] call _check;
_record set ["cleaned",false]; _record set ["clearanceRemaining",0];
spawner setVariable [_marker,2];
["clearance_despawn_not_clearance",([_marker] call A3I_fnc_siteClearance) # 1 == "site_not_active"] call _check;
spawner setVariable [_marker,0]; sidesX setVariable [_marker,east];
["clearance_other_owner_rejected",([_marker] call A3I_fnc_siteClearance) # 1 == "ownership"] call _check;
sidesX setVariable [_marker,west]; _record set ["fault","test_fault"];
["clearance_fault_rejected",([_marker] call A3I_fnc_siteClearance) # 1 == "site_fault"] call _check;
_record set ["fault",""]; _record deleteAt "clearanceRemaining";
["clearance_missing_ledger_rejected",([_marker] call A3I_fnc_siteClearance) # 1 == "ledger_unavailable"] call _check;
_record set ["clearanceRemaining",0]; terminate _worker; sleep 0.1;
["clearance_stopped_controller_rejected",([_marker] call A3I_fnc_siteClearance) # 1 == "controller_unavailable"] call _check;
_record set ["cleaned",true];
{deleteVehicle _x} forEach _actors;
sleep 0.1; deleteGroup _group; deleteMarker _marker;
{deleteVehicle (missionNamespace getVariable _x); missionNamespace setVariable [_x,_saved get _x]} forEach ["sidesX","spawner","garrison"];
missionNamespace setVariable ["A3I_sites",_saved get "A3I_sites"];
