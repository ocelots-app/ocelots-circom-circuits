include_directories(
    ../src
    ../build
    ../depends/json/single_include)

link_libraries(${GMP_LIB})

add_definitions(${GMP_DEFINIONS})

if(USE_ASM)
    if(ARCH MATCHES "arm64")
            add_definitions(-DUSE_ASM -DARCH_ARM64)
    elseif(ARCH MATCHES "x86_64")
            add_definitions(-DUSE_ASM -DARCH_X86_64)
    endif()
endif()

if(USE_ASM AND ARCH MATCHES "x86_64")

    if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin" AND NOT TARGET_PLATFORM MATCHES "^android(_x86_64)?")
        set(NASM_FLAGS -fmacho64 --prefix _)
    else()
        set(NASM_FLAGS -felf64 -DPIC)
    endif()

    add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/build/fq_asm.o
        COMMAND nasm ${NASM_FLAGS} fq.asm -o fq_asm.o
        DEPENDS ${CMAKE_SOURCE_DIR}/build/fq.asm
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/build)

    add_custom_command(OUTPUT ${CMAKE_SOURCE_DIR}/build/fr_asm.o
        COMMAND nasm ${NASM_FLAGS} fr.asm -o fr_asm.o
        DEPENDS ${CMAKE_SOURCE_DIR}/build/fr.asm
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/build)
endif()

set(FR_SOURCES
    ../build/fr.hpp
    ../build/fr.cpp
    )

if(USE_ASM)
    if(ARCH MATCHES "arm64")
        set(FR_SOURCES ${FR_SOURCES} ../build/fr_raw_arm64.s ../build/fr_raw_generic.cpp ../build/fr_generic.cpp)
    elseif(ARCH MATCHES "x86_64")
        set(FR_SOURCES ${FR_SOURCES} ../build/fr_asm.o)
    endif()
else()
    set(FR_SOURCES ${FR_SOURCES} ../build/fr_generic.cpp ../build/fr_raw_generic.cpp)
endif()

add_library(fr STATIC ${FR_SOURCES})
set_target_properties(fr PROPERTIES POSITION_INDEPENDENT_CODE ON)

link_libraries(fr)


add_executable(tests tests.cpp)
add_executable(test_platform test_platform.cpp)


set(LIB_SOURCES
    calcwit.cpp
    witnesscalc.h
    witnesscalc.cpp
    )

# disclose
set(DISCLOSE_SOURCES ${LIB_SOURCES}
    disclose.cpp
    witnesscalc_disclose.h
    witnesscalc_disclose.cpp
    )

add_library(witnesscalc_disclose SHARED ${DISCLOSE_SOURCES})
add_library(witnesscalc_discloseStatic STATIC ${DISCLOSE_SOURCES})
set_target_properties(witnesscalc_disclose PROPERTIES OUTPUT_NAME witnesscalc_disclose)

add_executable(disclose main.cpp)
target_link_libraries(disclose witnesscalc_disclose)

target_compile_definitions(witnesscalc_disclose PUBLIC CIRCUIT_NAME=disclose)
target_compile_definitions(witnesscalc_discloseStatic PUBLIC CIRCUIT_NAME=disclose)
target_compile_definitions(disclose PUBLIC CIRCUIT_NAME=disclose)

# register_sha256WithRSAEncryption_65537
set(REGISTER_SHA256WITHRSAENCRYPTION_65537_SOURCES ${LIB_SOURCES}
    register_sha256WithRSAEncryption_65537.cpp
    witnesscalc_register_sha256WithRSAEncryption_65537.h
    witnesscalc_register_sha256WithRSAEncryption_65537.cpp
    )

add_library(witnesscalc_register_sha256WithRSAEncryption_65537 SHARED ${REGISTER_SHA256WITHRSAENCRYPTION_65537_SOURCES})
add_library(witnesscalc_register_sha256WithRSAEncryption_65537Static STATIC ${REGISTER_SHA256WITHRSAENCRYPTION_65537_SOURCES})
set_target_properties(witnesscalc_register_sha256WithRSAEncryption_65537Static PROPERTIES OUTPUT_NAME witnesscalc_register_sha256WithRSAEncryption_65537)

add_executable(register_sha256WithRSAEncryption_65537 main.cpp)
target_link_libraries(register_sha256WithRSAEncryption_65537 witnesscalc_register_sha256WithRSAEncryption_65537Static)

target_compile_definitions(witnesscalc_register_sha256WithRSAEncryption_65537 PUBLIC CIRCUIT_NAME=register_sha256WithRSAEncryption_65537)
target_compile_definitions(witnesscalc_register_sha256WithRSAEncryption_65537Static PUBLIC CIRCUIT_NAME=register_sha256WithRSAEncryption_65537)
target_compile_definitions(register_sha256WithRSAEncryption_65537 PUBLIC CIRCUIT_NAME=register_sha256WithRSAEncryption_65537)