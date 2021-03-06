#!/bin/bash

# The default number of active torrents to keep running
max_active=5

# Host, port and authentication arguments for transmission-remote.
options=( localhost:9091 -n admin:admin )

do_start=1
do_pause=1

usage() {
  cat << EOF
Usage: ${0##*/} [OPTIONS] [transmission-remote args]

  -h          Print this help message and exit
  -m number   Set maximum number of active torrents (default: 5)
  -s          Only start torrents
  -p          Only pause torrents

  Remaining arguments will be passed on to transmission-remote.

  Example usage:

  Make sure 10 torrents are active, starting and stopping torrents as
  necessary:
    trqueue -m 10 

  Make sure at most 10 torrents are active, but do not start any.
    requeue -m 10 -p

  Provide username and password for transmission
    trqueue -- -n transmission-user:secret
EOF
}

remote() { transmission-remote "${options[@]}" "$@"; }

# Parses out 4 values for each torrent from transmission-remote -l and sorts
# numerically
# <running (0/1)> <percentage done> <ratio> <torrent id>
filter() { 
  remote -l | awk -F'^ +|  +' 'NF>9{print ($9!="Stopped"),$3+0,$8+0,$2}' | 
    /usr/bin/sort -n -k1,1 -k2,2 -k3,3
}

while getopts "hm:ps" opt; do
  case $opt in
    h) usage; exit;;
    m)
      if [[ $OPTARG = *[![:digit:]]* ]]; then
        usage
        exit 1
      fi
      max_active=$OPTARG
      ;;
    p) do_pause=1 do_start=0;;
    s) do_pause=0 do_start=1;;
    \?) usage; exit 1;;
  esac
done
shift "$((OPTIND-1))"
[[ $1 = -- ]] && shift
(( $# )) && options=( "$@" )

num_active=0 num_stopped=0 active=() stopped=()
while read running percent ratio id; do 
  if (( running )); then
    active[num_active++]=$id
  else
    stopped[num_stopped++]=$id
  fi
done < <(filter)

if (( do_pause && num_active > max_active )); then
  (IFS=,; remote -t "${active[*]:max_active}" --stop)
elif (( do_start && num_active < max_active )); then
  (IFS=,; remote -t "${stopped[*]:0:max_active-num_active}" --start)
fi