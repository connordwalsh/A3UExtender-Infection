/* Approved 14 November 2026: full-town shifted logistic, floor 10, cap 200.
   [Ultimate population] -> rounded infected count; -1 rejects invalid data.
   Keep model parameters centralized for later server customization. */
params [["_population",-1]];
if !(_population isEqualType 0 && {finite _population} && {_population >= 0}) exitWith {-1};
private _growth = ln (11 / 7) / 50;
round ((400 / (1 + exp (-_growth * _population)) - 200) max 10 min 200)
