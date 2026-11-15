// Real engine objects and marker geometry; no delivery mission or rewards yet.
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace;
private _hq = "a3i_delivery_hq";
private _site = "a3i_delivery_site";
respawnTeamPlayer = _hq; posHQ = [4000,4000,0];
createMarker [_hq,posHQ];
createMarker [_site,[4500,4000,0]];
_site setMarkerShape "ELLIPSE"; _site setMarkerSize [80,50];
sidesX setVariable [_site,teamPlayer,true];
airportsX = []; milbases = []; outposts = []; factories = []; resourcesX = []; seaports = [];
citiesX = []; controlsX = []; milAdministrationsX = [];
private _truck = createVehicle ["O_Truck_03_ammo_F",[4101,4000,0],[],0,"CAN_COLLIDE"];
_truck enableSimulationGlobal false;
private _group = createGroup civilian;
private _survivor = _group createUnit ["C_man_1",[4051,4000,0],[],0,"NONE"];
_survivor enableSimulationGlobal false;
private _faction = A3A_faction_occ;
A3A_faction_occ = createHashMap;
["delivery_inactive",([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""] call _check;
A3A_faction_occ = _faction;
["delivery_invalid_subject_or_kind",([objNull,"truck"] call A3I_fnc_deliveryDestination) == ""
    && {([_truck,"unknown"] call A3I_fnc_deliveryDestination) == ""}] call _check;
_truck setPosATL [4099,4000,0];
["delivery_hq_truck_inside",([_truck,"truck"] call A3I_fnc_deliveryDestination) == _hq] call _check;
_truck setPosATL [4101,4000,0];
["delivery_hq_truck_outside",([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""] call _check;
_survivor setPosATL [4049,4000,0];
["delivery_hq_survivor_inside",([_survivor,"survivor"] call A3I_fnc_deliveryDestination) == _hq] call _check;
_survivor setPosATL [4051,4000,0];
["delivery_hq_survivor_outside",([_survivor,"survivor"] call A3I_fnc_deliveryDestination) == ""] call _check;
_truck setPosATL [4500,4000,0]; _survivor setPosATL [4500,4005,0];
{
    missionNamespace setVariable [_x,[_site]];
    ["delivery_site_" + _x,([_truck,"truck"] call A3I_fnc_deliveryDestination) == _site
        && {([_survivor,"survivor"] call A3I_fnc_deliveryDestination) == _site}] call _check;
    missionNamespace setVariable [_x,[]];
} forEach ["airportsX","milbases","outposts","factories","resourcesX","seaports"];
factories = [_site];
_truck setPosATL [4581,4000,0];
["delivery_outside_site_boundary",([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""] call _check;
_truck setPosATL [4500,4000,0];
sidesX setVariable [_site,west,true];
private _west = [_truck,"truck"] call A3I_fnc_deliveryDestination;
sidesX setVariable [_site,east,true];
["delivery_enemy_sites_refused",_west == "" && {([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""}] call _check;
sidesX setVariable [_site,teamPlayer,true];
["delivery_ownership_rechecked",([_truck,"truck"] call A3I_fnc_deliveryDestination) == _site] call _check;
{
    missionNamespace setVariable [_x,[_site]];
    ["delivery_excludes_" + _x,([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""] call _check;
    missionNamespace setVariable [_x,[]];
} forEach ["citiesX","controlsX","milAdministrationsX"];
_site setMarkerShape "ICON"; _site setMarkerType "mil_dot";
["delivery_invalid_site_shape",([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""] call _check;
_site setMarkerShape "RECTANGLE"; _site setMarkerSize [20,80]; _site setMarkerDir 90;
_truck setPosATL [4560,4000,0];
["delivery_rotated_rectangle",([_truck,"truck"] call A3I_fnc_deliveryDestination) == _site] call _check;
_site setMarkerSize [0,80];
["delivery_zero_size_refused",([_truck,"truck"] call A3I_fnc_deliveryDestination) == ""] call _check;
_site setMarkerSize [80,50]; _truck setPosATL [4500,4000,0];
deleteMarker _hq;
["delivery_missing_hq_keeps_sites",([_truck,"truck"] call A3I_fnc_deliveryDestination) == _site] call _check;
private _side = sidesX getVariable _site;
private _damage = damage _truck;
[_truck,"truck"] call A3I_fnc_deliveryDestination;
["delivery_read_only",sidesX getVariable _site == _side && {damage _truck == _damage}
    && {alive _survivor} && {factories isEqualTo [_site]}] call _check;
_survivor setDamage 1; sleep 0.1;
["delivery_dead_subject_refused",([_survivor,"survivor"] call A3I_fnc_deliveryDestination) == ""] call _check;
{deleteVehicle _x} forEach [_truck,_survivor,sidesX];
sleep 0.2; deleteGroup _group; deleteMarker _site;
sleep 1;
["delivery_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
