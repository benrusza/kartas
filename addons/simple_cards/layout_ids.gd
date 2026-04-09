# AUTO-GENERATED FILE - DO NOT EDIT MANUALLY
# This file is regenerated when layouts are modified in the Card Layouts panel

class_name LayoutID

const DEFAULT: StringName = &"default"
const DEFAULT_BACK: StringName = &"default_back"
const SPANISH_LAYOUT: StringName = &"spanish_layout"
const SPANISH_LAYOUT_BACK: StringName = &"spanish_layout_back"
const STANDARD_BACK_LAYOUT: StringName = &"standard_back_layout"
const STANDARD_LAYOUT: StringName = &"standard_layout"


## Returns all available layout IDs
static func get_all() -> Array[StringName]:
	return [
		DEFAULT,
		DEFAULT_BACK,
		SPANISH_LAYOUT,
		SPANISH_LAYOUT_BACK,
		STANDARD_BACK_LAYOUT,
		STANDARD_LAYOUT
	]


## Check if a layout ID is valid
static func is_valid(id: StringName) -> bool:
	return id in get_all()