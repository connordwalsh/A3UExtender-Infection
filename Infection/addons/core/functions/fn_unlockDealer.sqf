// Preserve native unlock triggers, location constraints, trader services and save fields.
params [["_source","",[""]]];
if (!isServer || {isRemoteExecuted} || {!canSuspend} || {!([west] call A3I_fnc_isActive)}
    || {missionNamespace getVariable ["disableTrader",true]}
    || {missionNamespace getVariable ["isTraderQuestCompleted",false]}
    || {_source == ""} || {!(_source in allMapMarkers)}) exitWith {false};
isTraderQuestAssigned=true;publicVariable "isTraderQuestAssigned";
private _center=getMarkerPos _source;
private _enemySites=(airportsX+milbases+outposts+seaports+factories+resourcesX)
    select {sidesX getVariable [_x,sideUnknown] != teamPlayer};
private _position=[];
// Native terrain and enemy-site clearance, with bounded failure instead of an endless search.
for "_attempt" from 0 to 199 do {
    private _radius=if (_attempt==0) then {300} else {100+5*_attempt};
    private _candidate=[_center,0,_radius,0,0,0.3,0,[],[_center,_center]] call BIS_fnc_findSafePos;
    private _gradient=[_candidate,0] call BIS_fnc_terrainGradAngle;
    if (_gradient > -0.25 && {_gradient < 0.25} && {!isOnRoad _candidate}
        && {!surfaceIsWater _candidate} && {(_candidate findIf {_x<0 || {_x>worldSize}})==-1}
        && {(_enemySites findIf {_candidate distance2D getMarkerPos _x < 300 || {_candidate inArea _x}})==-1})
        exitWith {_position=_candidate};
};
if (_position isEqualTo []) exitWith {false};
private _trader=[_position] call SCRT_fnc_trader_createTrader;
if (isNil "_trader" || {isNull _trader}) exitWith {false};
traderX=_trader;publicVariable "traderX";
[traderX] call SCRT_fnc_trader_setStockType;
[traderX] remoteExecCall ["SCRT_fnc_trader_addVehicleMarketAction",0,true];
traderPosition=_position;publicVariable "traderPosition";
traderMarker=createMarker ["TraderMarker",_position];
traderMarker setMarkerType "A3AU_dealer_mrk";
traderMarker setMarkerSize [1,1];traderMarker setMarkerText "";
traderMarker setMarkerColor "ColorUNKNOWN";traderMarker setMarkerAlpha 1;
sidesX setVariable [traderMarker,teamPlayer,true];publicVariable "traderMarker";
isTraderQuestAssigned=false;isTraderQuestCompleted=true;
publicVariable "isTraderQuestAssigned";publicVariable "isTraderQuestCompleted";
[traderMarker] call A3A_fnc_mrkUpdate;
true
