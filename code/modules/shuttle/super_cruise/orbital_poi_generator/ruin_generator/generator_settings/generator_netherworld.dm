/datum/generator_settings/netherworld
	probability = 1
	floor_break_prob = 30
	structure_damage_prob = 40

/datum/generator_settings/netherworld/get_floortrash()
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
		/mob/living/simple_animal/hostile/netherworld/blankbody = 2,
		/mob/living/simple_animal/hostile/netherworld/migo = 2,
		/obj/structure/spawner/nether = 0.3,
		/obj/structure/destructible/cult/pylon = 2,
		/obj/structure/destructible/cult/forge = 1,
		/obj/effect/rune/blood_boil = 1,
		/obj/effect/rune/empower = 1,
		null = 140,
	)
	for(var/trash in subtypesof(/obj/item/trash))
		.[trash] = 1

/datum/generator_settings/netherworld/get_non_directional_walltrash()
	return list(
		/obj/structure/sign/poster/random = 4,
		/obj/structure/sign/poster/ripped = 2,
		null = 30
	)
