/*Self-Respiration
 * Slight increase to stealth
 * Greatly reduces resistance
 * Greatly reduces stage speed
 * Reduces transmission tremendously
 * Lethal level
 * Bonus: Gives the carrier TRAIT_NOBREATH, preventing suffocation and CPR
*/
/datum/symptom/oxygen
	name = "Self-Respiration"
	desc = "The virus rapidly synthesizes oxygen, effectively removing the need for breathing."
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 6
	base_message_chance = 5
	symptom_delay_min = 1
	symptom_delay_max = 1
	var/regenerate_blood = FALSE
	threshold_descs = list(
		"Resistance 8" = "Additionally regenerates lost blood."
	)

/datum/symptom/oxygen/sync_properties(list/properties)
	. = ..()
	if(!.)
		return
	if(properties[PATHOGEN_PROP_RESISTANCE] >= 8) //blood regeneration
		regenerate_blood = TRUE

/datum/symptom/oxygen/on_process(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			M.adjustOxyLoss(-7, 0)
			M.losebreath = max(0, M.losebreath - 4)
			if(regenerate_blood && M.blood_volume < BLOOD_VOLUME_NORMAL)
				M.blood_volume += 1
		else
			if(prob(base_message_chance))
				to_chat(M, span_notice("[pick("Your lungs feel great.", "You realize you haven't been breathing.", "You don't feel the need to breathe.")]"))
	return

/datum/symptom/oxygen/on_stage_change(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/M = A.affected_mob
	if(A.stage >= 4)
		ADD_TRAIT(M, TRAIT_NOBREATH, PATHOGEN_TRAIT)
	else
		REMOVE_TRAIT(M, TRAIT_NOBREATH, PATHOGEN_TRAIT)
	return TRUE

/datum/symptom/oxygen/on_stop_processing(datum/pathogen/advance/A)
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(A.affected_mob, TRAIT_NOBREATH, PATHOGEN_TRAIT)
