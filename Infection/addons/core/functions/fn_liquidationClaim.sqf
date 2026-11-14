// Only a live, unfinished assignment can constrain normal capture rules.
params [["_marker","",[""]]];
private _record = (missionNamespace getVariable ["A3I_liquidationClaims",createHashMap])
    getOrDefault [_marker,createHashMap];
if (_record getOrDefault ["settled",true] || {_record getOrDefault ["outcome",""] != "pending"}
    || {_record getOrDefault ["target",""] != _marker}) exitWith {createHashMap};
_record
