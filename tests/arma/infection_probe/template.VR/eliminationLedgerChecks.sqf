// Real approved special classes and native death/deletion events. No public mission.
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
private _classes = call A3I_fnc_eliminationClasses;
["elim_initial_roster",_classes isEqualTo ["Zombie_Special_BLUFOR_Screamer","Zombie_Special_BLUFOR_Boomer","Zombie_Special_BLUFOR_Leaper_2"]] call _check;
private _saved = A3A_faction_occ; A3A_faction_occ = createHashMap;
["elim_inactive_roster",call A3I_fnc_eliminationClasses isEqualTo []] call _check;
A3A_faction_occ = _saved;
private _wait = {
    params ["_condition",["_seconds",8]]; private _until = diag_tickTime+_seconds;
    waitUntil {sleep 0.05; call _condition || {diag_tickTime > _until}};
    call _condition
};
private _new = {
    params ["_name",["_class","Zombie_Special_BLUFOR_Leaper_2"]];
    private _group = createGroup [west,true];
    private _unit = _group createUnit [_class,[1000,1000,0],[],0,"NONE"];
    private _record = [_name,_unit,time+3600] call A3I_fnc_createEliminationLedger;
    [{!isNil {_unit getVariable "WBK_AI_ISZombie"}},10] call _wait;
    sleep 2;
    _record
};
private _retire = {
    params ["_record"];
    [_record get "name",_record get "serial"] call A3I_fnc_releaseEliminationLedger;
    deleteVehicle (_record get "unit");
    sleep 0.3;
    {if (units _x isEqualTo []) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
};
// Complete cleanup between native special trials also removes their owned effects.
private _clearTrial = {
    {deleteVehicle _x} forEach ((entities [[],[],true,false]) - _before);
    sleep 0.3;
    {if (units _x isEqualTo []) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
    sleep 1;
};
{
    private _record = ["death_"+_x,_x] call _new; private _unit = _record get "unit";
    ["elim_prepared_"+_x,count _record > 0 && {alive _unit} && {local _unit}
        && {side group _unit == west} && {_unit getVariable ["WBK_AI_ISZombie",false]}] call _check;
    _unit setDamage 1;
    [{_record get "killedAt" >= 0 || {_record get "outcome" != "pending"}}] call _wait;
    [_record] call A3I_fnc_updateEliminationLedger;
    ["elim_death_"+_x,_record get "outcome" == "neutralized" && {_record get "killedAt" >= 0}] call _check;
    deleteVehicle _unit; [{isNull _unit}] call _wait;
    [_record] call A3I_fnc_updateEliminationLedger;
    ["elim_corpse_deletion_"+_x,_record get "outcome" == "neutralized"] call _check;
    [_record] call _retire; call _clearTrial;
} forEach _classes;
private _record = ["guards"] call _new; private _unit = _record get "unit";
["elim_duplicate_actor",count (["another",_unit,time+3600] call A3I_fnc_createEliminationLedger) == 0] call _check;
[_record get "name",_record get "serial"] call A3I_fnc_releaseEliminationLedger;
["elim_invalid_deadline",count (["expired",_unit,time-1] call A3I_fnc_createEliminationLedger) == 0] call _check;
_record = ["guards",_unit,time+3600] call A3I_fnc_createEliminationLedger;
["elim_living_kill_refused",!([_unit,"killed"] call A3I_fnc_eliminationTargetEvent)
    && {_record get "killedAt" == -1}] call _check;
[_unit,"killed"] remoteExecCall ["A3I_fnc_eliminationTargetEvent",2]; sleep 0.2;
["elim_remote_event_refused",_record get "killedAt" == -1 && {_record get "outcome" == "pending"}] call _check;
["elim_stale_release_refused",!([_record get "name",(_record get "serial")-1] call A3I_fnc_releaseEliminationLedger)] call _check;
private _foreign = ["another_owner",9999]; _unit setVariable ["A3I_eliminationOwner",_foreign];
[_record] call A3I_fnc_updateEliminationLedger;
["elim_reassigned_not_kill",_record get "outcome" == "interrupted"] call _check;
[_record get "name",_record get "serial"] call A3I_fnc_releaseEliminationLedger;
["elim_release_preserves_foreign_actor",alive _unit && {(_unit getVariable ["A3I_eliminationOwner",[]]) isEqualTo _foreign}] call _check;
call _clearTrial;
_record = ["disappeared"] call _new; _unit = _record get "unit";
deleteVehicle _unit; [{_record get "outcome" != "pending"}] call _wait;
["elim_live_deletion_no_credit",_record get "outcome" == "interrupted" && {_record get "killedAt" == -1}] call _check;
[_record] call _retire; call _clearTrial;
_record = ["deadline"] call _new;
_record set ["deadline",time-1]; [{_record get "outcome" != "pending"}] call _wait;
["elim_independent_timeout",_record get "outcome" == "failed" && {_record get "reason" == "timeout"}] call _check;
(_record get "unit") setDamage 1; sleep 0.2; [_record] call A3I_fnc_updateEliminationLedger;
["elim_terminal_frozen",_record get "outcome" == "failed"] call _check;
[_record] call _retire; call _clearTrial;
_record = ["lateDeath"] call _new; _unit = _record get "unit";
isNil {_record set ["deadline",time-0.1]; _unit setDamage 1};
[{_record get "outcome" != "pending"}] call _wait;
["elim_late_death_not_success",_record get "outcome" == "failed"] call _check;
[_record] call _retire; call _clearTrial;
_record = ["captured"] call _new;
sidesX = [true] call A3A_fnc_createNamespace;
private _marker = "a3i_elim_original_location"; createMarker [_marker,[1000,1000,0]];
sidesX setVariable [_marker,west]; sidesX setVariable [_marker,teamPlayer];
[_record] call A3I_fnc_updateEliminationLedger;
sidesX setVariable [_marker,east]; [_record] call A3I_fnc_updateEliminationLedger;
["elim_location_capture_keeps_hunt",_record get "outcome" == "pending" && {alive (_record get "unit")}] call _check;
deleteVehicle sidesX; deleteMarker _marker;
A3A_faction_occ = createHashMap; [_record] call A3I_fnc_updateEliminationLedger;
["elim_inactive_cancels",_record get "outcome" == "cancelled"] call _check;
A3A_faction_occ = _saved;
[_record] call _retire; call _clearTrial;
private _first = ["sameName"] call _new; private _oldSerial = _first get "serial";
private _second = ["parallel"] call _new;
[_first] call _retire;
["elim_parallel_observers_retained",!isNil "A3I_eliminationKilledEH" && {count A3I_eliminationLedgers == 1}] call _check;
_record = ["sameName"] call _new;
["elim_reused_name_rejects_old_record",([_first] call A3I_fnc_updateEliminationLedger) == "invalid"
    && {!(["sameName",_oldSerial] call A3I_fnc_releaseEliminationLedger)}] call _check;
[_record] call _retire; [_second] call _retire; call _clearTrial;
private _humanGroup = createGroup west;
private _human = _humanGroup createUnit ["B_Soldier_F",[1000,1000,0],[],0,"NONE"];
["elim_human_rejected",count (["human",_human,time+3600] call A3I_fnc_createEliminationLedger) == 0] call _check;
call _clearTrial;
// Native Boomer may kill itself and remove its corpse: death must remain durable.
west setFriend [teamPlayer,0]; teamPlayer setFriend [west,0];
_record = ["nativeBoomer","Zombie_Special_BLUFOR_Boomer"] call _new; _unit = _record get "unit";
private _victimGroup = createGroup [teamPlayer,true];
private _victim = _victimGroup createUnit ["I_Soldier_F",[1000,1006,0],[],0,"NONE"];
removeAllWeapons _victim; {_victim disableAI _x} forEach ["PATH","TARGET","AUTOTARGET"];
_victimGroup setCombatMode "BLUE";
[{_record get "outcome" != "pending"},35] call _wait;
["elim_native_boomer_death",_record get "outcome" == "neutralized" && {_record get "killedAt" >= 0}] call _check;
[{isNull _unit},12] call _wait;
["elim_native_boomer_cleanup_durable",isNull _unit && {_record get "outcome" == "neutralized"}] call _check;
[_record] call _retire; call _clearTrial;
["elim_last_release_retires_observers",count A3I_eliminationLedgers == 0
    && {isNil "A3I_eliminationKilledEH"} && {isNil "A3I_eliminationDeletedEH"}
    && {isNil "A3I_eliminationLedgerHandle"}] call _check;
["elim_cleanup",(entities [[],[],true,false]) - _before isEqualTo [] && {allGroups - _groupsBefore isEqualTo []}] call _check;
