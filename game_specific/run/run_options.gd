class_name RunOptions
extends Resource

## Characters used by the run. The [RunController] owns these instances for the
## whole run, so their state carries over between combats.
@export var hero: Hero
@export var villain: Villain
## Conditions that end a combat. Created by the [RunController] so it can read
## the result of the combat it just ran. Not exported: [EndCondition] is not a
## [Resource].
var end_conditions: Array[EndCondition] = []
## When true the combat uses the headless resolution port instead of the
## visual one. Visual combat is the default.
@export var headless: bool = false
