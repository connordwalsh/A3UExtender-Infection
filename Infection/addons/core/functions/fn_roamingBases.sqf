// Read-only selection shared with the mixed patrol adapter. The ordinary-side
// predicate is the pinned native one; infected seaports can supply land patrols.
#include "\x\a3a\addons\core\script_component.hpp"
params [["_players",allPlayers - entities "HeadlessClient_F",[[]]]];
(seaports + airportsX + outposts + milbases) select {
    call {
        if (!(_x in allMapMarkers) || {_players inAreaArray [markerPos _x,2000,2000] isEqualTo []}) exitWith {false};
        private _side = sidesX getVariable [_x,sideUnknown];
        if (_side == teamPlayer) exitWith {false};
        if ([_side] call A3I_fnc_isActive) exitWith {
            [_x] call A3I_fnc_roamingEligible && {!(isNil "NavGrid")}
            && {!(isNil "A3A_navCellHM")} && {[getMarkerPos _x] call A3A_fnc_getNearestNavPoint != -1}
        };
        if (_x in seaports and Faction(_side) get "vehiclesGunBoats" isEqualTo []) exitWith {false};
        if (_x call A3A_fnc_getMarkerNavPoint == -1) exitWith {false};
        true
    }
}
