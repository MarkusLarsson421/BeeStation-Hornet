/datum/job/exploration_crew
	title = JOB_NAME_EXPLORATIONCREW
	description = "Go out into space to complete different missions for loads of cash. Find and deliver back research disks for rare technologies."
	department_for_prefs = DEPT_BITFLAG_SCI
	department_head = list(JOB_NAME_RESEARCHDIRECTOR)
	supervisors = "the research director"
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

/datum/job/exploration_crew/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source)
	if(outfit_override)
		return ..()
	if(visualsOnly || latejoin)
		return ..()
	var/static/exploration_job_id = 0
	exploration_job_id ++
	switch(exploration_job_id)
		if(1)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'sciradio'>Scientist</span>!</span>")
			to_chat(H, "<span class='notice'>Scan undiscovered creates to gain discovery research points!</span>")
			outfit_override = /datum/outfit/job/exploration_crew/scientist
		if(2)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'medradio'>Medical Doctor</span>!</span>")
			to_chat(H, "<span class='notice'>Ensure your team's health by locating and healing injured team members.</span>")
			outfit_override = /datum/outfit/job/exploration_crew/medic
		if(3)
			to_chat(H, "<span class='notice big'>You are the exploration team's <span class'engradio'>Engineer</span>!</span>")
			to_chat(H, "<span class='notice'>Create entry points with your explosives and maintain the hull of your ship.</span>")
			outfit_override = /datum/outfit/job/exploration_crew/engineer
	. = ..(H, visualsOnly, announce, latejoin, outfit_override, preference_source)

/datum/outfit/job/exploration_crew
	name = JOB_NAME_EXPLORATIONCREW
	jobtype = /datum/job/exploration_crew

	id = /obj/item/card/id/job/exploration_crew
	belt = /obj/item/modular_computer/tablet/pda/exploration_crew
	ears = /obj/item/radio/headset/headset_exploration
	shoes = /obj/item/clothing/shoes/jackboots
	uniform = /obj/item/clothing/under/rank/cargo/exploration

	chameleon_extras = /obj/item/gun/energy/e_gun/mini/exploration

/datum/outfit/job/exploration_crew/scientist
	name = "Exploration Crew (Scientist)"

/datum/outfit/job/exploration_crew/engineer
	department_head = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFENGINEER)
	supervisors = "the research director and chief engineer"

	name = "Exploration Crew (Engineer)"
	r_pocket = /obj/item/modular_computer/tablet/pda/exploration_crew

/datum/outfit/job/exploration_crew/medic
	department_head = list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the research director and chief medical officer"

	name = "Exploration Crew (Medical Doctor)"

/datum/outfit/job/exploration_crew/hardsuit
	name = "Exploration Crew (Hardsuit)"
	suit = /obj/item/clothing/suit/space/hardsuit/exploration
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	mask = /obj/item/clothing/mask/breath

/obj/item/radio/headset/headset_exploration/sci
	keyslot = new /obj/item/encryptionkey/headset_sci
	keyslot2 = new /obj/item/encryptionkey/headset_exp

/obj/item/radio/headset/headset_exploration/eng
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_exp

/obj/item/radio/headset/headset_exploration/med
	keyslot = new /obj/item/encryptionkey/headset_med
	keyslot2 = new /obj/item/encryptionkey/headset_exp
