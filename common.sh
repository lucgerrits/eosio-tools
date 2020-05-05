#!/bin/bash

#open env:
export $(grep -v '^#' .env | xargs -d '\n')


############################################################
#
#                   Error messages
#
############################################################

stop_program () {
    exit 1
}

error_missing_x () {
    #missing an argument
    echo -n "Missing "
    echo -n $1
    echo "."
    stop_program
}

error_give_pub_key () {
    printf "Please give a public key. You can find them with the 'list_keys' option.\n"
    printf "Be sure to save a default key is you use only default accounts/keys.\n"
    stop_program
}

error_cannot_x () {
    #used to show random "Cannot ..." errors
    echo -n "Cannot "
    echo -n $1
    echo "."
    stop_program
}

############################################################
#
#                   Wallet & keys
#
############################################################

open_wallet () {
    #Wallets are closed by default when starting a keosd instance
    if cleos wallet open ; then
        echo "Default wallet open."
    else
        error_cannot_x "open default wallet"
    fi
}

unlock_wallet () {
    open_wallet
    if cleos wallet unlock < $PASSWORD_PATH ; then
        echo "Default wallet unlock."
    else
        error_cannot_x "unlock default wallet"
    fi
}

list_wallets () {
    unlock_wallet
    cleos wallet list
}

create_wallet () {
    if cleos wallet create -f $DEFAULT_PASSWORD_PATH ; then
        cp $DEFAULT_PASSWORD_PATH $PASSWORD_PATH
        echo "Password saved to $PASSWORD_PATH"
    else
        error_cannot_x "create default wallet failed. Maybe already exists."
    fi
}

list_keys () {
    unlock_wallet
    cleos wallet keys
}

create_key () {
    unlock_wallet
    cleos wallet create_key
}

save_default_key () {
    echo "$1" > $DEFAULT_KEY_PATH
    echo "Default key saved in: $DEFAULT_KEY_PATH"
    echo "This key will be used for all other actions."
}

############################################################
#
#                   Accounts
#
############################################################

import_eosio_dev_key () {
    if echo "$EOSIO_DEV_PRIVATE_KEY" | cleos wallet import > /dev/null 2>&1; then #""> /dev/null 2>&1" used to not print anything
        echo "Imported missing eosio dev private key."
    fi
}

test_pub_key () {
    #test if pub key is set
    if [ -z ${1+x} ]; then
        error_give_pub_key
    else
        echo "Using public key $1"
    fi
}

create_bob_alice () {
    cleos create account eosio bob $1
    cleos create account eosio alice $1
}

create_account_x () {
    #cleos create account creator name OwnerKey
    cleos create account $1 $2 $3 $4
    # cmd="cleos create account $@"
    # echo "$ $cmd"
    # eval $cmd
}

create_account () {
    unlock_wallet
    import_eosio_dev_key
    DEFAULT_KEY=$(cat $DEFAULT_KEY_PATH)
    if [ -z ${1+x} ]; then
        #default accounts are bob and alice
        echo "Using default"
        test_pub_key $DEFAULT_KEY
        create_bob_alice $DEFAULT_KEY
    else
        test_pub_key $3
        create_account_x "$@"
    fi
}

list_accounts () {
    DEFAULT_KEY=$(cat $DEFAULT_KEY_PATH)
    if [ -z ${1+x} ]; then
        echo "Using default"
        test_pub_key $DEFAULT_KEY
        cleos get accounts $DEFAULT_KEY
    else
        test_pub_key $1
        cleos get accounts $1
    fi
}

############################################################
#
#                   Smart contracts
#
############################################################

# create_SC_account () {
#     #account that is used to interface for the contract
#     cleos create account $1 $2 $3 -p $1@active
# }

build_wasm () {
    CPP_FILE_PATH=$1
    WASM_FILE_PATH="${CPP_FILE_PATH%.*}.wasm"
    cmd="eosio-cpp $CPP_FILE_PATH -o $WASM_FILE_PATH"
    echo "$ $cmd"
    eval $cmd
    echo "Done compiling"
}

compile_sc () {
    if [ -z ${1+x} ]; then
        error_missing_x "CPP file"
    else
        build_wasm "$@"
    fi
}

publish_sc () {
    DEFAULT_KEY=$(cat $DEFAULT_KEY_PATH)
    #the account if the interface of the SC, so will create a new one for each SC
    SC_PATH=$1
    SC_NAME=$2

    #be sure he account exists:
     
    if create_account "eosio" $SC_NAME $DEFAULT_KEY "-p eosio@active" > /dev/null 2>&1; then
        echo "SUCCESS: Created SC account with the name: $SC_NAME."
    else
        echo "WARNING: SC account already exists."
    fi

    #set SC:
    
    if cleos set contract $SC_NAME $SC_PATH -p $SC_NAME@active; then
        echo "SUCCESS: SC $SC_NAME is set in blockchain."
    else
        echo "ERROR: SC $SC_NAME is set in blockchain."
    fi
}

execute_sc () {
    SC_NAME=$1
    SC_ACTION=$2
    SC_DATA=$3
    SC_ACCOUNT=$4

    #ex: cleos push action hello hi '["bob"]' -p bob@active
    if cleos push action $SC_NAME $SC_ACTION $SC_DATA -p $SC_ACCOUNT@active; then
        echo "SUCCESS: send action to SC $SC_NAME."
    else
        echo "ERROR: send action to SC $SC_NAME."
    fi
}