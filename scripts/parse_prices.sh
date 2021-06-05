#!/bin/bash

jq '
  def cleanprice: 
    if test("\\,") then sub(","; "") 
      | "0" * (6 - length) + . 
      | .[0:1] + "." + .[1:6] 
    else . end;

  def replacetime:
    .["time"] = .["Hora"][0:2] + ":00";
  
  def replacedate:
    .["date"] = 
      .["Dia"][6:10] + "-" +
      .["Dia"][3:5] + "-" +
      .["Dia"][0:2];

  def deletekeys:
    del(.Dia, .Hora, .COF2TD, .PCB, .CYM, .PMHPCB, .PMHCYM, .SAHPCB, .SAHCYM, .FOMPCB, .FOMCYM, .FOSPCB, .FOSCYM, .INTPCB, .INTCYM, .PCAPPCB, .PCAPCYM, .TEUPCB, .TEUCYM, .CCVPCB, .CCVCYM, .EDSRPCB, .EDSRCYM);

  def icbvalues:
    .["ICB"] = {
      price: .PCB,
      market: .PMHPCB,
      adjustment: .SAHPCB,
      om_financing: .FOMPCB,
      os_financing: .FOSPCB,
      uninterruptibility: .INTPCB,
      capacity: .PCAPPCB,
      tolls: .TEUPCB,
      variables: .CCVPCB,
      auctions: .EDSRPCB
    };

  def camvalues: 
    .["CAM"] = {
      price: .CYM,
      market: .PMHCYM,
      adjustment: .SAHCYM,
      om_financing: .FOMCYM,
      os_financing: .FOSCYM,
      uninterruptibility: .INTCYM,
      capacity: .PCAPCYM,
      tolls: .TEUCYM,
      variables: .CCVCYM,
      auctions: .EDSRCYM
    };
  
  [.PVPC
    | .[]
    | map_values(cleanprice)
    | replacedate
    | replacetime
    | icbvalues
    | camvalues
    | deletekeys
  ]
' ./source/2021-06-05_Sat.json > ./prices/2021-06-05_Sat.json