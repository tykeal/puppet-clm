# Class: clm::config
# ===========================
#
# CLM server configuration class
#
# Parameters
# ----------
#
# None
#
# Variables
# ----------
#
# None
#
# Authors
# -------
#
# Andrew J Grimberg <agrimberg@linuxfoundation.org>
#
# Copyright
# ---------
#
# Copyright 2015 Andrew J Grimberg
#
class clm::config (
  $clm_config,
  $clm_group,
  $clm_user,
  $clm_user_home,
) {
  # since we aren't using assert_private because of not knowing how to
  # test using rspec when it's set we need to be extra paranoid and
  # revalidate all the params
  validate_hash($clm_config)
  validate_string($clm_group)
  validate_string($clm_user)
  validate_absolute_path($clm_user_home)
}
