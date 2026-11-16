// Full native campaign. Only forcedSpawn requests activate/deactivate sites;
// no scheduler, creator, ownership or garrison endpoint replacements.
private _checks=0;private _failures=[];
private _siteCheck={params ["_name","_ok",["_details",[]]];
    _checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_CAMPAIGN_SITES] %1",["check",_name,_ok,_details]];
};
private _siteWait={params ["_condition",["_seconds",120]];
    private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};
    call _condition
};
diag_log "[INFECTION_CAMPAIGN_SITES] start";
private _choices=[];
{
    _x params ["_kind","_markers","_controllerKind"];
    private _ranked=[];
    {
        private _marker=_x;
        if (sidesX getVariable [_marker,sideUnknown]!=west || {_marker in forcedSpawn}
            || {spawner getVariable [_marker,2]!=2} || {getMarkerPos _marker distance2D petros<2500}) then {continue};
        private _size=if (_kind=="City") then {
            count (([_marker] call A3I_fnc_cityRoster) # 0)
        } else {count (garrison getVariable [_marker,[]])};
        if (_size>0) then {_ranked pushBack [_size,_marker]};
    } forEach _markers;
    _ranked sort true;
    if (_ranked isNotEqualTo []) then {_choices pushBack [_kind,(_ranked # 0) # 1,_controllerKind]};
} forEach [["City",citiesX,"City"],["Resource",resourcesX,"Resource"],
    ["Factory",factories,"Resource"],["Outpost",outposts,"Outpost"],
    ["Seaport",seaports,"Outpost"],["Milbase",milbases,"Milbase"],["Airport",airportsX,"Airport"]];
["seven_native_targets",count _choices==7,_choices] call _siteCheck;
{
    _x params ["_kind","_marker","_controllerKind"];
    private _priorId=-1;
    for "_visit" from 1 to 2 do {
        private _prefix=format ["%1_%2_",toLower _kind,_visit];
        private _beforeRoster=+(garrison getVariable [_marker,[]]);
        private _expected=if (_kind=="City") then {count (([_marker] call A3I_fnc_cityRoster) # 0)+count _beforeRoster} else {count _beforeRoster};
        forcedSpawn pushBackUnique _marker;
        private _started=[{_marker in (missionNamespace getVariable ["A3I_sites",createHashMap])}] call _siteWait;
        [_prefix+"native_dispatch",_started,[_marker,_expected]] call _siteCheck;
        private _record=(missionNamespace getVariable ["A3I_sites",createHashMap]) getOrDefault [_marker,createHashMap];
        if (_started) then {
            [_prefix+"new_controller",(_record get "id")!=_priorId && {_record get "kind"==_controllerKind}] call _siteCheck;
            _priorId=_record get "id";
            private _wanted=if (_kind=="City") then {_expected} else {_expected min 24};
            private _ready=[{count ((_record get "units") select {alive _x})>=_wanted || {_record get "fault"!=""}},180] call _siteWait;
            private _units=+(_record get "units");
            private _groups=+(_record get "groups");
            private _assets=(_record get "crates")+(_record get "civilians")+[_record get "flag"];
            private _queue=count (_record get "queue")+count (_record getOrDefault ["extraQueue",[]]);
            [_prefix+"full_roster_accounted",_ready && {_record get "fault"==""}
                && {count (_units select {alive _x})+_queue==_expected},[count _units,_queue,_expected,_record get "fault"]] call _siteCheck;
            [_prefix+"valid_infected",_units isNotEqualTo [] && {(_units findIf {!alive _x || {side group _x!=west}
                || {!(_x getVariable ["A3I_initialized",false])}})==-1}] call _siteCheck;
            // Use the same native forced-spawn API for release; wait for distance
            // processing, controller cleanup, and deferred engine group deletion.
            forcedSpawn=forcedSpawn-[_marker];
            private _retired=[{!(_marker in A3I_sites) && {spawner getVariable [_marker,0]==2}
                && {(_units findIf {!isNull _x})==-1} && {(_groups findIf {!isNull _x})==-1}},120] call _siteWait;
            [_prefix+"native_cleanup",_retired,[spawner getVariable [_marker,-1]]] call _siteCheck;
            private _assetsRetired=[{(_assets findIf {!isNull _x})==-1},120] call _siteWait;
            [_prefix+"asset_cleanup",_assetsRetired,[_assets apply {if (isNull _x) then {"deleted"} else {typeOf _x}}]] call _siteCheck;
            private _context="site:"+_marker;
            [_prefix+"budget_released",((keys A3I_budgetRecords) findIf {(A3I_budgetRecords get _x) # 0==_context})==-1] call _siteCheck;
            [_prefix+"roster_preserved",garrison getVariable [_marker,[]] isEqualTo _beforeRoster] call _siteCheck;
        } else {forcedSpawn=forcedSpawn-[_marker]};
    };
} forEach _choices;
diag_log format ["[INFECTION_CAMPAIGN_SITES] %1",["complete",_checks,_failures]];
