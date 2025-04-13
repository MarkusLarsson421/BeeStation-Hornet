/obj/effect/spawner/random_derelict_cyborg
	icon = 'icons/mob/robots.dmi'
	icon_state = "random_derelict_cyborg"
	name = "spawn random derelict silicon"
	desc = "Automagically transforms into a random silicon. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/random_derelict_cyborg/Initialize(mapload)
	..()

	var/random_cyborg = pick(subtypesof(/mob/living/silicon/robot/derelict/modules))
	new random_cyborg(loc)

	return INITIALIZE_HINT_QDEL
