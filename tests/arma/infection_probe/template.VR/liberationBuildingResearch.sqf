// Engine investigation only. These diagnostics are not acceptance checks.
private _oldDestroyed = missionNamespace getVariable ["destroyedBuildings",[]];
destroyedBuildings = [];
private _handler = addMissionEventHandler ["BuildingChanged", {
    params ["_oldBuilding","_newBuilding","_isRuin"];
    diag_log text ("[A3I_BUILDING_RESEARCH] " + str ["changed",typeOf _oldBuilding,typeOf _newBuilding,_isRuin,getPosATL _oldBuilding,getPosATL _newBuilding]);
    if (_isRuin) then {
        _oldBuilding setVariable ["ruins",_newBuilding];
        _newBuilding setVariable ["building",_oldBuilding];
        destroyedBuildings pushBack _oldBuilding;
    };
}];
{
    private _building = createVehicle [_x,[5000,4500,0],[],0,"CAN_COLLIDE"];
    sleep 1;
    private _originalPos = getPosATL _building;
    diag_log text ("[A3I_BUILDING_RESEARCH] " + str ["initial",_x,local _building,damage _building,_originalPos,count (_building buildingPos -1),getText (configFile >> "CfgVehicles" >> _x >> "destrType")]);
    _building setDamage 0.8;
    sleep 2;
    diag_log text ("[A3I_BUILDING_RESEARCH] " + str ["partial",_x,damage _building,alive _building,getPosATL _building,isObjectHidden _building,[_building] call A3A_fnc_repairRuinedBuilding]);
    _building setDamage 1;
    sleep 12;
    private _ruin = _building getVariable ["ruins",objNull];
    diag_log text ("[A3I_BUILDING_RESEARCH] " + str ["ruined",_x,damage _building,alive _building,getPosATL _building,isObjectHidden _building,typeOf _ruin,count destroyedBuildings]);
    private _repair = [_building] call A3A_fnc_repairRuinedBuilding;
    sleep 5;
    diag_log text ("[A3I_BUILDING_RESEARCH] " + str ["repaired",_x,_repair,damage _building,alive _building,getPosATL _building,isObjectHidden _building,isNull _ruin,count destroyedBuildings]);
    deleteVehicle _building;
    deleteVehicle _ruin;
    sleep 1;
} forEach ["Land_i_House_Small_01_V1_F","Land_i_House_Big_01_V1_F"];
removeMissionEventHandler ["BuildingChanged",_handler];
destroyedBuildings = _oldDestroyed;
private _smoke = configFile >> "CfgVehicles" >> "test_EmptyObjectForSmoke";
diag_log text ("[A3I_BUILDING_RESEARCH] " + str ["smoke_config",getText (_smoke >> "simulation"),getText (_smoke >> "EventHandlers" >> "init"),getText (_smoke >> "EventHandlers" >> "deleted")]);
