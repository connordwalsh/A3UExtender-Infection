/* Internal server API. Nothing is persisted or broadcast.
   [operation, arguments] -> [success, payload, reason]
   reserve: [context, requested, localLimit=12] -> [ticket, granted]
   remaining: [ticket] -> unbound slots after expiry/limit reconciliation
   bind: [ticket, unit] -> 1; close: [ticket] -> unused slots released
   cancel: [ticket] -> living units deleted; release: [unit] -> slots released
   stats: [] -> [cap, living, pending, tickets, [[context, occupied], ...]]
   Every mutation is unscheduled, including calls from scheduled spawn scripts. */
params [["_operation", "stats", [""]], ["_args", [], [[]]]];
if (!isServer) exitWith {[false, [], "server_only"]};
if (isRemoteExecuted && {remoteExecutedOwner != 2}) exitWith {[false, [], "server_origin_only"]};
if (canSuspend) exitWith {[A3I_fnc_budget, _this] call CBA_fnc_directCall};
if (isNil "A3I_budgetRecords") then {A3I_budgetRecords = createHashMap; A3I_budgetSerial = 0};
private _cap = missionNamespace getVariable ["A3I_activeLimit", 40];
if !(_cap isEqualType 0 && {finite _cap}) then {_cap = 40};
_cap = (floor _cap) max 0 min 48;
private _contextCap = missionNamespace getVariable ["A3I_contextLimit", 12];
if !(_contextCap isEqualType 0 && {finite _contextCap}) then {_contextCap = 12};
_contextCap = (floor _contextCap) max 0 min 24;

// Retire dead/null bindings and expired unfilled reservations before granting.
// A stopped spawn script cannot retain capacity indefinitely. Bound live units
// remain counted even after their ticket is closed or its pending part expires.
if (_operation != "release") then {
    {
        private _ticket = _x;
        private _record = A3I_budgetRecords get _ticket;
        private _units = _record # 2;
        {
            if (!alive _x && {!isNull _x} && {_x getVariable ["A3I_budgetTicket", ""] == _ticket}) then {
                _x setVariable ["A3I_budgetTicket", nil];
            };
        } forEach _units;
        _record set [2, _units select {alive _x}];
        if (diag_tickTime >= _record # 3) then {_record set [1,0]; _record set [4,true]};
        if (_record # 1 == 0 && {_record # 2 isEqualTo []}) then {
            A3I_budgetRecords deleteAt _ticket;
        };
    } forEach keys A3I_budgetRecords;
};
private _active = 0;
private _pending = 0;
private _contexts = createHashMap;
private _ordered = [];
{
    _y params ["_context", "_reserved", "_units"];
    _active = _active + count _units;
    _contexts set [_context, (_contexts getOrDefault [_context,0]) + count _units];
    _ordered pushBack [_y # 6, _x];
} forEach A3I_budgetRecords;
// A reduced limit trims unfilled slots, preserving older reservations first. Existing
// living units are retained; later binds cannot spend capacity removed here.
_ordered sort true;
private _free = (_cap - _active) max 0;
{
    private _ticket = _x # 1;
    private _record = A3I_budgetRecords get _ticket;
    private _context = _record # 0;
    private _contextFree = (((_record # 5) min _contextCap) - (_contexts getOrDefault [_context,0])) max 0;
    private _remaining = (_record # 1) min _free min _contextFree;
    if (_remaining < _record # 1) then {
        _record set [1,_remaining];
        if (_remaining == 0) then {_record set [4,true]};
    };
    _free = _free - _remaining;
    _pending = _pending + _remaining;
    _contexts set [_context, (_contexts getOrDefault [_context,0]) + _remaining];
    if (_remaining == 0 && {_record # 2 isEqualTo []}) then {A3I_budgetRecords deleteAt _ticket};
} forEach _ordered;

private _result = switch (_operation) do {
    case "stats": {
        private _names = (keys _contexts) select {_contexts get _x > 0};
        _names sort true;
        [true, [_cap, _active, _pending, count A3I_budgetRecords, _names apply {[_x, _contexts get _x]}], ""]
    };
    case "reserve": {
        if !([west] call A3I_fnc_isActive) exitWith {[false, ["",0], "inactive"]};
        private _context = _args param [0, ""];
        private _requested = _args param [1, 0];
        private _localLimit = _args param [2, 12];
        if !(_context isEqualType "" && {_context != ""} && {count _context <= 128}
            && {_requested isEqualType 0} && {finite _requested} && {_requested >= 1}
            && {floor _requested == _requested} && {_localLimit isEqualType 0}
            && {finite _localLimit} && {_localLimit >= 1} && {floor _localLimit == _localLimit})
            exitWith {[false, ["",0], "invalid_request"]};
        private _limit = _localLimit min _contextCap;
        {
            if (_y # 0 == _context) then {_limit = _limit min (_y # 5)};
        } forEach A3I_budgetRecords;
        private _available = (_cap - _active - _pending) min (_limit - (_contexts getOrDefault [_context,0]));
        private _granted = _requested min (_available max 0);
        if (_granted == 0) exitWith {[false, ["",0], "capacity"]};
        A3I_budgetSerial = A3I_budgetSerial + 1;
        private _ticket = "A3I_" + str A3I_budgetSerial;
        // Store the caller's ceiling, not the current CBA setting or an older
        // ticket's effective limit. Those are reconciled on every operation;
        // retaining their old minimum would prevent later setting increases.
        // context, unbound slots, units, lease deadline, closed, local ceiling, sequence
        A3I_budgetRecords set [_ticket, [_context, _granted, [], diag_tickTime + 30, false, _localLimit min 24, A3I_budgetSerial]];
        [true, [_ticket, _granted], ""]
    };
    case "remaining": {
        private _ticket = _args param [0, ""];
        if !(_ticket isEqualType "") exitWith {[false,0,"invalid_ticket"]};
        private _record = A3I_budgetRecords getOrDefault [_ticket,[]];
        if (_record isEqualTo []) exitWith {[false,0,"unknown_ticket"]};
        if (_record # 4 || {_record # 1 < 1}) exitWith {[false,0,"closed_ticket"]};
        [true,_record # 1,""]
    };
    case "bind": {
        private _ticket = _args param [0, ""];
        private _unit = _args param [1, objNull];
        if !(_ticket isEqualType "" && {_unit isEqualType objNull} && {alive _unit}
            && {local _unit} && {[_unit] call A3I_fnc_isManagedUnit})
            exitWith {[false, 0, "invalid_unit"]};
        private _record = A3I_budgetRecords getOrDefault [_ticket, []];
        if (_record isEqualTo []) exitWith {[false, 0, "unknown_ticket"]};
        private _bound = _unit getVariable ["A3I_budgetTicket", ""];
        if (_bound != "") exitWith {
            if (_bound == _ticket && {_unit in (_record # 2)}) then {[true,0,"already_bound"]}
            else {[false,0,"already_bound_elsewhere"]}
        };
        if (_record # 4 || {_record # 1 < 1}) exitWith {[false,0,"closed_ticket"]};
        (_record # 2) pushBack _unit;
        _record set [1, (_record # 1) - 1];
        _record set [3, diag_tickTime + 30];
        _unit setVariable ["A3I_budgetTicket", _ticket];
        _unit addEventHandler ["Killed", {["release", [_this # 0]] call A3I_fnc_budget}];
        _unit addEventHandler ["Deleted", {["release", [_this # 0]] call A3I_fnc_budget}];
        [true, 1, ""]
    };
    case "release": {
        private _unit = _args param [0, objNull];
        if !(_unit isEqualType objNull && {!isNull _unit}) exitWith {[false,0,"invalid_unit"]};
        // Only real death or the live engine Deleted event may unbind an actor.
        if (alive _unit && {isNil "_thisEvent" || {_thisEvent != "Deleted"}})
            exitWith {[false,0,"unit_still_alive"]};
        private _ticket = _unit getVariable ["A3I_budgetTicket", ""];
        private _record = A3I_budgetRecords getOrDefault [_ticket, []];
        _unit setVariable ["A3I_budgetTicket", nil];
        if (_record isEqualTo []) exitWith {[true,0,"already_released"]};
        private _index = (_record # 2) find _unit;
        if (_index == -1) exitWith {[true,0,"already_released"]};
        (_record # 2) deleteAt _index;
        if (_record # 1 == 0 && {_record # 2 isEqualTo []}) then {A3I_budgetRecords deleteAt _ticket};
        [true,1,""]
    };
    case "close";
    case "cancel": {
        private _ticket = _args param [0, ""];
        if !(_ticket isEqualType "") exitWith {[false,0,"invalid_ticket"]};
        private _record = A3I_budgetRecords getOrDefault [_ticket, []];
        if (_record isEqualTo []) exitWith {[true,0,"already_closed"]};
        private _unused = _record # 1;
        private _units = +(_record # 2);
        _record set [1,0];
        _record set [4,true];
        if (_units isEqualTo []) then {A3I_budgetRecords deleteAt _ticket};
        if (_operation == "cancel") then {
            {deleteVehicle _x} forEach _units;
            [true,count _units,""]
        } else {
            [true,_unused,""]
        }
    };
    default {[false,[],"unknown_operation"]};
};
if (missionNamespace getVariable ["A3I_budgetDiagnostics", false] && {_operation != "stats"}) then {
    diag_log format ["[INFECTION_BUDGET] operation=%1 result=%2 activeBefore=%3 pendingBefore=%4 cap=%5",
        _operation, _result, _active, _pending, _cap];
};
_result
