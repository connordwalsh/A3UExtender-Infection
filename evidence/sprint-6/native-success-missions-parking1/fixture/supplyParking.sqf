// Read-only search survey over current infected-held locations. No ownership,
// geometry, faction, search endpoint, timer, or vehicle is altered by the probe.
private _plan=[];
{
    private _site=_x;
    {
        private _kind=_x;
        {
            _plan pushBack [_site,_kind,_x];
        } forEach (([_kind] call A3I_fnc_supplyTruckClasses) arrayIntersect ([_kind] call A3I_fnc_supplyTruckClasses));
    } forEach ([_site] call A3I_fnc_supplySiteKinds);
} forEach (call A3I_fnc_interceptionLocations);
diag_log format ["[INFECTION_SUPPLY_PARKING] %1",["start",worldName,count _plan]];
{diag_log format ["[INFECTION_SUPPLY_PARKING] %1",["planned"]+_x]} forEach _plan;
private _found=0;private _unavailable=0;private _invalid=0;
{
    _x params ["_site","_kind","_class"];
    private _start=diag_tickTime;
    private _parking=[_site,_class] call A3I_fnc_findSupplyPosition;
    private _elapsed=diag_tickTime-_start;
    private _available=_parking # 0 isNotEqualTo [];
    private _valid=true;
    if (_available) then {
        _found=_found+1;
        _valid=([_parking # 0,_site] call A3I_fnc_interceptionContains)
            && {([_parking # 0,_class,call A3I_fnc_spawnObservers,getMarkerPos respawnTeamPlayer] call A3I_fnc_positionSafety) # 0}
            && {([_parking # 0,_class,_parking # 1] call A3I_fnc_supplyPositionClear) # 0};
        if (!_valid) then {_invalid=_invalid+1};
    } else {_unavailable=_unavailable+1};
    diag_log format ["[INFECTION_SUPPLY_PARKING] %1",["result",_site,_kind,_class,_available,_valid,_parking,_elapsed]];
    sleep 0.05;
} forEach _plan;
diag_log format ["[INFECTION_SUPPLY_PARKING] %1",["complete",count _plan,_found,_unavailable,_invalid]];
