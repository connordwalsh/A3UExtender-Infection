// Prefer the selected Russian/Invader template's declared logistics pools.
// Vanilla stand-ins keep the three approved roles available without extra mods.
params [["_kind","",[""]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {[]};
private _definition = switch (_kind) do {
    case "ammunition": {["vehiclesAmmoTrucks",["O_Truck_02_Ammo_F","O_Truck_03_ammo_F"]]};
    case "fuel": {["vehiclesFuelTrucks",["O_Truck_02_fuel_F","O_Truck_03_fuel_F"]]};
    case "repair": {["vehiclesRepairTrucks",["O_Truck_02_box_F","O_Truck_03_repair_F"]]};
    default {[]};
};
if (_definition isEqualTo []) exitWith {[]};
private _valid = {
    params ["_pool"];
    if !(_pool isEqualType []) exitWith {[]};
    _pool select {_x isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _x)}
        && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") == 2}
        && {_x isKindOf "Car"} && {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") == 0}}
};
private _faction = missionNamespace getVariable ["A3A_faction_inv",createHashMap];
private _pool = if (_faction isEqualType createHashMap) then {
    [_faction getOrDefault [_definition # 0,[]]] call _valid
} else {[]};
if (_pool isEqualTo []) then {_pool = [_definition # 1] call _valid};
_pool
