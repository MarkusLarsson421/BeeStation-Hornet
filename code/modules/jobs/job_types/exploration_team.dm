/datum/job/exploration_crew
	title = JOB_NAME_EXPLORATIONCREW
	description = "Go out into space to complete different missions for loads of cash. Find and deliver back research disks for rare technologies."
	department_for_prefs = DEPT_BITFLAG_SCI
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	supervisors = "the research director, and the head of your department (if applicable)"
	faction = "Station"
	total_positions = 3
	spawn_positions = 3
	minimal_player_age = 3
	exp_requirements = 900
	exp_type = EXP_TYPE_CREW
	selection_color = "#ffeeff"

	outfit = /datum/outfit/job/exploration_crew

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_MECH_SCIENCE, ACCESS_XENOBIOLOGY)
	minimal_access = list(ACCESS_RESEARCH, ACCESS_EXPLORATION, ACCESS_TOX, ACCESS_MECH_SCIENCE)

	departments = DEPT_BITFLAG_SCI
	bank_account_department = ACCOUNT_SCI_BITFLAG
	payment_per_department = list(ACCOUNT_SCI_ID = PAYCHECK_HARD)

	display_order = JOB_DISPLAY_ORDER_EXPLORATION
	rpg_title = "Sailor"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/exploration_crew
	)
	biohazard = 40//who knows what you'll find out there that could have nasties on it...

	lightup_areas = list(
		/area/science/mixing,
		/area/science/storage,
		/area/science/xenobiology
	)
	minimal_lightup_areas = list(/area/quartermaster/exploration_dock, /area/quartermaster/exploration_prep)

GLOBAL_LIST_INIT(available_exp_depts, list(EXP_DEPT_ENGINEERING, EXP_DEPT_MEDICAL, EXP_DEPT_SCIENCE))

/datum/job/exploration_crew/after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	. = ..()
	// Assign department exploration
	var/department
	if(preference_source?.prefs)
		department = preference_source.prefs.read_character_preference(/datum/preference/choiced/exploration_department)
		if(!LAZYLEN(GLOB.available_exp_depts) || department == "None")
			return
		if(!on_dummy && M.client)
			if(department in GLOB.available_exp_depts)
				LAZYREMOVE(GLOB.available_exp_depts, department)
			else
				department = pick_n_take(GLOB.available_exp_depts)
	var/ears = null
	var/list/dep_access = null
	switch(department)
		if(EXP_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_exploration/eng
			if(!on_dummy)
				dep_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE, ACCESS_CONSTRUCTION, ACCESS_TECH_STORAGE)
				minimal_lightup_areas |= GLOB.engineering_lightup_areas
		if(EXP_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_exploration/med
			if(!on_dummy)
				dep_access = list(ACCESS_MECH_MEDICAL, ACCESS_MEDICAL)
				minimal_lightup_areas |= GLOB.medical_lightup_areas
		if(EXP_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_exploration/sci
			if(!on_dummy)
				dep_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_MECH_SCIENCE)
				minimal_lightup_areas |= GLOB.science_lightup_areas

	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),ITEM_SLOT_EARS)

	var/obj/item/card/id/W = H.wear_id
	W.access |= dep_access

	if(!M.client || on_dummy)
		return

	switch(department)
		if(EXP_DEPT_SCIENCE)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'sciradio'>Scientist</span>!</span>")
			to_chat(H, "<span class='notice'>Scan undiscovered creates to gain discovery research points!</span>")
			outfit_override = /datum/outfit/job/exploration_crew/scientist
		if(EXP_DEPT_MEDICAL)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'medradio'>Medical Doctor</span>!</span>")
			to_chat(H, "<span class='notice'>Ensure your team's health by locating and healing injured team members.</span>")
			outfit_override = /datum/outfit/job/exploration_crew/medic
		if(EXP_DEPT_ENGINEERING)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'engradio'>Engineer</span>!</span>")
			to_chat(H, "<span class='notice'>Create entry points with your explosives and maintain the hull of your ship.</span>")
			outfit_override = /datum/outfit/job/exploration_crew/engineer
		else
			to_chat(M, "<b>You have not been assigned to any department. Assist the other Explorers help where needed.</b>")

/datum/outfit/job/exploration_crew
	name = JOB_NAME_EXPLORATIONCREW
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew
	belt = /obj/item/modular_computer/tablet/pda/exploration_crew
	shoes = /obj/item/clothing/shoes/jackboots
	uniform = /obj/item/clothing/under/rank/cargo/exploration

	chameleon_extras = /obj/item/gun/energy/e_gun/mini/exploration

/datum/outfit/job/exploration_crew/scientist
	name = "Exploration Scientist"

/datum/outfit/job/exploration_crew/engineer
	name = "Exploration Engineer"
	belt = /obj/item/modular_computer/tablet/pda/exploration_crew

/datum/outfit/job/exploration_crew/medic
	name = "Exploration Doctor"

/datum/outfit/job/exploration_crew/hardsuit
	name = "Exploration Crew (Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/exploration
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/breath
