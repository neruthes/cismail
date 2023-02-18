#
# libcontacts.sh
#
# This file includes the interactions with age.
#

function age_getself() {
    Name="$1"
    MY_KEYPAIRS_LIST="$(ls "$CONFDIR/self.age")"
    if [[ -n "$Name" ]]; then
        PrivKeyFile="$CONFDIR/self.age/$Name"
    else
        PrivKeyFile="$CONFDIR/self.age/$(head -n1 <<< "$MY_KEYPAIRS_LIST")"
    fi
    echo "$(realpath "$PrivKeyFile")"
}
function age_showpub() {
    PrivKeyFile="$1"
    age-keygen -y "$PrivKeyFile"
}
