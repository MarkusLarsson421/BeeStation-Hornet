/obj/structure/closet/secure_closet/locker/explorer

/obj/structure/closet/secure_closet/locker/explorer/PopulateContents()
	..()
	//clothes
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/under/rank/cargo/exploration(src)
	new /obj/item/radio/headset/headset_exploration(src)
	//equipment
	new /obj/item/knife/combat/survival(src)
	new /obj/item/stack/marker_beacon/thirty(src)
	new /obj/item/gun/energy/e_gun/mini/exploration(src)

/obj/structure/closet/secure_closet/locker/explorer/scientist
	name = "\proper explorer scientist locker"
	req_access = list(ACCESS_EXPLORATION, ACCESS_TOX)
	icon_state = "rd"

/obj/structure/closet/secure_closet/locker/explorer/scientist/PopulateContents()
	..()
	//clothes
	new /obj/item/storage/backpack/explorer(src)
	new /obj/item/storage/backpack/satchel/explorer(src)
	new /obj/item/storage/backpack/duffelbag(src)
	//equipment
	new /obj/item/clothing/glasses/science(src)
	new /obj/item/sbeacondrop/exploration(src)
	new /obj/item/research_disk_pinpointer(src)

/obj/structure/closet/secure_closet/locker/explorer/engineer
	name = "\proper explorer engineer locker"
	req_access = list(ACCESS_EXPLORATION, ACCESS_TOX)
	icon_state = "rd"

/obj/structure/closet/secure_closet/locker/explorer/engineer/PopulateContents()
	..()
	//clothes
	//equipment
	new /obj/item/grenade/exploration(src)
	new /obj/item/grenade/exploration(src)
	new /obj/item/grenade/exploration(src)
	new /obj/item/exploration_detonator(src)
	new /obj/item/discovery_scanner(src)
	new /obj/item/storage/belt/utility/full(src)

/obj/structure/closet/secure_closet/locker/explorer/doctor
	name = "\proper explorer doctor locker"
	req_access = list(ACCESS_EXPLORATION, ACCESS_TOX)
	icon_state = "rd"

/obj/structure/closet/secure_closet/locker/explorer/doctor/PopulateContents()
	..()
	//clothes
	new /obj/item/storage/backpack/medic(src)
	new /obj/item/storage/backpack/satchel/med(src)
	new /obj/item/storage/backpack/duffelbag/med(src)
	//equipment
	new /obj/item/storage/firstaid/medical(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/sensor_device(src)
	new /obj/item/rollerbed(src)
	new /obj/item/discovery_scanner(src)