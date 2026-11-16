// Actual native campaign and death handlers; forcedSpawn only controls visits.
private _checks=0;private _failures=[];
private _check={params ["_name","_ok",["_details",[]]];
    _checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_CAMPAIGN_CASUALTIES] %1",["check",_name,_ok,_details]];
};
private _wait={params ["_condition",["_seconds",120]];
    private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};
    call _condition
};
diag_log "[INFECTION_CAMPAIGN_CASUALTIES] start";
private _limit=(floor (missionNamespace getVariable ["A3I_contextLimit",12])) max 0 min 24;
private _shared=(floor (missionNamespace getVariable ["A3I_activeLimit",40])) max 0 min 48;
private _ranked=[];
{
    private _size=count (garrison getVariable [_x,[]]);
    if (_size>=_limit+4 && {_limit>=4} && {_shared>=_limit}
        && {sidesX getVariable [_x,sideUnknown]==west} && {!(_x in forcedSpawn)}
        && {spawner getVariable [_x,2]==2} && {getMarkerPos _x distance2D petros>2500}) then {
        _ranked pushBack [_size,_x];
    };
} forEach (resourcesX+factories+outposts+seaports+milbases+airportsX);
_ranked sort true;
["native_overflow_target",_ranked isNotEqualTo [],[_ranked,_limit,_shared]] call _check;
if (_ranked isNotEqualTo []) then {
    private _marker=(_ranked # 0) # 1;
    private _expected=+(garrison getVariable [_marker,[]]);
    private _previous=-1;
    for "_visit" from 1 to 2 do {
        private _prefix=format ["visit_%1_",_visit];
        forcedSpawn pushBackUnique _marker;
        private _started=[{_marker in (missionNamespace getVariable ["A3I_sites",createHashMap])}] call _wait;
        [_prefix+"dispatch",_started,[_marker]] call _check;
        if (_started) then {
            private _record=A3I_sites get _marker;
            [_prefix+"new_controller",(_record get "id")!=_previous] call _check;
            _previous=_record get "id";
            private _ready=[{count ((_record get "units") select {alive _x})==_limit},180] call _wait;
            [_prefix+"roster_accounted",_ready && {_record get "fault"==""}
                && {count ((_record get "units") select {alive _x})+count (_record get "queue")==count _expected},
                [count ((_record get "units") select {alive _x}),count (_record get "queue"),count _expected]] call _check;
            if (_visit==1 && {_ready}) then {
                private _initial=+(_record get "units");
                private _victims=(_initial select {alive _x}) select [0,4];
                private _beforeQueue=count (_record get "queue");
                {
                    private _index=_expected find (_x getVariable ["unitType",""]);
                    if (_index>=0) then {_expected deleteAt _index};
                } forEach _victims;
                // setDamage invokes actual engine Killed handlers, not a mocked callback.
                {_x setDamage 1} forEach _victims;
                private _dead=[{(_victims findIf {alive _x || {!(_x getVariable ["A3I_finalized",false])}})==-1},30] call _wait;
                ["four_deaths_handled",_dead && {count _victims==4}] call _check;
                private _updated=[{garrison getVariable [_marker,[]] isEqualTo _expected},30] call _wait;
                ["native_roster_reduced",_updated,[count _expected,count (garrison getVariable [_marker,[]])]] call _check;
                private _refilled=[{count ((_record get "units") select {alive _x})==_limit
                    && {count (_record get "queue")==_beforeQueue-4}},180] call _wait;
                ["queue_replaces_casualties",_refilled,[count (_record get "queue"),_beforeQueue]] call _check;
                private _new=(_record get "units") select {alive _x && {!(_x in _initial)}};
                ["four_new_initialized_infected",count _new==4 && {(_new findIf {side group _x!=west
                    || {!(_x getVariable ["A3I_initialized",false])}})==-1}] call _check;
                ["no_roster_loss_or_duplication",count ((_record get "units") select {alive _x})
                    +count (_record get "queue")==count _expected && {sidesX getVariable [_marker,sideUnknown]==west}] call _check;
            };
            private _living=(_record get "units") select {alive _x};
            forcedSpawn=forcedSpawn-[_marker];
            private _retired=[{!(_marker in A3I_sites) && {spawner getVariable [_marker,0]==2}
                && {(_living findIf {!isNull _x})==-1}}] call _wait;
            [_prefix+"cleanup",_retired] call _check;
            private _context="site:"+_marker;
            [_prefix+"budget_released",((keys A3I_budgetRecords) findIf {(A3I_budgetRecords get _x) # 0==_context})==-1] call _check;
            [_prefix+"reduced_roster_preserved",garrison getVariable [_marker,[]] isEqualTo _expected] call _check;
        } else {forcedSpawn=forcedSpawn-[_marker]};
    };
};
diag_log format ["[INFECTION_CAMPAIGN_CASUALTIES] %1",["complete",_checks,_failures]];
