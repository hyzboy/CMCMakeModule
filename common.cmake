# Common module for shared dependencies and configurations

# Find abseil-cpp package
find_package(absl CONFIG REQUIRED)

# vcpkg's absl target exports may include MSVC-specific ignore flags in
# INTERFACE link properties; strip them for non-MSVC toolchains.
if(NOT MSVC)
	set(_all_targets)
	get_property(_dir_imported_targets DIRECTORY PROPERTY IMPORTED_TARGETS)
	if(_dir_imported_targets)
		list(APPEND _all_targets ${_dir_imported_targets})
	endif()
	get_property(_global_targets GLOBAL PROPERTY TARGETS)
	if(_global_targets)
		list(APPEND _all_targets ${_global_targets})
	endif()
	list(REMOVE_DUPLICATES _all_targets)

	foreach(_tgt IN LISTS _all_targets)
		if(NOT _tgt MATCHES "^absl::")
			continue()
		endif()

		foreach(_prop IN ITEMS INTERFACE_LINK_LIBRARIES INTERFACE_LINK_OPTIONS)
			get_target_property(_vals ${_tgt} ${_prop})
			if(NOT _vals)
				continue()
			endif()

			set(_new_vals ${_vals})
			list(REMOVE_ITEM _new_vals
				"-ignore:4221"
				"/IGNORE:4221"
				"$<LINK_ONLY:-ignore:4221>"
				"$<LINK_ONLY:/IGNORE:4221>")

			if(NOT _new_vals STREQUAL _vals)
				set_target_properties(${_tgt} PROPERTIES ${_prop} "${_new_vals}")
			endif()
		endforeach()
	endforeach()
endif()
