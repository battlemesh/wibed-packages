#!/bin/bash

# cd to script's dir
cd ${0%/*}

# Case insensitive regular expression matching
shopt -s nocasematch

RESULTS_DIR="/var/wibed/results"

COMMANDS_PIPE="/var/wibed/pipes/commands"

# Function: commandExists
#
# Checks if the specified command exists in the system.
#
# Params:
# - command - The command to check.
#
# Returns:
# 0 - If the command exists, 1 - otherwise.
commandExists () {
    type "$1" &> /dev/null ;
}

# Function: readVariable
#
# Read variable from UCI or config files depending on
# environment.
#
# Params:
# - variableName - The name of the variable to load.
# - defaultValue - Value to use if no value exists for the variable.
#
# Returns:
# - Value read or initialized from provided default.
function readVariable {
    local variableName=$1
    local value=$2
    local readValue=""

    if [[ $UCI == 1 ]] ; then
        readValue=$(uci get ${UCI_CONFIG}.${variableName})
    else
        file="$CONFIG_DIR/$variableName"
        if [ -e $file ] ; then
            readValue=$(< $file)
        fi
    fi

    if [[ -n "$readValue" ]] ; then
        value="$readValue"
    fi

    echo $value
}

# Function: writeVariable
#
# Write variable to UCI or config files depending on
# environment.
#
# Params:
# - variableName - The name of the variable to write.
# - value - Value to write.
function writeVariable {
    local variableName=$1
    local value=$2

    if [[ $UCI == 1 ]] ; then
        uci set ${UCI_CONFIG}.${variableName}="$value"
    else
        echo "$value" > "$CONFIG_DIR/$variableName"
    fi
}

# Function: jsonEscape
#
# Escape characters for JSON output.
# 
# Params:
# - data - Unescaped json data.
#
# Returns:
# - Escaped json data.
function jsonEscape {
    local text=$1

    text=${text//\\/\\\\} # \ 
    text=${text//\//\\\/} # / 
    text=${text//\"/\\\"} # " 
    text=${text//   /\\t} # \t (tab)
    text=${text//$'\n'/\\\n} # \n (newline)
    text=${text//^M/\\\r} # \r (carriage return)
    text=${text//^L/\\\f} # \f (form feed)
    text=${text//^H/\\\b} # \b (backspace)

    echo $text
}


# Function: buildResults
#
# Builds a json list containing information about all non-acknowledged
# results.
#
# Params:
# - resultAck - The current result ack.
#
# Returns:
# - JSON list with information about non-acked results.
function buildResults {
    local resultAck=$1

    if [ ! -d "$RESULTS_DIR" ] ; then
        echo "[]"
        return 1
    fi

    local first=1
    local results="["
    local commandIds=$(ls -1 "$RESULTS_DIR")
    for commandId in $commandIds
    do
        cmdResultFolder="$RESULTS_DIR/$commandId"

        if [ $commandId -gt $resultAck ] ; then
            if [[ $first == 0 ]] ; then
                results="$results,"
            fi

            # If command still hasn't finished we can break
            # because no following command will have finished too.
            if [[ ! -e "$cmdResultFolder/exitCode" ]] ; then
                break
            fi

            exitCode=$(< "$cmdResultFolder/exitCode")
            stdout=$(< "$cmdResultFolder/stdout")
            stdout=$(jsonEscape "$stdout")
            stderr=$(< "$cmdResultFolder/stderr")
            stderr=$(jsonEscape "$stderr")

            results="$results[$commandId, $exitCode, \"$stdout\", \"$stderr\"]"
            first=0
        fi
    done 
    results="$results]"
    echo $results
}

# Function: parseResopnse
#
# Parses the JSON response string into a set of variables.
#
# Params:
# - json - The json to parse.
function parseResponse {
    local json="$1"
    local response=$(echo "$json" | $JSON_SCRIPT -b)

    echo "Response:"
    echo $json
    echo " "
    echo "Parsed response:"
    echo $response

    IFS_BAK=$IFS
    IFS=$'\n'

    responseLineRe='^\[([^]]*)\](.*)$'

    for line in $response; do
        if [[ $line =~ $responseLineRe ]] ; then
            # Remove " from keys and put them in an array
            IFS="," read -ra keys <<< "${BASH_REMATCH[1]//\"/}"

            # Trim value and remove "
            value=$(echo "${BASH_REMATCH[2]//\"/}" | 
                sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')

            if [[ ${keys[0]} == "experiment" ]] ; then
                if [[ ${keys[1]} == "id" ]] ; then
                    experimentId=$value
                elif [[ ${keys[1]} == "overlay" ]] ; then
                    experimentOverlay=$value
                elif [[ ${keys[1]} == "action" ]] ; then
                    experimentAction=$value
                fi
            elif [[ ${keys[0]} == "upgrade" ]] ; then
                if [[ ${keys[1]} == "version" ]] ; then
                    upgradeVersion=$value
                elif [[ ${keys[1]} == "delay" ]] ; then
                    upgradeDelay=$value
                fi
            elif [[ ${keys[0]} == "commands" ]] ; then
                if [[ ${keys[2]} == "0" ]] ; then
                    commandIds[${keys[1]}]="$value"
                else
                    commands[${keys[1]}]="$value"
                fi
            elif [[ ${keys[0]} == "resultAck" ]] ; then
                resultAck=$value
            elif [[ ${keys[0]} == "errors" ]] ; then
                errors[${keys[1]}]="$value"
            fi
        fi
    done 

    # return delimiter to previous value
    IFS=$IFS_BAK
    IFS_BAK=
}

# Function: doFirmwareUpgrade
#
# Start the firmware upgrade process.
#
# Params:
# - version - New firmware version.
# - delay - The delay until the actual installation of the firmware.
function doFirmwareUpgrade {
    local version=$1
    local delay=$2

    status=5
    # TODO: Get overlay from server
    # TODO: Launch upgrade script
}

# Function: doPrepareExperiment
#
# Prepares an experiment by downloading the respective overlay
# and installing it.
#
# Params:
# - experimentId - Id of the experiment.
# - overlayId - The id of the overlay used in the experiment.
function doPrepareExperiment {
    local experimentId=$1
    local overlayId=$2

    if errors=$(curl -o "overlay.tar.gz" "$apiUrl/static/overlays/$overlayId" \
            2>&1 >/dev/null) ; then
        status=2
        writeVariable "experiment.exp_id" $experimentId
        # TODO: Install overlay
        status=3
    else
        # Report error
        echo $errors
    fi
}

# Function: doStartExperiment
#
# Start the experiment.
function doStartExperiment {
    status=4
    # TODO: Call experiment starting script or reboot.
}

# Function: doFinishExperiment
#
# Finishes an active experiment.
function doFinishExperiment {
    # TODO: Kill experiment process

    echo "-1 exit" > $COMMANDS_PIPE
    rm -r results
    rm -r overlay.tar.gz
    status=1
}

# Function: executeCommands
#
# Sets up the commands provided as argument for execution.
#
# Args:
# cmdIds - An array of command ids.
# cmds - An array of actual commands.
function executeCommands {
    declare -a cmdIds=("${!1}")
    declare -a cmds=("${!2}")
    local lastCommandId=$commandAck

    local numCommands=${#cmdIds[@]}

    for (( i=0; i<numCommands; i++))
    do
        local commandId=${cmdIds[$i]}

        if [[ -z $commandId ]] ; then
            continue
        fi

        # If command executor is not running, launch it
        if [[ ! -e $COMMANDS_PIPE ]] ; then
            nohup ./command-executer.sh &
            # Give some time for named pipe to be created
            sleep 1
        fi

        # Escape command string
        local command=${cmds[$i]}
        echo "Executing command $commandId \"$command\""
        echo "$commandId $command" > $COMMANDS_PIPE
        lastCommandId=$commandId
    done

    writeVariable "general.commandAck" $lastCommandId
}

if commandExists "uci" ; then
    # Using UCI
    UCI=1
    UCI_CONFIG="wibed"
else
    # Using config files
    UCI=0
    CONFIG_DIR="config"

    if [[ ! -d "$CONFIG_DIR" ]] ; then
        mkdir -p "$CONFIG_DIR"
    fi
fi

if commandExists "resty" ; then
    RESTY_SCRIPT="resty"
elif [[ -d "resty" ]] ; then
    RESTY_SCRIPT="resty/resty"
else
    echo "Could not find resty. Exiting..."
    exit 2
fi

if commandExists "JSON.sh" ; then
    JSON_SCRIPT="JSON.sh"
elif [[ -d "json" ]] ; then
    JSON_SCRIPT="json/JSON.sh"
else
    echo "Could not find JSON.sh. Exiting..."
    exit 3
fi

# Load resty for easy REST API access
. $RESTY_SCRIPT

apiUrl=$(readVariable "general.api_url" "")
resty $apiUrl

id=$(readVariable "general.node_id" 0)
status=$(readVariable "general.status" 0)
model=$(readVariable "upgrade.model")
version=$(readVariable "upgrade.version")
experimentId=$(readVariable "experiment.exp_id" -1)
commandAck=$(readVariable "general.commandAck" -1)
resultAck=$(readVariable "general.resultAck" -1)

request="{\"status\": $status"

case $status in
    0)
        request="$request,
            \"model\": \"$model\",
            \"version\": \"$version\""
        ;;
    [1,4])
        results=$(buildResults $resultAck)
        request="$request,
            \"commandAck\": $commandAck,
            \"results\": $results"
        ;;
esac

request="$request}"

echo " "
echo "Request:"
echo $request
echo " "

if response=$(POST /api/wibednode/"$id" "$request" \
        -H "Content-Type: application/json") ; then
    echo "Communication with server successful"
    echo " "
    parseResponse "$response"

    if [[ "${#errors[@]}" -gt 0 ]] ; then
        echo "Error:"
        printf -- '%s\n' "${errors[@]}"
        exit 1
    fi

    # Migration from status 0 to 1 is automatic upon receival of response
    # by server.
    if [[ $status == "0" ]] ; then
        status=1
    fi

    case $status in
        # IDLE
        1)
            if [[ $upgradeVersion ]] ; then
                doFirmwareUpgrade $upgradeVersion $upgradeDelay
            elif [[ $experimentAction == "PREPARE" ]] ; then
                doPrepareExperiment $experimentId $experimentOverlay
            fi
            ;;
        # IN EXPERIMENT
        [234])
            if [[ $experimentAction == "FINISH" ]] ; then
                doFinishExperiment
            fi

            # READY
            if [[ $status == 3 && $experimentAction == "RUN" ]] ; then
                doStartExperiment
            fi
            ;;

        # UPGRADING
        5)
            ;;
    esac

    if [[ $status == 4 || $status == 1 ]] ; then
        executeCommands commandIds[@] commands[@]
    fi

    if [[ $resultAck ]] ; then
        writeVariable "general.resultAck" $resultAck
    fi

    # Update status on disk
    writeVariable "general.status" $status
else
    echo "Communication with server unsuccessful"
fi
