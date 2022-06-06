//enum of exit before timeout
enum ENUM_EXIT_BEFORE_TIMEOUT_MODE {
   LOW2_EXIT_BEFORE_TIMEOUT,
   BREAKEVEN_RATIO_EXIT_BEFORE_TIMEOUT,
   NONE_EXIT_BEFORE_TIMEOUT
};

input string exitBeforeTimeoutParam = "===== Exit before timeout =====";
input ENUM_EXIT_BEFORE_TIMEOUT_MODE exitBeforeTimeoutMode = BREAKEVEN_RATIO_EXIT_BEFORE_TIMEOUT;
input double breakEvenTouchRatio = 0.8;//Breakeven Touch Ration
input double breakevenLeaveRation = 0.5;//Breakeven Leave Ration
input int LOW2_value_before_timeout = 3;//2LOW value before timeout

void exitBeforeTimeOut(){

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
      
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position


      //--- check MagicNumber matches
      if(magic==MAGICNUMBER && position_symbol==Symbol())
        {

            double bebuy = (tp-entry)*breakEvenTouchRatio;
            double besell = (entry-tp)*breakEvenTouchRatio;

            if(exitBeforeTimeoutMode==BREAKEVEN_RATIO_EXIT_BEFORE_TIMEOUT){
               // BREAKEVEN_RATIO_EXIT_BEFORE_TIMEOUT mode
               double bebuyeven = entry+bebuy*breakevenLeaveRation;
               double beselleven = entry-besell*breakevenLeaveRation;
               if (type== POSITION_TYPE_BUY && bebuy>0 && last_tick.ask>entry+bebuy && sl<entry){
                  Print("Set break even.");
                  m_trade.PositionModify(position_ticket,bebuyeven,tp);
               }
               if(type== POSITION_TYPE_SELL && besell>0 && last_tick.bid>entry-besell  && sl>entry){
                  Print("Set break even.");
                  m_trade.PositionModify(position_ticket,beselleven,tp);
               }
            }else if (exitBeforeTimeoutMode==LOW2_EXIT_BEFORE_TIMEOUT){
               // LOW2_EXIT_BEFORE_TIMEOUT mode
               if(type == POSITION_TYPE_BUY && last_tick.ask>entry+bebuy) {//check touched be target
                  //get last n bars low
                  int llIndex = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,LOW2_value_before_timeout,1);
                  double low = iLow(Symbol(),PERIOD_CURRENT,llIndex);
                  if(sl<low){
                     m_trade.PositionModify(position_ticket,low,tp);
                  }
               }
               
               if(type== POSITION_TYPE_SELL && last_tick.bid<entry-besell){//check touched be target
                  //get last n bars high
                  int hhIndex = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,LOW2_value_before_timeout,1);
                  double high = iHigh(Symbol(),PERIOD_CURRENT,hhIndex);
                  if(sl>high){
                     m_trade.PositionModify(position_ticket,high,tp);
                  }
               }
            }

        }
     }
   
}
