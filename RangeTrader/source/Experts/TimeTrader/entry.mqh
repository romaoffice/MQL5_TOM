// module for management entry order


enum ENUM_ENTRY_MODE {
   Limit_Order_Entry,
   Additional_pips_Entry,
   No_of_time_breakout,
   Market_Price_Entry,
   Close_Next_Bar_Entry,
   Full_Next_Bar_Entry
};

enum ENUM_CAPITAL_MANAGEMENT {
   Fix_Lot,
   Fix_Risk_Amount,
   Fix_Percentage_Risk,
};

enum ENUM_STOPLOSS_METHOD {
   TP__SL_Range_Ration,
   SL_Prev_bars__TP_Range_Ratio,
   TP__SL_Prev_bars
   
};

input string entrymodestring = "===== ENTRY MODE=====";
input ENUM_ENTRY_MODE entry_mode = Market_Price_Entry;
input int Additonal_pips_value = 3;//Additonal pips value for entry
input int No_of_time_breakout_value = 2; // No. of time breakout value

input string tradingParam = "===== POSITION PARAM =====";
input ENUM_CAPITAL_MANAGEMENT capital_mode = Fix_Percentage_Risk;
input double Captial_Management_Value = 1;
input int tpRangeMinBar = -5;//TP Range Min Bar
input int tpRangeMaxBar = -2;//TP Range Max Bar
input string TpRangeMinTime = "0 10:00:00";// TP Range Min Time
input string TpRangeMaxTime = "0 18:00:00";// TP Range Max Time

input double takeProfitRatio = 0.5;//Takeprofit Ration
input ENUM_STOPLOSS_METHOD TP_SL_METHOD = TP__SL_Range_Ration;// STOP LOSS METHOD
input double stopLossRatio = 1;//Stoploss Ration
input int StopLossPreviousbars=2;//Stoploss Previous bars

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
int getTimeOfbreakout(int barIndexSpecTime,int direction,double level){
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
   if(TP_SL_METHOD==TP__SL_Range_Ration){
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
        m_trade.Buy(orderLot,symbol,price,sl,tp,comment);
     }else{//sell
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


//process place order
void createOrder(int barIndexSpecTime,datetime specTime,double hh,double ll,double rangeTP,datetime breakoutMaxDateTime){

   //check did trade already ================================
   //check it take trade already in this breakout period
   //the ea take only one trade per day within breakout period 
   double lastwork = GlobalVariableGet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER);
   
   //check for order place
   //dont trade ,if there are trade in current day
   if(lastwork==specTime ) return;
   
   //get last tick
   MqlTick last_tick; 
   SymbolInfoTick(Symbol(),last_tick);
   
   // prepare price to check breakout
   double priceCurrent;
   if(entry_mode==Close_Next_Bar_Entry || entry_mode==Full_Next_Bar_Entry){ 
      // use only close bar price 
      // we need wait close bar when start breakout range bar
      if(barIndexSpecTime<breakoutPeriodMin+1) return;
      priceCurrent = iClose(Symbol(),PERIOD_CURRENT,1);
   }else{ // use real time price
      priceCurrent = iClose(Symbol(),PERIOD_CURRENT,0);
   }
   
   //prepare additional pips by selected input params
   double _addpips =0;
   if(entry_mode==Additional_pips_Entry){
      //convert pips for 5 digits
      _addpips = Additonal_pips_value*Point()*10;
   }
   //get lot by capital management mode;
   
   //process variouse market order for Full_Next_Bar_Entry,Close_Next_Bar_Entry ,Additional_pips_Entry ,Market_Price_Entry
   if(entry_mode==Close_Next_Bar_Entry || entry_mode==Close_Next_Bar_Entry || entry_mode==Additional_pips_Entry || entry_mode==Market_Price_Entry){
      
      if(entry_mode==Close_Next_Bar_Entry ){// we use low price to compare
         priceCurrent = iLow(Symbol(),PERIOD_CURRENT,1);
      }
      if(priceCurrent>=hh+_addpips && buyFilter){//got break up
         ///---
         Print("Order processing for market buy");
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
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER,TimeCurrent());
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuy"+MAGICNUMBER,last_tick.ask+rangeTP*takeProfitRatio*breakEvenTouchRatio); //save be touch  price for buy
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuyeven"+MAGICNUMBER,last_tick.ask+rangeTP*takeProfitRatio*breakevenLeaveRation); //save be price for buy
         Print("!!Order send buy for "+Symbol()+" at "+last_tick.ask);
      }

      if(entry_mode==Close_Next_Bar_Entry ){// we use high price to compare
         priceCurrent = iHigh(Symbol(),PERIOD_CURRENT,1);
      }

      if(priceCurrent<=ll-_addpips  && sellFilter){//got break down
         Print("Order processing for market sell");
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
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER,TimeCurrent());
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbesell"+MAGICNUMBER,last_tick.bid-rangeTP*takeProfitRatio*breakEvenTouchRatio);//save be touch price for sell
         GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbeselleven"+MAGICNUMBER,last_tick.bid-rangeTP*takeProfitRatio*breakevenLeaveRation);//save be price for sell
      }
   }else{
      if(entry_mode==Limit_Order_Entry){//process stop order entry
         datetime now = TimeCurrent();
         if(priceCurrent>=hh && buyFilter){//got break up
            
            double tp = hh+rangeTP*takeProfitRatio; // take profit
            double sl = hh-rangeTP*takeProfitRatio*stopLossRatio; //stop loss
            //open position for buy, set expire for 6 hours
            double LOT = getLot(hh,sl,ORDER_TYPE_BUY);
            
            limitOrderBulk(1,LOT,hh,Symbol(),sl,tp,breakoutMaxDateTime);
            //save trade status to avoid another buy
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER,TimeCurrent());
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuy"+MAGICNUMBER,hh+rangeTP*takeProfitRatio*breakEvenTouchRatio); //save be touch  price for buy
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuyeven"+MAGICNUMBER,hh+rangeTP*takeProfitRatio*breakevenLeaveRation); //save be price for buy
            Print("--Order send buy for "+Symbol()+" at "+hh);
         }
      
         if(priceCurrent<=ll  && sellFilter){//got break down
            double tp = ll-rangeTP*takeProfitRatio; // take profit
            double sl = ll+rangeTP*takeProfitRatio*stopLossRatio; // stop loss
            //open position for sell, set expire for 6 hours
            double LOT = getLot(ll,sl,ORDER_TYPE_SELL);
            limitOrderBulk(-1,LOT,ll,Symbol(),sl,tp,breakoutMaxDateTime);
      
            //save trade status to avoid another sell
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER,TimeCurrent());
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbesell"+MAGICNUMBER,ll-rangeTP*takeProfitRatio*breakEvenTouchRatio);//save be touch price for sell
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbeselleven"+MAGICNUMBER,ll-rangeTP*takeProfitRatio*breakevenLeaveRation);//save be price for sell
            Print("--Order send sell for "+Symbol()+" at "+ll);
         }
      }else{//process No_of_time_breakout
         //get time of break our for buy
         if(getTimeOfbreakout(barIndexSpecTime,1,hh)>No_of_time_breakout_value){
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
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER,TimeCurrent());
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuy"+MAGICNUMBER,last_tick.ask+rangeTP*takeProfitRatio*breakEvenTouchRatio); //save be touch  price for buy
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbebuyeven"+MAGICNUMBER,last_tick.ask+rangeTP*takeProfitRatio*breakevenLeaveRation); //save be price for buy
            Print("//Order send buy for "+Symbol()+" at "+last_tick.ask);
         }
         //get time of break our for sell
         if(getTimeOfbreakout(barIndexSpecTime,-1,ll)>No_of_time_breakout_value){
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
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER,TimeCurrent());
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastwork"+MAGICNUMBER,specTime);
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbesell"+MAGICNUMBER,last_tick.bid-rangeTP*takeProfitRatio*breakEvenTouchRatio);//save be touch price for sell
            GlobalVariableSet(Symbol()+PERIOD_CURRENT+"lastworkbeselleven"+MAGICNUMBER,last_tick.bid-rangeTP*takeProfitRatio*breakevenLeaveRation);//save be price for sell
         }

      }
   }

}