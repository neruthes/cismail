#
# libcontacts.sh
#
# This file includes the CRUD for contacts.
#

#
# Contacts are saved in '$CONFDIR/contacts-v1.psv'
# It is a LF-delimited text file consisting of lines such as:
#       John Appleseed|kpid:age:age1145141919810


CONTACTSDBFILE1="$CONFDIR/contacts-v1.psv"

function contacts_v1_initdb() {
    touch "$CONTACTSDBFILE1"
}
function contacts_v1_search() {
    ( grep -E "|$1" "$CONTACTSDBFILE1"
    grep -E "^$1|" "$CONTACTSDBFILE1" ) | head -n1
}
function contacts_v1_insert() {
    echo "$1|$2" >> "$CONTACTSDBFILE1"
    sort -u "$CONTACTSDBFILE1" -o "$CONTACTSDBFILE1"
}
