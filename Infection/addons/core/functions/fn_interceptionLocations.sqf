// Towns and permanent sites only. Controls and HQ never become endpoints.
private _locations = [];
{_locations append (missionNamespace getVariable [_x,[]])}
    forEach ["citiesX","airportsX","milbases","outposts","seaports","resourcesX","factories","milAdministrationsX"];
_locations = _locations arrayIntersect _locations;
_locations select {
    _x isEqualType "" && {_x in allMapMarkers}
    && {_x != missionNamespace getVariable ["respawnTeamPlayer",""]}
    && {!(_x in (missionNamespace getVariable ["controlsX",[]]))}
    && {if (_x in (missionNamespace getVariable ["milAdministrationsX",[]])) then {
        private _position = getMarkerPos _x;
        ((missionNamespace getVariable ["A3A_milAdministrations",[]]) findIf {
            !isNull _x && {_x distance2D _position < 30}
            && {!(_x in (missionNamespace getVariable ["A3A_destroyedMilAdministrations",[]]))}
        }) != -1
    } else {
        markerShape _x in ["ELLIPSE","RECTANGLE"]
        && {(markerSize _x findIf {_x <= 0 || {!finite _x}}) == -1}
    }}
}
