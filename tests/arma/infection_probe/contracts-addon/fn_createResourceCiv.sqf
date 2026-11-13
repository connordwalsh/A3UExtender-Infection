// Preserve the group/unit return contract; the campaign's worker behavior is not tested here.
params ["_marker","_count"];
A3I_test_workerCalls pushBack +_this;
private _group = createGroup [civilian,false];
private _units = [];
for "_index" from 1 to _count do {
    private _unit = _group createUnit ["C_man_1",(getMarkerPos _marker) vectorAdd [10 * _index,10,0],[],0,"NONE"];
    _unit disableAI "ALL";
    _units pushBack _unit;
};
[_group,_units]
