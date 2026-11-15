// Native flat scene-wreck pool. Repeated entries retain their original weight;
// missing/empty categories do not inject an unrelated vehicle fallback.
private _classes = [];
{
    _x params ["_key","_categories"];
    private _faction = missionNamespace getVariable ["A3A_faction_" + _key,createHashMap];
    if !(_faction isEqualType createHashMap) then {continue};
    {
        private _pool = _faction getOrDefault [_x,[]];
        if !(_pool isEqualType []) then {continue};
        _classes append (_pool select {
            _x isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _x)}
            && {_x isKindOf "Car" || {_x isKindOf "Tank"}}
            && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") == 2}
            && {getNumber (configFile >> "CfgVehicles" >> _x >> "hasDriver") > 0}
            && {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") == 0}
        });
    } forEach _categories;
} forEach [
    ["occ",["vehiclesMilitiaAPCs","vehiclesMilitiaLightArmed","vehiclesMilitiaTrucks"]],
    ["reb",["vehiclesLightArmed","vehiclesLightUnarmed","vehiclesAT"]]
];
_classes
