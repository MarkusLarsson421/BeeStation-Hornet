/// Which department to put exploration crewmembers in, when the config is enabled
/datum/preference/choiced/exploration_department
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	preference_type = PREFERENCE_CHARACTER
	db_key = "preferred_exploration_department"

// This is what that #warn wants you to remove :)
/datum/preference/choiced/exploration_department/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.exploration_depts_prefs))
		return EXP_DEPT_NONE
	return ..()

/datum/preference/choiced/exploration_department/init_possible_values()
	return GLOB.exploration_depts_prefs

/datum/preference/choiced/exploration_department/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/exploration_department/create_default_value()
	return EXP_DEPT_NONE
