// Definitions for Howl so they don't have to be repeated.

/obj/structure/bed/dogbed/ian
	desc = "Howl's bed! Looks comfy."
	name = "Howl's bed"
	anchored = TRUE

/mob/living/basic/pet/dog/corgi/ian
    name = "Howl"
    real_name = "Howl"

/mob/living/basic/pet/dog/corgi/ian/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	. = ..()
	speech.emote_see = string_list(speech.emote_see + "howls at the moon.")

/mob/living/basic/pet/dog/corgi/puppy/ian
	name = "Howl"
	real_name = "Howl"
