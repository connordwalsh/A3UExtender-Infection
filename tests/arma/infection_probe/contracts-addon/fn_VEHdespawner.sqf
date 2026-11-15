if (missionNamespace getVariable ["A3I_test_abandonedMode",false]) exitWith {_this call A3I_fnc_testNativeVEHdespawner};
A3I_test_vehicleCleanup pushBack +_this;
