if (!isServer || {isRemoteExecuted} || {isNil "petros"} || {isNull petros}
    || {!alive petros} || {isNil "distanceMission"}) exitWith {[]};
[call A3I_fnc_extractionLocations,petros,true] call A3A_fnc_findIfNearAndHostile
