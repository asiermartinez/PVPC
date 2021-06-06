#!/bin/bash

SOURCE_FILE=$1
DESTINATION_FILE=./prices/${sourcefile##*/}

jq '
  def cleanprice: 
    if test("\\,") then sub(","; "") 
      | "0" * (6 - length) + . 
      | .[0:1] + "." + .[1:6] 
    else . end;

  def replacetime:
    .["time"] = .["Hora"][0:2] + ":00" |
    del(.Hora);
  
  def replacedate:
    .["date"] = 
      .["Dia"][6:10] + "-" +
      .["Dia"][3:5] + "-" +
      .["Dia"][0:2] |
    del(.Dia);
  
  [.PVPC
    | .[]
    | { Dia, Hora, PCB, CYM }
    | replacedate
    | replacetime
    | .["pcb_price"] = (.PCB | cleanprice)
    | .["cym_price"] = (.CYM | cleanprice)
    | del(.PCB, .CYM)
  ]
' ${SOURCE_FILE} > ${DESTINATION_FILE}