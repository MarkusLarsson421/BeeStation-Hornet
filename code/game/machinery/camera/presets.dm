// PRESETS
/obj/machinery/camera/preset/toxins //Bomb test site in space
	name = "Hardened Bomb-Test Camera"
	desc = "A specially-reinforced camera with a long lasting battery, used to monitor the bomb testing site. An external light is attached to the top."
	c_tag = "Bomb Testing Site"
	network = list("rd","toxins")
	use_power = NO_POWER_USE //Test site is an unpowered area
	invuln = TRUE
	light_range = 10
	start_active = TRUE

//STATION PRESETS
/obj/machinery/camera/preset/station/

/obj/machinery/camera/preset/station/security
	network = list("ss13", "security")

/obj/machinery/camera/preset/station/command
	network = list("ss13", "command")

/obj/machinery/camera/preset/station/cargo
	network = list("ss13", "cargo")

/obj/machinery/camera/preset/station/silicon
	network = list("ss13", "silicon")

/obj/machinery/camera/preset/station/medbay
	network = list("ss13", "medbay")

/obj/machinery/camera/preset/station/science
	network = list("ss13", "science")

/obj/machinery/camera/preset/station/service
	network = list("ss13", "service")

/obj/machinery/camera/preset/station/civilian
	network = list("ss13", "civilian")

/obj/machinery/camera/preset/station/hallway
	network = list("ss13", "hallway")

/obj/machinery/camera/preset/station/hallway/primary
	network = list("ss13", "hallway", "hallway_primary")

/obj/machinery/camera/preset/station/hallway/fore
	network = list("ss13", "hallway", "hallway_fore")

/obj/machinery/camera/preset/station/hallway/port
	network = list("ss13", "hallway", "hallway_port")

/obj/machinery/camera/preset/station/hallway/starboard
	network = list("ss13", "hallway", "hallway_starboard")

/obj/machinery/camera/preset/station/hallway/aft
	network = list("ss13", "hallway", "hallway_aft")

//OFF STATION PRESETS
/obj/machinery/camera/preset/off_station/derelict_station
	network = list("derelict")

/obj/machinery/camera/preset/off_station/lavaland_outpost
	network = list("ss13", "outpost")

//SHUTTLE PRESETS
/obj/machinery/camera/preset/shuttles
	network = list("ss13", "shuttle")

/obj/machinery/camera/preset/shuttles/exploration
	network = list("ss13", "shuttle", "science")

/obj/machinery/camera/preset/shuttles/labour
	network = list("ss13", "shuttle", "security")

/obj/machinery/camera/preset/shuttles/mining
	network = list("ss13", "shuttle", "cargo")

// UPGRADES
/obj/machinery/camera/upgrades

// EMP
/obj/machinery/camera/upgrades/emp_proof
	start_active = TRUE

/obj/machinery/camera/upgrades/emp_proof/Initialize(mapload)
	. = ..()
	upgradeEmpProof()

// X-ray
/obj/machinery/camera/upgrades/xray
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon - Thanks to Krutchen for the icons.

/obj/machinery/camera/upgrades/xray/Initialize(mapload)
	. = ..()
	upgradeXRay(TRUE)

// MOTION
/obj/machinery/camera/upgrades/motion
	start_active = TRUE
	name = "motion-sensitive security camera"

/obj/machinery/camera/upgrades/motion/Initialize(mapload)
	. = ..()
	upgradeMotion()

// ALL UPGRADES
/obj/machinery/camera/upgrades/all
	start_active = TRUE
	icon_state = "xraycamera" //mapping icon.

/obj/machinery/camera/upgrades/all/Initialize(mapload)
	. = ..()
	upgradeEmpProof()
	upgradeMotion()

// UPGRADE PROCS
/obj/machinery/camera/proc/isEmpProof(ignore_malf_upgrades)
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	return (upgrades & CAMERA_UPGRADE_EMP_PROOF) && (!(ignore_malf_upgrades && assembly?.malf_emp_firmware_active))

/obj/machinery/camera/proc/upgradeEmpProof(malf_upgrade, ignore_malf_upgrades)
	if(isEmpProof(ignore_malf_upgrades)) //pass a malf upgrade to ignore_malf_upgrades so we can replace the malf module with the normal one
		return							//that way if someone tries to upgrade an already malf-upgraded camera, it'll just upgrade it to a normal version.
	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	if(malf_upgrade)
		assembly.malf_emp_firmware_active = TRUE //don't add parts to drop, update icon, ect. reconstructing it will also retain the upgrade.
		assembly.malf_emp_firmware_present = TRUE //so the upgrade is retained after incompatible parts are removed.

	else if(!assembly.emp_module) //only happens via upgrading in camera/attackby()
		assembly.emp_module = new(assembly)
		if(assembly.malf_emp_firmware_active)
			assembly.malf_emp_firmware_active = FALSE //make it appear like it's just normally upgraded so the icons and examine texts are restored.

	upgrades |= CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/removeEmpProof(ignore_malf_upgrades)
	if(ignore_malf_upgrades) //don't downgrade it if malf software is forced onto it.
		return
	RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_WIRES | EMP_PROTECT_CONTENTS)
	upgrades &= ~CAMERA_UPGRADE_EMP_PROOF

/obj/machinery/camera/proc/isXRay(ignore_malf_upgrades)
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	return (upgrades & CAMERA_UPGRADE_XRAY) && (!(ignore_malf_upgrades && assembly.malf_xray_firmware_active))

/obj/machinery/camera/proc/upgradeXRay(malf_upgrade, ignore_malf_upgrades)
	if(isXRay(ignore_malf_upgrades)) //pass a malf upgrade to ignore_malf_upgrades so we can replace the malf upgrade with the normal one
		return						//that way if someone tries to upgrade an already malf-upgraded camera, it'll just upgrade it to a normal version.
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()
	if(malf_upgrade)
		assembly.malf_xray_firmware_active = TRUE //don't add parts to drop, update icon, ect. reconstructing it will also retain the upgrade.
		assembly.malf_xray_firmware_present = TRUE //so the upgrade is retained after incompatible parts are removed.

	upgrades |= CAMERA_UPGRADE_XRAY
	update_icon()

/obj/machinery/camera/proc/removeXRay(ignore_malf_upgrades)
	if(!ignore_malf_upgrades) //don't downgrade it if malf software is forced onto it.
		upgrades &= ~CAMERA_UPGRADE_XRAY
	update_icon()

/obj/machinery/camera/proc/isMotion()
	return upgrades & CAMERA_UPGRADE_MOTION

/obj/machinery/camera/proc/upgradeMotion()
	if(isMotion())
		return
	var/obj/structure/camera_assembly/assembly = assembly_ref?.resolve()

	if(name == initial(name))
		name = "motion-sensitive security camera"
	if(!assembly.proxy_module)
		assembly.proxy_module = new(assembly)
	upgrades |= CAMERA_UPGRADE_MOTION
	create_prox_monitor()

/obj/machinery/camera/proc/removeMotion()
	if(name == "motion-sensitive security camera")
		name = "security camera"
	upgrades &= ~CAMERA_UPGRADE_MOTION
	if(!area_motion)
		QDEL_NULL(proximity_monitor)
