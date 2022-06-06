//+------------------------------------------------------------------+
//|                                                   2LegTrader.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#property version "1.0"
#property description "2Leg trader" 

enum ORDERTYPE {
   MARKETORDER,
   CLOSE_NEXT_BAR_ENTRY,
   FULL_NEXT_BAR_ENTRY
};
enum ENUM_CAPITAL_MANAGEMENT {
   Fix_Lot,
   Fix_Risk_Amount,
   Fix_Percentage_Risk,
};
enum STOPLOSSMODE {
   RATIO_OF_BC,
   ATR_RATE
};
enum TAKEPROFITMODE {
   TP_SL_RATIO,
   TP_BC_RATIO
};
input int MAGICNUMBER = 6666666;
input string scomma0 = "========== zigzag params ============";
input int Depth = 6;//Depth for Zigzag param
input int Deviation = 3;//Deviation for Zigzag param
input int BackStep = 3;//Back step for Zigzag param
input string scomma1 = "========== legs defins ============";
input double minRetraceBC = 0.1;// minimum retrace rate of BC against AB
input double maxRetraceBC = 0.6;// maximum retrace rate of BC against AB
input int minBClength = 7;//Min bars of BC
input int maxBClength = 20;//Max bars of BC
input string scomma2 = "=============== order =================";
input int ADX_PERIOD = 14;
input double minAdx = 40; // min adx value to place order
input double maxAdx = 80; // max adx value to place order
input ORDERTYPE ordertype = MARKETORDER;//Order Type
input ENUM_CAPITAL_MANAGEMENT capital_mode = Fix_Percentage_Risk;
input double Captial_Management_Value = 1;
input string scomma3 = "=============== TP/SL =================";
input int ATR_PERIOD = 100;
input STOPLOSSMODE stoploss_mode=RATIO_OF_BC;
input double stoploss_value = 1;
input TAKEPROFITMODE takeprofit_mode=TP_SL_RATIO;
input double takeprofit_value = 1;
#include "leave.mqh"

struct ZZ {
   datetime zzDate;
   double zzValue;
};
struct LEG {
   datetime legDate;
   int   legLength;
   double legValue;
};
#define maxZZItems  5
ZZ zzList[maxZZItems];
LEG legList[maxZZItems-1];

int zzCount =0;
double zigzagBuffer[];
bool legIsValid = false;

#include "draw.mqh"
#include "getlot.mqh"

#include <Trade\Trade.mqh>
CTrade            m_trade;                      // trading object


int handleATR;
double atr_buffer[];
int handleADX;
double adx_buffer[];

int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   ArraySetAsSeries(zigzagBuffer,true); 
   ArraySetAsSeries(atr_buffer,true); 
   handleATR = iATR(Symbol(),PERIOD_CURRENT,ATR_PERIOD);
   handleADX = iADX(Symbol(),PERIOD_CURRENT,ADX_PERIOD);
   m_trade.SetExpertMagicNumber(MAGICNUMBER);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
datetime lastchecksignal = 0;
void OnTimer()
  {
//---
      if(lastchecksignal!=iTime(Symbol(),PERIOD_CURRENT,1)){
         checkPattern();
         lastchecksignal = iTime(Symbol(),PERIOD_CURRENT,1);
      }
      if(legIsValid){
         checkOrder();
      }
      leaveProcess();
  }
//+------------------------------------------------------------------+

//get leg pattern
void checkPattern(){
   // we use zigzag indicator to get pattern
   int Zigzag_Handle = iCustom(NULL,0,"Examples\\ZigZag", 
                     Depth, 
                     Deviation, 
                     BackStep
                     );
   int totalbars = Bars(Symbol(),PERIOD_CURRENT);
   int copy=CopyBuffer(Zigzag_Handle,0,0,totalbars,zigzagBuffer); 

   if(copy<=0){
      Print("Failed to get zigzag");
      return; 
   } 
   
   //find 5 point for zigzag and make 4legs
   zzCount = 0;
   bool passempty = false;
   for(int i =1;i<totalbars;i++ ){
      if(zigzagBuffer[i]!=0){
         if(passempty==false){
            passempty = true;
         }else{
            if(zzCount==0 && iTime(Symbol(),PERIOD_CURRENT,i)==zzList[zzCount].zzDate) return;
            zzList[zzCount].zzDate = iTime(Symbol(),PERIOD_CURRENT,i);
            zzList[zzCount].zzValue= zigzagBuffer[i];
            zzCount++;
            if(zzCount>=maxZZItems) break;
         }
      }
   }
   if(zzCount<maxZZItems) {
      Print("Dont hve enough leg yet");
      return;
   }
   for(int i=0;i<maxZZItems-1;i++){
      legList[i].legDate = zzList[maxZZItems-1-i].zzDate;
      legList[i].legLength = iBarShift(Symbol(),PERIOD_CURRENT,zzList[maxZZItems-1-i].zzDate)-iBarShift(Symbol(),PERIOD_CURRENT,zzList[maxZZItems-1-i-1].zzDate)+1;
      legList[i].legValue = zzList[maxZZItems-1-i-1].zzValue-zzList[maxZZItems-1-i].zzValue;
   }
   
   legIsValid = CheckLegValid();
   Print(legIsValid ,",",legList[0].legDate,legList[1].legDate,",",legList[2].legDate,",",legList[3].legDate);
   
}
void drawLeg(){
   
   string trendnameafx = "trend"+legList[0].legDate;
   for(int i =4;i>0;i--){
      color clrLine = i==4 ? clrBlue:clrYellow;
      string trendname = trendnameafx+i;
      bool success = TrendCreate(0,trendname,0,zzList[i].zzDate,zzList[i].zzValue,zzList[i-1].zzDate,zzList[i-1].zzValue,clrLine,0,2,false,false);
      if(success ==false) return;
   }

}
//check valid leg
bool CheckLegValid(){
   
   
   int copyitems = CopyBuffer(handleADX,0,zzList[3].zzDate,1,adx_buffer);
   if(copyitems<0) {
      Print("Faile to copy atr buffer");
      return false;
   }
   if(adx_buffer[0]<minAdx || adx_buffer[0]>maxAdx ){
      Print("Not good for adx");
      return false;
   }
            

   //check bc leg's length
   int lenBC = legList[1].legLength + legList[2].legLength+legList[3].legLength;
   if(lenBC<minBClength || lenBC>maxBClength) {
      Print("Wrong length of BC",lenBC);
      return false;
   }
   
   //check not good bc pattern;
   double r21 = MathAbs(legList[2].legValue)/MathAbs(legList[1].legValue);
   double r32 = MathAbs(legList[3].legValue)/MathAbs(legList[2].legValue);
   if(r21>1 && r32>1) {
      Print("Bad pattern H2 is higher than H1 AND L2 lower than L1",r21,r32);
      return false;
   }
   
   //BC retrace
   double retrace;
   if(legList[0].legValue>0 && zzList[0].zzValue>=zzList[3].zzValue || 
      legList[0].legValue<0 && zzList[0].zzValue<=zzList[3].zzValue 
   ){
      Print("Wrong direction",legList[0].legValue,",",zzList[0].zzValue,",",zzList[3].zzValue);
      return(false);
   }else{
      retrace= MathAbs(zzList[0].zzValue-zzList[3].zzValue)/MathAbs(zzList[3].zzValue-zzList[4].zzValue);
   }
   
   if(retrace<minRetraceBC || retrace>maxRetraceBC){
      Print("Wrong retrace rate for BC",retrace);
      return(false);
   }
   return true;
}
void checkOrder(){
   double last_trade ;
   string varName = "lasttrade_2leg"+Symbol()+Period();
   if(GlobalVariableCheck(varName)){
      last_trade = GlobalVariableGet(varName);
   }else{
      last_trade = 0;
   }
   datetime tradeTime = legList[0].legDate;
   //this leg traded already
   if(last_trade ==tradeTime ){
      return ;
   }

   int copyitems;
   
   bool needOrder = false;
   double priceBreak = zzList[1].zzValue;
   int direction = legList[0].legValue>0?1:-1;
   if(direction==1){// up, need buy
      switch(ordertype){
         case MARKETORDER:
            if(iHigh(Symbol(),PERIOD_CURRENT,0)>priceBreak) needOrder = true;
            break;
         case CLOSE_NEXT_BAR_ENTRY:
            if(iClose(Symbol(),PERIOD_CURRENT,1)>priceBreak) needOrder = true;
            break;
         case FULL_NEXT_BAR_ENTRY:
            if(iLow(Symbol(),PERIOD_CURRENT,1)>priceBreak) needOrder = true;
            break;
      }
   }else{ // down , need sell
      switch(ordertype){
         case MARKETORDER:
            if(iLow(Symbol(),PERIOD_CURRENT,0)<priceBreak) needOrder = true;
            break;
         case CLOSE_NEXT_BAR_ENTRY:
            if(iClose(Symbol(),PERIOD_CURRENT,1)<priceBreak) needOrder = true;
            break;
         case FULL_NEXT_BAR_ENTRY:
            if(iHigh(Symbol(),PERIOD_CURRENT,1)<priceBreak) needOrder = true;
            break;
      }
   }
   if(needOrder){
      double sl_value = 0;
      switch(stoploss_mode){
         case RATIO_OF_BC:
            sl_value = MathAbs(legList[1].legValue)*stoploss_value;
            break;
         case ATR_RATE:
            copyitems = CopyBuffer(handleATR,0,1,1,atr_buffer);
            if(copyitems<0) {
               Print("Faile to copy atr buffer");
               return;
            }
            sl_value = atr_buffer[0]*stoploss_value;
            break;
      }
      double tp_value = 0;
      switch(takeprofit_mode){
         case TP_SL_RATIO:
            tp_value = sl_value*takeprofit_value;
            break;
         case TP_BC_RATIO:
            tp_value = MathAbs(zzList[0].zzValue-zzList[3].zzValue)*takeprofit_value;
            break;
      }
      Print("SL,TP Value=",sl_value,",",tp_value);
      //get last tick
      MqlTick last_tick; 
      SymbolInfoTick(Symbol(),last_tick);
      double stoploss,takeprofit,lot;
      if(direction==1){//need buy
         stoploss = last_tick.ask-sl_value;
         takeprofit = last_tick.ask+tp_value;
         lot = getLot(last_tick.ask,stoploss ,ORDER_TYPE_BUY);
         m_trade.Buy(lot,Symbol(),last_tick.ask,stoploss ,takeprofit,"");
      }else{
         stoploss = last_tick.bid+sl_value;
         takeprofit = last_tick.bid-tp_value;
         lot = getLot(last_tick.bid,stoploss ,ORDER_TYPE_SELL);
         m_trade.Sell(lot,Symbol(),last_tick.bid,stoploss ,takeprofit,"");
      }
      drawLeg();
      GlobalVariableSet(varName,legList[0].legDate);
   }
}
