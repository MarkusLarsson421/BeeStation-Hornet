// Base chasm, defaults to oblivion but can be overridden
/turf/open/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturfs = /turf/open/chasm
	icon = 'icons/turf/floors/chasms.dmi'
	icon_state = "chasms-255"
	base_icon_state = "chasms"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = list(SMOOTH_GROUP_TURF_OPEN, SMOOTH_GROUP_TURF_CHASM)
	canSmoothWith = list(SMOOTH_GROUP_TURF_CHASM)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	bullet_bounce_sound = null //abandon all hope ye who enter
	resistance_flags = INDESTRUCTIBLE

/turf/open/chasm/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/chasm, GET_TURF_BELOW(src))

/turf/open/chasm/proc/set_target(turf/target)
	var/datum/component/chasm/chasm_component = GetComponent(/datum/component/chasm)
	chasm_component.target_turf = target

/turf/open/chasm/proc/drop(atom/movable/AM)
	var/datum/component/chasm/chasm_component = GetComponent(/datum/component/chasm)
	chasm_component.drop(AM)

/turf/open/chasm/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/chasm/MakeDry()
	return

/turf/open/chasm/rust_heretic_act()
	return FALSE

/turf/open/chasm/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_FLOORWALL)
		return list("mode" = RCD_FLOORWALL, "delay" = 0, "cost" = 3)
	return FALSE

/turf/open/chasm/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_FLOORWALL)
		to_chat(user, "<span class='notice'>You build a floor.</span>")
		log_attack("[key_name(user)] has constructed a floor over a chasm at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	return FALSE

/turf/open/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(!L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				// Create a lattice, without reverting to our baseturf
				new /obj/structure/lattice(src)
			else
				to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
			return
	if(istype(C, /obj/item/stack/tile/iron))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/iron/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				// Create a floor, which has this chasm underneath it
				PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place iron rods first.</span>")

/// Lets people walk into chasms.
/turf/open/chasm/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	return TRUE

// Chasms for Lavaland, with planetary atmos and lava glow
/turf/open/chasm/lavaland
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/lavaland
	light_range = 1.9 //slightly less range than lava
	light_power = 0.65 //less bright, too
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right


// Chasms for the jungle, with planetary atmos and a different icon
/turf/open/chasm/jungle
	icon = 'icons/turf/floors/junglechasm.dmi'
	icon_state = "junglechasm-0"
	base_icon_state = "junglechasm"
	initial_gas_mix = OPENTURF_LOW_PRESSURE
	planetary_atmos = TRUE
	baseturfs = /turf/open/chasm/jungle

/turf/open/chasm/jungle/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "dirt"
	return TRUE
