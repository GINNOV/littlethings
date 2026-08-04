
#
# Test building configuration
#

find_program (BASH_PROGRAM bash)

include_directories (
  ${PROJECT_SOURCE_DIR}/src
  ${PROJECT_SOURCE_DIR}/src/generic
  ${PROJECT_BINARY_DIR}/src
)

add_executable ( access access.c common.c common.h log.c log.h )
target_link_libraries ( access adf )

add_executable ( bitmap_read_segfault bitmap_read_segfault.c log.c log.h )
target_link_libraries ( bitmap_read_segfault adf )

add_executable ( bitmap_recreate bitmap_recreate.c log.c log.h )
target_link_libraries ( bitmap_recreate adf )

add_executable ( bootdisk bootdisk.c common.c common.h log.c log.h )
target_link_libraries ( bootdisk adf )

add_executable ( bootdisk2 bootdisk2.c common.c common.h log.c log.h )
target_link_libraries ( bootdisk2 adf )

add_executable ( cache_crash cache_crash.c )
target_link_libraries ( cache_crash adf )

# an incomplete test?
#add_executable ( cache_test cache_test.c )
#target_link_libraries ( cache_test adf )

add_executable ( comment comment.c common.c common.h  log.c log.h )
target_link_libraries ( comment adf )

add_executable ( del_test del_test.c common.c common.h log.c log.h )
target_link_libraries ( del_test adf )

add_executable ( dir_test dir_test.c common.c common.h log.c log.h )
target_link_libraries ( dir_test adf )

add_executable ( dir_test2 dir_test2.c common.c common.h  log.c log.h )
target_link_libraries ( dir_test2 adf )

add_executable ( dir_test_chdir dir_test_chdir.c )
target_link_libraries ( dir_test_chdir adf )

#add_executable ( dirc dirc.c )
#target_link_libraries ( dirc adf )

#add_executable ( dirc_test dirc_test.c )
#target_link_libraries ( dirc_test adf )

add_executable ( dispsect dispsect.c common.c common.h log.c log.h )
target_link_libraries ( dispsect adf )

add_executable ( file_read_hard_link_test file_read_hard_link_test.c log.c log.h )

target_link_libraries ( file_read_hard_link_test adf )

add_executable ( file_seek_test file_seek_test.c common.c common.h log.c log.h )
target_link_libraries ( file_seek_test adf )

add_executable ( file_seek_test2 file_seek_test2.c common.c common.h log.c log.h )
target_link_libraries ( file_seek_test2 adf )

add_executable ( file_seek_after_write file_seek_after_write.c log.c log.h )
target_link_libraries ( file_seek_after_write adf )

add_executable ( file_test file_test.c common.c common.h log.c log.h )
target_link_libraries ( file_test adf )

add_executable ( file_test2 file_test2.c common.c common.h log.c log.h )
target_link_libraries ( file_test2 adf )

#add_executable ( file_test2a file_test2a.c common.c common.h log.c log.h )
#target_link_libraries ( file_test2a adf )

add_executable ( file_test3 file_test3.c common.c common.h log.c log.h )
target_link_libraries ( file_test3 adf )

add_executable ( fl_test fl_test.c common.c common.h log.c log.h )
target_link_libraries ( fl_test adf )

add_executable ( fl_test2 fl_test2.c common.c common.h log.c log.h )
target_link_libraries ( fl_test2 adf )

add_executable ( floppy_overfilling_test floppy_overfilling_test.c log.c log.h )
target_link_libraries ( floppy_overfilling_test adf )

add_executable ( hardfile hardfile.c common.c common.h log.c log.h )
target_link_libraries ( hardfile adf )

add_executable ( hardfile2 hardfile2.c common.c common.h log.c log.h )
target_link_libraries ( hardfile2 adf )

add_executable ( hd_test hd_test.c common.c common.h log.c log.h )
target_link_libraries ( hd_test adf )

add_executable ( hd_test2 hd_test2.c common.c common.h log.c log.h )
target_link_libraries ( hd_test2 adf )

add_executable ( hd_test3 hd_test3.c common.c common.h log.c log.h )
target_link_libraries ( hd_test3 adf )

add_executable ( hd_test_a590 hd_test_a590.c common.c common.h log.c log.h )
target_link_libraries ( hd_test_a590 adf )

add_executable ( readonly readonly.c common.c common.h log.c log.h )
target_link_libraries ( readonly adf )

add_executable ( rename rename.c common.c common.h log.c log.h )
target_link_libraries ( rename adf )

add_executable ( rename2 rename2.c common.c common.h log.c log.h )
target_link_libraries ( rename2 adf )

add_executable ( undel undel.c common.c common.h log.c log.h )
target_link_libraries ( undel adf )

add_executable ( undel2 undel2.c common.c common.h log.c log.h )
target_link_libraries ( undel2 adf )

add_executable ( progbar progbar.c common.c common.h log.c log.h )
target_link_libraries ( progbar adf )

add_executable ( test_update_datasize_ofs test_update_datasize_ofs.c )
target_link_libraries ( test_update_datasize_ofs adf )


foreach ( a_file
    floppy.sh
    bigdev.sh
    bootdisk.sh
    bitmap_read_segfault.sh
    bitmap_recreate.sh
    cache_crash.sh
    common.sh
    del_test.sh
    dir_test2.sh
    dir_test_chdir.sh
    dir_test.sh
    file_read_hard_link_test.sh
    file_seek_test2.sh
    file_seek_test.sh
    file_test2.sh
    file_test3.sh
    file_test.sh
    floppy.sh
    fl_test2.sh
    fl_test.sh
    hardfile.sh
    hd_test.sh
    hd_test2.sh
    hd_test3.sh
    hd_test_a590.sh
    rename2.sh
    rename.sh
    undel2.sh
    undel.sh )
  configure_file ( ${a_file} ${a_file} COPYONLY )
endforeach ( a_file )


#
# Test executing configuration
#

add_test ( floppy.sh ${BASH_PROGRAM} floppy.sh )
add_test ( bigdev.sh ${BASH_PROGRAM} bigdev.sh )
add_test ( floppy_overfilling_test floppy_overfilling_test )
add_test ( test_update_datasize_ofs test_update_datasize_ofs )
