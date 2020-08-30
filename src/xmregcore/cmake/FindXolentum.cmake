#------------------------------------------------------------------------------
# CMake helper for the majority of the cpp-ethereum modules.
#
# This module defines
#     Xolentum_XXX_LIBRARIES, the libraries needed to use ethereum.
#     Xolentum_FOUND, If false, do not try to use ethereum.
#
# File addetped from cpp-ethereum
#
# The documentation for cpp-ethereum is hosted at http://cpp-ethereum.org
#
# ------------------------------------------------------------------------------
# This file is part of cpp-ethereum.
#
# cpp-ethereum is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# cpp-ethereum is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with cpp-ethereum.  If not, see <http://www.gnu.org/licenses/>
#
# (c) 2014-2016 cpp-ethereum contributors.
#------------------------------------------------------------------------------

#set(LIBS        common;blocks;cryptonote_basic;cryptonote_core;
#		cryptonote_protocol;daemonizer;mnemonics;epee;lmdb;device;
#                blockchain_db;ringct;wallet;cncrypto;easylogging;version;checkpoints;
#                ringct_basic;randomx;hardforks)


if (NOT XOLENTUM_DIR)
    set(XOLENTUM_DIR ~/xolentum)
endif()

message(STATUS XOLENTUM_DIR ": ${XOLENTUM_DIR}")

set(XOLENTUM_SOURCE_DIR ${XOLENTUM_DIR}
        CACHE PATH "Path to the root directory for Monero")

# set location of xolentum build tree
set(XOLENTUM_BUILD_DIR ${XOLENTUM_SOURCE_DIR}/build/release/
        CACHE PATH "Path to the build directory for Xolentum")


if (NOT EXISTS ${XOLENTUM_BUILD_DIR})
    # try different location
    message(STATUS "Trying different folder for xolentum libraries")
    set(XOLENTUM_BUILD_DIR ${XOLENTUM_SOURCE_DIR}/build/Linux/master/release/
        CACHE PATH "Path to the build directory for Xolentum" FORCE)
endif()


if (NOT EXISTS ${XOLENTUM_BUILD_DIR})
  message(FATAL_ERROR "Xolentum libraries not found in: ${XOLENTUM_BUILD_DIR}")
endif()


set(CMAKE_LIBRARY_PATH ${CMAKE_LIBRARY_PATH} "${XOLENTUM_BUILD_DIR}"
        CACHE PATH "Add Xolentum directory for library searching")


set(LIBS  cryptonote_core
          blockchain_db
          #cryptonote_protocol
          cryptonote_basic
          #daemonizer
          blocks
          lmdb
          ringct
          ringct_basic
          common
          #mnemonics
          easylogging
          device
          epee
          checkpoints
          version
          cncrypto
          randomx
          hardforks)

set(Xol_INCLUDE_DIRS "${CPP_XOLENTUM_DIR}")

# if the project is a subset of main cpp-ethereum project
# use same pattern for variables as Boost uses

set(Xolentum_LIBRARIES "")

foreach (l ${LIBS})

	string(TOUPPER ${l} L)

	find_library(Xol_${L}_LIBRARY
			NAMES ${l}
			PATHS ${CMAKE_LIBRARY_PATH}
                        PATH_SUFFIXES "/src/${l}"
                                      "/src/"
                                      "/external/db_drivers/lib${l}"
                                      "/lib" "/src/crypto"
                                      "/contrib/epee/src"
                                      "/external/easylogging++/"
                                      "/src/ringct/"
                                      "/external/${l}"
			NO_DEFAULT_PATH
			)

	set(Xol_${L}_LIBRARIES ${Xol_${L}_LIBRARY})

	message(STATUS FindXolentum " Xol_${L}_LIBRARIES ${Xol_${L}_LIBRARY}")

    add_library(${l} STATIC IMPORTED)
	set_property(TARGET ${l} PROPERTY IMPORTED_LOCATION ${Xol_${L}_LIBRARIES})

    set(Xolentum_LIBRARIES ${Xolentum_LIBRARIES} ${l} CACHE INTERNAL "Xolentum LIBRARIES")

endforeach()


message("FOUND Xolentum_LIBRARIES: ${Xolentum_LIBRARIES}")

message(STATUS ${XOLENTUM_SOURCE_DIR}/build)

#macro(target_include_xolentum_directories target_name)

    #target_include_directories(${target_name}
        #PRIVATE
        #${XOLENTUM_SOURCE_DIR}/src
        #${XOLENTUM_SOURCE_DIR}/external
        #${XOLENTUM_SOURCE_DIR}/build
        #${XOLENTUM_SOURCE_DIR}/external/easylogging++
        #${XOLENTUM_SOURCE_DIR}/contrib/epee/include
        #${XOLENTUM_SOURCE_DIR}/external/db_drivers/liblmdb)

#endmacro(target_include_xolentum_directories)


add_library(Xolentum::Xolentum INTERFACE IMPORTED GLOBAL)

# Requires to new cmake
#target_include_directories(Xolentum::Xolentum INTERFACE
    #${XOLENTUM_SOURCE_DIR}/src
    #${XOLENTUM_SOURCE_DIR}/external
    #${XOLENTUM_SOURCE_DIR}/build
    #${XOLENTUM_SOURCE_DIR}/external/easylogging++
    #${XOLENTUM_SOURCE_DIR}/contrib/epee/include
    #${XOLENTUM_SOURCE_DIR}/external/db_drivers/liblmdb)

set_target_properties(Xolentum::Xolentum PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES
            "${XOLENTUM_SOURCE_DIR}/src;${XOLENTUM_SOURCE_DIR}/external;${XOLENTUM_SOURCE_DIR}/build;${XOLENTUM_SOURCE_DIR}/external/easylogging++;${XOLENTUM_SOURCE_DIR}/contrib/epee/include;${XOLENTUM_SOURCE_DIR}/external/db_drivers/liblmdb")


target_link_libraries(Xolentum::Xolentum INTERFACE
    ${Xolentum_LIBRARIES})
