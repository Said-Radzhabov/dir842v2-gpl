#!/usr/bin/python
# -*- coding: utf-8 -*-

import shutil

from pack_misc import *


def prop_pack(part_j, out_file):
	TMP_KRN = 'tmp_krn.bin'
	TMP_RF = 'tmp_rf.bin'
	TMP_FW = 'tmp_fw.bin'

	orig_krn = BINARIES_DIR + '/' + LINUX26_IMAGE_NAME
	tmp_krn = BINARIES_DIR + '/' + TMP_KRN

	shutil.copyfile(orig_krn, tmp_krn)
	round_file(tmp_krn, 64 * 1024, 16)

	orig_sqsh = BINARIES_DIR + '/' + 'rootfs.squashfs'
	tmp_sqsh = BINARIES_DIR + '/' + TMP_RF

	shutil.copyfile(orig_sqsh, tmp_sqsh)

	tmp_fw = BINARIES_DIR + '/' + TMP_FW

	krnfp = open(tmp_krn, 'rb')
	sqshfp = open(tmp_sqsh, 'rb')
	fwfp = open(tmp_fw, 'w+b')

	shutil.copyfileobj(krnfp, fwfp, FILE_CHUNK)
	shutil.copyfileobj(sqshfp, fwfp, FILE_CHUNK)

	krnfp.close()
	sqshfp.close()
	fwfp.close()

	cvimg = HOST_DIR + '/usr/bin/cvimg'

	cvimg_cmd = cvimg + ' linux-ro ' + tmp_fw + ' ' + out_file + ' ' + krn_config.get('CONFIG_LOAD_START_ADDR') + ' ' + krn_config.get('CONFIG_FLASH_FW_POS')

	#cvimg hdr
	os.system(cvimg_cmd)

	#dlink sign
	os.system(SIGN_PROGRAM + ' sign ' + out_file + ' ' + SIGN_FILE)

	os.unlink(tmp_krn)
	os.unlink(tmp_sqsh)
	os.unlink(tmp_fw)
