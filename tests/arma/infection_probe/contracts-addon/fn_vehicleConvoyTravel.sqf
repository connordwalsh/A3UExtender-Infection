if (!(missionNamespace getVariable ["A3I_test_convoyMode",false])) exitWith {_this call A3I_fnc_testNativeVehicleConvoyTravel};
A3I_test_convoyTravel pushBack +_this;
params ["_vehicle","_route","_convoy","_speed","_objective"];
if (_objective) then {A3I_test_convoyObjective = _vehicle};
