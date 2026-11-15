// Optional faction packs are represented by Ultimate's selected template pools.
params [["_kind","",[""]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {[]};
private _definition = switch (_kind) do {
    case "civilian": {["A3A_faction_civ","vehiclesCivCar",["C_Offroad_01_F","C_Hatchback_01_F","C_SUV_01_F"]]};
    case "police": {["A3A_faction_inv","vehiclesPolice",["B_GEN_Offroad_01_gen_F"]]};
    case "military": {["A3A_faction_inv","vehiclesLightUnarmed",["O_MRAP_02_F"]]};
    default {[]};
};
if (_definition isEqualTo []) exitWith {[]};
private _valid = {
    params ["_pool"];
    if !(_pool isEqualType []) exitWith {[]};
    _pool select {_x isEqualType "" && {isClass (configFile >> "CfgVehicles" >> _x)}
        && {getNumber (configFile >> "CfgVehicles" >> _x >> "scope") == 2}
        && {_x isKindOf "Car"} && {!(_x isKindOf "Wheeled_APC_F")}
        && {getNumber (configFile >> "CfgVehicles" >> _x >> "isUav") == 0}}
};
private _faction = missionNamespace getVariable [_definition # 0,createHashMap];
private _classes = if (_faction isEqualType createHashMap) then {
    [_faction getOrDefault [_definition # 1,[]]] call _valid
} else {[]};
if (_classes isEqualTo []) then {_classes = [_definition # 2] call _valid};
_classes
