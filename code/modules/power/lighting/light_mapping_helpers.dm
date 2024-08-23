// the larger light fixture

/obj/machinery/light/broken
	status = LIGHT_BROKEN
	icon_state = "tube-broken"

/obj/machinery/light/built
	icon_state = "tube-empty"
	start_with_cell = FALSE

/obj/machinery/light/dim
	bulb_power = 0.6

/obj/machinery/light/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE, TRUE)

// Some VERY dim lights, used for the void sacrifice realm.
/obj/machinery/light/very_dim
	nightshift_allowed = FALSE
	bulb_colour = "#d6b6a6ff"
	brightness = 3
	bulb_power = 0.5
	fitting = "void" // If you set this to "tube" or "bulb" the brightness is reset in LateInitialize()

/obj/machinery/light/very_dim/directional/north
	dir = NORTH

/obj/machinery/light/very_dim/directional/south
	dir = SOUTH

/obj/machinery/light/very_dim/directional/east
	dir = EAST

/obj/machinery/light/very_dim/directional/west
	dir = WEST

// the smaller bulb light fixture

/obj/machinery/light/small
	icon_state = "bulb"
	base_state = "bulb"
	fitting = "bulb"
	brightness = 6
	desc = "A small lighting fixture."
	bulb_colour = "#FFE6CC" //little less cozy, bit more industrial, but still cozy.. -qwerty
	light_type = /obj/item/light/bulb

/obj/machinery/light/small/broken
	status = LIGHT_BROKEN
	icon_state = "bulb-broken"

/obj/machinery/light/small/dim
	bulb_power = 0.6

/obj/machinery/light/small/red
	bulb_power = 0.6
	bulb_colour = "#F44336"

/obj/machinery/light/small/built
	icon_state = "bulb-empty"
	start_with_cell = FALSE

/obj/machinery/light/small/built/Initialize(mapload)
	. = ..()
	status = LIGHT_EMPTY
	update(FALSE, TRUE)
