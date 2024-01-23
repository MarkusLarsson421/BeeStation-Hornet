// Pirates threat
/// No way
#define PIRATE_RESPONSE_NO_PAY "pirate_answer_no_pay"
/// We'll pay
#define PIRATE_RESPONSE_PAY "pirate_answer_pay"

/datum/round_event_control/pirates/pirates_1728
	name = "1728 Space Pirates"
	typepath = /datum/round_event/pirates/pirates_1728
	weight = 10
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE
	gamemode_blacklist = list("nuclear")
	cannot_spawn_after_shuttlecall = TRUE

/datum/round_event/pirates/pirates_1728/start()
	if(!GLOB.pirates_spawned)
		send_pirate_1728_threat()

/proc/send_pirate_1728_threat()
	GLOB.pirates_spawned = TRUE
	var/ship_name = "Space Privateers Association"
	var/payoff_min = 7500
	var/payoff = 0
	var/initial_send_time = world.time
	var/response_max_time = rand(2,5) MINUTES
	priority_announce("Incoming subspace communication. Secure channel opened at all communication consoles.", "Incoming Message", SSstation.announcer.get_rand_report_sound())
	var/datum/comm_message/threat = new
	var/datum/bank_account/D = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)
	if(D)
		payoff = max(payoff_min, FLOOR(D.account_balance * 0.40, 1000))
	ship_name = pick(strings(PIRATE_NAMES_FILE, "ship_names"))
	threat.title = "Business proposition"
	threat.content = "Avast, ye scurvy dogs! Our fine ship <i>[ship_name]</i> has come for yer booty. Immediately transfer [payoff] space doubloons from yer Cargo budget or ye'll be walkin' the plank. Don't try and cheat us, make sure it's all tharr!"
	threat.possible_answers = list(
		PIRATE_RESPONSE_PAY = "We'll pay.",
		PIRATE_RESPONSE_NO_PAY = "No way.",
	)
	threat.answer_callback = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(pirates_answered), threat, payoff, ship_name, initial_send_time, response_max_time)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(spawn_1728_pirates), threat, FALSE), response_max_time)
	SScommunications.send_message(threat,unique = TRUE)

/proc/spawn_1728_pirates(datum/comm_message/threat, skip_answer_check)
	// If they paid it off in the meantime, don't spawn pirates
	// If they couldn't afford to pay, don't spawn another - it already spawned (see above)
	// If they selected "No way.", this spawns on the timeout, so we don't want to return for the answer check
	if(!skip_answer_check && threat?.answered == PIRATE_RESPONSE_PAY)
		return

	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for 1728 pirate crew?", ROLE_SPACE_PIRATE, /datum/role_preference/midround_ghost/space_pirate, 15 SECONDS)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/pirate/pirate_1728/ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Pirate event found no turf to load in")

	var/datum/async_map_generator/template_placer = ship.load(T)
	template_placer.on_completion(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(after_pirate_spawn), ship, candidates))

	priority_announce("Unidentified armed ship detected near the station.", sound = SSstation.announcer.get_rand_alert_sound())

/proc/after_pirate_1728_spawn(datum/map_template/shuttle/pirate/pirate_1728/ship, list/candidates, datum/async_map_generator/async_map_generator, turf/T)
	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/pirate/spawner in A)
			if(candidates.len > 0)
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
				notify_ghosts("The pirate ship has an object of interest: [M]!", source=M, action=NOTIFY_ORBIT, header="Something's Interesting!")
			else
				notify_ghosts("The pirate ship has an object of interest: [spawner]!", source=spawner, action=NOTIFY_ORBIT, header="Something's Interesting!")

#undef PIRATE_RESPONSE_NO_PAY
#undef PIRATE_RESPONSE_PAY
