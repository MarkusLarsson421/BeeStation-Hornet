#define TURRET_STUN 0
#define TURRET_LETHAL 1

#define POPUP_ANIM_TIME 5
#define POPDOWN_ANIM_TIME 5 //Be sure to change the icon animation at the same time or it'll look bad

/obj/machinery/porta_turret
	name = "turret"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turretCover"
	layer = OBJ_LAYER
	//the turret is invisible if it's inside its cover
	invisibility = INVISIBILITY_MAXIMUM
	density = TRUE
	desc = "A covered turret that shoots at its enemies."
	//this turret uses and requires power
	use_power = IDLE_POWER_USE
	//when inactive, this turret takes up constant 50 Equipment power
	idle_power_usage = 100
	//when active, this turret takes up constant 300 Equipment power
	active_power_usage = 600
	req_access = list(ACCESS_SECURITY)
	//drains power from the EQUIPMENT channel
	power_channel = AREA_USAGE_EQUIP

	//if TRUE this will cause the turret to stop working if the stored_gun var is null in process()
	var/uses_stored = TRUE

	base_icon_state = "standard"
	var/scan_range = 7
	//for turrets inside other objects
	var/atom/base = null

	//if the turret cover is "open" and the turret is raised
	var/raised = 0
	//if the turret is currently opening or closing its cover
	var/raising= 0

	//the turret's health
	max_integrity = 160
	integrity_failure = 0.5
	armor = list(MELEE = 50, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 30, BIO = 0, RAD = 0, FIRE = 90, ACID = 90, STAMINA = 0, BLEED = 0)

	//if the turret's behaviour control access is locked
	var/locked = TRUE
	//if the turret responds to control panels
	var/controllock = FALSE

	//the type of weapon installed by default
	var/installation = /obj/item/gun/energy/e_gun/turret
	var/obj/item/gun/stored_gun = null
	//the charge of the gun when retrieved from wreckage
	var/gun_charge = 0

	var/mode = TURRET_STUN

	//stun mode projectile type
	var/stun_projectile = null
	var/stun_projectile_sound
	//lethal mode projectile type
	var/lethal_projectile = null
	var/lethal_projectile_sound

	//power needed per shot
	var/reqpower = 500
	//Will stay active
	var/always_up = 0
	//Hides the cover
	var/has_cover = 1

	//the cover that is covering this turret
	var/obj/machinery/porta_turret_cover/cover = null

	var/last_fired = 0		//world.time the turret last fired
	var/shot_delay = 15		//ticks until next shot (1.5 ?)


	var/check_records = 1	//checks if it can use the security records
	var/criminals = 1		//checks if it can shoot people on arrest
	var/auth_weapons = 0	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/stun_all = 0		//if this is active, the turret shoots everything that isn't security or head of staff
	var/check_anomalies = 1	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/shoot_unloyal = 0	//checks if it can shoot people that aren't loyalty implantd
	var/target_cyborgs = 0	//checks if it can shoot cyborgs regardless of faction

	var/attacked = 0		//if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	var/on = TRUE				//determines if the turret is on

	var/list/faction = list("turret") // Same faction mobs will never be shot at, no matter the other settings

	var/datum/effect_system/spark_spread/spark_system	//the spark system, used for generating... sparks?

	var/obj/machinery/turretid/cp = null

	var/wall_turret_direction //The turret will try to shoot from a turf in that direction when in a wall

	var/manual_control = FALSE //
	var/datum/action/turret_quit/quit_action
	var/datum/action/turret_toggle/toggle_action
	var/mob/remote_controller

/obj/machinery/porta_turret/Initialize(mapload)
	. = ..()
	if(!base)
		base = src
	update_icon()
	//Sets up a spark system
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	setup()
	if(has_cover)
		cover = new /obj/machinery/porta_turret_cover(loc)
		cover.parent_turret = src
		var/mutable_appearance/base = mutable_appearance('icons/obj/turrets.dmi', "basedark")
		base.layer = NOT_HIGH_OBJ_LAYER
		underlays += base
	if(!has_cover)
		INVOKE_ASYNC(src, PROC_REF(popUp))

/obj/machinery/porta_turret/proc/toggle_on(var/set_to)
	var/current = on
	if (!isnull(set_to))
		on = set_to
	else
		on = !on
	if (current != on)
		check_should_process()
		if (!on && !always_up)
			popDown()

/obj/machinery/porta_turret/proc/check_should_process()
	if (datum_flags & DF_ISPROCESSING)
		if (!on || !anchored || (machine_stat & BROKEN) || !powered())
			end_processing()
	else
		if (on && anchored && !(machine_stat & BROKEN) && powered())
			begin_processing()

/obj/machinery/porta_turret/update_icon()
	cut_overlays()
	if(!anchored)
		icon_state = "turretCover"
		return
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]_broken"
	else
		if(powered())
			if(on && raised)
				switch(mode)
					if(TURRET_STUN)
						icon_state = "[base_icon_state]_stun"
					if(TURRET_LETHAL)
						icon_state = "[base_icon_state]_lethal"
			else
				icon_state = "[base_icon_state]_off"
		else
			icon_state = "[base_icon_state]_unpowered"


/obj/machinery/porta_turret/proc/setup(obj/item/gun/turret_gun)
	if(stored_gun)
		qdel(stored_gun)
		stored_gun = null

	if(installation && !turret_gun)
		stored_gun = new installation(src)
	else if (turret_gun)
		turret_gun.forceMove(src)
		stored_gun = turret_gun

	RegisterSignal(stored_gun, COMSIG_PARENT_PREQDELETED, PROC_REF(null_gun))
	var/list/gun_properties = stored_gun.get_turret_properties()

	//required properties
	stun_projectile = gun_properties["stun_projectile"]
	stun_projectile_sound = gun_properties["stun_projectile_sound"]
	lethal_projectile = gun_properties["lethal_projectile"]
	lethal_projectile_sound = gun_properties["lethal_projectile_sound"]
	base_icon_state = gun_properties["base_icon_state"]

	//optional properties
	if(gun_properties["shot_delay"])
		shot_delay = gun_properties["shot_delay"]
	if(gun_properties["reqpower"])
		reqpower = gun_properties["reqpower"]

	update_icon()
	return gun_properties

///destroys reference to stored_gun to prevent hard deletions
/obj/machinery/porta_turret/proc/null_gun()
	SIGNAL_HANDLER

	stored_gun = null

/obj/machinery/porta_turret/Destroy()
	//deletes its own cover with it
	QDEL_NULL(cover)
	base = null
	if(cp)
		cp.turrets -= src
		cp = null
	QDEL_NULL(stored_gun)
	QDEL_NULL(spark_system)
	remove_control()
	return ..()


/obj/machinery/porta_turret/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/porta_turret/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	var/dat
	dat += "Status: <a href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</a><br>"
	dat += "Behaviour controls are [locked ? "locked" : "unlocked"]<br>"

	if(!locked)
		dat += "Check for Weapon Authorization: <A href='?src=[REF(src)];operation=authweapon'>[auth_weapons ? "Yes" : "No"]</A><BR>"
		dat += "Check Security Records: <A href='?src=[REF(src)];operation=checkrecords'>[check_records ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize Identified Criminals: <A href='?src=[REF(src)];operation=shootcrooks'>[criminals ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize All Non-Security and Non-Command Personnel: <A href='?src=[REF(src)];operation=shootall'>[stun_all ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize All Unidentified Life Signs: <A href='?src=[REF(src)];operation=checkxenos'>[check_anomalies ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize All Non-Loyalty Implanted Personnel: <A href='?src=[REF(src)];operation=checkloyal'>[shoot_unloyal ? "Yes" : "No"]</A><BR>"
		dat += "Neutralize All Cyborgs: <A href='?src=[REF(src)];operation=checkborg'>[target_cyborgs ? "Yes" : "No"]</A><BR>"
	if(issilicon(user))
		if(!manual_control)
			var/mob/living/silicon/S = user
			if(S.hack_software)
				dat += "Assume direct control : <a href='?src=[REF(src)];operation=manual'>Manual Control</a><br>"
		else
			dat += "Warning! Remote control protocol enabled.<br>"


	var/datum/browser/popup = new(user, "autosec", "Automatic Portable Turret Installation", 300, 300)
	popup.set_content(dat)
	popup.open()

/obj/machinery/porta_turret/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["power"] && !locked)
		if(anchored)	//you can't turn a turret on/off if it's not anchored/secured
			on = !on	//toggle on/off
		else
			to_chat(usr, "<span class='notice'>It has to be secured first!</span>")
		interact(usr)
		return

	if(href_list["operation"])
		switch(href_list["operation"])	//toggles customizable behavioural protocols
			if("authweapon")
				auth_weapons = !auth_weapons
			if("checkrecords")
				check_records = !check_records
			if("shootcrooks")
				criminals = !criminals
			if("shootall")
				stun_all = !stun_all
			if("checkxenos")
				check_anomalies = !check_anomalies
			if("checkloyal")
				shoot_unloyal = !shoot_unloyal
			if("checkborg")
				target_cyborgs = !target_cyborgs
			if("manual")
				if(issilicon(usr) && !manual_control)
					give_control(usr)
		interact(usr)

/obj/machinery/porta_turret/power_change()
	. = ..()
	if(!anchored || (machine_stat & BROKEN) || !powered())
		update_icon()
		remove_control()
	check_should_process()


/obj/machinery/porta_turret/attackby(obj/item/I, mob/user, params)
	if(machine_stat & BROKEN)
		if(I.tool_behaviour == TOOL_CROWBAR)
			//If the turret is destroyed, you can remove it with a crowbar to
			//try and salvage its components
			to_chat(user, "<span class='notice'>You begin prying the iron coverings off...</span>")
			if(I.use_tool(src, user, 20))
				if(prob(70))
					if(stored_gun)
						stored_gun.forceMove(loc)
					to_chat(user, "<span class='notice'>You remove the turret and salvage some components.</span>")
					if(prob(50))
						new /obj/item/stack/sheet/iron(loc, rand(1,4))
					if(prob(50))
						new /obj/item/assembly/prox_sensor(loc)
				else
					to_chat(user, "<span class='notice'>You remove the turret but did not manage to salvage anything.</span>")
				qdel(src)

	else if((I.tool_behaviour == TOOL_WRENCH) && (!on))
		if(raised)
			return

		//This code handles moving the turret around. After all, it's a portable turret!
		if(!anchored && !isinspace())
			set_anchored(TRUE)
			invisibility = INVISIBILITY_MAXIMUM
			update_icon()
			to_chat(user, "<span class='notice'>You secure the exterior bolts on the turret.</span>")
			if(has_cover)
				cover = new /obj/machinery/porta_turret_cover(loc) //create a new turret. While this is handled in process(), this is to workaround a bug where the turret becomes invisible for a split second
				cover.parent_turret = src //make the cover's parent src
		else if(anchored)
			set_anchored(FALSE)
			to_chat(user, "<span class='notice'>You unsecure the exterior bolts on the turret.</span>")
			power_change()
			invisibility = 0
			qdel(cover) //deletes the cover, and the turret instance itself becomes its own cover.

	else if(I.GetID())
		//Behavior lock/unlock mangement
		if(allowed(user))
			locked = !locked
			to_chat(user, "<span class='notice'>Controls are now [locked ? "locked" : "unlocked"].</span>")
		else
			to_chat(user, "<span class='notice'>Access denied.</span>")
	else
		return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/porta_turret)

DEFINE_BUFFER_HANDLER(/obj/machinery/porta_turret)
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You add [src] to multitool buffer.</span>")
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/porta_turret/on_emag(mob/user)
	..()
	to_chat(user, "<span class='warning'>You short out [src]'s threat assessment circuits.</span>")
	visible_message("[src] hums oddly...")
	controllock = TRUE
	toggle_on(FALSE) //turns off the turret temporarily
	update_icon()
	//6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
	addtimer(CALLBACK(src, PROC_REF(after_emag)), 6 SECONDS)

/obj/machinery/porta_turret/proc/after_emag()
	if(QDELETED(src))
		return
	toggle_on(TRUE) //turns it back on. The cover popUp() popDown() are automatically called in process(), no need to define it here


/obj/machinery/porta_turret/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	if(on)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		//and scrambles its settings, with a slight chance of having an emag effect
		check_records = pick(0, 1)
		criminals = pick(0, 1)
		auth_weapons = pick(0, 1)
		stun_all = pick(0, 0, 0, 0, 1)	//stun_all is a pretty big deal, so it's least likely to get turned on

		toggle_on(FALSE)
		remove_control()

		addtimer(CALLBACK(src, PROC_REF(toggle_on), TRUE), rand(60,600))

/obj/machinery/porta_turret/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && obj_integrity > 0) //damage received
		if(prob(30))
			spark_system.start()
		if(on && !attacked && !(obj_flags & EMAGGED))
			attacked = TRUE
			addtimer(CALLBACK(src, PROC_REF(reset_attacked)), 60)

/obj/machinery/porta_turret/proc/reset_attacked()
	attacked = FALSE

/obj/machinery/porta_turret/deconstruct(disassembled = TRUE)
	qdel(src)

/obj/machinery/porta_turret/obj_break(damage_flag)
	. = ..()
	if(.)
		power_change()
		invisibility = 0
		spark_system.start() //creates some sparks because they look cool
		qdel(cover) //deletes the cover - no need on keeping it there!

/obj/machinery/porta_turret/process()
	//the main machinery process
	if(cover == null && anchored)	//if it has no cover and is anchored
		if(machine_stat & BROKEN)	//if the turret is borked
			qdel(cover)	//delete its cover, assuming it has one. Workaround for a pesky little bug
		else
			if(has_cover)
				cover = new /obj/machinery/porta_turret_cover(loc)	//if the turret has no cover and is anchored, give it a cover
				cover.parent_turret = src	//assign the cover its parent_turret, which would be this (src)

	if(!on || (machine_stat & (NOPOWER|BROKEN)))
		return PROCESS_KILL
	if(manual_control)
		return PROCESS_KILL
	if(uses_stored && !stored_gun)
		return PROCESS_KILL

	//Turrets can shoot up, but not down.
	var/list/valid_turfs = list()
	var/turf/temp = get_turf(src)
	while(temp && (isspaceturf(temp) || temp == get_turf(src)))
		valid_turfs["[temp.z]"] = temp
		temp = temp.above()

	var/list/targets = list()
	for(var/turf_z as() in valid_turfs)
		var/turf/T = valid_turfs[turf_z]
		for(var/mob/A as() in hearers(scan_range, T))
			if(A.invisibility > SEE_INVISIBLE_LIVING)
				continue

			if(check_anomalies)//if it's set to check for simple animals
				if(isanimal(A))
					var/mob/living/simple_animal/SA = A
					if(SA.stat || in_faction(SA)) //don't target if dead or in faction
						continue
					targets += SA
					continue

			if(issilicon(A))
				var/mob/living/silicon/sillycone = A

				if(ispAI(A))
					continue

				if(target_cyborgs && sillycone.stat != DEAD && iscyborg(sillycone))
					targets += sillycone
					continue

				if(sillycone.stat || in_faction(sillycone))
					continue

				if(iscyborg(sillycone))
					var/mob/living/silicon/robot/sillyconerobot = A
					if((FACTION_SYNDICATE in faction) && sillyconerobot.emagged == TRUE)
						continue

			else if(iscarbon(A))
				var/mob/living/carbon/C = A
				//If not emagged, only target carbons that can use items
				if(mode != TURRET_LETHAL && (C.stat || C.handcuffed || !(C.mobility_flags & MOBILITY_USE)))
					continue

				//If emagged, target all but dead carbons
				if(mode == TURRET_LETHAL && C.stat == DEAD)
					continue

				//if the target is a human and not in our faction, analyze threat level
				if(ishuman(C) && !in_faction(C))
					if(assess_perp(C) >= 4)
						targets += C

				else if(check_anomalies) //non humans who are not simple animals (xenos etc)
					if(!in_faction(C))
						targets += C

		for(var/A in GLOB.mechas_list)
			if((get_dist(A, base) < scan_range) && can_see(base, A, scan_range))
				var/obj/vehicle/sealed/mecha/mech = A
				for(var/O in mech.occupants)
					var/mob/living/occupant = O
					if(!in_faction(occupant)) //If there is a user and they're not in our faction
						if(assess_perp(occupant) >= 4)
							targets += mech

		if(check_anomalies && GLOB.blobs.len && (mode == TURRET_LETHAL))
			for(var/obj/structure/blob/B in view(scan_range, T))
				targets += B

	if(targets.len)
		tryToShootAt(targets, valid_turfs)
	else if(!always_up)
		popDown() // no valid targets, close the cover

/obj/machinery/porta_turret/proc/tryToShootAt(list/atom/movable/targets, list/turf/valid_shot_turfs)
	while(targets.len > 0)
		var/atom/movable/M = pick(targets)
		targets -= M
		if(target(M, valid_shot_turfs["[M.z]"]))
			return 1


/obj/machinery/porta_turret/proc/popUp()	//pops the turret up
	if(!anchored)
		return
	if(raising || raised)
		return
	if(machine_stat & BROKEN)
		return
	invisibility = 0
	raising = 1
	if(cover)
		flick("popup", cover)
	sleep(POPUP_ANIM_TIME)
	raising = 0
	if(cover)
		cover.icon_state = "openTurretCover"
	raised = 1
	layer = MOB_LAYER

/obj/machinery/porta_turret/proc/popDown()	//pops the turret down
	if(raising || !raised)
		return
	if(machine_stat & BROKEN)
		return
	layer = OBJ_LAYER
	raising = 1
	if(cover)
		flick("popdown", cover)
	sleep(POPDOWN_ANIM_TIME)
	raising = 0
	if(cover)
		cover.icon_state = "turretCover"
	raised = 0
	invisibility = 2
	update_icon()

/obj/machinery/porta_turret/proc/assess_perp(mob/living/carbon/human/perp)
	//if the turret has been attacked or is angry, target all non-sec people
	if((stun_all || attacked) && !allowed(perp))
		if(!allowed(perp))
			return 10
	//Check for judgement
	var/judgement = NONE
	if(obj_flags & EMAGGED)
		judgement |= JUDGE_EMAGGED
	if(auth_weapons)
		judgement |= JUDGE_WEAPONCHECK
	if(check_records)
		judgement |= JUDGE_RECORDCHECK
	. = perp.assess_threat(judgement, weaponcheck=CALLBACK(src, PROC_REF(check_for_weapons)))
	if(shoot_unloyal)
		if (!perp.has_mindshield_hud_icon())
			. += 4

/obj/machinery/porta_turret/proc/check_for_weapons(var/obj/item/slot_item)
	if(slot_item && (slot_item.item_flags & NEEDS_PERMIT))
		return TRUE
	return FALSE

/obj/machinery/porta_turret/proc/in_faction(mob/target)
	for(var/faction1 in faction)
		if(faction1 in target.faction)
			return TRUE
	return FALSE

/obj/machinery/porta_turret/proc/target(atom/movable/target, turf/bullet_source)
	if(target)
		popUp()				//pop the turret up if it's not already up.
		setDir(get_dir(base, target))//even if you can't shoot, follow the target
		shootAt(target, bullet_source)
		return 1
	return

/obj/machinery/porta_turret/proc/shootAt(atom/movable/target, turf/bullet_source)
	if(!raised) //the turret has to be raised in order to fire - makes sense, right?
		return

	if(!(obj_flags & EMAGGED))	//if it hasn't been emagged, cooldown before shooting again
		if(last_fired + shot_delay > world.time)
			return
		last_fired = world.time

	var/turf/T = bullet_source || get_turf(src)
	var/turf/U = get_turf(target)
	if(!istype(T) || !istype(U))
		return

	//Wall turrets will try to find adjacent empty turf to shoot from to cover full arc
	if(T.density)
		if(wall_turret_direction)
			var/turf/closer = get_step(T,wall_turret_direction)
			if(istype(closer) && !closer.is_blocked_turf() && T.Adjacent(closer))
				T = closer
		else
			var/target_dir = get_dir(T,target)
			for(var/d in list(0,-45,45))
				var/turf/closer = get_step(T,turn(target_dir,d))
				if(istype(closer) && !closer.is_blocked_turf() && T.Adjacent(closer))
					T = closer
					break

	update_icon()
	var/obj/projectile/A
	//any emagged turrets drains 2x power and uses a different projectile?
	if(mode == TURRET_STUN)
		use_power(reqpower)
		A = new stun_projectile(T)
		playsound(loc, stun_projectile_sound, 75, 1)
	else
		use_power(reqpower * 2)
		A = new lethal_projectile(T)
		playsound(loc, lethal_projectile_sound, 75, 1)


	//Shooting Code:
	A.preparePixelProjectile(target, T)
	A.firer = src
	A.fired_from = bullet_source
	A.fire()
	return A

/obj/machinery/porta_turret/proc/setState(on, mode, shoot_cyborgs)
	if(controllock)
		return
	toggle_on(on)
	src.mode = mode
	src.target_cyborgs = shoot_cyborgs
	power_change()


/datum/action/turret_toggle
	name = "Toggle Mode"
	icon_icon = 'icons/hud/actions/actions_mecha.dmi'
	button_icon_state = "mech_cycle_equip_off"

/datum/action/turret_toggle/Trigger()
	var/obj/machinery/porta_turret/P = target
	if(!istype(P))
		return
	P.setState(P.on, !P.mode, P.target_cyborgs)

/datum/action/turret_quit
	name = "Release Control"
	icon_icon = 'icons/hud/actions/actions_mecha.dmi'
	button_icon_state = "mech_eject"

/datum/action/turret_quit/Trigger()
	var/obj/machinery/porta_turret/P = target
	if(!istype(P))
		return
	P.remove_control(FALSE)

/obj/machinery/porta_turret/proc/give_control(mob/A)
	if(manual_control || !can_interact(A))
		return FALSE
	remote_controller = A
	if(!quit_action)
		quit_action = new(src)
	quit_action.Grant(remote_controller)
	if(!toggle_action)
		toggle_action = new(src)
	toggle_action.Grant(remote_controller)
	remote_controller.reset_perspective(src)
	remote_controller.click_intercept = src
	manual_control = TRUE
	always_up = TRUE
	popUp()
	return TRUE

/obj/machinery/porta_turret/proc/remove_control(warning_message = TRUE)
	if(!manual_control)
		return FALSE
	if(remote_controller)
		if(warning_message)
			to_chat(remote_controller, "<span class='warning'>Your uplink to [src] has been severed!</span>")
		quit_action.Remove(remote_controller)
		toggle_action.Remove(remote_controller)
		remote_controller.click_intercept = null
		remote_controller.reset_perspective()
	always_up = initial(always_up)
	manual_control = FALSE
	remote_controller = null
	check_should_process()
	return TRUE

/obj/machinery/porta_turret/proc/InterceptClickOn(mob/living/caller, params, atom/A)
	if(!manual_control)
		return FALSE
	if(!can_interact(caller))
		remove_control()
		return FALSE
	log_combat(caller,A,"fired with manual turret control at", src)
	target(A)
	return TRUE

/obj/machinery/porta_turret/syndicate
	installation = null
	always_up = TRUE
	use_power = NO_POWER_USE
	has_cover = FALSE
	scan_range = 9
	req_access = list(ACCESS_SYNDICATE)
	uses_stored = FALSE
	mode = TURRET_LETHAL
	stun_projectile = /obj/projectile/bullet
	lethal_projectile = /obj/projectile/bullet
	lethal_projectile_sound = 'sound/weapons/gunshot.ogg'
	stun_projectile_sound = 'sound/weapons/gunshot.ogg'
	icon_state = "syndie_off"
	base_icon_state = "syndie"
	faction = list(FACTION_SYNDICATE)
	desc = "A ballistic machine gun auto-turret."

/obj/machinery/porta_turret/syndicate/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)

/obj/machinery/porta_turret/syndicate/setup()
	return

/obj/machinery/porta_turret/syndicate/assess_perp(mob/living/carbon/human/perp)
	return 10 //Syndicate turrets shoot everything not in their faction

/obj/machinery/porta_turret/syndicate/energy
	icon_state = "standard_lethal"
	base_icon_state = "standard"
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/laser
	lethal_projectile_sound = 'sound/weapons/laser.ogg'
	desc = "An energy blaster auto-turret."

/obj/machinery/porta_turret/syndicate/energy/heavy
	name = "syndicate heavy laser turret"
	desc = "A heavy laser auto-turret."
	icon_state = "standard_lethal"
	base_icon_state = "standard"
	stun_projectile = /obj/projectile/energy/electrode
	stun_projectile_sound = 'sound/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/laser/heavylaser
	lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'
	desc = "An energy blaster auto-turret."

/obj/machinery/porta_turret/syndicate/energy/raven
	stun_projectile =  /obj/projectile/beam/laser
	stun_projectile_sound = 'sound/weapons/laser.ogg'
	faction = list("neutral","silicon","turret")


/obj/machinery/porta_turret/syndicate/pod
	name = "syndicate semi-auto turret"
	desc = "A ballistic semi-automatic auto-turret."
	integrity_failure = 0.5
	max_integrity = 40
	stun_projectile = /obj/projectile/bullet/syndicate_turret
	lethal_projectile = /obj/projectile/bullet/syndicate_turret

/obj/machinery/porta_turret/syndicate/shuttle
	name = "syndicate penetrator turret"
	desc = "A ballistic penetrator auto-turret."
	lethal_projectile_sound = 'sound/weapons/gunshot_smg.ogg'
	stun_projectile_sound = 'sound/weapons/gunshot_smg.ogg'
	armor = list(MELEE = 50,  BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 80, BIO = 0, RAD = 0, FIRE = 90, ACID = 90, STAMINA = 0, BLEED = 0)

/obj/machinery/porta_turret/syndicate/shuttle/target(atom/movable/target)
	if(target)
		setDir(get_dir(base, target))//even if you can't shoot, follow the target
		shootAt(target)
		addtimer(CALLBACK(src, PROC_REF(shootAt), target), 5)
		addtimer(CALLBACK(src, PROC_REF(shootAt), target), 10)
		addtimer(CALLBACK(src, PROC_REF(shootAt), target), 15)
		return TRUE

/obj/machinery/porta_turret/ai
	faction = list("silicon")
	var/emp_proofing = FALSE

/obj/machinery/porta_turret/ai/emp_act(severity)
	if(emp_proofing)
		return
	. = ..()

/obj/machinery/porta_turret/ai/assess_perp(mob/living/carbon/human/perp)
	return 10 //AI turrets shoot at everything not in their faction

/obj/machinery/porta_turret/aux_base
	name = "perimeter defense turret"
	desc = "A plasma beam turret calibrated to defend outposts against non-humanoid fauna. It is more effective when exposed to the environment."
	installation = null
	uses_stored = FALSE
	stun_projectile = /obj/projectile/plasma/turret
	lethal_projectile = /obj/projectile/plasma/turret
	lethal_projectile_sound = 'sound/weapons/plasma_cutter.ogg'
	mode = TURRET_LETHAL //It would be useless in stun mode anyway
	faction = list("neutral","silicon","turret") //Minebots, medibots, etc that should not be shot.

/obj/machinery/porta_turret/aux_base/assess_perp(mob/living/carbon/human/perp)
	return 0 //Never shoot humanoids. You are on your own if Ashwalkers or the like attack!

/obj/machinery/porta_turret/aux_base/setup()
	return

/obj/machinery/porta_turret/aux_base/interact(mob/user) //Controlled solely from the base console.
	return

/obj/machinery/porta_turret/aux_base/Initialize(mapload)
	. = ..()
	cover.name = name
	cover.desc = desc

/obj/machinery/porta_turret/centcom_shuttle
	installation = null
	max_integrity = 260
	always_up = TRUE
	use_power = NO_POWER_USE
	has_cover = 0
	scan_range = 9
	stun_projectile = /obj/projectile/beam/laser
	lethal_projectile = /obj/projectile/beam/laser
	lethal_projectile_sound = 'sound/weapons/plasma_cutter.ogg'
	stun_projectile_sound = 'sound/weapons/plasma_cutter.ogg'
	icon_state = "syndie_off"
	base_icon_state = "syndie"
	faction = list("neutral","silicon","turret")
	mode = TURRET_LETHAL

/obj/machinery/porta_turret/centcom_shuttle/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES)

/obj/machinery/porta_turret/centcom_shuttle/assess_perp(mob/living/carbon/human/perp)
	return 0

/obj/machinery/porta_turret/centcom_shuttle/setup()
	return

/obj/machinery/porta_turret/centcom_shuttle/weak
	max_integrity = 120
	integrity_failure = 0.5
	name = "Old Laser Turret"
	desc = "A turret built with substandard parts and run down further with age. Still capable of delivering lethal lasers to the odd space carp, but not much else."
	stun_projectile = /obj/projectile/beam/weak/penetrator
	lethal_projectile = /obj/projectile/beam/weak/penetrator
	faction = list("neutral","silicon","turret")

////////////////////////
//Turret Control Panel//
////////////////////////

/obj/machinery/turretid
	name = "turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_standby"
	density = FALSE
	req_access = list(ACCESS_AI_UPLOAD)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


	/// Variable dictating if linked turrets are active and will shoot targets
	var/enabled = TRUE
	/// Variable dictating if linked turrets will shoot lethal projectiles
	var/lethal = FALSE
	/// Variable dictating if the panel is locked, preventing changes to turret settings
	var/locked = TRUE
	/// An area in which linked turrets are located, it can be an area name, path or nothing
	var/control_area = null
	/// Silicons are unable to use this machine if set to TRUE
	var/ailock = FALSE
	/// Variable dictating if linked turrets will shoot cyborgs
	var/shoot_cyborgs = FALSE
	/// List of all linked turrets
	var/list/turrets = list()

CREATION_TEST_IGNORE_SUBTYPES(/obj/machinery/turretid)

/obj/machinery/turretid/Initialize(mapload, ndir = 0, built = 0)
	. = ..()
	if(built)
		locked = FALSE
	power_change() //Checks power and initial settings

/obj/machinery/turretid/Destroy()
	turrets.Cut()
	return ..()

/obj/machinery/turretid/Initialize(mapload) //map-placed turrets autolink turrets
	. = ..()
	if(!mapload)
		return

	if(control_area)
		control_area = get_area_instance_from_text(control_area)
		if(control_area == null)
			control_area = get_area(src)
			stack_trace("Bad control_area path for [src], [src.control_area]")
	else if(!control_area)
		control_area = get_area(src)

	for(var/obj/machinery/porta_turret/T in control_area)
		turrets |= T
		T.cp = src

/obj/machinery/turretid/examine(mob/user)
	. += ..()
	if(issilicon(user) && !(machine_stat & BROKEN))
		. += "<span class='notice'>Ctrl-click [src] to [ enabled ? "disable" : "enable"] turrets.</span>\n"+\
				"<span class='notice'>Alt-click [src] to set turrets to [ lethal ? "stun" : "kill"].</span>"

/obj/machinery/turretid/attackby(obj/item/I, mob/user, params)
	if(machine_stat & BROKEN)
		return

	if (issilicon(user))
		return attack_hand(user)

	if ( get_dist(src, user) == 0 )		// trying to unlock the interface
		if (allowed(usr))
			if(obj_flags & EMAGGED)
				to_chat(user, "<span class='notice'>The turret control is unresponsive.</span>")
				return

			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the panel.</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

REGISTER_BUFFER_HANDLER(/obj/machinery/turretid)

DEFINE_BUFFER_HANDLER(/obj/machinery/turretid)
	if(buffer && istype(buffer, /obj/machinery/porta_turret))
		turrets |= buffer
		to_chat(user, "You link \the [buffer] with \the [src]")
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/turretid/on_emag(mob/user)
	..()
	to_chat(user, "<span class='danger'>You short out the turret controls' access analysis module.</span>")
	locked = FALSE

/obj/machinery/turretid/attack_robot(mob/user)
	if(!ailock)
		return attack_hand(user)
	else
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")

/obj/machinery/turretid/attack_ai(mob/user)
	if(!ailock || IsAdminGhost(user))
		return attack_hand(user)
	else
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")

/obj/machinery/turretid/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/turretid/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurretControl")
		ui.open()

/obj/machinery/turretid/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = locked
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["enabled"] = enabled
	data["lethal"] = lethal
	data["shootCyborgs"] = shoot_cyborgs
	return data

/obj/machinery/turretid/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!allowed(usr))
		to_chat(usr, "<span class='warning'>Invalid access.</span>")
		return

	switch(action)
		if("lock")
			if(!usr.has_unlimited_silicon_privilege)
				return
			if((obj_flags & EMAGGED) || (machine_stat & BROKEN))
				to_chat(usr, "<span class='warning'>The turret control is unresponsive!</span>")
				return
			locked = !locked
			return TRUE
		if("power")
			toggle_on(usr)
			return TRUE
		if("mode")
			toggle_lethal(usr)
			return TRUE
		if("shoot_silicons")
			shoot_silicons(usr)
			return TRUE

/obj/machinery/turretid/proc/toggle_lethal(mob/user)
	lethal = !lethal
	add_hiddenprint(user)
	log_combat(user, src, "[lethal ? "enabled" : "disabled"] lethals on", important = FALSE)
	updateTurrets()
	ui_update()

/obj/machinery/turretid/proc/toggle_on(mob/user)
	enabled = !enabled
	add_hiddenprint(user)
	log_combat(user, src, "[enabled ? "enabled" : "disabled"]", important = FALSE)
	updateTurrets()
	ui_update()

/obj/machinery/turretid/proc/shoot_silicons(mob/user)
	shoot_cyborgs = !shoot_cyborgs
	add_hiddenprint(user)
	log_combat(user, src, "[shoot_cyborgs ? "Shooting Borgs" : "Not Shooting Borgs"]", important = FALSE)
	updateTurrets()
	ui_update()

/obj/machinery/turretid/proc/updateTurrets()
	for (var/obj/machinery/porta_turret/aTurret in turrets)
		aTurret.setState(enabled, lethal, shoot_cyborgs)
	update_icon()

/obj/machinery/turretid/update_icon()
	..()
	if(machine_stat & NOPOWER)
		icon_state = "control_off"
	else if (enabled)
		if (lethal)
			icon_state = "control_kill"
		else
			icon_state = "control_stun"
	else
		icon_state = "control_standby"

/obj/item/wallframe/turret_control
	name = "turret control frame"
	desc = "Used for building turret control panels."
	icon_state = "apc"
	result_path = /obj/machinery/turretid
	custom_materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)
	pixel_shift = 29

/obj/item/gun/proc/get_turret_properties()
	. = list()
	.["lethal_projectile"] = null
	.["lethal_projectile_sound"] = null
	.["stun_projectile"] = null
	.["stun_projectile_sound"] = null
	.["base_icon_state"] = "standard"

/obj/item/gun/energy/get_turret_properties()
	. = ..()

	var/obj/item/ammo_casing/primary_ammo = ammo_type[1]

	.["stun_projectile"] = initial(primary_ammo.projectile_type)
	.["stun_projectile_sound"] = initial(primary_ammo.fire_sound)

	if(ammo_type.len > 1)
		var/obj/item/ammo_casing/secondary_ammo = ammo_type[2]
		.["lethal_projectile"] = initial(secondary_ammo.projectile_type)
		.["lethal_projectile_sound"] = initial(secondary_ammo.fire_sound)
	else
		.["lethal_projectile"] = .["stun_projectile"]
		.["lethal_projectile_sound"] = .["stun_projectile_sound"]

/obj/item/gun/ballistic/get_turret_properties()
	. = ..()
	var/obj/item/ammo_box/mag = mag_type
	var/obj/item/ammo_casing/primary_ammo = initial(mag.ammo_type)

	.["base_icon_state"] = "syndie"
	.["stun_projectile"] = initial(primary_ammo.projectile_type)
	.["stun_projectile_sound"] = initial(primary_ammo.fire_sound)
	.["lethal_projectile"] = .["stun_projectile"]
	.["lethal_projectile_sound"] = .["stun_projectile_sound"]


/obj/item/gun/energy/laser/bluetag/get_turret_properties()
	. = ..()
	.["stun_projectile"] = /obj/projectile/beam/lasertag/bluetag
	.["lethal_projectile"] = /obj/projectile/beam/lasertag/bluetag
	.["base_icon_state"] = "blue"
	.["shot_delay"] = 30
	.["team_color"] = "blue"

/obj/item/gun/energy/laser/redtag/get_turret_properties()
	. = ..()
	.["stun_projectile"] = /obj/projectile/beam/lasertag/redtag
	.["lethal_projectile"] = /obj/projectile/beam/lasertag/redtag
	.["base_icon_state"] = "red"
	.["shot_delay"] = 30
	.["team_color"] = "red"

/obj/item/gun/energy/e_gun/turret/get_turret_properties()
	. = ..()

/obj/machinery/porta_turret/lasertag
	req_access = list(ACCESS_MAINT_TUNNELS, ACCESS_THEATRE)
	check_records = 0
	criminals = 0
	auth_weapons = 1
	stun_all = 0
	check_anomalies = 0
	var/team_color

/obj/machinery/porta_turret/lasertag/assess_perp(mob/living/carbon/human/perp)
	. = 0
	if(team_color == "blue")	//Lasertag turrets target the opposing team, how great is that? -Sieve
		. = 0		//But does not target anyone else
		if(istype(perp.wear_suit, /obj/item/clothing/suit/redtag))
			. += 4
		if(perp.is_holding_item_of_type(/obj/item/gun/energy/laser/redtag))
			. += 4
		if(istype(perp.belt, /obj/item/gun/energy/laser/redtag))
			. += 2

	if(team_color == "red")
		. = 0
		if(istype(perp.wear_suit, /obj/item/clothing/suit/bluetag))
			. += 4
		if(perp.is_holding_item_of_type(/obj/item/gun/energy/laser/bluetag))
			. += 4
		if(istype(perp.belt, /obj/item/gun/energy/laser/bluetag))
			. += 2

/obj/machinery/porta_turret/lasertag/setup(obj/item/gun/gun)
	var/list/properties = ..()
	if(properties["team_color"])
		team_color = properties["team_color"]

/obj/machinery/porta_turret/lasertag/ui_interact(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(team_color == "blue" && istype(H.wear_suit, /obj/item/clothing/suit/redtag))
			return
		if(team_color == "red" && istype(H.wear_suit, /obj/item/clothing/suit/bluetag))
			return

	var/dat = "Status: <a href='?src=[REF(src)];power=1'>[on ? "On" : "Off"]</a>"

	var/datum/browser/popup = new(user, "autosec", "Automatic Portable Turret Installation", 300, 300)
	popup.set_content(dat)
	popup.open()

//lasertag presets
/obj/machinery/porta_turret/lasertag/red
	installation = /obj/item/gun/energy/laser/redtag
	team_color = "red"

/obj/machinery/porta_turret/lasertag/blue
	installation = /obj/item/gun/energy/laser/bluetag
	team_color = "blue"

/obj/machinery/porta_turret/lasertag/bullet_act(obj/projectile/P)
	. = ..()
	if(on)
		if(team_color == "blue")
			if(istype(P, /obj/projectile/beam/lasertag/redtag))
				toggle_on(FALSE)
				addtimer(CALLBACK(src, PROC_REF(toggle_on), TRUE), 10 SECONDS)
		else if(team_color == "red")
			if(istype(P, /obj/projectile/beam/lasertag/bluetag))
				toggle_on(FALSE)
				addtimer(CALLBACK(src, PROC_REF(toggle_on), TRUE), 10 SECONDS)

#undef TURRET_STUN
#undef TURRET_LETHAL

#undef POPUP_ANIM_TIME
#undef POPDOWN_ANIM_TIME
