/datum/ai_controller/robot_customer
	ai_movement = /datum/ai_movement/basic_avoidance
	non_mob_movement_delay = 0.8 SECONDS
	blackboard = list(BB_CUSTOMER_CURRENT_ORDER = null,
	BB_CUSTOMER_MY_SEAT = null,
	BB_CUSTOMER_PATIENCE = 999,
	BB_CUSTOMER_CUSTOMERINFO = null,
	BB_CUSTOMER_EATING = FALSE,
	BB_CUSTOMER_LEAVING = FALSE,
	BB_CUSTOMER_ATTENDING_VENUE = null,
	BB_CUSTOMER_SAID_CANT_FIND_SEAT_LINE = FALSE)
	planning_subtrees = list(/datum/ai_planning_subtree/robot_customer)

/datum/ai_controller/robot_customer/Destroy()
	// clear possible datum refs
	set_blackboard_key(BB_CUSTOMER_CURRENT_ORDER, null)
	set_blackboard_key(BB_CUSTOMER_CUSTOMERINFO, null)
	return ..()

/datum/ai_controller/robot_customer/TryPossessPawn(atom/new_pawn)
	if(!istype(new_pawn, /mob/living/simple_animal/robot_customer))
		return AI_CONTROLLER_INCOMPATIBLE
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(new_pawn, COMSIG_ATOM_GET_GRABBED, PROC_REF(on_get_pulled))
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_get_punched))
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_GET_GRABBED, COMSIG_ATOM_ATTACK_HAND))
	return ..() //Run parent at end

/datum/ai_controller/robot_customer/proc/on_attackby(datum/source, obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	if(attending_venue.is_correct_order(I, blackboard[BB_CUSTOMER_CURRENT_ORDER]))
		to_chat(user, span_notice("You hand [I] to [pawn]"))
		eat_order(I, attending_venue)
		return COMPONENT_NO_AFTERATTACK
	else
		INVOKE_ASYNC(src, PROC_REF(warn_greytider), user)


/datum/ai_controller/robot_customer/proc/eat_order(obj/item/order_item, datum/venue/attending_venue)
	if(!blackboard[BB_CUSTOMER_EATING])
		set_blackboard_key(BB_CUSTOMER_EATING, TRUE)
		attending_venue.on_get_order(pawn, order_item)
		var/our_order = blackboard[BB_CUSTOMER_CURRENT_ORDER]
		if(isdatum(our_order))
			qdel(our_order)
		set_blackboard_key(BB_CUSTOMER_CURRENT_ORDER, null)


///Called when
/datum/ai_controller/robot_customer/proc/on_get_pulled(datum/source, mob/living/puller)
	SIGNAL_HANDLER


	INVOKE_ASYNC(src, PROC_REF(async_on_get_pulled), source, puller)

/datum/ai_controller/robot_customer/proc/async_on_get_pulled(datum/source, mob/living/puller)
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/item/card/id/used_id = puller.get_idcard(TRUE)

	if(used_id && (attending_venue.req_access in used_id?.GetAccess()))
		customer.say(customer_data.friendly_pull_line)
		return
	warn_greytider(puller)
	customer.resist()




/datum/ai_controller/robot_customer/proc/warn_greytider(mob/living/greytider)
	var/mob/living/simple_animal/robot_customer/customer = pawn
	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]
	var/datum/customer_data/customer_data = blackboard[BB_CUSTOMER_CUSTOMERINFO]
	//Living mobs are tagged, so these will always be valid
	attending_venue.mob_blacklist[REF(greytider)] += 1

	switch(attending_venue.mob_blacklist[REF(greytider)])
		if(1)
			customer.say(customer_data.first_warning_line)
			return
		if(2)
			customer.say(customer_data.second_warning_line)
			return
		if(3)
			customer.say(customer_data.self_defense_line)
	set_blackboard_key(BB_CUSTOMER_CURRENT_TARGET, greytider)

	CancelActions()

/datum/ai_controller/robot_customer/proc/on_get_punched(datum/source, mob/living/living_hitter)
	SIGNAL_HANDLER

	var/datum/venue/attending_venue = blackboard[BB_CUSTOMER_ATTENDING_VENUE]

	var/obj/item/card/id/used_id = living_hitter.get_idcard(hand_first = TRUE)

	if(used_id && (attending_venue.req_access in used_id?.GetAccess()))
		return

	if(living_hitter.combat_mode)
		INVOKE_ASYNC(src, PROC_REF(warn_greytider), living_hitter)
