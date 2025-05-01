/obj/structure/necromorph/node/root
	name = "root"
	icon = 'deadspace/icons/effects/corruption.dmi'
	icon_state = "minigrowth1"
	corruption_node_type = /datum/corruption_node/root
	max_integrity = 45
	cost = 7

/obj/structure/necromorph/node/root/Initialize(mapload, obj/structure/marker/new_master)
	. = ..()
	icon_state = "minigrowth[rand(1, 2)]"

/datum/corruption_node/root
	remaining_weed_amount = 60
	control_range = 8
