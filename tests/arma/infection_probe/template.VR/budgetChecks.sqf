// Real server budget, CBA settings and prepared actors. No site spawning policy.
#include "\x\a3a\addons\core\script_component.hpp"
private _budgetEntitiesBefore = entities [[], [], true, false];
private _budgetGroupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContextCap = A3I_contextLimit;
private _savedFaction = A3A_faction_occ;
private _settings = ["A3I_activeLimit", "A3I_contextLimit", "A3I_budgetDiagnostics"];
private _serverOnly = _settings apply {(cba_settings_default getVariable [_x, []]) param [7,-1]};
["budget_settings_registered", (["A3I_activeLimit", "default"] call CBA_settings_fnc_get) == 40
    && {(["A3I_contextLimit", "default"] call CBA_settings_fnc_get) == 12}
    && {_serverOnly isEqualTo [2,2,2]}, _serverOnly] call _check;
private _setLimits = {
    params ["_total", "_context"];
    ["A3I_activeLimit", _total, 2, "server", false] call CBA_settings_fnc_set;
    ["A3I_contextLimit", _context, 2, "server", false] call CBA_settings_fnc_set;
    sleep 0.3;
};
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
private _closeAll = {{["close", [_x]] call A3I_fnc_budget} forEach keys A3I_budgetRecords};
[4,3] call _setLimits;
A3A_faction_occ = createHashMap;
private _result = ["reserve", ["inactive",1]] call A3I_fnc_budget;
["budget_inactive_denied", _result isEqualTo [false,["",0],"inactive"], _result] call _check;
A3A_faction_occ = _savedFaction;
private _badRequests = [
    ["",1], ["invalid",0], ["invalid",-1], ["invalid",1.5],
    ["invalid","one"], [[],1], ["invalid",1,0], ["invalid",1,2.5]
] apply {["reserve",_x] call A3I_fnc_budget};
["budget_invalid_requests", _badRequests findIf {!(_x isEqualTo [false,["",0],"invalid_request"])} == -1
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}, _badRequests] call _check;

private _first = ["reserve", ["site:A",4,2]] call A3I_fnc_budget;
private _ticketA = _first # 1 # 0;
private _sameContext = ["reserve", ["site:A",4,10]] call A3I_fnc_budget;
private _second = ["reserve", ["site:B",4,3]] call A3I_fnc_budget;
private _ticketB = _second # 1 # 0;
private _third = ["reserve", ["site:C",1]] call A3I_fnc_budget;
private _state = call _stats;
["budget_global_and_context_caps", _first # 0 && {_first # 1 # 1 == 2}
    && {!(_sameContext # 0)} && {_second # 0 && {_second # 1 # 1 == 2}}
    && {!(_third # 0)} && {_state isEqualTo [4,0,4,2,[["site:A",2],["site:B",2]]]},
    [_first,_sameContext,_second,_third,_state]] call _check;
private _closed = ["close",[_ticketA]] call A3I_fnc_budget;
private _closedAgain = ["close",[_ticketA]] call A3I_fnc_budget;
["budget_close_idempotent", _closed # 1 == 2 && {_closedAgain # 1 == 0}
    && {(call _stats) select [1,3] isEqualTo [0,2,1]}, [_closed,_closedAgain,call _stats]] call _check;
["close",[_ticketB]] call A3I_fnc_budget;

[8,8] call _setLimits;
A3I_test_budgetResults = [];
for "_i" from 0 to 19 do {
    [_i] spawn {
        params ["_index"];
        private _answer = ["reserve", ["race:" + str _index,1,1]] call A3I_fnc_budget;
        A3I_test_budgetResults pushBack _answer;
    };
};
private _deadline = diag_tickTime + 10;
waitUntil {sleep 0.1; count A3I_test_budgetResults == 20 || {diag_tickTime > _deadline}};
private _accepted = A3I_test_budgetResults select {_x # 0};
private _unique = (_accepted apply {_x # 1 # 0}) arrayIntersect (_accepted apply {_x # 1 # 0});
_state = call _stats;
["budget_concurrent_reservations", count A3I_test_budgetResults == 20 && {count _accepted == 8}
    && {count _unique == 8} && {_state select [0,4] isEqualTo [8,0,8,8]},
    [count A3I_test_budgetResults,count _accepted,count _unique,_state]] call _check;
call _closeAll;
// This is a server-origin remote call, matching the normal scheduler's server route.
["reserve", ["remote-server",1,1]] remoteExecCall ["A3I_fnc_budget",2];
sleep 0.4;
["budget_server_remote_call", (call _stats) select [1,3] isEqualTo [0,1,1], call _stats] call _check;
call _closeAll;

[4,3] call _setLimits;
private _older = ["reserve",["reduce:A",2,2]] call A3I_fnc_budget;
private _newer = ["reserve",["reduce:B",2,2]] call A3I_fnc_budget;
[2,3] call _setLimits;
private _afterGlobalReduction = call _stats;
[4,1] call _setLimits;
private _afterContextReduction = call _stats;
["budget_pending_limit_reduction", _afterGlobalReduction isEqualTo [2,0,2,1,[["reduce:A",2]]]
    && {_afterContextReduction isEqualTo [4,0,1,1,[["reduce:A",1]]]},
    [_afterGlobalReduction,_afterContextReduction]] call _check;
call _closeAll;
[4,3] call _setLimits;
private _actors = [];
private _newBudgetActor = {
    params [["_role", "militia_Rifleman"]];
    private _group = createGroup [west,true];
    private _unit = [_group, "loadouts_occ_" + _role, [1000,1000,0]] call A3A_fnc_createUnit;
    _actors pushBack _unit;
    private _deadline = diag_tickTime + 10;
    waitUntil {sleep 0.1; !isNil {_unit getVariable "WBK_AI_AttachedHandlers"} || {diag_tickTime > _deadline}};
    sleep 0.7;
    _unit
};
// Retain the actual combat bookkeeping and garbage queue while recording its endpoints.
A3A_GCThreshold = 600;
GVAR(despawnQueue) = [];
A3A_recentDamageOcc = [];
A3I_test_support = [];
A3I_test_aggression = [];
A3I_test_zones = [];
_result = ["reserve",["live",3,3]] call A3I_fnc_budget;
private _ticket = _result # 1 # 0;
private _liveActors = [];
private _bindings = [];
{
    private _unit = [_x] call _newBudgetActor;
    _bindings pushBack (["bind",[_ticket,_unit]] call A3I_fnc_budget);
    [_unit,"",false,"garrison"] call A3A_fnc_NATOinit;
    _liveActors pushBack _unit;
} forEach ["militia_Rifleman","military_Rifleman","elite_Rifleman"];
["budget_bind_basic", _bindings findIf {!(_x # 0)} == -1
    && {(call _stats) select [1,3] isEqualTo [3,0,1]}, [_bindings,call _stats]] call _check;
private _duplicate = ["bind",[_ticket,_liveActors # 0]] call A3I_fnc_budget;
private _other = ["reserve",["other",1,1]] call A3I_fnc_budget;
private _otherTicket = _other # 1 # 0;
private _stolen = ["bind",[_otherTicket,_liveActors # 0]] call A3I_fnc_budget;
["budget_duplicate_binding", _duplicate isEqualTo [true,0,"already_bound"]
    && {_stolen isEqualTo [false,0,"already_bound_elsewhere"]}
    && {(call _stats) select [1,3] isEqualTo [3,1,2]}, [_duplicate,_stolen,call _stats]] call _check;
["close",[_otherTicket]] call A3I_fnc_budget;
_result = ["release",[_liveActors # 0]] call A3I_fnc_budget;
["budget_live_release_denied", _result isEqualTo [false,0,"unit_still_alive"]
    && {(call _stats) select [1,3] isEqualTo [3,0,1]}, _result] call _check;
[2,3] call _setLimits;
_result = ["reserve",["after-lowering",1,1]] call A3I_fnc_budget;
["budget_capacity_reduction_keeps_units", !(_result # 0)
    && {{alive _x} count _liveActors == 3} && {(call _stats) select [0,4] isEqualTo [2,3,0,1]}, call _stats] call _check;
(_liveActors # 0) setDamage 1;
sleep 0.5;
private _releasedAgain = ["release",[_liveActors # 0]] call A3I_fnc_budget;
["budget_kill_release", (call _stats) select [1,3] isEqualTo [2,0,1]
    && {isNil {(_liveActors # 0) getVariable "A3I_budgetTicket"}}
    && {_releasedAgain # 1 == 0}, [call _stats,_releasedAgain]] call _check;
deleteVehicle (_liveActors # 1);
sleep 0.5;
private _deletedEventCount = count ((A3I_budgetRecords get _ticket) # 2);
["budget_live_delete_release", _deletedEventCount == 1
    && {(call _stats) select [1,3] isEqualTo [1,0,1]}, [_deletedEventCount,call _stats]] call _check;
["close",[_ticket]] call A3I_fnc_budget;
["budget_close_preserves_bound", alive (_liveActors # 2)
    && {(call _stats) select [1,3] isEqualTo [1,0,1]}, call _stats] call _check;
_result = ["cancel",[_ticket]] call A3I_fnc_budget;
sleep 0.5;
private _cancelledRecordGone = isNil {A3I_budgetRecords get _ticket};
["budget_cancel_deletes_bound", _result # 1 == 1 && {isNull (_liveActors # 2)}
    && {_cancelledRecordGone} && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [_result,_cancelledRecordGone,call _stats]] call _check;

[4,3] call _setLimits;
_result = ["reserve",["lease",2,2]] call A3I_fnc_budget;
_ticket = _result # 1 # 0;
private _leaseActor = [] call _newBudgetActor;
["bind",[_ticket,_leaseActor]] call A3I_fnc_budget;
private _lateActor = [] call _newBudgetActor;
private _orphan = ["reserve",["orphan",1,1]] call A3I_fnc_budget;
sleep 31;
_state = call _stats;
_result = ["bind",[_ticket,_lateActor]] call A3I_fnc_budget;
["budget_expiry_preserves_bound", alive _leaseActor && {_state select [1,3] isEqualTo [1,0,1]}
    && {_result isEqualTo [false,0,"closed_ticket"]}, [_state,_result]] call _check;
["budget_expiry_unbound", (A3I_budgetRecords getOrDefault [_orphan # 1 # 0, []]) isEqualTo [], call _stats] call _check;
["cancel",[_ticket]] call A3I_fnc_budget;
_result = ["unknown"] call A3I_fnc_budget;
["budget_unknown_operation", _result isEqualTo [false,[],"unknown_operation"], _result] call _check;
_result = ["reserve",["preflight",2,2]] call A3I_fnc_budget;
_ticket = _result # 1 # 0;
private _beforeClose = ["remaining",[_ticket]] call A3I_fnc_budget;
["close",[_ticket]] call A3I_fnc_budget;
private _afterClose = ["remaining",[_ticket]] call A3I_fnc_budget;
private _invalidTicket = ["remaining",[123]] call A3I_fnc_budget;
["budget_ticket_preflight",_beforeClose isEqualTo [true,2,""]
    && {_afterClose isEqualTo [false,0,"unknown_ticket"]}
    && {_invalidTicket isEqualTo [false,0,"invalid_ticket"]},
    [_beforeClose,_afterClose,_invalidTicket]] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _actors;
sleep 0.5;
{if (count units _x == 0) then {deleteGroup _x}} forEach (allGroups - _budgetGroupsBefore);
sleep 3;
[_savedCap,_savedContextCap] call _setLimits;
private _remaining = (entities [[], [], true, false]) - _budgetEntitiesBefore;
private _groupsLeft = allGroups - _budgetGroupsBefore;
["budget_cleanup", _remaining isEqualTo [] && {_groupsLeft isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [_remaining apply {typeOf _x}, count _groupsLeft, call _stats]] call _check;
GVAR(despawnQueue) = [];
