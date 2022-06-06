// module to manage exit method after timeout

input string exitMethodAfterTimeoutparams = "====== EXIT METHOD AFTER TIMEOUT =====";
input string paramsForPositive = "----- Timout Positive Trade -----";
input bool Market_price_after_Timeout_Positive = false;
input double Breakeven_Touch_Ratio_After_Timeout_Positive = 0.8;
input double Breakeven_Leave_Ratio_After_Timeout_Positive = 0.5;
input int LOW2_after_timeout_value_Positive = 3;
input int Percentage_stop_order_after_timeout_positive = 60;
input string paramsForNegative = "----- Timout Negative Trade -----";
input bool Market_price_after_Timeout_Negative = false;
input double Breakeven_Touch_Ratio_After_Timeout_Negative = 0.8;
input double Breakeven_Leave_Ratio_After_Timeout_Negative = 0.5;

void exitAfterTimeOut(){

   //get last tick
   MqlTick last_tick; 
   SymbolInfoTick(Symbol(),last_tick);
   int total=PositionsTotal(); // number of open positions   
   //--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                    // ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL);                      // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);            // digits of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                               // volume of the position
      double sl=PositionGetDouble(POSITION_SL);                                       // Stop Loss of the position
      double tp=PositionGetDouble(POSITION_TP);                                       // Take Profit of the position
      double entry = PositionGetDouble(POSITION_PRICE_OPEN);                          // Entry price of position
      double comment = PositionGetString(POSITION_COMMENT);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position


      //--- check MagicNumber matches
      if(magic==MAGICNUMBER && position_symbol==Symbol())
        {
            
            //double bebuy = GlobalVariableGet(Symbol()+PERIOD_CURRENT+"lastworkbebuy");
            //double besell = GlobalVariableGet(Symbol()+PERIOD_CURRENT+"lastworkbesell");
            //check position is positive profit
            bool positiveProfit = type== POSITION_TYPE_BUY && last_tick.ask>entry ||
                     type== POSITION_TYPE_SELL && last_tick.bid<entry ;
                     
            
            // we check another condition if position is positive 
            if(positiveProfit){
            
               //if market price after timeout is true , we process only market order close
               if(Market_price_after_Timeout_Positive){ // close order by market price
                  m_trade.PositionClose(position_ticket);
               }
               if(Breakeven_Touch_Ratio_After_Timeout_Positive>0 && Breakeven_Leave_Ratio_After_Timeout_Positive>0){//set for Breakeven_Touch_Ratio_After_Timeout_Positive
                  
                  if (type== POSITION_TYPE_BUY){
                     if((last_tick.ask-entry)/(tp-entry)>Breakeven_Touch_Ratio_After_Timeout_Positive){
                        double newsl = entry + (last_tick.ask-entry)*Breakeven_Leave_Ratio_After_Timeout_Positive;
                        if(sl<newsl ){
                           Print("change sl.");
                           m_trade.PositionModify(position_ticket,newsl,tp);
                        }
                     }  
                  }
                  if(type== POSITION_TYPE_SELL){
                     if((entry-last_tick.bid)/(entry-tp)>Breakeven_Touch_Ratio_After_Timeout_Positive){
                        double newsl = entry - (entry-last_tick.bid)*Breakeven_Leave_Ratio_After_Timeout_Positive;
                        if(sl>newsl ){
                           Print("change sl.");
                           m_trade.PositionModify(position_ticket,newsl,tp);
                        }
                     }  
                  }                  

               }
               if(LOW2_after_timeout_value_Positive>0){//set for LOW2_after_timeout_value_Positive
                  if(type == POSITION_TYPE_BUY) {//check touched be target
                     if((last_tick.ask-entry)/(tp-entry)>Breakeven_Touch_Ratio_After_Timeout_Positive){
                        //get last n bars low
                        int llIndex = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,LOW2_after_timeout_value_Positive,1);
                        double low = iLow(Symbol(),PERIOD_CURRENT,llIndex);
                        if(sl<low){
                           m_trade.PositionModify(position_ticket,low,tp);
                        }
                     }
                  }
                  
                  if(type== POSITION_TYPE_SELL){//check touched be target
                     if((entry-last_tick.bid)/(entry-tp)>Breakeven_Touch_Ratio_After_Timeout_Positive){
                        //get last n bars high
                        int hhIndex = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,LOW2_after_timeout_value_Positive,1);
                        double high = iHigh(Symbol(),PERIOD_CURRENT,hhIndex);
                        if(sl>high){
                           m_trade.PositionModify(position_ticket,high,tp);
                        }
                     }
                  }                  
               }
               if(Percentage_stop_order_after_timeout_positive>0){//set for Percentage_stop_order_after_timeout_positive
                  if(type == POSITION_TYPE_BUY) {//check touched be target
                     double newsl = entry + (last_tick.ask-entry)*Percentage_stop_order_after_timeout_positive/100;
                     if(sl<newsl){
                        m_trade.PositionModify(position_ticket,newsl,tp);
                     }
                  }
                  
                  if(type== POSITION_TYPE_SELL){//check touched be target
                     double newsl = entry - (entry-last_tick.bid)*Percentage_stop_order_after_timeout_positive/100;
                     if(sl>newsl){
                        m_trade.PositionModify(position_ticket,newsl,tp);
                     }
                  }                  
               }
            }else{
               //if market price after timeout is true , we process only market order close
               if(Market_price_after_Timeout_Negative){ // close order by market price
                  m_trade.PositionClose(position_ticket);
               }
               if(Breakeven_Touch_Ratio_After_Timeout_Negative>0 && Breakeven_Leave_Ratio_After_Timeout_Negative>0){//set for Breakeven_Touch_Ratio_After_Timeout_Positive
                  
                  if (type== POSITION_TYPE_BUY){
                     if((last_tick.ask-entry)/(tp-entry)>Breakeven_Touch_Ratio_After_Timeout_Negative){
                        double newsl = entry + (last_tick.ask-entry)*Breakeven_Leave_Ratio_After_Timeout_Negative;
                        if(sl<newsl ){
                           Print("change sl.");
                           m_trade.PositionModify(position_ticket,newsl,tp);
                        }
                     }  
                  }
                  if(type== POSITION_TYPE_SELL){
                     if((entry-last_tick.bid)/(entry-tp)>Breakeven_Touch_Ratio_After_Timeout_Negative){
                        double newsl = entry - (entry-last_tick.bid)*Breakeven_Leave_Ratio_After_Timeout_Negative;
                        if(sl>newsl ){
                           Print("change sl.");
                           m_trade.PositionModify(position_ticket,newsl,tp);
                        }
                     }  
                  }                  

               }
            }
        }
     }
}