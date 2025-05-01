/obj/structure/necromorph/node/branch
	name = "branch"
	icon = 'deadspace/icons/effects/corruption.dmi'
	icon_state = "minigrowth3"
	corruption_node_type = /datum/corruption_node/branch
	max_integrity = 45
	cost = 3

/obj/structure/necromorph/node/branch/Initialize(mapload, obj/structure/marker/new_master)
	. = ..()
	icon_state = "minigrowth[rand(3, 4)]"

/datum/corruption_node/branch
	remaining_weed_amount = 80
	control_range = 5
