// Towns and permanent sites only. Controls and HQ never become endpoints.
private _locations = [];
{_locations append (missionNamespace getVariable [_x,[]])}
    forEach ["citiesX","airportsX","milbases","outposts","seaports","resourcesX","factories","milAdministrationsX"];
_locations = _locations arrayIntersect _locations;
_locations select {
    _x isEqualType "" && {_x in allMapMarkers}
    && {_x != missionNamespace getVariable ["respawnTeamPlayer",""]}
    && {!(_x in (missionNamespace getVariable ["controlsX",[]]))}
    && {markerShape _x in ["ELLIPSE","RECTANGLE"]}
    && {(markerSize _x findIf {_x <= 0 || {!finite _x}}) == -1}
}
