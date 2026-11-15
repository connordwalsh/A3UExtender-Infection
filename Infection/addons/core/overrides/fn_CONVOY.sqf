// Automatic Russian supply attacks remain world activity in Infection campaigns.
// Requested/direct convoys become walking interceptions. Ordinary campaigns
// delegate unchanged; automatic Russian supply attacks remain background activity.
if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalConvoy};
params ["_destination","_origin",["_type",""],["_pool","legacy"]];
if !(_type == "Supplies" && {_pool == "attack"} && {!isNil "sidesX"}
    && {sidesX getVariable [_origin,sideUnknown] == Invaders}) exitWith {
    [_destination,_origin] call A3I_fnc_dispatchInterception;
};
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
if (!canSuspend) exitWith {
    [{_this spawn A3I_fnc_backgroundSupplyConvoy},+_this] call CBA_fnc_execNextFrame;
};
_this call A3I_fnc_backgroundSupplyConvoy
