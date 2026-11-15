// Native townBattle chooses a Rebel vehicle category, then a class. Retain that
// weighting, but never select an empty category, invalid class, aircraft or UAV.
private _faction = missionNamespace getVariable ["A3A_faction_reb",createHashMap];
if !(_faction isEqualType createHashMap) exitWith {[]};
private _categories = [];
{
    private _pool = _faction getOrDefault [_x,_faction getOrDefault ["vehiclesBasic",[]]];
    if !(_pool isEqualType []) then {continue};
    private _valid = _pool select {
        _x isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _x)}
        && {_x isKindOf "Car" || {_x isKindOf "Tank"}}
        && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") == 2}
        && {getNumber (configFile >> "CfgVehicles" >> _x >> "hasDriver") > 0}
        && {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") == 0}
    };
    if (_valid isNotEqualTo []) then {_categories pushBack _valid};
} forEach ["vehiclesLightArmed","vehiclesLightUnarmed","vehiclesAT","vehiclesCivCar","vehiclesCivSupply"];
_categories
