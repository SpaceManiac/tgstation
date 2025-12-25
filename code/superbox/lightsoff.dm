//! System for turning off the lights of roundstart unoccupied areas.

SUBSYSTEM_DEF(lightsoff)
	name = "Lights Off"
	init_order = -50
	wait = 10
	runlevels = RUNLEVEL_GAME
	flags = SS_NO_INIT

/datum/controller/subsystem/lightsoff/fire(resumed)
	// Fires once after roundstart, due to the default runlevel.
	can_fire = FALSE

	var/list/info = GLOB.lightsoff_info[SSmapping.current_map.map_name]
	if (!info)
		return

	// combine all candidates into a list
	var/list/lightsoff_areas = list()
	var/list/job_mappings = list()

	for(var/key in info)
		var/value = info[key]
		for(var/job in key)
			job_mappings[job] = value
		lightsoff_areas |= value

	for(var/datum/record/crew/record in GLOB.manifest.general)
		var/rank = record.rank
		var/datum/job/J = SSjob.get_job(rank)
		lightsoff_areas -= job_mappings[J?.type]

	for(var/obj/machinery/door/poddoor/M in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/poddoor))
		if(M.id in lightsoff_areas)
			INVOKE_ASYNC(M, /obj/machinery/door/poddoor.proc/close)

	for(var/area_path in lightsoff_areas)
		var/area/area = GLOB.areas_by_type[area_path]
		if (area)
			area.lightswitch = !area.lightswitch
			area.update_icon()
			for(var/obj/machinery/light_switch/L in area)
				L.update_icon()
			area.power_change()

GLOBAL_LIST_INIT(lightsoff_info, list(
	"SB Station" = list(
		// unconditional
		list() = list(
			/area/station/maintenance,
			/area/station/maintenance/disposal,
			/area/station/maintenance/department/electrical,
			/area/station/security/courtroom,
		),
		// security
		list(/datum/job/head_of_security, /datum/job/security_officer, /datum/job/warden, /datum/job/prisoner) = list(
			/area/station/command/heads_quarters/hos,
			/area/station/security,
			/area/station/security/brig,
			"brigfront",
			"hoslock",
		),
		// cargo
		list(/datum/job/quartermaster, /datum/job/cargo_technician, /datum/job/shaft_miner) = list(
			/area/station/cargo/warehouse,
			/area/station/cargo/miningdock,
			/area/station/cargo/bitrunning/den,
		),
		// medical
		list(/datum/job/chief_medical_officer, /datum/job/doctor, /datum/job/chemist) = list(
			/area/station/command/heads_quarters/cmo,
			/area/station/medical/medbay/central,
			/area/station/medical/chemistry,
			/area/station/medical/morgue,
		),
		// genetics are part-medical, part-science: give them their own lightsoff list
		list(/datum/job/geneticist) = list(
			/area/station/science/genetics,
		),
		// science
		list(/datum/job/research_director, /datum/job/scientist, /datum/job/roboticist) = list(
			/area/station/command/heads_quarters/rd,
			/area/station/science/research,
			/area/station/science/server,
			/area/station/science/xenobiology,
			/area/station/science/lab,
			/area/station/science/robotics/lab,
			/area/station/science/robotics/mechbay,
		),
		// service
		list(/datum/job/bartender, /datum/job/botanist, /datum/job/cook) = list(
			/area/station/service/hydroponics,
			/area/station/service/kitchen,
			"kitchen",
		),
		// engineering
		list(/datum/job/chief_engineer, /datum/job/station_engineer, /datum/job/atmospheric_technician) = list(
			/area/station/command/heads_quarters/ce,
			/area/station/engineering/main,
			/area/station/engineering/atmos,
			"ceblast",
		),
		// AI
		list(/datum/job/ai, /datum/job/human_ai) = list(
			/area/station/tcommsat/server,
			/area/station/ai/satellite/chamber,
		),
		// private offices
		list(/datum/job/lawyer) = list(
			/area/station/service/lawoffice,
			"lawyer_blast",
		),
		list(/datum/job/detective) = list(
			/area/station/security/detectives_office,
			"kanyewest",
		),
		list(/datum/job/janitor) = list(
			/area/station/service/janitor,
		),
		list(/datum/job/chaplain) = list(
			/area/station/service/chapel,
			/area/station/service/chapel/office,
		),
		list(/datum/job/head_of_personnel) = list(
			/area/station/command/heads_quarters/hop,
			"hopline",
			"hopblast",
		),
		list(/datum/job/captain) = list(
			/area/station/command/heads_quarters/captain,
			"captainhall",
		),
	)
))
