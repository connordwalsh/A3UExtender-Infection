// Actual packages, attachment and nearby actors; sampled time is injected.
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
private _town = "a3i_aid_town"; createMarker [_town,[4500,4500,0]];
_town setMarkerShape "ELLIPSE"; _town setMarkerSize [100,100]; citiesX = [_town];
sidesX setVariable [_town,west];
private _rebelGroup = createGroup teamPlayer; private _enemyGroup = createGroup west;
private _escort = _rebelGroup createUnit ["I_soldier_F",[4510,4500,0],[],0,"NONE"];
private _enemy = _enemyGroup createUnit ["B_soldier_F",[4700,4500,0],[],0,"NONE"];
{_x enableSimulationGlobal false; _x allowDamage false} forEach [_escort,_enemy];
_escort setVariable ["spawner",true];
private _packages = []; private _records = [];
private _new = {
    params ["_name",["_hard",false]];
    private _package = createVehicle ["Land_FoodSacks_01_cargo_brown_F",[4500,4500,0],[],0,"CAN_COLLIDE"];
    _package allowDamage false; _packages pushBack _package;
    private _record = [_name,_town,_package,time+3600,_hard] call A3I_fnc_createAidLedger;
    _records pushBack _record; _record
};
private _release = {
    params ["_r"];
    [_r get "name",_r get "serial"] call A3I_fnc_releaseAidLedger;
    deleteVehicle (_r get "package");
};
private _advance = {
    params ["_r"];
    isNil {_r set ["lastCheck",time-1]; [_r] call A3I_fnc_updateAidLedger};
};
private _r = ["normal"] call _new; private _package = _r get "package";
private _anchor = objNull;
// These injected one-second samples form one deterministic scenario. Keep the
// production PFH from adding real elapsed time between a sample and its check.
// The independent-deadline case below still tests the live PFH separately.
isNil {
["aid_normal_duration",_r get "requiredSeconds" == 180] call _check;
["aid_duplicate_actor_refused",count (["duplicate",_town,_package,time+3600] call A3I_fnc_createAidLedger) == 0] call _check;
_escort setVariable ["spawner",false];
[_r] call _advance;
["aid_empty_escort_no_progress",_r get "unloadedSeconds" == 0 && {_r get "outcome" == "pending"}] call _check;
_escort setVariable ["spawner",true];
[_r] call _advance;
["aid_first_ready_sample_no_free_progress",_r get "unloadedSeconds" == 0] call _check;
[_r] call _advance;
["aid_ready_progress",_r get "unloadedSeconds" > 0 && {_r get "unloadedSeconds" <= 1}] call _check;
private _progress = _r get "unloadedSeconds";
_escort setVariable ["incapacitated",true]; [_r] call _advance;
["aid_incapacitated_escort_pauses",_r get "unloadedSeconds" == _progress] call _check;
_escort setVariable ["incapacitated",false]; [_r] call _advance;
_enemy setPosATL [4510,4510,0]; [_r] call _advance;
["aid_near_infected_pauses",_r get "unloadedSeconds" == _progress] call _check;
_enemy setPosATL [4700,4500,0]; [_r] call _advance;
_anchor = createVehicle ["Land_Can_V3_F",[4500,4500,0],[],0,"CAN_COLLIDE"];
_package attachTo [_anchor,[0,0,0.5]]; [_r] call _advance;
["aid_attached_package_pauses",_r get "unloadedSeconds" == _progress] call _check;
detach _package; _package setPosATL [4500,4500,0]; [_r] call _advance;
_package setPosATL [4550,4500,0]; [_r] call _advance;
["aid_outside_dropoff_pauses",_package distance getMarkerPos _town >= 40 && {_r get "unloadedSeconds" == _progress},[_progress,_r get "unloadedSeconds",getPosATL _package,_r get "wasEligible"]] call _check;
_package setPosATL [4500,4500,0]; [_r] call _advance;
isNil {_r set ["lastCheck",time-600]; [_r] call A3I_fnc_updateAidLedger};
["aid_stall_does_not_skip_unloading",_r get "unloadedSeconds" <= _progress+1,[_progress,_r get "unloadedSeconds",_r get "wasEligible"]] call _check;
isNil {_r set ["unloadedSeconds",179]; _r set ["wasEligible",true]; [_r] call _advance};
["aid_normal_finishes_after_unloading",_r get "outcome" == "delivered" && {_r get "unloadedSeconds" == 180}] call _check;
_r set ["deadline",time-1]; sidesX setVariable [_town,east]; [_r] call _advance;
["aid_terminal_result_frozen",_r get "outcome" == "delivered"] call _check;
[_r] call _release; sidesX setVariable [_town,west];
};
_r = ["hard",true] call _new;
["aid_difficult_duration",_r get "requiredSeconds" == 90] call _check;
isNil {_r set ["unloadedSeconds",89]; _r set ["wasEligible",true]; [_r] call _advance};
["aid_difficult_finishes_after_unloading",_r get "outcome" == "delivered"] call _check;
[_r] call _release;
{
    private _side = _x; _r = ["capture_"+str _side] call _new;
    isNil {
        _r set ["unloadedSeconds",179]; _r set ["wasEligible",true]; _r set ["deadline",time-1];
        sidesX setVariable [_town,_side]; [_r] call _advance;
    };
    ["aid_ownership_cancel_"+str _side,_r get "outcome" == "cancelled"
        && {_r get "reason" == "destination_unavailable"} && {_r get "unloadedSeconds" == 179}] call _check;
    [_r] call _release; sidesX setVariable [_town,west];
} forEach [teamPlayer,east];
_r = ["timeout"] call _new;
_r set ["deadline",time-1]; [_r] call _advance;
["aid_deadline_fails",_r get "outcome" == "failed" && {_r get "reason" == "timeout"}] call _check;
[_r] call _release;
_r = ["destroyed"] call _new; (_r get "package") setDamage 1;
private _eventUntil = diag_tickTime+3;
waitUntil {sleep 0.05; _r get "killed" || {diag_tickTime > _eventUntil}};
[_r] call _advance;
["aid_destroyed_package_fails",_r get "outcome" == "failed" && {_r get "reason" == "destroyed"} && {_r get "killed"}] call _check;
[_r] call _release;
_r = ["missing"] call _new; deleteVehicle (_r get "package");
_eventUntil = diag_tickTime+3;
waitUntil {sleep 0.05; _r get "deleted" || {diag_tickTime > _eventUntil}};
[_r] call _advance;
["aid_missing_package_not_delivery",_r get "outcome" == "interrupted" && {_r get "deleted"} && {!(_r get "killed")}] call _check;
[_r] call _release;
_r = ["foreign"] call _new; _package = _r get "package";
_package setVariable ["A3I_aidOwner",["foreign",100]]; [_r] call _advance;
["aid_reassigned_package_not_delivery",_r get "outcome" == "interrupted"] call _check;
["aid_stale_release_refused",!([_r get "name",(_r get "serial")-1] call A3I_fnc_releaseAidLedger)] call _check;
[_r get "name",_r get "serial"] call A3I_fnc_releaseAidLedger;
["aid_release_preserves_foreign_asset",alive _package && {(_package getVariable "A3I_aidOwner") isEqualTo ["foreign",100]}] call _check;
deleteVehicle _package;
_r = ["sling"] call _new; _package = _r get "package";
_package enableRopeAttach true;
private _helicopter = createVehicle ["I_Heli_Transport_02_F",[4500,4500,10],[],0,"FLY"];
_helicopter enableSimulationGlobal false;
private _rope = ropeCreate [_helicopter,[0,0,-2],_package,[0,0,0],12];
private _ropeWait = diag_tickTime+3;
waitUntil {sleep 0.05; !isNull ropeAttachedTo _package || {diag_tickTime > _ropeWait}};
private _ropeProgress = _r get "unloadedSeconds";
isNil {_r set ["wasEligible",true]; [_r] call _advance};
["aid_real_sling_prevents_unloading",!isNull _rope && {ropeAttachedTo _package == _helicopter}
    && {_r get "unloadedSeconds" == _ropeProgress} && {_r get "outcome" == "pending"}] call _check;
ropeDestroy _rope; deleteVehicle _helicopter; [_r] call _release;
_r = ["independent"] call _new; _r set ["deadline",time+0.1];
private _until = diag_tickTime+4;
waitUntil {sleep 0.1; _r get "outcome" != "pending" || {diag_tickTime > _until}};
["aid_independent_deadline_tick",_r get "outcome" == "failed"] call _check;
[_r] call _release;
["aid_handlers_retired",count A3I_aidLedgers == 0 && {isNil "A3I_aidLedgerHandle"} && {isNil "A3I_aidKilledEH"} && {isNil "A3I_aidDeletedEH"}] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _packages;
{deleteVehicle _x} forEach [_escort,_enemy,_anchor,sidesX];
deleteMarker _town; sleep 0.3; deleteGroup _rebelGroup; deleteGroup _enemyGroup; sleep 0.5;
["aid_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
