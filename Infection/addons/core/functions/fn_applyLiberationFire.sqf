// Server-issued presentation only. A single persistent call applies the whole
// effect for current and joining clients; no actors or campaign state are made.
params [["_emitter",objNull,[objNull]],["_light",objNull,[objNull]],
    ["_type","",[""]]];
if (!isRemoteExecuted || {remoteExecutedOwner != 2}) exitWith {false};
if (isNull _emitter || {isNull _light} || {typeOf _emitter != "#particlesource"}
    || {typeOf _light != "#lightpoint"}
    || {!(_type in ["BigDestructionFire","SmallDestructionFire"])}) exitWith {false};
_emitter setParticleClass _type;
_light setLightBrightness 0.3;
_light setLightAmbient [0.70,0.3,0.3];
_light setLightColor [0.70,0.3,0.3];
true
