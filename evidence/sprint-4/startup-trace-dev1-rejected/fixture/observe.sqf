if (!isServer) exitWith {};
diag_log format ["[INFECTION_TRACE] %1",["preInit",time,count allMissionObjects "All"]];
A3ITrace_created=0;
A3ITrace_createdEH=addMissionEventHandler ["EntityCreated",{
    params ["_object"];
    A3ITrace_created=A3ITrace_created+1;
    if (A3ITrace_created<=70) then {
        diag_log format ["[INFECTION_TRACE] %1",["created",time,typeOf _object,netId _object,str _object,vehicleVarName _object]];
    };
}];
A3ITrace_deletedEH=addMissionEventHandler ["EntityDeleted",{
    params ["_object"];
    diag_log format ["[INFECTION_TRACE] %1",["deleted",time,typeOf _object,netId _object,str _object,vehicleVarName _object]];
}];
[] spawn {
    sleep 10;
    removeMissionEventHandler ["EntityCreated",A3ITrace_createdEH];
    removeMissionEventHandler ["EntityDeleted",A3ITrace_deletedEH];
    diag_log format ["[INFECTION_TRACE] %1",["observation_complete",time,A3ITrace_created]];
};
