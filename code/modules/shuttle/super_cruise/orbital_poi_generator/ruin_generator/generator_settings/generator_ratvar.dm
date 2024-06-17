/datum/generator_settings/ratvar
	probability = 200
	floor_break_prob = 8
	structure_damage_prob = 6

/datum/generator_settings/ratvar/get_floortrash()
	. = list(
		null = 70,
		/obj/effect/decal/cleanable/dirt = 20,
		/obj/effect/decal/cleanable/blood/old = 15,
		/obj/effect/decal/cleanable/oil = 2,
		/obj/effect/decal/cleanable/robot_debris/old = 1,
		/obj/effect/decal/cleanable/vomit/old = 4,
		/obj/effect/decal/cleanable/blood/gibs/old = 1,
		/obj/effect/decal/cleanable/greenglow/filled = 1,
		/obj/effect/spawner/lootdrop/glowstick/lit = 6,
		/obj/effect/spawner/lootdrop/maintenance = 3,
		/obj/effect/spawner/structure/ratvar_skewer_trap = 4,
		/obj/effect/spawner/structure/ratvar_flipper_trap = 2,
		/obj/effect/spawner/structure/ratvar_skewer_trap_kill = 1,
		/mob/living/simple_animal/hostile/clockwork_marauder = 1,
		/obj/structure/destructible/clockwork/wall_gear/displaced = 10,
		/obj/effect/spawner/ocular_warden_setup = 1,
		/obj/effect/spawner/interdiction_lens_setup = 1,
	)
	for(var/trash in subtypesof(/obj/item/trash))
		.[trash] = 1

/datum/generator_settings/ratvar/get_non_directional_walltrash()
	return list(
		/obj/structure/sign/poster/random = 4,
		/obj/structure/sign/poster/ripped = 2,
		/obj/structure/destructible/clockwork/trap/delay = 1,
		/obj/structure/destructible/clockwork/trap/lever = 1,
		null = 30
	)
