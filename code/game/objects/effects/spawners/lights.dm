/obj/effect/spawner/random_light
	icon = 'icons/obj/lighting.dmi'
	name = "spawn random lights"
	desc = "Automagically transforms into a random light. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/random_light/tube
	icon_state = "tube_random"
	name = "spawn random tube light"
	desc = "Automagically transforms into a random tube light. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/random_light/tube/Initialize(mapload)
	..()
	var/random_light = pick_weight(
		/obj/machinery/light = 1,
		/obj/machinery/light/broken = 3,
	)
	var/obj/machinery/light/light = new random_light(loc)

	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/random_light/bulb
	icon_state = "bulb_random"
	name = "spawn random bulb light"
	desc = "Automagically transforms into a random bulb light. If you see this while in a shift, please create a bug report."

/obj/effect/spawner/random_light/bulb/Initialize(mapload)
	..()
	var/random_light = pick_weight(
		/obj/machinery/light/small = 1,
		/obj/machinery/light/small/broken = 3,
	)
	var/obj/machinery/light/light = new random_light(loc)

	return INITIALIZE_HINT_QDEL
