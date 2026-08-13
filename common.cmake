# Common module for shared dependencies and configurations

# Find abseil-cpp package
find_package(absl CONFIG REQUIRED)

# CMCore 的公开头文件（OrderedSet.h 等）直接包含 absl 头文件，而
# use_cm_module 会把各模块 inc 目录全局加入所有 target 的 include 路径。
# 因此必须把 absl 的 include 目录也全局暴露，否则链接了 CMCore 但未
# 直接链接 absl 的 target 在编译时会报 C1083。
set(_ABSL_GLOBAL_INCLUDE_DIRS "")
foreach(_absl_tgt IN ITEMS absl::btree absl::flat_hash_map absl::node_hash_map)
    if(TARGET ${_absl_tgt})
        get_target_property(_absl_incs ${_absl_tgt} INTERFACE_INCLUDE_DIRECTORIES)
        if(_absl_incs)
            list(APPEND _ABSL_GLOBAL_INCLUDE_DIRS ${_absl_incs})
        endif()
    endif()
endforeach()
list(REMOVE_DUPLICATES _ABSL_GLOBAL_INCLUDE_DIRS)
if(_ABSL_GLOBAL_INCLUDE_DIRS)
    include_directories(SYSTEM ${_ABSL_GLOBAL_INCLUDE_DIRS})
endif()
unset(_ABSL_GLOBAL_INCLUDE_DIRS)
unset(_absl_tgt)
unset(_absl_incs)

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
