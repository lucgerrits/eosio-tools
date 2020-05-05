#!/bin/bash

SCRIPT_PATH=$(dirname "$0")
cd $SCRIPT_PATH
source ./common.sh

help () {
    printf "############################################################\n"
    printf "    Smart contract: Compile, publish, execute \n"
    printf "############################################################\n"
    printf "\n"
    printf "Usage:\n"
    printf "$0 <MODE> <OPTIONS>\n"
    printf "\n"
    printf "Compile\n"
    printf "  Compile a smart contract:\n"
    printf "    $0 compile <CPP_CONTRACT_PATH>\n"
    printf "  Note: A smart contract has its own folder.\n"

    printf "\n"
    printf "Publish\n"
    printf "  Publish a smart contract:\n"
    printf "    $0 publish <SC_PATH> <SC_NAME>\n"
    printf "  Note: <SC_PATH> is the path to the smart contract folder.\n"
    printf "        <SC_NAME> is the name of the smart contract and \n"
    printf "        also the name of the used account.\n"

    printf "\n"
    printf "Execute\n"
    printf "  Execute a smart contract:\n"
    printf "    $0 execute <SC_NAME> <ACTION> <DATA> <ACCOUNT>\n"

    printf "\n"
    printf "\n"
    printf "~by luc\n"
    exit 0
}

main () {
    #run the correct cmd
    case $1 in
        "-h"|"--help") help "$@";;

        "compile") compile_sc $2 ;;
        "publish") publish_sc $2 $3 ;;
        "execute") execute_sc $2 $3 $4 $5 ;;

        *) echo "ERROR: Command not found. Use -h or --help for help." ;;
    esac

}

main "$@"