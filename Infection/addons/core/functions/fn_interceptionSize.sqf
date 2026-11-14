// Developer-tuned initial target: one complete 40-120 member basic horde.
params [["_warLevel",missionNamespace getVariable ["tierWar",0],[0]]];
if (!finite _warLevel) exitWith {40};
40 + 8 * ((floor _warLevel) max 0 min 10)
