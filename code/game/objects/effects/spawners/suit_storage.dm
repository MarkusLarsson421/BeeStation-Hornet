/obj/effect/spawner/random_suit_storage
	icon = ''
	name = "spawn random machine"
	desc = "Automagically transforms into a random suit storage unit. If you see this while in a shift, please create a bug report."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "random"

/obj/effect/spawner/randomvend/snack/Initialize(mapload)
	..()
	var/random_suit_storage = pick_weight(list(
		/obj/machinery/suit_storage_unit/open = 5,
		/obj/machinery/suit_storage_unit/engine = 2,
		/obj/machinery/suit_storage_unit = 10
	))
	new random_suit_storage(loc)

	return INITIALIZE_HINT_QDEL
