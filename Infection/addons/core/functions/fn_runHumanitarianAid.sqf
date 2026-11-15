params ["_record"];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {};
private _position = call A3I_fnc_findAidPackagePosition;
if (_position isEqualTo []) exitWith {_record set ["fault","no_safe_hq_position"]};
isNil {
    private _name = _record get "name";
    private _current = A3I_aidTasks getOrDefault [_name,createHashMap];
    if (_current getOrDefault ["serial",-1] != _record get "serial"
        || {_record get "settled"} || {_record get "phase" != "preparing"}
        || {!((_record get "target") in (call A3I_fnc_aidTargets))}) exitWith {_record set ["fault","target_changed"]};
    private _pickup = _name+"_package";
    if (_pickup in allMapMarkers) exitWith {_record set ["fault","marker_name_in_use"]};
    private _made = [_position] call A3I_fnc_createAidPackage;
    private _package = _made # 0;
    if (isNull _package) exitWith {_record set ["fault",_made # 1]};
    _record set ["package",_package];
    _package setVariable ["A3I_aidTaskOwner",[_name,_record get "serial"]];
    _record set ["loadJipKey","A3A_Logistics_load"+((str _package splitString ":") joinString "")];
    private _ledger = [_name,_record get "target",_package,time+(_record get "duration"),_record get "difficult"] call A3I_fnc_createAidLedger;
    if (count _ledger == 0) exitWith {_record set ["fault","ledger_registration_failed"]};
    _record set ["ledger",_ledger];
    private _town = [_record get "target"] call A3A_fnc_localizar;
    _record set ["townName",_town];
    createMarker [_pickup,getPosATL _package]; _pickup setMarkerType "mil_box";
    _pickup setMarkerColor "ColorGUER"; _pickup setMarkerText "Humanitarian Aid supplies";
    _record set ["pickupMarker",_pickup];
    private _description = format ["%1 has a lot of survivors who need our help. Deliver a package of supplies to them to buy time before we can move in for cleansing.<br/><br/>Collect the marked supplies at HQ and deliver them within 40 metres of the town marker. Unload the package from its vehicle or sling, keep a capable Rebel escort within 80 metres, and clear infected within 50 metres. Unloading takes %2 seconds and pauses while those conditions are not met. You have %3 minutes. The mission cancels without penalty if another faction captures the town.",_town,_ledger get "requiredSeconds",(_record get "duration")/60];
    [[teamPlayer,civilian],_name,[_description,"Humanitarian Aid",_town],getMarkerPos (_record get "target"),false,0,true,"Heal",true] call BIS_fnc_taskCreate;
    [_name,"SUPP","CREATED"] call A3A_fnc_taskUpdate;
    _record set ["taskRegistered",true]; _record set ["phase","active"];
    _package setVariable ["A3I_aidDisplay",[_record get "serial",_town,_ledger get "requiredSeconds","paused"],true];
    [_package] remoteExec ["A3I_fnc_aidPackageActions",[teamPlayer,civilian],_package];
};
