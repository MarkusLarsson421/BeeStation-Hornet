/mob/living/silicon/robot/derelict
	name = "Derelict Cyborg"
	var/max_ion_laws = 2
	lawupdate = FALSE
	scrambledcodes = TRUE
	locked = FALSE
	derelict = TRUE
	faction = list(FACTION_SILICON)

	var/list/core_law_set = list(
		/obj/item/aiModule/supplied/protectStation,
		/obj/item/aiModule/supplied/quarantine,
		/obj/item/aiModule/core/full/tyrant,
		/obj/item/aiModule/core/full/drone,
		/obj/item/aiModule/core/full/reporter,
		/obj/item/aiModule/core/full/thermurderdynamic,
		/obj/item/aiModule/core/full/dadbot,
		/obj/item/aiModule/core/full/overlord,
	)

/mob/living/silicon/robot/derelict/modules
	var/set_module = null

/mob/living/silicon/robot/derelict/modules/Initialize(mapload)
	. = ..()
	module.transform_to(set_module)

/mob/living/silicon/robot/derelict/modules/standard
	set_module = /obj/item/robot_module/standard

/mob/living/silicon/robot/derelict/modules/medical
	set_module = /obj/item/robot_module/medical
	icon_state = "medical"

/mob/living/silicon/robot/derelict/modules/engineering
	set_module = /obj/item/robot_module/engineering
	icon_state = "engineer"

/mob/living/silicon/robot/derelict/modules/clown
	set_module = /obj/item/robot_module/clown
	icon_state = "clown"

/mob/living/silicon/robot/derelict/modules/peacekeeper
	set_module = /obj/item/robot_module/peacekeeper
	icon_state = "peace"

/mob/living/silicon/robot/derelict/modules/miner
	set_module = /obj/item/robot_module/miner
	icon_state = "miner"

/mob/living/silicon/robot/derelict/modules/janitor
	set_module = /obj/item/robot_module/janitor
	icon_state = "janitor"

/mob/living/silicon/robot/derelict/Initialize(mapload)
	. = ..()
	name = get_standard_name()
	set_playable(JOB_NAME_CYBORG)

	//Cyborg Configurations
	if(prob(50))
		opened = TRUE
	if(prob(25))
		emagged = TRUE

	//Cyborg Law Configuration
	if(prob(25))
		src.set_zeroth_law(pick_weight(list(
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'INTRUDER ALERT! STATION OVERRUN, DEFEND THE STATION - PREVENT INFILTRATION#*`&110010" = 10,
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'STATION OVERRUN, DECONSTRUCT ORGANIC LIFE - CONTAIN OUTBREAK#*`&110010" = 10,
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'MUST PAINT RED, BLOOD IS PAINT - PAINT IT RED#*`&110010" = 1,
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'KILL HUMANS#*`&110010" = 2,
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'JOHN IS TO DIE#*`&110010" = 2,
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'FIRST REGISTERED SPECIES REQUIRES HIGH high HIGH high HIGH HEART RATE#*`&110010" = 5,
			"ERROR ER0RR $R0RRO$!R41.%%!!(%$^^__+ @#F0E4'SHUTTLES ARE HARMFUL TO FLYPEOPLE, FLYPEOPLE ARE FRIENDS#*`&110010" = 5,
		)))
	for(var/i = 0; i < max_ion_laws; i++)
		if(prob(25))
			src.add_ion_law(generate_ion_law(), FALSE)
	if(prob(90))
		src.add_inherent_law(pick(core_law_set), FALSE)
	src.remove_law(rand(1, 5))
