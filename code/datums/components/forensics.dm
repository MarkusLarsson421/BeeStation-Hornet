/datum/component/forensics
	dupe_mode = COMPONENT_DUPE_UNIQUE
	can_transfer = TRUE
	var/list/fingerprints		//assoc print = print
	var/list/hiddenprints		//assoc ckey = realname/gloves/ckey
	var/list/blood_DNA			//assoc dna = bloodtype
	var/list/fibers				//assoc print = print
	var/list/souls

/datum/component/forensics/InheritComponent(datum/component/forensics/F, original)		//Use of | and |= being different here is INTENTIONAL.
	fingerprints = LAZY_LISTS_OR(fingerprints, F.fingerprints)
	hiddenprints = LAZY_LISTS_OR(hiddenprints, F.hiddenprints)
	blood_DNA = LAZY_LISTS_OR(blood_DNA, F.blood_DNA)
	fibers = LAZY_LISTS_OR(fibers, F.fibers)
	souls = LAZY_LISTS_OR(souls, F.souls)
	add_blood_decal()
	return ..()

/datum/component/forensics/Initialize(new_fingerprints, new_hiddenprints, new_blood_DNA, new_fibers, new_souls)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	fingerprints = new_fingerprints
	hiddenprints = new_hiddenprints
	blood_DNA = new_blood_DNA
	fibers = new_fibers
	souls = new_souls
	add_blood_decal()

/datum/component/forensics/RegisterWithParent()
	add_blood_decal()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(clean_act))

/datum/component/forensics/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_COMPONENT_CLEAN_ACT))

/datum/component/forensics/PostTransfer()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/forensics/proc/wipe_fingerprints()
	fingerprints = null
	return TRUE

/datum/component/forensics/proc/wipe_hiddenprints()
	return	//no.

/datum/component/forensics/proc/wipe_blood_DNA()
	blood_DNA = null
	return TRUE

/datum/component/forensics/proc/wipe_fibers()
	fibers = null
	return TRUE

/datum/component/forensics/proc/wipe_souls(force)
	if(force)
		souls = null
		return TRUE

/datum/component/forensics/proc/clean_act(datum/source, clean_types)
	if(clean_types & CLEAN_TYPE_FINGERPRINTS)
		wipe_fingerprints()
		. = TRUE
	if(clean_types & CLEAN_TYPE_BLOOD)
		wipe_blood_DNA()
		. = TRUE
	if(clean_types & CLEAN_TYPE_FIBERS)
		wipe_fibers()
		. = TRUE

/datum/component/forensics/proc/add_fingerprint_list(list/_fingerprints)	//list(text)
	if(!length(_fingerprints))
		return
	LAZYINITLIST(fingerprints)
	for(var/i in _fingerprints)	//We use an associative list, make sure we don't just merge a non-associative list into ours.
		fingerprints[i] = i
	return TRUE

/datum/component/forensics/proc/add_fingerprint(mob/living/M, ignoregloves = FALSE)
	if(!isliving(M))
		if(!iscameramob(M))
			return
		if(isaicamera(M))
			var/mob/camera/ai_eye/ai_camera = M
			if(!ai_camera.ai)
				return
			M = ai_camera.ai
	add_hiddenprint(M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		add_fibers(H)
		add_soul(H)
		if(H.gloves) //Check if the gloves (if any) hide fingerprints
			var/obj/item/clothing/gloves/G = H.gloves
			if(G.transfer_prints)
				ignoregloves = TRUE
			if(!ignoregloves)
				H.gloves.add_fingerprint(H, TRUE) //ignoregloves = 1 to avoid infinite loop.
				return
		var/full_print = rustg_hash_string(RUSTG_HASH_MD5, H.dna.uni_identity)
		LAZYSET(fingerprints, full_print, full_print)
	return TRUE

/datum/component/forensics/proc/add_fiber_list(list/_fibertext)		//list(text)
	if(!length(_fibertext))
		return
	LAZYINITLIST(fibers)
	for(var/i in _fibertext)	//We use an associative list, make sure we don't just merge a non-associative list into ours.
		fibers[i] = i
	return TRUE

/datum/component/forensics/proc/add_fibers(mob/living/carbon/human/M)
	var/fibertext
	var/item_multiplier = isitem(src) ? 1.2 : 1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
		if(!(M.wear_suit.body_parts_covered & CHEST))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12 * item_multiplier) && !LAZYACCESS(fibers, fibertext)) //Wearing a suit means less of the uniform exposed.
					LAZYSET(fibers, fibertext, fibertext)
		if(!(M.wear_suit.body_parts_covered & HANDS))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
					LAZYSET(fibers, fibertext, fibertext)
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
			// "Added fibertext: [fibertext]"
			LAZYSET(fibers, fibertext, fibertext)
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
				LAZYSET(fibers, fibertext, fibertext)
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20 * item_multiplier) && !LAZYACCESS(fibers, fibertext))
			LAZYSET(fibers, fibertext, fibertext)
	return TRUE

/datum/component/forensics/proc/add_hiddenprint_list(list/_hiddenprints)	//list(ckey = text)
	if(!length(_hiddenprints))
		return
	LAZYINITLIST(hiddenprints)
	for(var/i in _hiddenprints)	//We use an associative list, make sure we don't just merge a non-associative list into ours.
		hiddenprints[i] = _hiddenprints[i]
	return TRUE

/datum/component/forensics/proc/add_hiddenprint(mob/M)
	if(!isliving(M))
		if(!iscameramob(M))
			return
		if(isaicamera(M))
			var/mob/camera/ai_eye/ai_camera = M
			if(!ai_camera.ai)
				return
			M = ai_camera.ai
	if(!M.key)
		return
	var/hasgloves = ""
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.gloves)
			hasgloves = "(gloves)"
	var/current_time = time_stamp()
	if(!LAZYACCESS(hiddenprints, M.key))
		LAZYSET(hiddenprints, M.key, "First: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]")
	else
		var/laststamppos = findtext(LAZYACCESS(hiddenprints, M.key), " Last: ")
		if(laststamppos)
			LAZYSET(hiddenprints, M.key, copytext(hiddenprints[M.key], 1, laststamppos))
		hiddenprints[M.key] += " Last: [M.real_name]\[[current_time]\][hasgloves]. Ckey: [M.ckey]"	//made sure to be existing by if(!LAZYACCESS);else
	var/atom/A = parent
	A.fingerprintslast = M.ckey
	return TRUE

/datum/component/forensics/proc/add_blood_DNA(list/dna)		//list(dna_enzymes = type)
	if(!length(dna))
		return
	LAZYINITLIST(blood_DNA)
	for(var/i in dna)
		blood_DNA[i] = dna[i]
	add_blood_decal()
	return TRUE

/datum/component/forensics/proc/add_soul_list(list/_souls)	//list(text)
	if(!length(_souls))
		return
	LAZYINITLIST(souls)
	for(var/i in _souls)
		souls[i] = i
	return TRUE

/datum/component/forensics/proc/add_soul(mob/living/carbon/human/H)
	var/glimmer = H.mind?.soul_glimmer || "#000"
	LAZYSET(souls, glimmer, glimmer)
	return TRUE

/datum/component/forensics/proc/add_blood_decal()
	if(!isitem(parent))
		return
	if(!length(blood_DNA))
		return
	var/obj/item/I = parent
	I.AddElement(/datum/element/decal/blood) //TODO: make decals actually work on all the items, it doesnt appear on a lot of them for some reason
