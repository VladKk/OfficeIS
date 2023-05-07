# Additional clean files
cmake_minimum_required(VERSION 3.16)

if("${CONFIG}" STREQUAL "" OR "${CONFIG}" STREQUAL "Debug")
  file(REMOVE_RECURSE
  "common/CMakeFiles/common_autogen.dir/AutogenUsed.txt"
  "common/CMakeFiles/common_autogen.dir/ParseCache.txt"
  "common/common_autogen"
  "filteringmodel/CMakeFiles/filteringmodel_autogen.dir/AutogenUsed.txt"
  "filteringmodel/CMakeFiles/filteringmodel_autogen.dir/ParseCache.txt"
  "filteringmodel/filteringmodel_autogen"
  "gui/CMakeFiles/gui_autogen.dir/AutogenUsed.txt"
  "gui/CMakeFiles/gui_autogen.dir/ParseCache.txt"
  "gui/CMakeFiles/gui_init_autogen.dir/AutogenUsed.txt"
  "gui/CMakeFiles/gui_init_autogen.dir/ParseCache.txt"
  "gui/CMakeFiles/gui_qmlcache_autogen.dir/AutogenUsed.txt"
  "gui/CMakeFiles/gui_qmlcache_autogen.dir/ParseCache.txt"
  "gui/CMakeFiles/gui_resources_1_autogen.dir/AutogenUsed.txt"
  "gui/CMakeFiles/gui_resources_1_autogen.dir/ParseCache.txt"
  "gui/CMakeFiles/gui_resources_2_autogen.dir/AutogenUsed.txt"
  "gui/CMakeFiles/gui_resources_2_autogen.dir/ParseCache.txt"
  "gui/gui_autogen"
  "gui/gui_init_autogen"
  "gui/gui_qmlcache_autogen"
  "gui/gui_resources_1_autogen"
  "gui/gui_resources_2_autogen"
  )
endif()
