/datum/action/innate/sense
	name = "Sense the Unwhole"
	desc = "They cannot stop what is coming. Use to sense those who are not Whole."
	button_icon = 'icons/mob/actions/actions_cult.dmi' //TODO : Get our own sense button sprites
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	button_icon_state = "cult_mark"
	var/list/poorsod = list()

//This is rewritten cultist harvester code kitbashed into the original sense code
//It works well enough for our purposes
/datum/action/innate/sense/Activate()
	var/mob/living/carbon/human/necromorph/sensor = owner
	if(sensor.marker == null)
		return
	if(sensor.searching) //Resets sense if it is already on
		desc = "They cannot stop what is coming. Use to sense those who are not Whole."
		button_icon_state = "cult_mark"
		sensor.searching = FALSE
		sensor.sense_target = null
		to_chat(sensor, "<span class='cult italic'>You are no longer sensing.</span>")
		sensor.clear_alert("necrosense")
		return

	//We look for any mob with a client, avoids necros and signals
	for(var/mob/living/survivors as anything in GLOB.player_list)
		if(survivors.stat != DEAD && !isnecromorph(survivors) && !ismarkereye(survivors) && is_station_level(survivors.loc?.z))
			poorsod += survivors

	if(!poorsod) //If the list is empty then it is because there is nobody on this floor
		to_chat(sensor, "<span class='cult italic'>There is nobody on this floor.</span>")
		return

	for(var/mob/living/found in poorsod) //This exists so we can reliably get their name out of the list
		found = pick(poorsod)
		sensor.sense_target = found
		to_chat(sensor, "<span class='cult italic'>You are now tracking your prey, [found.real_name] - find [found.p_them()]!</span>")
		break

	desc = "Activate to stop sensing."
	button_icon_state = "sintouch"
	sensor.searching = TRUE
	sensor.throw_alert("necrosense", /atom/movable/screen/alert/necrosense)
	sensor.play_necro_sound(SOUND_SPEECH, VOLUME_MID, TRUE, 3)
	play_effects()
	poorsod.Cut() //We want to get rid of the list once we are done with it

/datum/action/innate/sense/proc/play_effects()
	set waitfor = FALSE

	var/obj/effect/temp_visual/circle = new /obj/effect/temp_visual/expanding_circle(owner.loc, 2 SECONDS, 2)
	circle.pixel_y += 40 //Offset it so it appears to be at our mob's head
	sleep(7)
	circle = new /obj/effect/temp_visual/expanding_circle(owner.loc, 2 SECONDS, 2)
	circle.pixel_y += 40
	sleep(7)
	circle = new /obj/effect/temp_visual/expanding_circle(owner.loc, 2 SECONDS, 2)
	circle.pixel_y += 40
