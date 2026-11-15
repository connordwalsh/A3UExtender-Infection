/* Internal server API. Nothing is persisted or broadcast.
   [operation, arguments] -> [success, payload, reason]
   reserve: [context, requested, localLimit=12] -> [ticket, granted]
   remaining: [ticket] -> unbound slots after expiry/limit reconciliation
   bind: [ticket, unit] -> 1; close: [ticket] -> unused slots released
   transfer: [closed ticket, context, localLimit=24] -> living units moved
   handoff: [ticket, interception name, serial, marker, site ID] -> owned arrivals
   cancel: [ticket] -> living units deleted; release: [unit] -> slots released
   stats: [] -> [cap, living, pending, tickets, [[context, occupied], ...]]
   Registered towns and preparing interception hordes own separate allowances.
   Dedicated allowances move only through a validated interception handoff.
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
private _dedicatedCaps = createHashMap;
private _dedicatedAllowance = 0;
{
    private _site = _y;
    if (_site getOrDefault ["kind",""] == "City" && {!(_site getOrDefault ["cleaned",false])}
        && {_site getOrDefault ["context",""] == "site:" + _x}) then {
        private _target = _site getOrDefault ["populationTarget",0];
        private _base = _site getOrDefault ["baselineTarget",_target];
        private _extra = _site getOrDefault ["extraTarget",0];
        if (_target isEqualType 0 && {finite _target} && {_target > 0}
            && {_base isEqualType 0 && {finite _base} && {_base >= 0} && {_base <= 200} && {floor _base == _base}}
            && {_extra isEqualType 0 && {finite _extra} && {_extra >= 0} && {floor _extra == _extra}}
            && {_target == _base + _extra}) then {
            _dedicatedCaps set [_site get "context",floor _target];
            _dedicatedAllowance = _dedicatedAllowance + floor _target;
        };
    };
} forEach (missionNamespace getVariable ["A3I_sites",createHashMap]);

// Only a live server-owned preparing job can reserve its complete horde.
// Later phases retain their allowance for living actors but retire unused slots.
// Bindings remain dedicated even if a stopped job disappears before cleanup.
private _interceptionReservations = [];
{
    private _job = _y;
    private _context = "interception:" + _x;
    private _size = _job getOrDefault ["size",0];
    if (_job getOrDefault ["context",""] == _context
        && {_job getOrDefault ["phase",""] in ["preparing","marching","arrived","cleanup"]}
        && {!(_job getOrDefault ["retired",true])}
        && {_size isEqualType 0 && {finite _size} && {_size >= 1} && {_size <= 120} && {floor _size == _size}}) then {
        _dedicatedCaps set [_context,_size];
        _dedicatedAllowance = _dedicatedAllowance + _size;
        if (_job get "phase" == "preparing" && {!scriptDone (_job getOrDefault ["script",scriptNull])}) then {
            _interceptionReservations pushBack _context;
        };
    };
} forEach (missionNamespace getVariable ["A3I_interceptions",createHashMap]);

// Adopted permanent-site arrivals keep only their existing physical allowance.
// These closed contexts can never reserve replacements or consume shared slots.
{
    if ((_y # 0) find "arrival:" == 0 && {_y param [7,false]}
        && {_y # 4} && {_y # 1 == 0}) then {
        private _living = {alive _x} count (_y # 2);
        _dedicatedCaps set [_y # 0,_living];
        _dedicatedAllowance = _dedicatedAllowance + _living;
    };
} forEach A3I_budgetRecords;

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
private _sharedActive = 0;
private _sharedPending = 0;
private _contexts = createHashMap;
private _ordered = [];
{
    _y params ["_context", "_reserved", "_units"];
    _active = _active + count _units;
    if !(_y param [7,false]) then {_sharedActive = _sharedActive + count _units};
    _contexts set [_context, (_contexts getOrDefault [_context,0]) + count _units];
    _ordered pushBack [_y # 6, _x];
} forEach A3I_budgetRecords;
// A reduced limit trims unfilled slots, preserving older reservations first. Existing
// living units are retained; later binds cannot spend capacity removed here.
_ordered sort true;
private _free = (_cap - _sharedActive) max 0;
{
    private _ticket = _x # 1;
    private _record = A3I_budgetRecords get _ticket;
    private _context = _record # 0;
    private _dedicated = _record param [7,false];
    private _ceiling = if (_dedicated) then {_dedicatedCaps getOrDefault [_context,0]} else {_contextCap};
    if (_context find "interception:" == 0 && {!(_context in _interceptionReservations)}) then {_ceiling = 0};
    private _contextFree = (((_record # 5) min _ceiling) - (_contexts getOrDefault [_context,0])) max 0;
    private _remaining = (_record # 1) min _contextFree;
    if (!_dedicated) then {_remaining = _remaining min _free};
    if (_remaining < _record # 1) then {
        _record set [1,_remaining];
        if (_remaining == 0) then {_record set [4,true]};
    };
    if (!_dedicated) then {_free = _free - _remaining; _sharedPending = _sharedPending + _remaining};
    _pending = _pending + _remaining;
    _contexts set [_context, (_contexts getOrDefault [_context,0]) + _remaining];
    if (_remaining == 0 && {_record # 2 isEqualTo []}) then {A3I_budgetRecords deleteAt _ticket};
} forEach _ordered;

private _result = switch (_operation) do {
    case "stats": {
        private _names = (keys _contexts) select {_contexts get _x > 0};
        _names sort true;
        [true, [_cap + _dedicatedAllowance, _active, _pending, count A3I_budgetRecords, _names apply {[_x, _contexts get _x]}], ""]
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
        if (_context find "interception:" == 0 && {!(_context in _interceptionReservations)})
            exitWith {[false,["",0],"interception_closed"]};
        if (_context find "arrival:" == 0) exitWith {[false,["",0],"arrival_closed"]};
        private _dedicated = _context in _dedicatedCaps;
        private _ceiling = if (_dedicated) then {_dedicatedCaps get _context} else {_contextCap};
        private _limit = _localLimit min _ceiling;
        private _domainMismatch = false;
        {
            if (_y # 0 == _context) then {
                _limit = _limit min (_y # 5);
                if ((_y param [7,false]) != _dedicated) then {_domainMismatch = true};
            };
        } forEach A3I_budgetRecords;
        if (_domainMismatch) exitWith {[false,["",0],"context_closed"]};
        private _available = _limit - (_contexts getOrDefault [_context,0]);
        if (!_dedicated) then {_available = _available min (_cap - _sharedActive - _sharedPending)};
        private _granted = _requested min (_available max 0);
        if (_granted == 0) exitWith {[false, ["",0], "capacity"]};
        A3I_budgetSerial = A3I_budgetSerial + 1;
        private _ticket = "A3I_" + str A3I_budgetSerial;
        // Store the caller's ceiling, not the current CBA setting or an older
        // ticket's effective limit. Those are reconciled on every operation;
        // retaining their old minimum would prevent later setting increases.
        // context, unbound slots, units, lease deadline, closed, local ceiling, sequence, dedicated domain
        A3I_budgetRecords set [_ticket, [_context, _granted, [], diag_tickTime + 30, false,
            _localLimit min (if (_dedicated) then {_ceiling} else {24}), A3I_budgetSerial, _dedicated]];
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
    case "handoff": {
        if (isRemoteExecuted) exitWith {[false,0,"server_local_only"]};
        _args params [["_ticket","",[""]],["_name","",[""]],["_serial",-1,[0]],
            ["_marker","",[""]],["_siteId",-1,[0]]];
        private _record = A3I_budgetRecords getOrDefault [_ticket,[]];
        private _job = (missionNamespace getVariable ["A3I_interceptions",createHashMap])
            getOrDefault [_name,createHashMap];
        private _site = (missionNamespace getVariable ["A3I_sites",createHashMap])
            getOrDefault [_marker,createHashMap];
        if (_record isEqualTo [] || {!(_record # 4)} || {_record # 1 != 0}
            || {!(_record param [7,false])} || {_record # 2 isEqualTo []}
            || {_record # 0 != "interception:" + _name}
            || {_job getOrDefault ["serial",-1] != _serial}
            || {_job getOrDefault ["target",""] != _marker}
            || {_job getOrDefault ["outcome",""] != "arrived"}
            || {_job getOrDefault ["phase",""] != "arrived"}
            || {!(_job getOrDefault ["settled",false])} || {_job getOrDefault ["retired",true]})
            exitWith {[false,0,"invalid_arrival_owner"]};
        if (!([west] call A3I_fnc_isActive) || {isNil "sidesX"} || {isNil "spawner"}
            || {sidesX getVariable [_marker,sideUnknown] != west} || {spawner getVariable [_marker,2] != 0}
            || {_site getOrDefault ["id",-1] != _siteId}
            || {_site getOrDefault ["context",""] != "site:" + _marker}
            || {_site getOrDefault ["cleaned",true]} || {_site getOrDefault ["fault","missing"] != ""}
            || {_site getOrDefault ["captured",sideUnknown] != sideUnknown}
            || {scriptDone (_site getOrDefault ["script",scriptNull])}
            || {!(_site getOrDefault ["kind",""] in ["City","Resource","Outpost","Milbase","Airport","MilAdmin"])})
            exitWith {[false,0,"invalid_arrival_site"]};
        private _count = count (_record # 2);
        if (_site get "kind" == "City") then {
            private _context = _site get "context";
            if (!(_context in _dedicatedCaps)) exitWith {[false,0,"invalid_city_allowance"]};
            private _target = (_site get "populationTarget") + _count;
            _site set ["populationTarget",_target];
            _site set ["extraTarget",(_site getOrDefault ["extraTarget",0]) + _count];
            // Existing town reservations must still finish their original queue.
            {if (_y # 0 == _context) then {_y set [5,_target]}} forEach A3I_budgetRecords;
            _record set [0,_context]; _record set [5,_target];
            [true,_count,""]
        } else {
            _record set [0,"arrival:" + _ticket]; _record set [5,_count];
            [true,_count,""]
        }
    };
    case "transfer": {
        private _ticket = _args param [0, ""];
        private _context = _args param [1, ""];
        private _localLimit = _args param [2, 24];
        if !(_ticket isEqualType "" && {_context isEqualType ""} && {_context != ""}
            && {count _context <= 128} && {_localLimit isEqualType 0} && {finite _localLimit}
            && {_localLimit >= 1} && {floor _localLimit == _localLimit})
            exitWith {[false,0,"invalid_request"]};
        private _record = A3I_budgetRecords getOrDefault [_ticket,[]];
        if (_record isEqualTo []) exitWith {[false,0,"unknown_ticket"]};
        if (!(_record # 4) || {_record # 1 != 0}) exitWith {[false,0,"ticket_not_closed"]};
        if (_context find "arrival:" == 0) exitWith {[false,0,"arrival_closed"]};
        if (_record # 0 == _context) exitWith {[true,0,"already_transferred"]};
        // Dedicated populations cannot turn their allowance into shared capacity
        // or receive outside actors. Interception arrival needs an explicit
        // garrison handoff policy rather than bypassing this budget boundary.
        if ((_record param [7,false]) || {_context in _dedicatedCaps})
            exitWith {[false,0,if ((_record # 0) find "interception:" == 0 || {_context find "interception:" == 0})
                then {"interception_population_fixed"} else {"town_population_fixed"}]};
        private _limit = _localLimit min _contextCap;
        {if (_y # 0 == _context) then {_limit = _limit min (_y # 5)}} forEach A3I_budgetRecords;
        private _count = count (_record # 2);
        if (_count + (_contexts getOrDefault [_context,0]) > _limit)
            exitWith {[false,0,"capacity"]};
        // Moving existing bindings does not create global capacity or replace
        // their death/deletion handlers. The destination's ceiling still applies.
        _record set [0,_context];
        _record set [5,_localLimit min 24];
        [true,_count,""]
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
    diag_log format ["[INFECTION_BUDGET] operation=%1 result=%2 activeBefore=%3 pendingBefore=%4 sharedCap=%5 townAllowance=%6",
        _operation, _result, _active, _pending, _cap, _dedicatedAllowance];
};
_result
