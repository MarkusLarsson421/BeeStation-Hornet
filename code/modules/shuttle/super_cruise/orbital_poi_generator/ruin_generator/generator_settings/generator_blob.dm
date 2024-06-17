/datum/generator_settings/blob
	probability = 2
	floor_break_prob = 8
	structure_damage_prob = 6

/datum/generator_settings/blob/get_floortrash()
	. = list(
		/obj/effect/decal/cleanable/dirt = 6,
		/obj/effect/decal/cleanable/blood/old = 3,
		/obj/effect/decal/cleanable/oil = 2,
		/obj/effect/decal/cleanable/robot_debris/old = 1,
		/obj/effect/decal/cleanable/vomit/old = 4,
		/obj/effect/decal/cleanable/blood/gibs/old = 1,
		/obj/effect/decal/cleanable/greenglow/filled = 1,
		/obj/effect/spawner/lootdrop/glowstick/lit = 2,
		/obj/effect/spawner/lootdrop/glowstick = 4,
		/obj/effect/spawner/lootdrop/maintenance = 3,
		/obj/structure/blob/node/lone = 1,
		/mob/living/simple_animal/hostile/blob/blobspore = 2,
		/mob/living/simple_animal/hostile/blob/blobbernaut/independent = 1,
		null = 90,
	)
	for(var/trash in subtypesof(/obj/item/trash))
		.[trash] = 1

/datum/generator_settings/blob/get_non_directional_walltrash()
	return list(
		/obj/structure/sign/poster/random = 4,
		/obj/structure/sign/poster/ripped = 2,
		null = 30
	)
