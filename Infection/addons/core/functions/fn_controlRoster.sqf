/* Foot-only selection adapted from Ultimate 12.4.2 createAIcontrols (MIT).
   Keep its road/off-road probabilities and tiered infantry roles. Road/world
   classification belongs to the caller; no vehicle or mine pool is consulted.
   [isRoad, isFrontline] -> [roles, branch]. Empty roles mean no visit spawn. */
params [["_road",false,[true]],["_frontline",false,[true]]];
if !([west] call A3I_fnc_isActive) exitWith {[[],"inactive"]};
private _faction = A3A_faction_occ;
if (_road) exitWith {
    if (random 100 >= (aggressionOccupants max A3A_roadBlocksBaseChance)) exitWith {[[],"road_skipped"]};
    if (_frontline) exitWith {
        private _roles = +(selectRandom (_faction get "groupsMilitiaMedium"));
        // Both former static crew positions become ordinary foot defenders.
        private _crew = [_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered;
        _roles append [_crew,_crew];
        [_roles,"road_frontline"]
    };
    private _aggr = aggressionOccupants;
    private _police = linearConversion [0,60,_aggr,1,0,true];
    private _militia = linearConversion [40,60,_aggr,0.2,1,true] * linearConversion [60,85,_aggr,1,0.3,true];
    private _apc = linearConversion [40,80,_aggr,0,1,true];
    private _tank = linearConversion [70,120,_aggr,0,1,true];
    // All three former military vehicle categories use the same foot roles.
    if (selectRandomWeighted [true,_police,false,_militia + _apc + _tank]) then {
        private _roles = +(_faction get "groupPoliceOfficers");
        _roles pushBack (_faction get "unitPoliceOfficer");
        [_roles,"road_police"]
    } else {
        private _roles = +([_faction get "groupTierFireteam"] call SCRT_fnc_unit_getTiered);
        _roles pushBack ([_faction get "unitTierStaticCrew"] call SCRT_fnc_unit_getTiered);
        [_roles,"road_military"]
    }
};
if (_frontline) exitWith {[+(selectRandom (_faction get "groupSpecOpsRandom")),"field_frontline"]};
if (random 100 > tierWar * 3 + aggressionOccupants / 5) exitWith {[[],"field_skipped"]};
[+([_faction get "groupTierPatrolSniper"] call SCRT_fnc_unit_getTiered),"field_patrol"]
