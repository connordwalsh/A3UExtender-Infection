if (!isServer) exitWith {};
diag_log format ["[INFECTION_TRACE] %1",["preInit",time,count activatedAddons]];
[] spawn {
    sleep 10;
    diag_log format ["[INFECTION_TRACE] %1",["observation_complete",time,count activatedAddons,
        allCurators apply {[typeOf _x,count curatorAddons _x]}]];
};
