// Owner-approved sources: towns, bases, outposts and airfields, infected-held only.
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)} || {isNil "sidesX"}) exitWith {[]};
private _allowed = [];
{_allowed append (missionNamespace getVariable [_x,[]])} forEach ["citiesX","milbases","outposts","airportsX"];
(call A3I_fnc_interceptionLocations) select {
    _x in _allowed && {sidesX getVariable [_x,sideUnknown] == west}
    && {!(_x in (missionNamespace getVariable ["milAdministrationsX",[]]))}
}
