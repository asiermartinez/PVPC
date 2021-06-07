#!/bin/bash

# TODO Refactor and clean date operations

SOURCE_FILE=$1
DESTINATION_FILE=./prices/${SOURCE_FILE##*/}
UTC_OFFSET=$(TZ="Europe/Madrid" date +%z)

jq --arg UTC_OFFSET "$UTC_OFFSET" '
  # workaround for https://github.com/stedolan/jq/issues/2001
  def fromdate1: (. | fromdate) as $t1 | ($t1 | todate | fromdate) as $t2 | $t1 - ($t2 - $t1);

  def cleanprice: 
    if test("\\,") then sub(","; "") 
      | "0" * (6 - length) + . 
      | .[:1] + "." + .[1:6] 
    else . end;

  def fromCET:
    . - ($UTC_OFFSET[:3]|tonumber) * 60 * 60;

  def toCET:
    . + ($UTC_OFFSET[:3]|tonumber) * 60 * 60;

  def getutc:
      (.["Dia"][6:10] + "-" + .["Dia"][3:5] + "-" + .["Dia"][:2] +
      "T" + .["Hora"][:2] + ":00:00Z" | fromdate1 | fromCET | todate);

  def setdatetime:
    .["starts"] = 
      (.["Dia"][6:10] + "-" + .["Dia"][3:5] + "-" + .["Dia"][:2] +
      "T" + .["Hora"][:2] + ":00:00" + $UTC_OFFSET[:3] + ":" + $UTC_OFFSET[3:]);
  
  def getweekday:
    (getutc | fromdate1 | toCET | strftime("%a"));

  def gethour: 
    (getutc | fromdate1 | toCET | strftime("%H") | tonumber);

  def setrates:
    .["rate"] = 
    gethour as $rate_range |
    getweekday as $week_day |
    if $week_day == "Sat" or $week_day == "Sun" 
      or $rate_range >= 0 and $rate_range <= 7 then "valley"
    elif $rate_range >= 8 and $rate_range <= 9 
      or $rate_range >= 14 and $rate_range <= 17
      or $rate_range >= 22 and $rate_range <= 23 then "flat"
    elif $rate_range >= 10 and $rate_range <= 13 
      or $rate_range >= 18 and $rate_range <= 21 then "peak"
    else null end;
  
  [.PVPC
    | .[]
    | { Dia, Hora, PCB, CYM }
    | setdatetime
    | setrates
    | .["pcb_price"] = (.PCB | cleanprice)
    | .["cym_price"] = (.CYM | cleanprice)
    | del(.PCB, .CYM, .Dia, .Hora)
  ]
' ${SOURCE_FILE} > ${DESTINATION_FILE}