// Settlement bookkeeping with real survivors/events and controlled deadlines.
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _actors = [];
private _group = createGroup civilian;
sidesX = [true] call A3A_fnc_createNamespace;
private _hq = "a3i_extract_hq";
respawnTeamPlayer = _hq; posHQ = [4000,4000,0]; createMarker [_hq,posHQ];
airportsX = []; milbases = []; outposts = []; factories = []; resourcesX = []; seaports = [];
citiesX = []; controlsX = []; milAdministrationsX = [];
private _new = {
    private _unit = _group createUnit ["C_man_1",[4400,4000,0],[],0,"NONE"];
    _unit enableSimulationGlobal false; _actors pushBack _unit; _unit
};
private _release = {params ["_r"]; [_r get "name",_r get "serial"] call A3I_fnc_releaseExtractionLedger};
private _a = call _new; private _b = call _new;
private _faction = A3A_faction_occ; A3A_faction_occ = createHashMap;
["exledger_inactive_refused",count (["inactive",[_a],time+60] call A3I_fnc_createExtractionLedger) == 0] call _check;
A3A_faction_occ = _faction;
["exledger_invalid_rosters",count (["empty",[],time+60] call A3I_fnc_createExtractionLedger) == 0
    && {count (["duplicate",[_a,_a],time+60] call A3I_fnc_createExtractionLedger) == 0}
    && {count (["null",[_a,objNull],time+60] call A3I_fnc_createExtractionLedger) == 0}
    && {isNil {_a getVariable "A3I_extractionOwner"}}] call _check;
["exledger_expired_refused",count (["expired",[_a],time-1] call A3I_fnc_createExtractionLedger) == 0] call _check;
private _r = ["all",[_a,_b],time+60] call A3I_fnc_createExtractionLedger;
["exledger_registered",count _r > 0 && {_r get "unresolved" == 2}
    && {!isNil "A3I_extractionKilledEH"} && {!isNil "A3I_extractionLedgerHandle"}] call _check;
["exledger_double_ownership_refused",count (["other",[_a],time+60] call A3I_fnc_createExtractionLedger) == 0
    && {count (["all",[call _new],time+60] call A3I_fnc_createExtractionLedger) == 0}] call _check;
["exledger_all_pending",([_r] call A3I_fnc_updateExtractionLedger) == "pending"] call _check;
_a setPosATL posHQ;
["exledger_first_rescue_waits",([_r] call A3I_fnc_updateExtractionLedger) == "pending"
    && {_r get "rescued" == 1} && {_r get "unresolved" == 1}] call _check;
_a setPosATL [4400,4000,0];
[_r] call A3I_fnc_updateExtractionLedger;
["exledger_rescue_is_durable",_r get "rescued" == 1] call _check;
_b setPosATL posHQ;
["exledger_all_rescued_succeeds",([_r] call A3I_fnc_updateExtractionLedger) == "succeeded"
    && {_r get "rescued" == 2} && {_r get "reason" == "all_resolved"}] call _check;
private _settled = _r get "settledAt";
[_r] call A3I_fnc_updateExtractionLedger;
["exledger_settlement_once",_r get "settledAt" == _settled && {_r get "rescued" == 2}] call _check;
["exledger_stale_release_refused",!(["all",(_r get "serial")-1] call A3I_fnc_releaseExtractionLedger)
    && {"all" in A3I_extractionLedgers}] call _check;
[_r] call _release;
["exledger_release_preserves_assets",alive _a && {alive _b}
    && {isNil {_a getVariable "A3I_extractionOwner"}}] call _check;
private _old = _r;
_a setPosATL [4400,4000,0];
_r = ["all",[_a],time+60] call A3I_fnc_createExtractionLedger;
["exledger_reused_name_rejects_stale_record",_r get "serial" != _old get "serial"
    && {([_old] call A3I_fnc_updateExtractionLedger) == ""}] call _check;
[_r] call _release;

_a = call _new; _b = call _new; private _c = call _new;
_r = ["mixed",[_a,_b,_c],time+60] call A3I_fnc_createExtractionLedger;
_a setPosATL posHQ; [_r] call A3I_fnc_updateExtractionLedger;
_b setDamage 1; sleep 0.1;
["exledger_real_death_recorded",((_r get "entries") # 1) get "state" == "killed"] call _check;
["exledger_mixed_waits_for_last",([_r] call A3I_fnc_updateExtractionLedger) == "pending"
    && {_r get "rescued" == 1} && {_r get "killed" == 1} && {_r get "unresolved" == 1}] call _check;
_c setDamage 1; sleep 0.1;
["exledger_mixed_resolution_succeeds",([_r] call A3I_fnc_updateExtractionLedger) == "succeeded"
    && {_r get "rescued" == 1} && {_r get "killed" == 2}] call _check;
[_r] call _release;

_a = call _new; _r = ["dead",[_a],time+60] call A3I_fnc_createExtractionLedger;
_a setDamage 1; sleep 0.1; deleteVehicle _a; sleep 0.1;
["exledger_death_survives_corpse_deletion",([_r] call A3I_fnc_updateExtractionLedger) == "failed"
    && {_r get "killed" == 1} && {_r get "reason" == "all_resolved"}] call _check;
[_r] call _release;

_a = call _new; _r = ["missing",[_a],time+60] call A3I_fnc_createExtractionLedger;
deleteVehicle _a; sleep 0.2;
["exledger_living_deletion_unresolved",([_r] call A3I_fnc_updateExtractionLedger) == "pending"
    && {_r get "killed" == 0} && {_r get "unresolved" == 1}
    && {((_r get "entries") # 0) get "deleted"}] call _check;
_r set ["deadline",time-1];
["exledger_missing_deadline_fails",([_r] call A3I_fnc_updateExtractionLedger) == "failed"] call _check;
[_r] call _release;

_a = call _new; _b = call _new;
_r = ["timeout",[_a,_b],time+60] call A3I_fnc_createExtractionLedger;
_a setPosATL posHQ; [_r] call A3I_fnc_updateExtractionLedger;
_r set ["deadline",time-1];
["exledger_partial_deadline_succeeds",([_r] call A3I_fnc_updateExtractionLedger) == "succeeded"
    && {_r get "rescued" == 1} && {_r get "unresolved" == 1} && {_r get "reason" == "deadline"}] call _check;
_b setPosATL posHQ; [_r] call A3I_fnc_updateExtractionLedger;
["exledger_late_rescue_not_added",_r get "rescued" == 1 && {alive _b}] call _check;
[_r] call _release;
_a = call _new; _r = ["zero",[_a],time+60] call A3I_fnc_createExtractionLedger;
_r set ["deadline",time-1]; _a setPosATL posHQ;
["exledger_zero_deadline_fails",([_r] call A3I_fnc_updateExtractionLedger) == "failed"
    && {_r get "rescued" == 0} && {alive _a}] call _check;
[_r] call _release;

_a = call _new; _r = ["guards",[_a],time+60] call A3I_fnc_createExtractionLedger;
["exledger_living_kill_rejected",!([_a,"killed"] call A3I_fnc_extractionMemberEvent)] call _check;
_b = call _new; _b setVariable ["A3I_extractionOwner",_a getVariable "A3I_extractionOwner"];
_b setDamage 1; sleep 0.1;
["exledger_foreign_actor_rejected",((_r get "entries") # 0) get "state" == "pending"] call _check;
_a setPosATL posHQ; _a setVariable ["WBK_AI_ISZombie",true];
["exledger_converted_not_rescued",([_r] call A3I_fnc_updateExtractionLedger) == "pending"
    && {_r get "rescued" == 0}] call _check;
_a setVariable ["WBK_AI_ISZombie",nil];
private _owner = _a getVariable "A3I_extractionOwner"; _a setVariable ["A3I_extractionOwner",["foreign",0,0]];
["exledger_reassigned_actor_not_rescued",([_r] call A3I_fnc_updateExtractionLedger) == "pending"] call _check;
[_r] call _release;
["exledger_release_preserves_foreign_owner",(_a getVariable "A3I_extractionOwner") isEqualTo ["foreign",0,0]] call _check;
_a setVariable ["A3I_extractionOwner",nil];

_a = call _new; _b = call _new;
private _one = ["one",[_a],time+60] call A3I_fnc_createExtractionLedger;
private _two = ["two",[_b],time+60] call A3I_fnc_createExtractionLedger;
[_one] call _release;
["exledger_concurrent_observers_retained",!isNil "A3I_extractionKilledEH" && {"two" in A3I_extractionLedgers}] call _check;
_b setPosATL posHQ;
private _wait = diag_tickTime+4;
waitUntil {sleep 0.1; _two get "outcome" == "succeeded" || {diag_tickTime > _wait}};
["exledger_independent_tick_settles",_two get "outcome" == "succeeded" && {_two get "rescued" == 1}] call _check;
[_two] call _release;
["exledger_observers_removed",count A3I_extractionLedgers == 0 && {isNil "A3I_extractionKilledEH"}
    && {isNil "A3I_extractionDeletedEH"} && {isNil "A3I_extractionLedgerHandle"}] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _actors;
deleteVehicle sidesX; deleteMarker _hq; sleep 0.3; deleteGroup _group; sleep 0.5;
["exledger_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
