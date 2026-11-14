// Isolated observer injection; preserves native discovery. Not client/JIP proof.
private _observers = call A3I_fnc_testNativeSpawnObservers;
{_observers pushBackUnique _x} forEach (missionNamespace getVariable ["A3I_test_observers",[]]);
_observers
