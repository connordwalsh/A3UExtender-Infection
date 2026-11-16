// Read-only town eligibility shared by the server selector and client map shortcut.
// Mission construction, locks and authoritative revalidation remain server-owned.
params [["_marker","",[""]]];
if (!([west] call A3I_fnc_isActive) || {isNil "sidesX"} || {isNil "A3A_townData"}
    || {isNil "distanceMission"} || {!(distanceMission isEqualType 0)}
    || {!finite distanceMission} || {distanceMission<=0}
    || {!(_marker in (missionNamespace getVariable ["citiesX",[]]))}
    || {!(_marker in allMapMarkers)} || {_marker in (missionNamespace getVariable ["destroyedSites",[]])}
    || {sidesX getVariable [_marker,sideUnknown]!=west}) exitWith {false};
private _hq=missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq isEqualType "" && {_hq in allMapMarkers}) exitWith {false};
private _data=A3A_townData getOrDefault [_marker,[]];
if !(_data isEqualType [] && {count _data>=4}) exitWith {false};
private _support=_data # 3;
_support isEqualType 0 && {finite _support} && {_support>=0} && {_support<90}
    && {getMarkerPos _marker distance2D getMarkerPos _hq<distanceMission}
