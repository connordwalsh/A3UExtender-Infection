if (!(missionNamespace getVariable ["A3I_test_convoyMode",false])) exitWith {_this call A3I_fnc_testNativeAIVEHinit};
A3I_test_convoyVehicles pushBack +_this;
