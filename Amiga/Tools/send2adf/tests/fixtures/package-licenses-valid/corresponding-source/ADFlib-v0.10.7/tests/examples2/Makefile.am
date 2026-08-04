
# Add verbose output for test execution
#AM_TESTS_ENVIRONMENT = VERBOSE=1

# Define the script that needs to be generated
TESTS_ENVIRONMENT = CONFIG_SH=$(abs_top_builddir)/tests/config.sh


dist_check_SCRIPTS = \
	test_adfbitmap.sh \
	test_adfinfo.sh \
	test_adfinfo_hd.sh \
	test_adf_floppy.sh \
	test_adfls.sh \
	test_adfsalvage.sh \
	test_unadf.sh \
	test_unadf_hdd.sh \
	test_unadf_win32.sh

dist_check_DATA = \
	func.sh \
	gen_res_msys.sh \
	test_common.sh \
	test_runner.sh

include Makefile.am_cmd

check_SCRIPTS = $(dist_check_SCRIPTS)
check_DATA = $(dist_check_DATA)

TESTS = $(dist_check_SCRIPTS)
#TESTS = test_adfinfo_hd.sh

EXTRA_DIST = res

# Pre-test validation
# (disabled: it works, but runs _after_ running tests...)
#check-local:
#	@echo "Running pre-test validation 2..."
#	@test -f $(abs_top_builddir)/tests/config.sh && \
#            echo "config.sh is present" || \
#            echo "ERROR: config.sh is missing!"

