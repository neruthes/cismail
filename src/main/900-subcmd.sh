case $1 in
    ''|help|h)
        show_help_msg
        ;;
    keygen)
        mkdir -p "$CONFDIR/self.age"
        Name="$2"
        [[ -z "$Name" ]] && Name=$USER
        KEYFILE="$CONFDIR/self.age/$Name"
        if [[ -e "$KEYFILE" ]]; then
            echo "[ERROR] Keypair file '$KEYFILE' already exists. Delete the file if you want to overwrite."
            exit 1
        fi
        age-keygen -o "$KEYFILE"
        pubkey="$(age-keygen -y "$KEYFILE")"
        kpid="kpid:age:$pubkey"
        contacts_v1_insert "$Name" "$kpid"
        ;;
    ls)
        [[ -e "$CONTACTSDBFILE1" ]] || contacts_v1_initdb
        sed 's/^/    /' "$CONTACTSDBFILE1"
        ;;
    add)
        contacts_v1_insert "$2" "$3"
        ;;
    e|encrypt)
        ### argv: e {Recipient} msg-file.txt {MyName}
        tmp_task="/tmp/.cismail-session-$RANDOM$RANDOM$RANDOM"
        recipeint_hint="$2"
        rawmsgfile="$3"
        self_file="$(age_getself "$4")"
        from_name="$(basename "$self_file")"
        from_kpid="kpid:age:$(age_showpub "$self_file")"
        to_name="$(contacts_v1_search "$recipeint_hint" | cut -d'|' -f1)"
        to_kpid="$(contacts_v1_search "$recipeint_hint" | cut -d'|' -f2)"
        ### Step 1: Generate BMMM
        bmmm_gen "$from_name" "$from_kpid" "$to_name" "$to_kpid" "$rawmsgfile" > "$tmp_task.bmmm"
        ### Step 2: Pass to encryption
        age -e -r "$(cut -d: -f3 <<< "$to_kpid")" < "$tmp_task.bmmm" > "$tmp_task.ageout.bin"
        ### Step 3: Produce human-friendly output text
        echo "-----BEGIN CISMAILv1 MESSAGE-----"
        base64 -w70 "$tmp_task.ageout.bin"
        echo "-----END CISMAILv1 MESSAGE-----"
        ### GC
        rm $tmp_task.*
        ;;
    d|decrypt)
        tmp_task="/tmp/.cismail-session-$RANDOM$RANDOM$RANDOM"
        ### argv: d encrypted-msg.asc
        msg_asc_file="$2"
        [[ -z "$msg_asc_file" ]] && msg_asc_file="/dev/stdin"
        
        declare -a privkeys_arr
        for abspath in "$CONFDIR/self.age/"*; do
            privkeys_arr+=('-i' "$abspath")
        done
        
        cat "$msg_asc_file" | grep -v ^- | base64 --decode | age -d "${privkeys_arr[@]}" > "$tmp_task.bmmm"
        if [[ $? != 0 ]]; then
            echo "[ERROR] Cannot decrypt message. Is it malformed?"
            exit 1
        fi
        from_name="$(bmmm_get_header    from        "$tmp_task.bmmm")"
        from_kpid="$(bmmm_get_header    from_key    "$tmp_task.bmmm")"
        to_name="$(bmmm_get_header      to          "$tmp_task.bmmm")"
        to_kpid="$(bmmm_get_header      to_key      "$tmp_task.bmmm")"
        msgts="$(bmmm_get_header        time        "$tmp_task.bmmm")"
        # echo "from_name=$from_name"
        # echo "from_kpid=$from_kpid"
        # echo "to_name=$to_name"
        # echo "to_kpid=$to_kpid"
        if grep -sq "$(cut -d: -f3 <<< "$to_kpid")" "$CONFDIR/self.age/"*; then
            msg_stderr "Valid: The message is sent to us: ($to_name) $to_kpid"
        else
            msg_stderr "INVALID: The message is sent to someone else: ($to_name) $to_kpid"
            msg_stderr "INVALID: Beware of replay attacks"
        fi
        nowts="$(date +%s)"
        delta_sec="$((nowts-msgts))"
        delta_hr=$((delta_sec/3600))
        msg_stderr "Hint: Message was created at $(date --date=@"$msgts") ($((delta_hr/24))d $((delta_hr%24))hr ago)"
        if [[ -n "$(contacts_v1_search "$from_kpid")" ]]; then
            saved_name="$(contacts_v1_search "$from_kpid" | cut -d'|' -f1)"
            # msg_stderr "Hint: Message was sent by '$from_name' ($from_kpid)"
            if [[ "$saved_name" == "$from_name" ]]; then
                msg_stderr "Hint: The sender is a contact: '$from_name' ($from_kpid)"
            else
                msg_stderr "Hint: The sender '$from_name' is a contact, but saved as another name '$saved_name' ($from_kpid)"
            fi
        else
            msg_stderr "Hint: The sender is not a contact yet"
            msg_stderr "Hint: Run 'cismail add \"$from_name\" \"$from_kpid\"' to add contact"
        fi
        ### Print the message content
        msg_stderr "Below is raw message ---------------------------------------"
        BMMM_PRINT_STATE=init
        while read -r line; do
            if [[ "$BMMM_PRINT_STATE" == init ]]; then
                if [[ "$line" == '----'* ]]; then
                    BMMM_PRINT_STATE=sep
                fi
            fi
            if [[ "$BMMM_PRINT_STATE" == body ]]; then
                printf '%s\n' "$line"
            fi
            if [[ "$BMMM_PRINT_STATE" == sep ]]; then
                BMMM_PRINT_STATE=body
            fi
        done < "$tmp_task.bmmm"
        rm $tmp_task.*
        ;;
esac
