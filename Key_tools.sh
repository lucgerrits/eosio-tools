#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
cd $SCRIPT_PATH
source ./common.sh

help () {
    printf "############################################################\n"
    printf "    Create, unlock, list EOS wallets, keys and accounts\n"
    printf "############################################################\n"
    printf "\n"
    printf "Usage:\n"
    printf "$0 <MODE> <OPTIONS>\n"
    printf "\n"
    printf "Wallet & keys\n"
    printf "  Create a default wallet:\n"
    printf "    $0 create_wallet\n"
    printf "\n"
    printf "  View all wallets:\n"
    printf "    $0 list_wallets\n"
    printf "\n"
    printf "  Create a new default wallet key (as many you want):\n"
    printf "    $0 create_key\n"
    printf "\n"
    printf "  List default wallet keys (used to make accounts, etc):\n"
    printf "    $0 list_keys\n"
    printf "\n"
    printf "  Save a key (viw them with 'list_keys'):\n"
    printf "    $0 save_default_key <KEY>\n"

    printf "\n"
    printf "Accounts\n"
    printf "  Create a default accounts (bob & alice):\n"
    printf "    $0 create_account <CREATOR> <ACCOUNT_NAME> <OWNER_KEY>\n"
    printf "  Note: - By default creates bob & alice accounts.\n"
    printf "        - <CREATOR> <ACCOUNT_NAME> <OWNER_KEY> are optional \n"
    printf "          if you want to make a custom account.\n"
    
    printf "\n"
    printf "  View all accounts associated to a key:\n"
    printf "    $0 list_accounts <KEY>\n"
    printf "  Note: <KEY> is optional\n"

    printf "\n"
    printf "\n"
    printf "~by luc\n"
    exit 0
}

main () {
    #run the correct cmd
    case $1 in
        "-h"|"--help") help "$@";;
        #wallet & keys
        "create_wallet") create_wallet ;;
        "list_wallets") list_wallets ;;
        "create_key") create_key ;;
        "list_keys") list_keys ;;
        "save_default_key") save_default_key $2;;
        #account
        "create_account") create_account $2 $3 $4;;
        "list_accounts") list_accounts $2 $3 $4 ;;
        *) echo "ERROR: Command not found. Use -h or --help for help." ;;
    esac

}

main "$@"