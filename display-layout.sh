#!/bin/bash

# Get current display info using displayplacer list and parse it
CURRENT_INFO=$(displayplacer list)
MACBOOK_ID=$(echo "$CURRENT_INFO" | grep -A1 "Type: MacBook" | grep "Persistent" | cut -d " " -f 3)
EXTERNAL_ID=$(echo "$CURRENT_INFO" | grep -A1 "Type: .* external" | grep "Persistent" | cut -d " " -f 3)

MACBOOK_RES=$(echo "$CURRENT_INFO" | grep -A1 "Type: MacBook" | grep "Resolution:" | cut -d " " -f 2)
EXTERNAL_RES=$(echo "$CURRENT_INFO" | grep -A1 "Type: .* external" | grep "Resolution:" | cut -d " " -f 2)

MACBOOK_HZ=$(echo "$CURRENT_INFO" | grep -A1 "Type: MacBook" | grep "Hertz:" | cut -d " " -f 2)
EXTERNAL_HZ=$(echo "$CURRENT_INFO" | grep -A1 "Type: .* external" | grep "Hertz:" | cut -d " " -f 2)

function show_usage() {
   echo "Usage: display-layout [layout]"
   echo "Available layouts:"
   echo "  right   - MacBook screen on the right, external on the left"
   echo "  bottom  - External on top (main), MacBook on bottom"
   echo "  mirror  - Mirror both displays (using MacBook resolution)"
   echo "  list    - Show current arrangement"
   exit 1
}

function set_layout() {
   case $1 in
       "right")
           displayplacer \
               "id:$MACBOOK_ID res:$MACBOOK_RES hz:$MACBOOK_HZ color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" \
               "id:$EXTERNAL_ID res:$EXTERNAL_RES hz:$EXTERNAL_HZ color_depth:8 enabled:true scaling:off origin:(-$EXTERNAL_RES,0) degree:0"
           ;;
       "bottom")
           displayplacer \
               "id:$EXTERNAL_ID res:$EXTERNAL_RES hz:$EXTERNAL_HZ color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" \
               "id:$MACBOOK_ID res:$MACBOOK_RES hz:$MACBOOK_HZ color_depth:8 enabled:true scaling:on origin:(1033,$EXTERNAL_RES) degree:0"
           ;;
       "mirror")
           displayplacer \
               "id:$MACBOOK_ID+$EXTERNAL_ID res:$MACBOOK_RES hz:$MACBOOK_HZ color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"
           ;;
       "list")
           displayplacer list
           ;;
       *)
           show_usage
           ;;
   esac
}

[[ $# -eq 0 ]] && show_usage
set_layout "$1"
