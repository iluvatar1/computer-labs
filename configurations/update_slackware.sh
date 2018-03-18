echo "Update slackpkg and install security patches ..."
slackpkg update gpg # only the first time
slackpkg update
slackpkg upgrade patches
slackpkg upgrade-all
slackpkg install-new
