/datum/antagonist/pirate/pirate_1728
	name = "1728 Space Pirate"
	roundend_category = "1728 space pirates"

/datum/antagonist/pirate/pirate_1728/captain
	name = "Space Pirate Captain"

/datum/antagonist/pirate/pirate_1728/captain/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	set_antag_hud(current, "pirate-captain")

/datum/antagonist/pirate/pirate_1728/greet()
	to_chat(owner, "<span class='boldannounce'>You are a Space Pirate!</span>")
	to_chat(owner, "<B>The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot.</B>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Space Pirate",
		"The station refused to pay for your protection, protect the ship, siphon the credits from the station and raid it for even more loot.")
