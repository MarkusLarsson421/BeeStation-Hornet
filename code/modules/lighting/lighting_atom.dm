
/atom
	var/light_power = 1 // Intensity of the light.
	var/light_range = 0 // Range in tiles of the light.
	var/light_color     // Hexadecimal RGB string representing the colour of the light.

	var/tmp/datum/light_source/light // Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/list/light_sources       // Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.

// The proc you should always use to set the light of this atom.
// Nonesensical value for l_color default, so we can detect if it gets set to null.
#define NONSENSICAL_VALUE -99999
/atom/proc/set_light(l_range, l_power, l_color = NONSENSICAL_VALUE, l_on)
	if(l_range > 0 && l_range < MINIMUM_USEFUL_LIGHT_RANGE)
		l_range = MINIMUM_USEFUL_LIGHT_RANGE //Brings the range up to 1.4, which is just barely brighter than the soft lighting that surrounds players.

	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT, l_range, l_power, l_color, l_on) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return

	if(!isnull(l_power))
		set_light_power(l_power)

	if(!isnull(l_range))
		set_light_range(l_range)

	if(l_color != NONSENSICAL_VALUE)
		set_light_color(l_color)

	if(!isnull(l_on))
		set_light_on(l_on)

	update_light()

#undef NONSENSICAL_VALUE

// Will update the light (duh).
// Creates or destroys it if needed, makes it update values, makes sure it's got the correct source turf...
/atom/proc/update_light()
	set waitfor = FALSE
	if (QDELETED(src))
		return

	if(light_system != STATIC_LIGHT)
		CRASH("update_light() for [src] with following light_system value: [light_system]")

	if (!light_power || !light_range || !light_on) // We won't emit light anyways, destroy the light source.
		QDEL_NULL(light)
	else
		if (!ismovable(loc)) // We choose what atom should be the top atom of the light here.
			. = src
		else
			. = loc

		if (light) // Update the light or create it if it does not exist.
			light.update(.)
		else
			light = new/datum/light_source(src, .)

/**
  * Updates the atom's opacity value.
  *
  * This exists to act as a hook for associated behavior.
  * It notifies (potentially) affected light sources so they can update (if needed).
  */
/atom/proc/set_opacity(new_opacity)
	if (new_opacity == opacity)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_SET_OPACITY, new_opacity)
	. = opacity
	opacity = new_opacity


/atom/movable/set_opacity(new_opacity)
	. = ..()
	if(isnull(.) || !isturf(loc))
		return

	if(opacity)
		AddElement(/datum/element/light_blocking)
	else
		RemoveElement(/datum/element/light_blocking)


/turf/set_opacity(new_opacity)
	. = ..()
	if(isnull(.))
		return
	recalculate_directional_opacity()


/atom/movable/Moved(atom/OldLoc, Dir)
	. = ..()
	for (var/datum/light_source/light as anything in light_sources) // Cycle through the light sources on this atom and tell them to update.
		light.source_atom.update_light()

/atom/vv_edit_var(var_name, var_value)
	switch (var_name)
		if (NAMEOF(src, light_range))
			if(light_system == STATIC_LIGHT)
				set_light(l_range = var_value)
			else
				set_light_range(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if (NAMEOF(src, light_power))
			if(light_system == STATIC_LIGHT)
				set_light(l_power = var_value)
			else
				set_light_power(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

		if (NAMEOF(src, light_color))
			if(light_system == STATIC_LIGHT)
				set_light(l_color = var_value)
			else
				set_light_color(var_value)
			datum_flags |= DF_VAR_EDITED
			return TRUE

	return ..()


/atom/proc/flash_lighting_fx(range = FLASH_LIGHT_RANGE, power = FLASH_LIGHT_POWER, color = COLOR_WHITE, duration = FLASH_LIGHT_DURATION, light_type = /obj/effect/dummy/lighting_obj)
	if(!duration)
		stack_trace("Lighting FX obj created on \[[type]\] without a duration")
	var/obj/effect/dummy/light_obj = new light_type(get_turf(src), range, power, color, duration)
	return light_obj

/mob/living/flash_lighting_fx(range = FLASH_LIGHT_RANGE, power = FLASH_LIGHT_POWER, color = COLOR_WHITE, duration = FLASH_LIGHT_DURATION, light_type = /obj/effect/dummy/lighting_obj/moblight)
	return mob_light(range, power, color, duration)

/mob/living/proc/mob_light(range, power, color, duration, light_type = /obj/effect/dummy/lighting_obj/moblight)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = new light_type(src, range, power, color, duration)
	return mob_light_obj

/// Setter for the light power of this atom.
/atom/proc/set_light_power(new_power)
	if(new_power == light_power)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_POWER, new_power) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_power
	light_power = new_power
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_POWER, .)

/// Setter for the light range of this atom.
/atom/proc/set_light_range(new_range)
	if(new_range == light_range)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_RANGE, new_range) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_range
	light_range = new_range
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_RANGE, .)

/// Setter for the light color of this atom.
/atom/proc/set_light_color(new_color)
	if(new_color == light_color)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_COLOR, new_color) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_color
	light_color = new_color
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_COLOR, .)

/// Setter for whether or not this atom's light is on.
/atom/proc/set_light_on(new_value)
	if(new_value == light_on)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_ON, new_value) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_on
	light_on = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_ON, .)

/// Setter for the light flags of this atom.
/atom/proc/set_light_flags(new_value)
	if(new_value == light_flags)
		return
	if(SEND_SIGNAL(src, COMSIG_ATOM_SET_LIGHT_FLAGS, new_value) & COMPONENT_BLOCK_LIGHT_UPDATE)
		return
	. = light_flags
	light_flags = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_LIGHT_FLAGS, .)
