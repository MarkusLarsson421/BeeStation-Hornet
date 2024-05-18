/datum/job/chemist
	title = JOB_NAME_CHEMIST
	description = "Create healing medicines and fullfill other requests when medicine isn't needed. Label everything you produce correctly to prevent confusion."
	department_for_prefs = DEPT_BITFLAG_MED
	department_head = list(JOB_NAME_CHIEFMEDICALOFFICER)
	supervisors = "the chief medical officer"
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	selection_color = "#d4ebf2"
	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/chemist

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_MECH_MEDICAL, ACCESS_MINERAL_STOREROOM)

	departments = DEPT_BITFLAG_MED
	bank_account_department = ACCOUNT_MED_BITFLAG
	payment_per_department = list(ACCOUNT_MED_ID = PAYCHECK_MEDIUM)
	mind_traits = list(TRAIT_MEDICAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_CHEMIST
	rpg_title = "Alchemist"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/chemist
	)
	biohazard = 25

	lightup_areas = list(
		/area/medical/surgery,
		/area/medical/virology,
		/area/medical/genetics
	)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/medical/chemistry,
		/area/medical/apothecary
	)

/datum/outfit/job/chemist
	name = JOB_NAME_CHEMIST
	jobtype = /datum/job/chemist

	id = /obj/item/card/id/job/chemist
	belt = /obj/item/modular_computer/tablet/pda/chemist
	uniform = /obj/item/clothing/under/rank/medical/chemist
	ears = /obj/item/radio/headset/headset_med
	shoes = /obj/item/clothing/shoes/sneakers/white

	chameleon_extras = /obj/item/gun/syringe

