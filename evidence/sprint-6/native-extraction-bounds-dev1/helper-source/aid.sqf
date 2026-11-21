// Real campaign request and native ownership cancellation. No player/UI claim.
private _checks=0;private _failures=[];
private _check={params ["_name","_ok",["_details",[]]];
    _checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_CAMPAIGN_AID] %1",["check",_name,_ok,_details]];
};
private _wait={params ["_condition",["_seconds",180]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};call _condition
};
private _finish={diag_log format ["[INFECTION_CAMPAIGN_AID] %1",["complete",_checks,_failures]]};
diag_log "[INFECTION_CAMPAIGN_AID] start";
private _targets=call A3I_fnc_aidTargets;
["eligible_targets",_targets isNotEqualTo [],[_targets]] call _check;
if (_targets isEqualTo []) exitWith {call _finish};
private _serial=missionNamespace getVariable ["A3I_aidTaskSerial",0];
["SUPP",2,true] spawn A3A_fnc_missionRequest;
private _dispatched=[{(missionNamespace getVariable ["A3I_aidTaskSerial",0])>_serial}] call _wait;
["public_dispatch",_dispatched] call _check;
if (!_dispatched) exitWith {call _finish};
private _name="A3I_AID_"+str A3I_aidTaskSerial;
private _record=A3I_aidTasks get _name;
private _registered=[{_record get "taskRegistered" || {_record get "settled"}}] call _wait;
["task_registered",_registered && {_record get "taskRegistered"} && {_record get "fault"==""},[_record get "fault"]] call _check;
if !(_record get "taskRegistered") exitWith {call _finish};
private _target=_record get "target";private _package=_record get "package";private _ledger=_record get "ledger";
private _pickup=_record get "pickupMarker";
["infected_target",_target in _targets && {sidesX getVariable _target==west},[_target]] call _check;
["native_package",alive _package && {typeOf _package=="Land_FoodSacks_01_cargo_brown_F"}
    && {[_package] call A3A_Logistics_fnc_isLoadable} && {_pickup in allMapMarkers},[getPosATL _package]] call _check;
["native_task_created",[_name] call BIS_fnc_taskState=="CREATED"
    && {(A3A_tasksData findIf {_x # 0==_name && {_x # 1=="SUPP"} && {_x # 2=="CREATED"}})>=0}] call _check;
sleep 5;
["hq_package_paused",_ledger get "unloadedSeconds"==0 && {!(_record get "settled")}] call _check;
if (call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\aid-success-mode.sqf") exitWith {
    [_record,_check,_wait] call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\aidSuccess.sqf";
    call _finish;
};
private _funds=server getVariable "resourcesFIA";private _hr=server getVariable "hr";
private _support=+(A3A_townData get _target);
// Capture through the actual transaction, not a replacement ledger/side endpoint.
private _capture=[Invaders,_target] spawn A3A_fnc_markerChange;
private _changed=[{scriptDone _capture && {sidesX getVariable _target==Invaders}},90] call _wait;
["native_town_capture",_changed] call _check;
private _settled=[{_record get "settled"},30] call _wait;
["ownership_cancelled",_settled && {_record get "outcome"=="cancelled"}
    && {_ledger get "reason"=="destination_unavailable"}] call _check;
private _retired=[{_record get "assetRetired" && {_record get "taskRetired"} && {isNull _package}
    && {!(_name in A3I_aidTasks)}},30] call _wait;
["native_cleanup",_retired && {!(_pickup in allMapMarkers)}] call _check;
["native_task_removed",!([_name] call BIS_fnc_taskExists) && {(A3A_tasksData findIf {_x # 0==_name})==-1}] call _check;
["supply_lock_released",isNil "A3I_aidSupplyLock" && {isNil "A3A_supplyMissionActive"} && {!(call A3I_fnc_aidTaskBusy)}] call _check;
["no_support_penalty",(A3A_townData get _target) isEqualTo _support,[_support,A3A_townData get _target]] call _check;
["no_resource_penalty",server getVariable "resourcesFIA"==_funds && {server getVariable "hr"==_hr}] call _check;
["captured_town_ineligible",!(_target in (call A3I_fnc_aidTargets))] call _check;
["hq_intact",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
call _finish;
