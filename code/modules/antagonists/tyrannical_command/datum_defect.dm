/datum/antagonist/tyrannical/defect
	name = "Defect"
	roundend_category = "defects"
	antag_moodlet = /datum/mood_event/defect_scared

/datum/antagonist/tyrannical/proc/add_objective(datum/objective/O)
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/tyrannical/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/tyrannical/greet()
	var/list/msg = list()

	msg += span_alerttyrannt("You are a [owner.special_role].")
	owner.current.client?.tgui_panel?.give_antagonist_popup(antagpanel_category, "Complete your objectives, for the humanity.")

	ui_interact(owner.current)
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tyrannt.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

	to_chat(owner.current, examine_block(msg.Join("\n")))

/datum/antagonist/tyrannical/proc/update_traitor_icons_added(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.join_hud(owner.current)
	set_antag_hud(owner.current, "traitor")

/datum/antagonist/tyrannical/proc/update_traitor_icons_removed(datum/mind/traitor_mind)
	var/datum/atom_hud/antag/traitorhud = GLOB.huds[ANTAG_HUD_TRAITOR]
	traitorhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/tyrannical/proc/equip(var/silent = FALSE)
	var/obj/item/uplink_loc = owner.equip_traitor(employer, silent, src)
	var/datum/component/uplink/uplink = uplink_loc?.GetComponent(/datum/component/uplink)
	if(uplink)
		uplink_ref = WEAKREF(uplink)

//TODO Collate
/datum/antagonist/tyrannical/defect/roundend_report()
	var/list/result = list()

	var/traitorwin = TRUE

	result += printplayer(owner)

	var/objectives_text = ""
	if(objectives.len)
		var/count = 1
		for(var/datum/objective/objective in objectives)
			objectives_text += "<br><B>Objective #[count]</B>: [objective.get_completion_message()]"
			if(!objective.check_completion())
				traitorwin = FALSE
			count++

	result += objectives_text

	var/special_role_text = LOWER_TEXT(name)

	if(traitorwin)
		result += span_greentext("The [special_role_text] was successful!")
		SEND_SOUND(owner.current, 'sound/misc/gamma.ogg')
	else
		result += span_redtext("The [special_role_text] has failed!")
		SEND_SOUND(owner.current, 'sound/weapons/autoguninsert.ogg')
		SEND_SOUND(owner.current, 'sound/ambience/ambifailure.ogg')

	return result.Join("<br>")
