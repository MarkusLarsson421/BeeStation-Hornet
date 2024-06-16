/*!
 * Custom rendering solution to allow for advanced effects
 * We (ab)use plane masters and render source/target to cheaply render 2+ planes as 1
 * if you want to read more read the _render_readme.md
 */


/**
 * Render relay object assigned to a plane master to be able to relay it's render onto other planes that are not it's own
 */
/atom/movable/render_plane_relay
	screen_loc = "CENTER"
	layer = -1
	plane = 0
	appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER

/**
 * ## Rendering plate
 *
 * Acts like a plane master, but for plane masters
 * Renders other planes onto this plane, through the use of render objects
 * Any effects applied onto this plane will act on the unified plane
 * IE a bulge filter will apply as if the world was one object
 * remember that once planes are unified on a render plate you cant change the layering of them!
 */
/atom/movable/screen/plane_master/rendering_plate
	name = "default rendering plate"


///this plate renders the final screen to show to the player
/atom/movable/screen/plane_master/rendering_plate/master
	name = "master rendering plate"
	plane = RENDER_PLANE_MASTER
	render_relay_plane = null
	generate_render_target = FALSE

///renders general in charachter game objects
/atom/movable/screen/plane_master/rendering_plate/game_world
	name = "game rendering plate"
	plane = RENDER_PLANE_GAME
	render_relay_plane = RENDER_PLANE_MASTER

/atom/movable/screen/plane_master/rendering_plate/game_world/Initialize(mapload)
	. = ..()
	add_filter("displacer", 1, displacement_map_filter(render_source = GRAVITY_PULSE_RENDER_TARGET, size = 10))

///render plate for OOC stuff like ghosts, hud-screen effects, etc
/atom/movable/screen/plane_master/rendering_plate/non_game
	name = "non-game rendering plate"
	plane = RENDER_PLANE_NON_GAME
	render_relay_plane = RENDER_PLANE_MASTER


/**
 * Plane master proc called in backdrop() that creates a relay object, sets it as needed and then adds it to the clients screen
 * Sets:
 * * layer from plane to avoid z-fighting
 * * plane to relay the render to
 * * render_source so that the plane will render on this object
 * * mouse opacity to ensure proper mouse hit tracking
 * * name for debugging purposes
 * Other vars such as alpha will automatically be applied with the render source
 * Arguments:
 * * mymob: mob whose plane is being backdropped
 * * relay_plane: plane we are relaying this plane master to
 */
/atom/movable/screen/plane_master/proc/relay_render_to_plane(mob/mymob, relay_plane)
	if(mymob && (relay in mymob.client.screen)) //backdrop can be called multiple times
		return
	if(!render_target && generate_render_target)
		render_target = "*[name]: AUTOGENERATED RENDER TGT"
	relay = new()
	relay.render_source = render_target
	relay.plane = relay_plane
	relay.layer = (plane + abs(LOWEST_EVER_PLANE))*0.5 //layer must be positive but can be a decimal
	if(blend_mode_override)
		relay.blend_mode = blend_mode_override
	else
		relay.blend_mode = blend_mode
	relay.mouse_opacity = mouse_opacity
	relay.name = render_target
	if (mymob)
		mymob.client.screen += relay
	if(blend_mode != BLEND_MULTIPLY) //internal beyond snowflake do not touch
		blend_mode = BLEND_DEFAULT
	return relay
