cls

# single JSON element       
$FirmwareExample1 = @"
    { 
        "Model": "U3419W",
        "Index": "1",
        "MarketingName": "",
        "TargetFeature": "FWVERSION",
        "Value": "M3B114"
    }
"@
 
 # Array of JSON elements    
$FirmwareExample2 = @"
      [  
        { 
          "Model": "P2422H",
          "Index": "1",
          "MarketingName": "",
          "TargetFeature": "FWVERSION",
          "Value": "M2B103"
        }
        ,
        
        {
          "Model": "C2422HE",
          "Index": "2",
          "MarketingName": "",
          "TargetFeature": "FWVERSION",
          "Value": "M2T113"
        }  
      ]
"@  

# single JSON element     
 $SensorExample = @"
            {
                "Sensor_1":  "Poximity",
                "Sensor_2":  "Time-of-Flight",
                "Sensor_3":  "BlueTooth"
            }
"@  
#    $JsonPsObj | gm # -MemberType noteproperty

Function Main 
    {
    $FctName = "Main() -"
    
    [String]$JsonString =     $FirmwareExample2  #  $FirmwareExample1 # 


    # #####################################################
    # verify if JSON-String has valid syntax
    # ##################################################### 
    if (get-command -Name "Check-JsonString_Valid")
        {
        Write-Host "starting 'Check-JsonString_Valid' - first run"
        $ValidatedString = Check-JsonString_Valid -JsonString $JsonString  #-Debug 
        # Write-Host "`r`n'$ValidatedString'`r`n"
        if ( $ValidatedString -eq "" -or $ValidatedString -eq $Null ) 
            {
            Write-Host "`r`nstarting Fix1 JSON-ARRAY-format  `$('[' + JSONString.Replace( '} {' , '},{'') + ']'"
            $FixedString   = "[" + $ResultString.Replace(   '} {'   ,  '},{'  ) + "]" 
            
            Write-Host "`r`nstarting 'Check-JsonString_Valid' - second run"
            $ValidatedString = Check-JsonString_Valid -JsonString $FixedString # -Debug 
            }
        if ( $ValidatedString -eq "" -or $ValidatedString -eq $Null ) { throw }
        Write-Host "starting 'Check-JsonString_Valid' - SUCCESS"
        $JsonString = $ValidatedString
        }


    # #####################################################
    #  'Single' JSON-Object or 'Array' of JSON-Objects
    #  -> always create an array of JSON Objects / JHSON Strings
    # ##################################################### 
    $ArrJsonStrings = @()
    $AllJsonPsObj = ($JsonString | ConvertFrom-JSON)
    if ( $AllJsonPsObj -is [system.array] )
        {
        foreach( $JsonObject in $AllJsonPsObj )
            {
            $JsonString = $JsonObject | ConvertTo-JSON
            $ArrJsonStrings += $JsonString 
            }
        }
    else
        { 
        # array containing only one element 
        $ArrJsonStrings += $JsonString   
        }    
    Write-Host "converted start paramter '[STRING]`$JsonString'  to  '[ARRAY]`$ArrJsonStrings'"
    # the rest of the script will work only with the array '$ArrJsonStrings'
    

if ( 1 -eq 2 ) # JsonString - add a NoteItems (NodeProperty) from JsonString
    {
    ForEach ( $JsonString in $ArrJsonStrings )
        {
        # Remove current object
        $ArrJsonStrings = $ArrJsonStrings -ne $JsonString
        Write-Host "--------------------"
        $JsonString = Remove-JsonString_NodeProperty -JsonString $JsonString -NodePropertyName 'Result'
        $JsonString = Remove-JsonString_NodeProperty -JsonString $JsonString -NodePropertyName 'Message'
        $JsonString = Remove-JsonString_NodeProperty -JsonString $JsonString -NodePropertyName 'Command'
        $JsonString = Remove-JsonString_NodeProperty -JsonString $JsonString -NodePropertyName 'MarketingName'
        $JsonPsObj = ($JsonString | ConvertFrom-JSON )
        # RE-Add modified object
        $ArrJsonStrings += $JsonString 
        }
        Write-Host "------- summary after remove -------------"
        $ArrJsonStrings
        Write-Host "--------------------"
    }
    
if ( 1 -eq 2 ) #  different ways to display JSONstring or JSONnPsObject
    {
    # #####################################################
    # different ways to display JSONstring or JSONnPsObject
    # #####################################################
    
    ForEach ( $JsonString in $ArrJsonStrings )
        {
        $JsonPsObj =  $JsonString | ConvertFrom-JSON

        Write-Host "$FctName OutPut 'Write-Host `$JsonPsObj'"  
        Write-Host $JsonPsObj                       
        #  @{Model=U3419W; Index=1; TargetFeature=FWVERSION; Value=M3B114}
        Write-Host   
    
        Write-Host "$FctName OutPut '`$JsonPsObj | FT'"
        $JsonPsObj | FT
        <#
            Model  Index TargetFeature Value 
            -----  ----- ------------- ----- 
            U3419W 1     FWVERSION     M3B114
        #>
        }
    }

if ( 1 -eq 2 ) # JsonString - Get value from JSON NodeProperty
    {    
    # #####################################################
    # JsonString - Get value from NodeProperty
    # #####################################################
    
    ForEach ( $JsonString in $ArrJsonStrings )
        {
        $NodeProperty = 'Model'
        $Result1 = ($JsonString | ConvertFrom-JSON ).$NodeProperty 
        Write-Host "$FctName JsonString - Get value from NodeItem: '$NodeProperty' = '$Result1'"

        # JsonPsObj - Get value from NodeProperty
        $NodeProperty = 'Value'
        $JsonPsObj = ($JsonString | ConvertFrom-JSON )
        $Result2 = $JsonPsObj.$NodeProperty 
        Write-Host "$FctName JsonPsObj  - Get value from NodeItem: '$NodeProperty' = '$Result2'"
        }
    
    Write-Host "------- summary after 'Get value from JSON NodeProperty'  -------------"
    $ArrJsonStrings
    Write-Host "--------------------"

    }

if ( 1 -eq 2 ) # JsonString - add a new NodeProperty "NewProperty" with value "Value-NewProperty"
    {    
    # #####################################################
    # add a new NodeProperty "NewProperty" with value "Value-NewProperty"
    # #####################################################
    ForEach ( $JsonString in $ArrJsonStrings )
        {
        # Remove current object
        $ArrJsonStrings = $ArrJsonStrings -ne $JsonString

        $JsonString = Add-JsonString_NodeProperty -JsonString $JsonString -NodePropertyName "NewProperty" -NodePropertyValue "Value-NewProperty"
        $JsonPsObj = ($JsonString | ConvertFrom-JSON )
        Write-Host "$FctName OutPut 'Write-Host `$JsonPsObj'"  
        Write-Host $JsonPsObj  
        Write-Host "------- added -------------"
        $JsonString = Remove-JsonString_NodeProperty -JsonString $JsonString -NodeProperty "NewProperty"
        $JsonString = Check-JsonString_Valid         -JsonString $JsonString
        Write-Host "------- removed -------------"
        # RE-Add modified object
         $ArrJsonStrings += $JsonString 
        }
    Write-Host "$FctName Add and Remove of 'NewProperty' done"
    Write-Host "------- summary after add and remove -------------"
    $ArrJsonStrings
    Write-Host "--------------------"
    }
   
    $NodeName ='Network'
    $AdapterNodeName ='NetAdapter'
    $Adapter1_Model ="Realtek";            $Adapter1_Speed = "100 Mbit"
    $Adapter2_Model ="Intel";              $Adapter2_Speed =  "50 Mbit"

    $NodeName ='Network'
    $ConnectorsNodeName ='NetConnectors-Supported'
    $ConnectorType1 ="RJ45";            $ConnectorType2 = "BNC" ;     $ConnectorType3 ="Token-Ring"

if ( 1 -eq 1) # add a new SubNode 'SubNodeName' with different and properties and values
    {
    # #####################################################
    # add a new SubNode 'SubNodeName' with different and properties and values
    # #####################################################
    $NodeName ='Network'
    $AdapterNodeName ='NetAdapter'
    $Adapter1_Model ="Realtek";            $Adapter1_Speed = "100 Mbit"
    $Adapter2_Model ="Intel";              $Adapter2_Speed =  "50 Mbit"
    $JsonString_NetAdapters = New-JSON_JsonString_SubNode_With_Two_Properties -NodeName $AdapterNodeName -NodeProperty1Name $Adapter1_Model -NodeProperty1Value $Adapter1_Speed -NodeProperty2Name $Adapter2_Model -NodeProperty2Value $Adapter2_Speed
    # $JsonString_NetAdapters     
        <#
            {
                "NetAdapter":  {
                                   "Realtek":  "100 Mbit",
                                   "Intel":  "50 Mbit"
                               }
            }        
        #> 

    ForEach ( $JsonString in $ArrJsonStrings )
        {
        # Remove current object
        $ArrJsonStrings = $ArrJsonStrings -ne $JsonString


        $JsonPsObj = ConvertFrom-Json($JsonString)
        $JsonPsObj | Add-Member -Name $NodeName -value (Convertfrom-Json $JsonString_NetAdapters )  -MemberType NoteProperty
        # Write-Host $JsonPsObj
        # @{Realtek=; Intel=}
        
        $JsonString      = ($JsonPsObj | ConvertTo-JSON)
        Write-Host $JsonString
        <#
            {
            "Model":  "U3419W",
            "Index":  "1",
            "TargetFeature":  "FWVERSION",
            "Value":  "M3B114",
            "Network":  {
                            "NetAdapter":  {
                                               "Realtek":  "100 Mbit",
                                               "Intel":  "50 Mbit"
                                           }
                        }
            }
        #>
        Write-Host "------- added node '$NodeName' - subnode '$AdapterNodeName' -------------"

        $NodeName ='Network'
        $ConnectorsNodeName ='NetConnectors-Supported'
        $ConnectorType1 ="RJ45";            $ConnectorType2 = "BNC" ;     $ConnectorType3 ="Token-Ring"
    

        $JsonPsObj = ConvertFrom-Json($JsonString)
        # ERROR will occur - if the SubNode 'Network' already exists
        #       CHeck 'Network' exists
        if ( $JsonPsObj.$NodeName )
            {
            # --------------------------
            $ArrayConnectors       = "[`n" + """$ConnectorType1"",`n"  + """$ConnectorType2"",`n" + """$ConnectorType3""`n"   + "]`n"
            $ArrayConnectors = Check-JsonString_Valid -JsonString $ArrayConnectors # -Debug
            # $ArrayConnectors 
            <#
                 [
                "RJ45",
                "BNC",
                "Token-Ring"
                ]
            #>
            $JsonPsObj.$NodeName  | Add-Member -Name $ConnectorsNodeName -value (Convertfrom-Json $ArrayConnectors )  -MemberType NoteProperty
            }
        else
            {
            # --------------------------
            $JsonString_ConnectorsNode  = New-JSON_JsonString_SubNode_With_Array_Of_Values -ArrayNodeName $ConnectorsNodeName -NodeValue1 $ConnectorType1 -NodeValue2 $ConnectorType1 -NodeValue3 $ConnectorType3 
            <#
                {
                    "NetConnectors-Supported":  [
                                                    "RJ45",
                                                    "BNC",
                                                    "Token-Ring"
                                                ]
                }    
            #>
            $JsonPsObj | Add-Member -Name $NodeName -value (Convertfrom-Json $JsonString_Connector )  -MemberType NoteProperty
            }
        # Write-Host $JsonPsObj
        # 
        $JsonString      = ($JsonPsObj | ConvertTo-JSON)
        $JsonString 
        <#
            {
            ....
            "TargetFeature":  "FWVERSION",
            "Value":  "M3B114",
            "Network":  {
                                "NetAdapter":  {
                                                   "Realtek":  "100 Mbit",
                                                   "Intel":  "50 Mbit"
                                               },
                                "NetConnectors-Supported":  {
                                                                "value":  [
                                                                              "RJ45",
                                                                              "BNC",
                                                                              "Token-Ring"
                                                                          ],
                                                                "Count":  3
                                                            }
                        }
            }
        #>
        Write-Host "------- added node '$NodeName' - subnode '$ConnectorsNodeName' -------------"
    
        # RE-Add modified object
         $ArrJsonStrings += $JsonString 
        }
    Write-Host "$FctName 'Add-SubNode-Network-NetConnectors' done"
    Write-Host "------- summary after add subnode -------------"
    $ArrJsonStrings
    Write-Host "--------------------"
    }


if ( 1 -eq 1 ) # query Sub-Sub-...Sub-Nodes and values
    {
     ForEach ( $JsonString in $ArrJsonStrings )
        {
        Write-Host 
        ######################################################
        # Diplay the result in different layouts 
        ######################################################

        $JsonPsObj = ConvertFrom-Json($JsonString)
        $JsonPsObj
        <#
            Model         : U3419W
            Index         : 1
            TargetFeature : FWVERSION
            Value         : M3B114
            Network       : @{NetAdapter=; NetConnectors-Supported=}
        #>
    
        Write-Host $JsonPsObj 
        # @{Model=U3419W; Index=1; TargetFeature=FWVERSION; Value=M3B114; Network=}

        
        if ( $JsonPsObj.$NodeName -eq $Null )
            {
            Write-Host "$FctName subnode '$NodeName' does not exists"
            }
        else
            {
            # ----------------------------------
            # $NodeName ='Network'                               # value is already set above
            $JsonPsObj.$NodeName
            <#
                NetAdapter              : @{Realtek=100 Mbit; Intel=50 Mbit}
                NetConnectors-Supported : @{value=System.Object[]; Count=3}
            #>


            Write-Host $JsonPsObj.$NodeName
            # @{NetAdapter=; NetConnectors-Supported=}

            # ----------------------------------
            # $ConnectorsNodeName = "NetConnectors-Supported"    # value is already set above
            if ( $JsonPsObj.$NodeName.$ConnectorsNodeName -eq $Null )
                {
                Write-Host "$FctName subnode '.$NodeName.$ConnectorsNodeName' does not exists"
                }
            else
                {

                $JsonPsObj.$NodeName.$ConnectorsNodeName
                <#
                    value : {RJ45, BNC, Token-Ring}
                    Count : 3
                #>
                Write-Host $JsonPsObj.$NodeName.$ConnectorsNodeName
                # @{value=System.Object[]; Count=3}


                # ----------------------------------
                # $AdapterNodeName ='NetAdapter'                      # value is already set above
                $JsonPsObj.$NodeName.$AdapterNodeName
                <#
                    Realtek : 100 Mbit
                    Intel   : 50 Mbit
                #>

                $JsonPsObj.$NodeName.$AdapterNodeName  | Select * | FT
                    <#
                        Realtek  Intel  
                        -------  -----  
                        100 Mbit 50 Mbit
                    #>
                Write-Host $JsonPsObj.$NodeName.$AdapterNodeName
                # @{Realtek=100 Mbit; Intel=50 Mbit}


                $JsonPsObj.$NodeName.$AdapterNodeName.Realtek  | Select * | FT
                    <#
                        Length
                        ------
                             8
                    #>
    
                $JsonPsObj.$NodeName.$AdapterNodeName.Realtek  
                    <#
                        100 Mbit
                    #>
                Write-Host $JsonPsObj.$NodeName.$AdapterNodeName.Realtek
                # 100 Mbit
                Write-Host "------- query  '$NodeName' - subnode '$ConnectorsNodeName' done"
                }
            Write-Host "------- query  '$NodeName' done"
            } 
        
        
        }
    }


    $SubNodeName          = "IntegratedDock"
    $SubNodePropertyName  = "WiFi_Capable"
    $SubNodePropertyValue = "Yes"
if ( 1 -eq 2 ) # add a new SubNode 'SubNodeName' with 'SubNodePropertyName' and 'SubNodePropertyValue'
    {
    # #####################################################
    # add a new SubNode 'SubNodeName' with 'SubNodePropertyName' and 'SubNodePropertyValue'
    # #####################################################
    
    $SubNodeName          = "IntegratedDock"
    $SubNodePropertyName  = "WiFi_Capable"
    $SubNodePropertyValue = "Yes"
        <#
            {
                "IntegratedDock":  {
                        "WiFi_Capable":  "Yes",
                        "USBc_Connectors":  "2",
                        "USBa_Connectors":  "3"
                        }
            }
        #>
    
    ForEach ( $JsonString in $ArrJsonStrings )
        {
        # Remove current object
        $ArrJsonStrings = $ArrJsonStrings -ne $JsonString
        
        $JsonString = Add-JsonString_SubNode_with_One_SubNodeProperty -JsonString $JsonString -SubNodeName $SubNodeName -SubNodePropertyName $SubNodePropertyName  -SubNodePropertyValue $SubNodePropertyValue 
        
        
        # RE-Add modified object
         $ArrJsonStrings += $JsonString 
        }
    Write-Host "$FctName 'Add-SubNode-IntegratedDock' done"
    Write-Host "------- summary after add subnode -------------"
    $ArrJsonStrings
    Write-Host "--------------------"
    }

if ( 1 -eq 2 ) # JsonString - Get value from SubNode-NodeProperty
    {
    # #####################################################
    # #####################################################
    # JsonString - Get value from SubNode-NodeProperty
    $SubNodeName          = "IntegratedDock"
    $SubNodePropertyName  = "WiFi_Capable"     # 'USBc'
    ForEach ( $JsonString in $ArrJsonStrings )
        {
        $JsonPsObj = ConvertFrom-Json($JsonString)
        # Write-Host $JsonPsObj.$SubNodeName
        #     @{WiFi_Capable=Yes; USBc_Connectors=2; USBa_Connectors=3}
        # Write-Host $JsonPsObj.$SubNodeName.$SubNodePropertyName
        #     2
        $Result1 = $JsonPsObj.$SubNodeName.$SubNodePropertyName
        Write-Host "$FctName JsonString - Get value from SubNode: '$SubNodeName':  NodeItem '$SubNodePropertyName'   =>   Result  = '$Result1'"
        }

    Write-Host "$FctName 'JsonString - Get value from SubNode' done"
    
    }
    # end of Main
    }   

Function Check-JsonString_Valid   # maybe any manipulation has an invalid syntax in JSON string
    {
    Param (  [String]$JsonString,[Switch]$Debug)
    $FctName = "Check-JsonString_Valid() -"
    
   # if ( $Debug ) { Write-Host "$FctName $JsonStringNew" }
    try
        {
        $JsonPsObj      = $JsonString | ConvertFrom-JSON -ErrorAction SilentlyContinue 
        $JsonStringNew  = $JsonPsObj  | ConvertTo-JSON

        if ( $Debug ) { Write-Host $JsonStringNew }
            <#
                {
                "Model":  "U3419W",
                "Index":  "1",
                "TargetFeature":  "FWVERSION",
                "Value":  "M3B114",
                }
            #>
        Return $JsonStringNew 
        }
    catch 
        {
        Write-Warning "$FctName Invalid JSON systnax - EXIT    - INPUT '`$JsonString' "
        Write-Host $JsonString -ForegroundColor Red
        Write-Warning "$FctName Invalid JSON systnax - EXIT"
        Return $Bull
        }
    }

Function New-JSON_JsonString_SubNode_With_Array_Of_Values
    {
    Param([String]$ArrayNodeName,
        [String]$NodeValue1,[String]$NodeValue2,[String]$NodeValue3)

    <#
        Example:   
        
        $ConnectorsNodeName ='NetConnectors-Supported'
        $ConnectorType1 ="RJ45";            $ConnectorType2 = "BNC" ;     $ConnectorType1 ="Token-Ring"
        
        $s1 = New-JSON_JsonString_SubNode_With_Array_Of_Values -ArrayNodeName $ConnectorsNodeName -NodeValue1 $ConnectorType1 -NodeValue2 $ConnectorType1 -NodeValue3 $ConnectorType1 
        $s1     
             
        <#
            {
                "NetConnectors-Supported":  [
                                                "RJ45",
                                                "BNC",
                                                "Token-Ring"
                                            ]
            }
                    
        #> 
    #>
    $ArrayNodeString = "{`n""$ArrayNodeName"": [`n" + """$NodeValue1"",`n"  + """$NodeValue2"",`n" + """$NodeValue3""`n"   + "]`n"   + "}`n"
    # $ArrayNodeString
    if (get-command -Name "Check-JsonString_Valid")
        {
        $ArrayNodeString = Check-JsonString_Valid -JsonString $ArrayNodeString # -Debug
        }
    return $ArrayNodeString
    }

Function New-JSON_JsonString_SubNode_With_Two_Properties 
    {
    Param([String]$NodeName,
        [String]$NodeProperty1Name,[String]$NodeProperty1Value,
        [String]$NodeProperty2Name,[String]$NodeProperty2Value)


    <#
        Example:   
        
        $AdapterNodeName ='NetAdapter'
        $Adapter1_Model ="Realtek";            $Adapter1_Speed = "100 Mbit"
        $Adapter2_Model ="Intel";              $Adapter2_Speed =  "50 Mbit"
        
        $s1 = New-JSON_JsonString_SubNode_With_Two_Properties -NodeName $AdapterNodeName `
                                        -NodeProperty1Name $Adapter1_Model -NodeProperty1Value $Adapter1_Speed `
                                        -NodeProperty2Name $Adapter2_Model -NodeProperty2Value $Adapter2_Speed
        $s1     
             
        <#
            {
                "NetAdapter":  {
                                   "Realtek":  "100 Mbit",
                                   "Intel":  "50 Mbit"
                               }
            }        
        #> 
    #>

    $PropertyString = "{`n""$NodeProperty1Name"":  ""$NodeProperty1Value"","   +   "`n""$NodeProperty2Name"":  ""$NodeProperty2Value""" + "`n}"
    $NodeNameString = "{`n""$NodeName"":  " +  $PropertyString  + "`n}"
    # $NodeNameString
        
    if (get-command -Name "Check-JsonString_Valid")
        {
        $NodeNameString = Check-JsonString_Valid -JsonString $NodeNameString -Debug
        }

    return $NodeNameString
    }

Function Add-JsonString_SubNode_with_One_SubNodeProperty
    {
    # add a new SubNode 'SubNodeName' with 'SubNodePropertyName' and 'SubNodePropertyValue'
    # $SubNodeName          = "IntegratedDock"
    # $SubNodePropertyName  = "WiFi_Capable"
    # $SubNodePropertyValue = "Yes"

    # 1.   create a JSON string for SubNode
    # 2.   add SubNodeJsonString to JsonString via $JsonPsObj


    Param (  [String]$JsonString,[String]$SubNodeName,[String]$SubNodePropertyName,[String]$SubNodePropertyValue )
    $FctName = "Add-JsonString_SubNode_with_One_SubNodeProperty() -"
    

    # create a JSON string for SubNode
    $SubNodeJsonString = @"
            {
            "$SubNodePropertyName":  "$SubNodePropertyValue",
            "USBc_Connectors":  "2",
            "USBa_Connectors":  "3"
            }
"@
    Write-Host "$FctName new SubNodeJsonString for '$SubNodeName' - checking scripting syntax"
    $SubNodeJsonString = Check-JsonString_Valid -JsonString $SubNodeJsonString # -Debug 
    if ( $SubNodeJsonString -eq "" -or $SubNodeJsonString -eq $Null ) { 
        Write-Warning "$FctName new SubNode '$SubNodeName' - check failed"

        return -1 
        }
    Write-Host "$FctName new SubNode '$SubNodeName' - check succeeded"

    # add SubNodeJsonString to JsonString via $JsonPsObj
    $JsonPsObj = ConvertFrom-Json($JsonString)
    $JsonPsObj | Add-Member -Name $SubNodeName -value (Convertfrom-Json $SubNodeJsonString)  -MemberType NoteProperty
    # Write-Host $JsonPsObj
    #      @{Model=U3419W; Index=1; MarketingName=; TargetFeature=FWVERSION; Value=M3B114; IntegratedDock=}
    $JsonStringNew      = ($JsonPsObj | ConvertTo-JSON)
    # Write-Host  $JsonStringNew # -ForegroundColor green
        <#
            {
            "Model":  "U3419W",
            "Index":  "1",
            "MarketingName":  "",
            "TargetFeature":  "FWVERSION",
            "Value":  "M3B114",
            "IntegratedDock":  {
                                   "WiFi_Capable":  "Yes",
                                   "USBc_Connectors":  "2",
                                   "USBa_Connectors":  "3"
                               }
            }
        #>
  
    if ( $JsonString -ne $JsonStringNew )
        {
        Write-Host "$FctName JsonPsObj  - add a new SubNode '$SubNodeName' with '$SubNodePropertyName' and '$SubNodePropertyValue'"
        # Write-Host $JsonPsObj 
            # @{Model=U3419W; Index=1; MarketingName=; TargetFeature=FWVERSION; Value=M3B114; IntegratedDock=}
        
        Write-Host $JsonStringNew
         <#
            {
                "Model":  "U3419W",
                "Index":  "1",
                "MarketingName":  "",
                "TargetFeature":  "FWVERSION",
                "Value":  "M3B114",
                "IntegratedDock":  {
                                       "WiFi_Capable":  "Yes",
                                       "USBc_Connectors":  "2",
                                       "USBa_Connectors":  "3"
                                   }
            }
        #>
        Return $JsonStringNew
        }
    else
        {
        Write-Warning "`r`n$FctName ADD failed -  NodeProperty '$NodePropertyName' - value '$NodePropertyValue'"
        Return $JsonString
        }
    }


Function Remove-JsonString_NodeProperty
    {
    Param (  [String]$JsonString,[String]$NodePropertyName )
    $FctName = "Remove-JsonString_NodeProperty() -"
    
    $JsonPsObj          = ($JsonString | ConvertFrom-JSON)
    $JsonPsObj.PSObject.Properties.Remove($NodePropertyName)
    $JsonStringNew      = ($JsonPsObj |  ConvertTo-JSON)
    
    if ( $JsonString -ne $JsonStringNew )
        {
        Write-Host "`r`n$FctName removing NodeProperty '$NodePropertyName'"
        # Write-Host $JsonPsObj 
            # @{Model=U3419W; Index=1; TargetFeature=FWVERSION; Value=M3B114}
        
        Write-Host $JsonStringNew
            <#
                {
                "Model":  "U3419W",
                "Index":  "1",
                "TargetFeature":  "FWVERSION",
                "Value":  "M3B114",
                }
            #>
        Return $JsonStringNew
        }
    else
        {
        Return $JsonString
        }
    }

Function Add-JsonString_NodeProperty
    {
    # add a new NodeProperty "NewProperty" with value "Value-NewProperty"

    Param (  [String]$JsonString,[String]$NodePropertyName,[String]$NodePropertyValue )
    $FctName = "Add-JsonString_NodeProperty() -"
    
    $JsonPsObj          = ($JsonString | ConvertFrom-JSON)
    Write-Host "$FctName JsonPsObj  - Add NodeProperty with Value: '$NodePropertyName' = '$NodePropertyValue'"
    $JsonPsObj | Add-Member -Name $NodePropertyName  -value $NodePropertyValue -MemberType NoteProperty
    # Write-Host $JsonPsObj 
    # @{Model=U3419W; Index=1; TargetFeature=FWVERSION; Value=M3B114; NewProperty=Value-New-Property}

    $JsonStringNew  = ($JsonPsObj | ConvertTo-JSON)    
    # Write-Host  $JsonStringNew
    <#
        {
            "Model":  "U3419W",
            "Index":  "1",
            "TargetFeature":  "FWVERSION",
            "Value":  "M3B114",
            "NewProperty":  "Value-New-Property"
        }
    #>
    
    if ( $JsonString -ne $JsonStringNew )
        {
        Write-Host "`r`n$FctName added NodeProperty '$NodePropertyName' with value '$NodePropertyValue'"
        # Write-Host $JsonPsObj 
            # @{Model=U3419W; Index=1; TargetFeature=FWVERSION; Value=M3B114}
        
        Write-Host $JsonStringNew
            <#
                {
                "Model":  "U3419W",
                "Index":  "1",
                "TargetFeature":  "FWVERSION",
                "Value":  "M3B114",
                }
            #>
        Return $JsonStringNew
        }
    else
        {
        Write-Warning "`r`n$FctName ADD failed -  NodeProperty '$NodePropertyName' - value '$NodePropertyValue'"
        Return $JsonString
        }
    }

Main