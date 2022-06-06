
double getLot(double price_open, double price_close,ENUM_ORDER_TYPE action){

   double lot = 0;
   
   //calculate profit with 1 lot
   double profit ; 
      OrderCalcProfit( 
         action,           // type of the order (ORDER_TYPE_BUY or ORDER_TYPE_SELL) 
         Symbol(),           // symbol name 
         1,           // volume 
         price_open,       // open price 
         price_close,      // close price 
         profit            // variable for obtaining the profit value 
      );
   profit = MathAbs(profit);
   switch(capital_mode){
      case Fix_Lot:
         lot = Captial_Management_Value;
         break;
      case Fix_Risk_Amount:
         lot = Captial_Management_Value/profit;
         break;
      case Fix_Percentage_Risk:
         
         lot = AccountInfoDouble(ACCOUNT_BALANCE)*Captial_Management_Value/100;
         lot = lot /profit;

         break;
         
   }
   //get lot information for specific symbol
   double minlot = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double lotstep = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   //double maxlot = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   //adjust limit lot   
   //if(lot>maxlot) lot = maxlot;
   if(lot<minlot) lot = minlot;
   //adjust for lot step
   lot  = MathRound(lot / lotstep)*lotstep;
   
   return (lot);
}

