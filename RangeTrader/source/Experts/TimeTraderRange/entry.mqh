// module for management entry order


ENUM_ENTRY_MODE entry_mode ;
int Additonal_pips_value;
int No_of_time_breakout_value;
input string tradingParam = "===== POSITION PARAM =====";
input ENUM_CAPITAL_MANAGEMENT capital_mode = Fix_Percentage_Risk;
input double Captial_Management_Value = 1;

double takeProfitRatio;
ENUM_STOPLOSS_METHOD TP_SL_METHOD;
double stopLossRatio;
int StopLossPreviousbars;

double entryAreaMin;
double entryAreaMax;
int noOfFullNextBar;
int noOfCloseNextBar;
double hh_mainRange,ll_mainRange,range_main;
bool enableGoNow;

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
//get time of break out
int getTimeOfbreakout(int barIndexSpecTime,int direction,double level,int breakoutPeriodMin){
   int nStart = barIndexSpecTime-breakoutPeriodMin;
   int count =0;//time of break out
   bool reset = true;// flag to reset breakout
   for(int i=nStart;i>0;i--){
      if(direction>0){//check break buy
         if(reset){
            if(iClose(Symbol(),PERIOD_CURRENT,i)>level && reset){ // found breakout above level
               count ++;
               reset = false;
            }
         }else{
            if(iLow(Symbol(),PERIOD_CURRENT,i)<level) reset = true;
         }
      }else{//check break sell
         if(reset){
            if(iClose(Symbol(),PERIOD_CURRENT,i)<level && reset){ // found breakout bellow level
               count ++;
               reset = false;
            }
         }else{
            if(iHigh(Symbol(),PERIOD_CURRENT,i)>level) reset = true;
         }
      }
   }
   return(count);
}
//get stoploss
double getStoploss(double rangeTP,double price,int direction){
   double stoploss=0;
   if(TP_SL_METHOD==TP__SL_Range_Ration || TP_SL_METHOD==TP_Top_Bottom){
      if(direction==1){//get stop loss for buy
         stoploss = price-rangeTP*takeProfitRatio*stopLossRatio;
      }else{//get stop loss for sell
         stoploss = price+rangeTP*takeProfitRatio*stopLossRatio;
      }
   }else if(TP_SL_METHOD==SL_Prev_bars__TP_Range_Ratio || TP_SL_METHOD==TP__SL_Prev_bars){

      if(direction==1){//get stop loss for buy
         stoploss = iLow(Symbol(),PERIOD_CURRENT,iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,StopLossPreviousbars,1));
      }else{//get stop loss for sell
         stoploss = iHigh(Symbol(),PERIOD_CURRENT,iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,StopLossPreviousbars,1));
      }
   }
   return(stoploss);
}

//market order manager for big lot

void marketOrderBulk(int direction,double lot ,string symbol,double price,double sl,double tp,string comment){

   double maxlot = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   double minlot = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double lotstep = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   double remainLot = lot ;
   while(remainLot>0){
     double orderLot = remainLot>=maxlot?maxlot:remainLot;
     if(orderLot <minlot) orderLot = minlot;
     orderLot = MathRound(orderLot / lotstep)*lotstep;
     if(direction==1){//buy
        Print("Order placed",orderLot,",",symbol,",",price,",",sl,",",tp,",",comment);
        m_trade.Buy(orderLot,symbol,price,sl,tp,comment);
     }else{//sell
        Print("Order placed",orderLot,",",symbol,",",price,",",sl,",",tp,",",comment);
        m_trade.Sell(orderLot,symbol,price,sl,tp,comment);
     }
     remainLot = remainLot-orderLot;
   }
}

//limit order manager for big lot

void limitOrderBulk(int direction,double lot ,double price,string symbol,double sl,double tp,datetime breakoutMaxDateTime){
   double maxlot = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   double minlot = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double lotstep = SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   datetime now = TimeCurrent();
   double remainLot = lot ;
   while(remainLot>0){
     double orderLot = remainLot>=maxlot?maxlot:remainLot;
     if(orderLot <minlot) orderLot = minlot;
     orderLot = MathRound(orderLot / lotstep)*lotstep;
     if(direction==1){//buy
        m_trade.BuyLimit(orderLot,price,symbol,sl,tp,ORDER_TIME_SPECIFIED,breakoutMaxDateTime);
     }else{//sell
        m_trade.SellLimit(orderLot,price,symbol,sl,tp,ORDER_TIME_SPECIFIED,breakoutMaxDateTime);
     }
     remainLot = remainLot-orderLot;
   }
}
double adjustedTPRange(int direction,double _tpRange,double& takeProfitRatio,MqlTick &last_tick){
   //chage TP range when tp_top bottom mode
   if(TP_SL_METHOD==TP_Top_Bottom){
      Print("Call adjusted TP range");
      double marketPrice = last_tick.ask;
      if(direction==1){//buy
         if(hh_mainRange-marketPrice>marketPrice-ll_mainRange){
            _tpRange = hh_mainRange-marketPrice;
            takeProfitRatio=1;
         }
      }else{//sell
         marketPrice = last_tick.bid;
         Print("Call adjusted TP range ",marketPrice,",",ll_mainRange,",",hh_mainRange,",",marketPrice-ll_mainRange,",",hh_mainRange-marketPrice);

         if(marketPrice-ll_mainRange>hh_mainRange-marketPrice){
            _tpRange = marketPrice-ll_mainRange;
            takeProfitRatio=1;
            Print("Set tp to ll ",ll_mainRange);
         }
      }
   }
   return(_tpRange);
}
//process place order
int PrevI = -1000;
void createOrder(int barIndexSpecTime,datetime specTime,double hh,double ll,double rangeTP,int breakoutPeriodMin,int subrangeIndex,datetime breakoutMaxDateTime,int MainCompletedBar){

   //check did trade already ================================
   //check it take trade already in this breakout period
   //the ea take only one trade per day within breakout period 

   double lastwork = GlobalVariableGet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER);

   //check for order place
   //dont trade ,if there are trade in current day
   if(lastwork==specTime ) {
      PrevI = -1000;
      return;
   }
   
   //get last tick
   MqlTick last_tick; 
   SymbolInfoTick(Symbol(),last_tick);
   
   // prepare price to check breakout
   double priceCurrent;
   if(enableGoNow==false && (entry_mode==Close_Next_Bar_Entry || entry_mode==Full_Next_Bar_Entry)){ 
      // use only close bar price 
      // we need wait close bar when start breakout range bar
      int barcount = entry_mode==Close_Next_Bar_Entry ?_noOfCloseNextBar[subrangeIndex]:_noOfFullNextBar[subrangeIndex];
      if(barIndexSpecTime<breakoutPeriodMin+barcount) return;
      priceCurrent = iClose(Symbol(),PERIOD_CURRENT,1);
   }else{ // use real time price
      priceCurrent = iClose(Symbol(),PERIOD_CURRENT,0);
   }
   //check entry area
   bool isEntryAreaBuy = false;
   bool isEntryAreaSell = false;
   if(entryAreaMin==EMPTYVALUE || entryAreaMax==EMPTYVALUE ) {
      isEntryAreaBuy  = true;
      isEntryAreaSell = true;
   }else{
      double entryMin = ll_mainRange+entryAreaMin*range_main;
      double entryMax = ll_mainRange+entryAreaMax*range_main;
      if(entry_mode==Close_Next_Bar_Entry){
         if(iClose(Symbol(),PERIOD_CURRENT,1)>entryMin && iClose(Symbol(),PERIOD_CURRENT,1)<entryMax) isEntryAreaBuy = true;
      }else if(entry_mode==Full_Next_Bar_Entry){
         if(iLow(Symbol(),PERIOD_CURRENT,1)>entryMin && iHigh(Symbol(),PERIOD_CURRENT,1)<entryMax) isEntryAreaBuy = true;
      }else{
         if(iClose(Symbol(),PERIOD_CURRENT,0)>entryMin && iClose(Symbol(),PERIOD_CURRENT,0)<entryMax) isEntryAreaBuy = true;
      }
      
      entryMin = ll_mainRange-(entryAreaMin-1)*range_main;
      entryMax = ll_mainRange-(entryAreaMax-1)*range_main;
      if(entry_mode==Close_Next_Bar_Entry){
         if(iClose(Symbol(),PERIOD_CURRENT,1)<entryMin && iClose(Symbol(),PERIOD_CURRENT,1)>entryMax) isEntryAreaSell = true;
      }else if(entry_mode==Full_Next_Bar_Entry){
         if(iLow(Symbol(),PERIOD_CURRENT,1)<entryMin && iHigh(Symbol(),PERIOD_CURRENT,1)>entryMax) isEntryAreaSell = true;
      }else{
         if(iClose(Symbol(),PERIOD_CURRENT,0)<entryMin && iClose(Symbol(),PERIOD_CURRENT,0)>entryMax) isEntryAreaSell = true;
      }
      Comment(entryMin+","+entryMax+","+isEntryAreaBuy+","+isEntryAreaSell);
   }
   if(isEntryAreaBuy==false && isEntryAreaSell==false) return;
      
   //prepare additional pips by selected input params
   double _addpips =0;
   if(entry_mode==Additional_pips_Entry){
      //convert pips for 5 digits
      _addpips = Additonal_pips_value*Point()*10;
   }
   
   bool activeRange = false;
   double cp = iClose(Symbol(),PERIOD_CURRENT,MainCompletedBar+1);
   if(hh>=cp && cp>=ll) {
      activeRange = true;
   }
   if(activeRange==false) return;

   bool activeEnableGoNow = false;
   if(enableGoNow && MainCompletedBar==0){
      activeEnableGoNow = true;
   }
   if(MainCompletedBar!=PrevI){
      PrevI = MainCompletedBar;
      Print(activeRange,"::::",activeEnableGoNow,"--",cp,",",hh,",",ll,",",MainCompletedBar,",",barIndexSpecTime);
   }
   //process variouse market order for Full_Next_Bar_Entry,Close_Next_Bar_Entry ,Additional_pips_Entry ,Market_Price_Entry
   if(activeEnableGoNow || entry_mode==Close_Next_Bar_Entry || entry_mode==Full_Next_Bar_Entry || entry_mode==Additional_pips_Entry || entry_mode==Market_Price_Entry){

      if(entry_mode==Full_Next_Bar_Entry ){// we use low price to compare
         priceCurrent = iLow(Symbol(),PERIOD_CURRENT,1);
      }
      
      if((activeEnableGoNow || priceCurrent>=hh+_addpips) && buyFilter && isEntryAreaBuy){//got break up
         Print("Completed place order",iTime(Symbol(),PERIOD_CURRENT,0)," Close= ",iClose(Symbol(),PERIOD_CURRENT,0));
         ///---
         Print("Order processing for market buy");
         rangeTP = adjustedTPRange(1,rangeTP,takeProfitRatio,last_tick);
         double sl = getStoploss(rangeTP,last_tick.ask,1); //stop loss
         double rangeSL = MathAbs(last_tick.ask-sl);
         
         //if TP_SL_METHOD is TP__SL_Prev_bars  , tp calculaed from SL range
         double tp = TP_SL_METHOD!=TP__SL_Prev_bars ?
               last_tick.ask+rangeTP*takeProfitRatio:
               last_tick.ask+rangeSL*takeProfitRatio; // take profit
               
         //open position for buy
         double LOT = getLot(last_tick.ask,sl,ORDER_TYPE_BUY);
         marketOrderBulk(1,LOT,Symbol(),last_tick.ask,sl,tp,"");
         //save trade status to avoid another buy
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
         //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder",TimeCurrent());
         //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuy",last_tick.ask+rangeTP*takeProfitRatio*breakEvenTouchRatio); //save be touch  price for buy
         //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuyeven",last_tick.ask+rangeTP*takeProfitRatio*breakevenLeaveRation); //save be price for buy
         Print("!!Order send buy for "+Symbol()+" at "+last_tick.ask);
      }

      if(entry_mode==Full_Next_Bar_Entry ){// we use high price to compare
         priceCurrent = iHigh(Symbol(),PERIOD_CURRENT,1);
      }

      if((activeEnableGoNow || priceCurrent<=ll-_addpips ) && sellFilter && isEntryAreaSell){//got break down
         
         Print("Order processing for market sell");
         rangeTP = adjustedTPRange(-1,rangeTP,takeProfitRatio,last_tick);
         double sl = getStoploss(rangeTP,last_tick.bid,-1); // stop loss
         double rangeSL = MathAbs(last_tick.bid-sl);
         //if TP_SL_METHOD is TP__SL_Prev_bars  , tp calculaed from SL range
         double tp = TP_SL_METHOD!=TP__SL_Prev_bars ?
               last_tick.bid-rangeTP*takeProfitRatio:
               last_tick.bid-rangeSL*takeProfitRatio; // take profit
         //open position for sell
         double LOT = getLot(last_tick.bid,sl,ORDER_TYPE_SELL);
         marketOrderBulk(-1,LOT,Symbol(),last_tick.bid,sl,tp,"");
         Print("!!Order send sell for "+Symbol()+" at "+last_tick.bid," sell filter",sellFilter);
   
         //save trade status to avoid another sell
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
         //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder",TimeCurrent());
         //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbesell",last_tick.bid-rangeTP*takeProfitRatio*breakEvenTouchRatio);//save be touch price for sell
         //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbeselleven",last_tick.bid-rangeTP*takeProfitRatio*breakevenLeaveRation);//save be price for sell
      }
   }else{
      if(entry_mode==Limit_Order_Entry){//process stop order entry
         datetime now = TimeCurrent();
         if(priceCurrent>=hh && buyFilter && isEntryAreaBuy){//got break up
            
            double tp = hh+rangeTP*takeProfitRatio; // take profit
            double sl = hh-rangeTP*takeProfitRatio*stopLossRatio; //stop loss
            //open position for buy, set expire for 6 hours
            double LOT = getLot(hh,sl,ORDER_TYPE_BUY);
            
            limitOrderBulk(1,LOT,hh,Symbol(),sl,tp,breakoutMaxDateTime);
            //save trade status to avoid another buy
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder",TimeCurrent());
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuy",hh+rangeTP*takeProfitRatio*breakEvenTouchRatio); //save be touch  price for buy
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuyeven",hh+rangeTP*takeProfitRatio*breakevenLeaveRation); //save be price for buy
            Print("--Order send buy for "+Symbol()+" at "+hh);
         }
      
         if(priceCurrent<=ll  && sellFilter && isEntryAreaSell){//got break down
            double tp = ll-rangeTP*takeProfitRatio; // take profit
            double sl = ll+rangeTP*takeProfitRatio*stopLossRatio; // stop loss
            //open position for sell, set expire for 6 hours
            double LOT = getLot(ll,sl,ORDER_TYPE_SELL);
            limitOrderBulk(-1,LOT,ll,Symbol(),sl,tp,breakoutMaxDateTime);
      
            //save trade status to avoid another sell
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder",TimeCurrent());
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbesell",ll-rangeTP*takeProfitRatio*breakEvenTouchRatio);//save be touch price for sell
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbeselleven",ll-rangeTP*takeProfitRatio*breakevenLeaveRation);//save be price for sell
            Print("--Order send sell for "+Symbol()+" at "+ll);
         }
      }else if (entry_mode==No_of_time_breakout) {//process No_of_time_breakout
         //get time of break our for buy
         if(getTimeOfbreakout(barIndexSpecTime,1,hh,breakoutPeriodMin)>No_of_time_breakout_value){
            rangeTP = adjustedTPRange(1,rangeTP,takeProfitRatio,last_tick);
            double sl = getStoploss(rangeTP,last_tick.ask,1); //stop loss
            double rangeSL = MathAbs(last_tick.ask-sl);
            double tp = TP_SL_METHOD!=TP__SL_Prev_bars ?
               last_tick.ask+rangeTP*takeProfitRatio:
               last_tick.ask+rangeSL*takeProfitRatio; // take profit
            //open position for buy
            double LOT = getLot(last_tick.ask,sl,ORDER_TYPE_BUY);
            marketOrderBulk(1,LOT,Symbol(),last_tick.ask,sl,tp,"");
            //save trade status to avoid another buy
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder",TimeCurrent());
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuy",last_tick.ask+rangeTP*takeProfitRatio*breakEvenTouchRatio); //save be touch  price for buy
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuyeven",last_tick.ask+rangeTP*takeProfitRatio*breakevenLeaveRation); //save be price for buy
            Print("//Order send buy for "+Symbol()+" at "+last_tick.ask);
         }
         //get time of break our for sell
         if(getTimeOfbreakout(barIndexSpecTime,-1,ll,breakoutPeriodMin)>No_of_time_breakout_value){
            rangeTP = adjustedTPRange(-1,rangeTP,takeProfitRatio,last_tick);
            double sl = getStoploss(rangeTP,last_tick.bid,-1); // stop loss
            double rangeSL = MathAbs(last_tick.bid-sl);

            double tp = TP_SL_METHOD!=TP__SL_Prev_bars ?
               last_tick.bid-rangeTP*takeProfitRatio:
               last_tick.bid-rangeSL*takeProfitRatio; // take profit
            //open position for sell
            double LOT = getLot(last_tick.bid,sl,ORDER_TYPE_SELL);
            marketOrderBulk(-1,LOT,Symbol(),last_tick.bid,sl,tp,"");
            Print("//Order send sell for "+Symbol()+" at "+last_tick.bid);
            //save trade status to avoid another sell
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder",TimeCurrent());
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbesell",last_tick.bid-rangeTP*takeProfitRatio*breakEvenTouchRatio);//save be touch price for sell
            //GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbeselleven",last_tick.bid-rangeTP*takeProfitRatio*breakevenLeaveRation);//save be price for sell
         }

      }
   }

}