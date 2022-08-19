trigger Teilobjekte on Appartment__c(before insert, before update)
{
    if(checkRecursive.runOnce()) {
    if (trigger.isBefore)
    {

        // Write all Property__c Ids into a Set to query them all at once
    Set < Id > propertyIds = new Set < Id > ();
    List<Id> appIds = new List<Id>();
    for (Appartment__c app: Trigger.new)
    {
        propertyIds.add(app.Property__c);
        appIds.add(app.Id);
        Boolean renditeHasChanged = true;
        if(Trigger.isUpdate) {
            Appartment__c oldapp = Trigger.oldMap.get(app.Id);
            if(app.Rental_return__c == oldApp.Rental_return__c) {
            renditeHasChanged = false;
            }
        }
    
        if(renditeHasChanged) {
            app.Rental_return_old__c = app.Rental_return__c;
        }

        Boolean wertEinrichtungHasChanged = true;
        if(Trigger.isUpdate) {
            Appartment__c oldapp = Trigger.oldMap.get(app.Id);
            if(app.Value_Unit__c == oldapp.Value_Unit__c && app.Wert_Einrichtung_in_Euro__c == oldapp.Wert_Einrichtung_in_Euro__c ) {
                wertEinrichtungHasChanged = false;
            }
        }
        if((Trigger.IsInsert && app.Wert_Einrichtung_in_Euro__c  != 0 && app.Wert_Einrichtung_in_Euro__c  != null) || wertEinrichtungHasChanged) {
            if(app.Wert_Einrichtung_in_Euro__c != 0 && app.Wert_Einrichtung_in_Euro__c != null) {
                Decimal netAssetValue = 93;
                Decimal valueOfOutdoor = 4;
                Decimal valueOfLand = 3;
                Decimal valueOfEinrichtung = 0.0;
                Decimal purchasePrice = app.Purchase_Price__c;
                Decimal einrichtungPrice = app.Wert_Einrichtung_in_Euro__c;
                
                netAssetValue *= (purchasePrice-einrichtungPrice)/purchasePrice;
                valueOfOutdoor *= (purchasePrice-einrichtungPrice)/purchasePrice;
                valueOfLand *= (purchasePrice-einrichtungPrice)/purchasePrice;
                valueOfEinrichtung = einrichtungPrice/purchasePrice*100;
                
                app.Net_asset_value__c = netAssetValue;
                app.Value_of_OIutdoor__c = valueOfOutdoor;
                app.Land_Value__c = valueOfLand;
                app.Value_Unit__c = valueOfEinrichtung;
            }
            if(wertEinrichtungHasChanged && (app.Value_Unit__c == 0 || app.Wert_Einrichtung_in_Euro__c == 0)) {
                app.Net_asset_value__c = 93;
                app.Value_of_OIutdoor__c = 4;
                app.Land_Value__c = 3;
                app.Wert_Einrichtung_in_Euro__c = 0;
                app.Value_Unit__c = 0;
            }
        } 
    }
    //List<Opportunity> opps = new List<Opportunity>([SELECT Id FROM Opportunity WHERE StageName = 'Reservierung angefragt' AND Appartement__c IN :appIds]);
    Map < Id, Property__c > properties = new Map < Id, Property__c > ([SELECT AFA_Art__c,
        Administrator_Cost_Increase_After_Years__c,
        Purchase_Price_sqm__c,
        Additional_Costs__c,
        Percent_Increase_In_Administrator_Cost__c,
        Manager_Cost_p_a__c,
        Financing_Costs__c,
        Appreciation_After_Years__c,
        Percent_Appreciation_Value__c,
        Afa_Plot__c,
        Value_Plot__c,
        maintenance_sqm_p_a__c,
        Rent_Long_Term_sqm__c,
        Building_Share_Value__c,
        Afa_Building_Shares__c,
        Afa_Outdoor__c,
        Real_Estate_Transfer_Tax__c,
        Rent_Increase_After_Years__c,
        Percent_Increase_In_Rent__c,
        Arrival__c,
        Repayment_Beginning__c,
        Value_Of_Outdoor__c,
        Value_Preservation__c,
        Processing_Fee__c,
        Maintenance_Cost_Increase_After_Years__c,
        Afa_Facility__c,
        Erbbauzins_Restlaufzeit__c,
        Erbbauzins__c,
        Bauart__c
        FROM Property__c WHERE ID in : propertyIds
    ]);
    //Map für den Hebesatz für den Erbbauzins. Nach den Vervielfältiger in Anhang 9a zum Bewertungsgesetz.
    Map < Decimal, Double > erbbauHebeSatz = new Map < Decimal, Double > ();
    erbbauHebeSatz.put(0, 0);
    erbbauHebeSatz.put(1, 0.974);
    erbbauHebeSatz.put(2, 1.897);
    erbbauHebeSatz.put(3, 2.772);
    erbbauHebeSatz.put(4, 3.602);
    erbbauHebeSatz.put(5, 4.388);
    erbbauHebeSatz.put(6, 5.133);
    erbbauHebeSatz.put(7, 5.839);
    erbbauHebeSatz.put(8, 6.509);
    erbbauHebeSatz.put(9, 7.143);
    erbbauHebeSatz.put(10, 7.745);
    erbbauHebeSatz.put(11, 8.315);
    erbbauHebeSatz.put(12, 8.856);
    erbbauHebeSatz.put(13, 9.368);
    erbbauHebeSatz.put(14, 9.853);
    erbbauHebeSatz.put(15, 10.314);
    erbbauHebeSatz.put(16, 10.750);
    erbbauHebeSatz.put(17, 11.163);
    erbbauHebeSatz.put(18, 11.555);
    erbbauHebeSatz.put(19, 11.927);
    erbbauHebeSatz.put(20, 12.279);
    erbbauHebeSatz.put(21, 12.613);
    erbbauHebeSatz.put(22, 12.929);
    erbbauHebeSatz.put(23, 13.229);
    erbbauHebeSatz.put(24, 13.513);
    erbbauHebeSatz.put(25, 13.783);
    erbbauHebeSatz.put(26, 14.038);
    erbbauHebeSatz.put(27, 14.280);
    erbbauHebeSatz.put(28, 14.510);
    erbbauHebeSatz.put(29, 14.727);
    erbbauHebeSatz.put(30, 14.933);
    erbbauHebeSatz.put(31, 15.129);
    erbbauHebeSatz.put(32, 15.314);
    erbbauHebeSatz.put(33, 15.490);
    erbbauHebeSatz.put(34, 15.656);
    erbbauHebeSatz.put(35, 15.814);
    erbbauHebeSatz.put(36, 15.963);
    erbbauHebeSatz.put(37, 16.105);
    erbbauHebeSatz.put(38, 16.239);
    erbbauHebeSatz.put(39, 16.367);
    erbbauHebeSatz.put(40, 16.487);
    erbbauHebeSatz.put(41, 16.602);
    erbbauHebeSatz.put(42, 16.710);
    erbbauHebeSatz.put(43, 16.813);
    erbbauHebeSatz.put(44, 16.910);
    erbbauHebeSatz.put(45, 17.003);
    erbbauHebeSatz.put(46, 17.090);
    erbbauHebeSatz.put(47, 17.173);
    erbbauHebeSatz.put(48, 17.252);
    erbbauHebeSatz.put(49, 17.326);
    erbbauHebeSatz.put(50, 17.397);
    erbbauHebeSatz.put(51, 17.464);
    erbbauHebeSatz.put(52, 17.528);
    erbbauHebeSatz.put(53, 17.588);
    erbbauHebeSatz.put(54, 17.645);
    erbbauHebeSatz.put(55, 17.699);
    erbbauHebeSatz.put(56, 17.750);
    erbbauHebeSatz.put(57, 17.799);
    erbbauHebeSatz.put(58, 17.845);
    erbbauHebeSatz.put(59, 17.888);
    erbbauHebeSatz.put(60, 17.930);
    erbbauHebeSatz.put(61, 17.969);
    erbbauHebeSatz.put(62, 18.006);
    erbbauHebeSatz.put(63, 18.041);
    erbbauHebeSatz.put(64, 18.075);
    erbbauHebeSatz.put(65, 18.106);
    erbbauHebeSatz.put(66, 18.136);
    erbbauHebeSatz.put(67, 18.165);
    erbbauHebeSatz.put(68, 18.192);
    erbbauHebeSatz.put(69, 18.217);
    erbbauHebeSatz.put(70, 18.242);
    erbbauHebeSatz.put(71, 18.264);
    erbbauHebeSatz.put(72, 18.286);
    erbbauHebeSatz.put(73, 18.307);
    erbbauHebeSatz.put(74, 18.326);
    erbbauHebeSatz.put(75, 18.345);
    erbbauHebeSatz.put(76, 18.362);
    erbbauHebeSatz.put(77, 18.379);
    erbbauHebeSatz.put(78, 18.395);
    erbbauHebeSatz.put(79, 18.410);
    erbbauHebeSatz.put(80, 18.424);
    erbbauHebeSatz.put(81, 18.437);
    erbbauHebeSatz.put(82, 18.450);
    erbbauHebeSatz.put(83, 18.462);
    erbbauHebeSatz.put(84, 18.474);
    erbbauHebeSatz.put(85, 18.485);
    erbbauHebeSatz.put(86, 18.495);
    erbbauHebeSatz.put(87, 18.505);
    erbbauHebeSatz.put(88, 18.514);
    erbbauHebeSatz.put(89, 18.523);
    erbbauHebeSatz.put(90, 18.531);
    erbbauHebeSatz.put(91, 18.539);
    erbbauHebeSatz.put(92, 18.546);
    erbbauHebeSatz.put(93, 18.553);
    erbbauHebeSatz.put(94, 18.560);
    erbbauHebeSatz.put(95, 18.566);
    erbbauHebeSatz.put(96, 18.572);
    erbbauHebeSatz.put(97, 18.578);
    erbbauHebeSatz.put(98, 18.583);
    erbbauHebeSatz.put(99, 18.589);
    erbbauHebeSatz.put(100, 18.593);
    erbbauHebeSatz.put(101, 18.598);
    erbbauHebeSatz.put(102, 18.600);

        if (trigger.isInsert)
        {
            for (Appartment__c app: trigger.new)
            {
                if (app.Area_sq_m__c == NULL || app.Property__c == NULL || app.Area_sq_m__c == 0)
                {
                    app.addError('Bitte Appartmentgröße und zugehörige Immobilie angeben');
                }
                else
                {
                    try
                    {



                        if (app.Purchase_Price_sq_m__c == 0)
                        {
                            app.Purchase_Price_sq_m__c = properties.get(app.Property__c).Purchase_Price_sqm__c;
                        }





                        if (app.Purchase_Price__c == 0)
                        {
                            app.Purchase_Price__c = app.Area_sq_m__c * app.Purchase_Price_sq_m__c;
                        }

                        if (app.Opt_Zusatzkosten_auf_Kaufpreis_addieren__c)
                        {
                            if (app.wert_k_che__c != null)
                            {
                                app.Purchase_Price__c += app.wert_k_che__c;
                            }

                            if (app.Value_Parking_Space__c != 0)
                            {
                                app.Purchase_Price__c += app.Value_Parking_Space__c;
                            }
                        }

                        if (app.wert_k_che__c != 0)
                        {
                            app.Value_Unit__c = app.wert_k_che__c / app.Purchase_Price__c;
                        }
                        //if(app.Value_Parking_Space__c != 0){app.Purchase_Price__c += app.Value_Parking_Space__c;}

                        if (app.Afa_Art__c == 0)
                        {
                            app.Afa_Art__c = properties.get(app.Property__c).AFA_Art__c;
                        }
                        if (app.AFA_Total__c == 0)
                        {
                            app.AFA_Total__c = app.Purchase_Price__c;
                        }
                        if (app.Depreciation_Value__c == 0)
                        {
                            app.Depreciation_Value__c = app.Purchase_Price__c;
                        }
                        if (app.Admin_Costs_Increase_After_Years__c == 0)
                        {
                            app.Admin_Costs_Increase_After_Years__c = properties.get(app.Property__c).Administrator_Cost_Increase_After_Years__c;
                        }

                        if (app.Admin_Costs_Increase_In__c == 0)
                        {
                            app.Admin_Costs_Increase_In__c = properties.get(app.Property__c).Percent_Increase_In_Administrator_Cost__c;
                        }
                        if (app.Cost_Admin__c == 0)
                        {
                            app.Cost_Admin__c = properties.get(app.Property__c).Manager_Cost_p_a__c;
                        }
                        if (app.Financing_Costs__c == 0)
                        {
                            app.Financing_Costs__c = properties.get(app.Property__c).Financing_Costs__c;
                        }
                        if (app.Increase_in_Value_For_Years__c == null)
                        {
                            app.Increase_in_Value_For_Years__c = properties.get(app.Property__c).Appreciation_After_Years__c;
                        }
                        if (app.Increase_In_Value_In__c == 0)
                        {
                            app.Increase_In_Value_In__c = properties.get(app.Property__c).Percent_Appreciation_Value__c;
                        }
                        if (app.Land_AFA__c == 0)
                        {
                            app.Land_AFA__c = properties.get(app.Property__c).Afa_Plot__c;
                        }
                        if (app.Land_Value__c == 0)
                        {
                            app.Land_Value__c = properties.get(app.Property__c).Value_Plot__c;
                        }
                        if (app.Maintenance_sqm__c == 0)
                        {
                            app.Maintenance_sqm__c = properties.get(app.Property__c).maintenance_sqm_p_a__c;
                        }
                        if (app.Monthly_rent_sq_m__c == null)
                        {
                            app.Monthly_rent_sq_m__c = properties.get(app.Property__c).Rent_Long_Term_sqm__c;
                        }
                        if (app.Monthly_Rent__c == 0)
                        {
                            app.Monthly_Rent__c = (app.Monthly_rent_sq_m__c * app.Area_sq_m__c);
                        }
                        if (app.Rent_Parking_Space__c != 0)
                        {
                            app.Monthly_Rent__c += app.Rent_Parking_Space__c;
                        }
                        if (app.Net_asset_value__c == 0)
                        {
                            app.Net_asset_value__c = properties.get(app.Property__c).Building_Share_Value__c;
                        }
                        if (app.Net_Asset_Value_AFA__c == 0)
                        {
                            app.Net_Asset_Value_AFA__c = properties.get(app.Property__c).Afa_Building_Shares__c;
                        }
                        if (app.Outdoor_AFA__c == 0)
                        {
                            app.Outdoor_AFA__c = properties.get(app.Property__c).Afa_Outdoor__c;
                        }
                        if (app.Erbbauzins__c == 0)
                        {
                            app.Erbbauzins__c = properties.get(app.Property__c).Erbbauzins__c * app.Area_sq_m__c;
                        }


                        if (app.Erbbauzins__c != 0 && properties.get(app.Property__c).Erbbauzins_Restlaufzeit__c > 0)
                        {
                            Decimal restlaufzeit = 0;
                            if (properties.get(app.Property__c).Erbbauzins_Restlaufzeit__c > 102)
                            {
                                restlaufzeit = 102;
                            }
                            else
                            {
                                restlaufzeit = properties.get(app.Property__c).Erbbauzins_Restlaufzeit__c;
                            }
                            Double erbbauZinsAufschlag = app.Erbbauzins__c * erbbauHebeSatz.get(restlaufzeit) * properties.get(app.Property__c).Real_Estate_Transfer_Tax__c / 100;
                            app.Real_Estate_Transfer_Tax__c = (properties.get(app.Property__c).Real_Estate_Transfer_Tax__c / 100 * (app.Purchase_Price__c + app.Value_Parking_Space__c)) + erbbauZinsAufschlag;
                        }
                        else
                        {
                            app.Real_Estate_Transfer_Tax__c = properties.get(app.Property__c).Real_Estate_Transfer_Tax__c / 100 * (app.Purchase_Price__c + app.Value_Parking_Space__c);
                        }


                        if (app.Rent_Increase_After_Years__c == 0)
                        {
                            app.Rent_Increase_After_Years__c = properties.get(app.Property__c).Rent_Increase_After_Years__c;
                        }
                        if (app.Rent_Increase_In__c == 0)
                        {
                            app.Rent_Increase_In__c = properties.get(app.Property__c).Percent_Increase_In_Rent__c;
                        }
                        if (app.Rental_Start__c == null)
                        {
                            app.Rental_Start__c = properties.get(app.Property__c).Arrival__c;
                        }
                        if (app.Repayment_Beginning__c == null)
                        {
                            app.Repayment_Beginning__c = properties.get(app.Property__c).Repayment_Beginning__c;
                        }
                        if (app.Value_of_OIutdoor__c == 0)
                        {
                            app.Value_of_OIutdoor__c = properties.get(app.Property__c).Value_Of_Outdoor__c;
                        }
                        if (app.Value_Preservation__c == 0)
                        {
                            app.Value_Preservation__c = properties.get(app.Property__c).Value_Preservation__c;
                        }
                        if (app.Processing_Fee__c == 0)
                        {
                            app.Processing_Fee__c = properties.get(app.Property__c).Processing_Fee__c;
                        }
                        if (app.Device_AFA__c == 0)
                        {
                            app.Device_AFA__c = properties.get(app.Property__c).Afa_Facility__c;
                        }


                    }
                    catch (Exception e)
                    {}
                }
            }
        }


        if (trigger.isUpdate)
        {
            Set < ID > propID = new Set < ID > ();

            for (Appartment__c app: trigger.new)
            {
                Appartment__c oldApp = Trigger.oldMap.get(app.ID);

                //Neuberechnung des Preises

                Property__c property = properties.get(app.Property__c);
                if(property != null) {
                    if(property.Bauart__c != 'Bestand' && app.MaBVBezahlt__c != oldApp.MaBVBezahlt__c) {
                        app.Bezahlt__c = app.MaBVBezahlt__c;
                    }
                }

                if (app.Property__c != null)
                {

                    

                    if (oldApp.Purchase_Price__c != app.Purchase_Price__c && app.Area_sq_m__c != 0)
                    {
                        app.Purchase_Price_sq_m__c = app.Purchase_Price__c / app.Area_sq_m__c;

                    }

                    app.Purchase_Price__c = app.Area_sq_m__c * app.Purchase_Price_sq_m__c;


                    if (app.Opt_Zusatzkosten_auf_Kaufpreis_addieren__c == true)
                    {
                        if (app.wert_k_che__c != null)
                        {
                            app.Purchase_Price__c += app.wert_k_che__c;
                        }

                        if (app.Value_Parking_Space__c != 0)
                        {
                            app.Purchase_Price__c += app.Value_Parking_Space__c;
                        }

                    }
                    if (app.Wert_K_che__c != oldApp.Wert_K_che__c)
                    {
                        if ((app.wert_k_che__c != null || app.wert_k_che__c != 0) && app.Purchase_Price__c != 0)
                        {
                            app.Value_Unit__c = app.wert_k_che__c / app.Purchase_Price__c * 100;
                        }
                    }

                    app.Depreciation_Value__c = app.Purchase_Price__c;

                    if (oldApp.Real_Estate_Transfer_Tax__c != app.Real_Estate_Transfer_Tax__c || oldApp.Purchase_Price__c != app.Purchase_Price__c || oldApp.Value_Parking_Space__c != app.Value_Parking_Space__c)
                    {



                        if (app.Erbbauzins__c != 0 && properties.get(app.Property__c).Erbbauzins_Restlaufzeit__c > 0)
                        {
                            Decimal restlaufzeit = 0;
                            if (properties.get(app.Property__c).Erbbauzins_Restlaufzeit__c > 102)
                            {
                                restlaufzeit = 102;
                            }
                            else
                            {
                                restlaufzeit = properties.get(app.Property__c).Erbbauzins_Restlaufzeit__c;
                            }
                            Double erbbauZinsAufschlag = app.Erbbauzins__c * erbbauHebeSatz.get(restlaufzeit) * properties.get(app.Property__c).Real_Estate_Transfer_Tax__c / 100;
                            app.Real_Estate_Transfer_Tax__c = (properties.get(app.Property__c).Real_Estate_Transfer_Tax__c / 100 * (app.Purchase_Price__c + app.Value_Parking_Space__c)) + erbbauZinsAufschlag;
                        }
                        else if(properties.get(app.Property__c) != null && properties.get(app.Property__c).Real_Estate_Transfer_Tax__c != null)
                        {
                            app.Real_Estate_Transfer_Tax__c = properties.get(app.Property__c).Real_Estate_Transfer_Tax__c / 100 * (app.Purchase_Price__c + app.Value_Parking_Space__c);
                        }

                    }
                    if (oldApp.Rent_Parking_Space__c != app.Rent_Parking_Space__c)
                    {
                        app.Monthly_Rent__c = (app.Monthly_rent_sq_m__c * app.Area_sq_m__c) + app.Rent_Parking_Space__c;
                    }


                    if (app.Erbbauzins__c == 0)
                    {
                        app.Erbbauzins__c = properties.get(app.Property__c).Erbbauzins__c * app.Area_sq_m__c;
                    }

                    if (oldApp.Monthly_rent_sq_m__c != app.Monthly_rent_sq_m__c)
                    {
                        app.Monthly_Rent__c = (app.Monthly_rent_sq_m__c * app.Area_sq_m__c) + app.Rent_Parking_Space__c;
                    }

                    // if(oldApp.Monthly_Rent__c != app.Monthly_Rent__c && app.Area_sq_m__c != 0){
                    //     app.Monthly_rent_sq_m__c = (app.Monthly_Rent__c - app.Rent_Parking_Space__c)/ app.Area_sq_m__c;
                    // }

                }
            }

        }
    }
}
}