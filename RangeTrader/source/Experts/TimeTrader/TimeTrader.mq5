//+------------------------------------------------------------------+
//|                                                   TimeTrader.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

//module to manage specific time
#include "news.mqh";


enum ENUM_BREAKOUT_COUTING {
   Max_Count_Bar,
   Max_Count_Time
};

//new data to use in tester
CNews news;

input string version = "===== version 0.5 =====";
input int EMPTYVALUE = 88888888;//EMPTY VALUE for bar index
//module to manage specific time
#include "time.mqh";

//module to manage entry mode
#include "entry.mqh";

input string rangeCalculate = "===== RANGE CALCULATE =====";
input int breakoutRangeMinbar = -5;//Breakout Range Min Bar
input int breakoutRangeMaxbar = -2;//Breakout Range Max Bar
input string breakoutRangeMinTime = "";// Breakout Range Min Time
input string breakoutRangeMaxTime = "";// Breakout Range Max Time

input string tradingRange = "===== RANGE TRADE =====";
input int breakoutPeriodMinBar = 2;//Breakout Period Min
input int breakoutPeriodMaxBar = 5;//Breakout Period Max
input string breakoutPeriodMinTime = "";// Breakout Period Min Time
input string breakoutPeriodMaxTime = "";// Breakout Period Max Time
int breakoutPeriodMin;
int breakoutPeriodMax;

//module to manage exit before time out
#include "exit_before_timeout.mqh"
#include "timeout_method.mqh"
#include "exit_method_after_timeout.mqh"

input int MAGICNUMBER = 88888888;
CTrade            m_trade;                      // trading object
int range; // length to calculate range


int OnInit()
  {
  
   m_trade.SetExpertMagicNumber(MAGICNUMBER); 
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
   m_trade.SetDeviationInPoints(30);
   
   init_event_data();
//--- create timer to run every second
   EventSetTimer(1);
   
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
  
datetime getTimeByShift(int _breakoutPeriodMaxBar,string _breakoutPeriodMaxTime,datetime timespec){
   
   datetime dateReturn = timespec;
   
   if(_breakoutPeriodMaxBar!=EMPTYVALUE){
      dateReturn = dateReturn + PeriodSeconds(PERIOD_CURRENT)*(_breakoutPeriodMaxBar+1);
   }
   if(_breakoutPeriodMaxTime!=""){
      string sep=" ";                // A separator as a character
      ushort u_sep;                  // The code of the separator character
      string timeToken[];
      u_sep=StringGetCharacter(sep,0);
      StringSplit(_breakoutPeriodMaxTime,u_sep,timeToken);
      int dayField = StringToInteger(timeToken[0]);
      string timeField = timeToken[1];
      datetime timespecDay = timespec+PeriodSeconds(PERIOD_D1)*dayField;
      MqlDateTime strDay;
      TimeToStruct(timespecDay,strDay);
      string rtTimeString = strDay.year+"."+strDay.mon+"."+strDay.day+" "+timeField;
      dateReturn = StringToTime(rtTimeString );
   }
   
   return dateReturn;
}  
//convert time to bar for max/min time string break/trade/tp range

int getBarFromTime(string timestring,datetime timespec){

   string sep=" ";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   string timeToken[];
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   StringSplit(timestring,u_sep,timeToken);

   int dayField = StringToInteger(timeToken[0]);
   string timeField = timeToken[1];
   //get date for spectime;
   int nDayBarShift = iBarShift(Symbol(),PERIOD_D1,timespec)-dayField;
   datetime timespecDay = iTime(Symbol(),PERIOD_D1,nDayBarShift);
   MqlDateTime strDay;
   TimeToStruct(timespecDay,strDay);
   
   string rtTimeString = strDay.year+"."+strDay.mon+"."+strDay.day+" "+timeField;
   datetime rtTime = StringToTime(rtTimeString );
   if(TimeCurrent()<rtTime || TimeCurrent()<timespec) {
      return(EMPTYVALUE);
   }

   int nbar = iBarShift(Symbol(),PERIOD_CURRENT,rtTime);
   int timeSpecbar = iBarShift(Symbol(),PERIOD_CURRENT,timespec);
   return(timeSpecbar-nbar);
}
// get range by using specific time and minBar,maxBar
double getRange(int SpecTime,int minBar,int maxBar,double &hh, double &ll){

    int range = maxBar-minBar+1;
    int barIndexHH = iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,range,SpecTime-maxBar);
    int barIndexLL = iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,range,SpecTime-maxBar);
    hh = iHigh(Symbol(),PERIOD_CURRENT,barIndexHH);
    ll = iLow(Symbol(),PERIOD_CURRENT,barIndexLL);
    double rangeHL = hh-ll;
    
    return(rangeHL);
}



void OnTimer(){
//---
    
    if(ArraySize(news.event)>0){
       Comment("Waiting "+startTime+","+ArraySize(news.event)+",",news.event[0].time);
    }else{
       Comment("Waiting "+startTime+","+ArraySize(news.event));
    }

    //check timeout
    if(isTimeOut()){
      //exit after time out
      exitAfterTimeOut();
    }else{
      // handle break even
      exitBeforeTimeOut();
    }
    
    // get specific time ========================
    datetime specTime = getSpecificTime();
    if(specTime==NULL) {
      if(lastSpecificTime==NULL) return;//dont get specific time yet
      specTime = lastSpecificTime;
    }
    // before specific time, we need ignore
    if(specTime>TimeCurrent()) return;
    Comment("Waiting working time period.");
    
    //convert time to bar index for specific time 
    int barIndexSpecTime = iBarShift(Symbol(),PERIOD_CURRENT,specTime);
    if(breakoutPeriodMinBar==EMPTYVALUE){
      breakoutPeriodMin = getBarFromTime(breakoutPeriodMinTime,specTime);
      
      if(EMPTYVALUE==breakoutPeriodMin ) {
         Print("Canceled by NULL",breakoutPeriodMin);
         return;
      }
    }else{
      breakoutPeriodMin = breakoutPeriodMinBar;
    }
    datetime breakoutMaxDateTime = getTimeByShift(breakoutPeriodMaxBar,breakoutPeriodMaxTime,specTime);
    
    if(breakoutPeriodMaxBar==EMPTYVALUE){
      breakoutPeriodMax = getBarFromTime(breakoutPeriodMaxTime,specTime);
    }else{
      breakoutPeriodMax = breakoutPeriodMaxBar;
    }
    //current bar is over of periodMax 
    if(breakoutPeriodMax>0 && barIndexSpecTime>breakoutPeriodMax) {
      return;
    }
    //current bar is before of breakoutPeriodMinBar
    if(barIndexSpecTime<breakoutPeriodMin) return;
    //Get Breakout Range =========================
    int rangeMin,rangeMax;
    if(breakoutRangeMinbar==EMPTYVALUE){
      rangeMin = getBarFromTime(breakoutRangeMinTime,specTime);
      if(EMPTYVALUE==rangeMin) return;
    }else{
      rangeMin = breakoutRangeMinbar;
    }
    if(breakoutRangeMaxbar==EMPTYVALUE){
      rangeMax = getBarFromTime(breakoutRangeMaxTime,specTime);
      if(EMPTYVALUE==rangeMax) return;
    }else{
      rangeMax = breakoutRangeMaxbar;
    }
    if(barIndexSpecTime<rangeMax) return;
    double hh,ll;
    double rangeHL = getRange(barIndexSpecTime,rangeMin,rangeMax,hh,ll); 
    string objName = Symbol()+"_"+PERIOD_CURRENT+"_"+specTime+"main";
    if(ObjectFind(0,objName)<0){//draw box
      Print("barIndexSpecTime-rangeMin",barIndexSpecTime-rangeMin);
      Print("barIndexSpecTime-rangeMax",barIndexSpecTime-rangeMax);
      Print("hh,ll",hh,ll);
      RectangleCreate(0,objName,0,
         iTime(Symbol(),PERIOD_CURRENT,barIndexSpecTime-rangeMin),hh,
         iTime(Symbol(),PERIOD_CURRENT,barIndexSpecTime-rangeMax),ll);
    }
    
    // get range for tp calculate ============================
    int tpMin,tpMax;
    if(tpRangeMinBar==EMPTYVALUE){
      tpMin = getBarFromTime(TpRangeMinTime,specTime);
      if(EMPTY_VALUE==tpMin) return;
      
    }else{
      tpMin = tpRangeMinBar;
    }
    if(tpRangeMaxBar==EMPTYVALUE){
      tpMax = getBarFromTime(TpRangeMaxTime,specTime);
      if(EMPTY_VALUE==tpMax) return;
    }else{
      tpMax = tpRangeMaxBar;
    }
    
    double hhTp,llTp;
    double rangeTP = getRange(barIndexSpecTime,tpMin,tpMax,hhTp,llTp);
    
    //try to place order
    createOrder(barIndexSpecTime,specTime,hh,ll,rangeTP,breakoutMaxDateTime);
    
}

//+------------------------------------------------------------------+ 
//| Create rectangle by the given coordinates                        | 
//+------------------------------------------------------------------+ 
bool RectangleCreate(const long            chart_ID=0,        // chart's ID 
                     const string          name="Rectangle",  // rectangle name 
                     const int             sub_window=0,      // subwindow index  
                     datetime              time1=0,           // first point time 
                     double                price1=0,          // first point price 
                     datetime              time2=0,           // second point time 
                     double                price2=0,          // second point price 
                     const color           clr=clrRed,        // rectangle color 
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines 
                     const int             width=1,           // width of rectangle lines 
                     const bool            fill=false,        // filling rectangle with color 
                     const bool            back=false,        // in the background 
                     const bool            selection=true,    // highlight to move 
                     const bool            hidden=false,       // hidden in the object list 
                     const long            z_order=0)         // priority for mouse click 
  { 
//--- set anchor points' coordinates if they are not set 
   ChangeRectangleEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create a rectangle by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a rectangle! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set rectangle color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set the style of rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set width of the rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- enable (true) or disable (false) the mode of filling the rectangle 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
  
//+------------------------------------------------------------------+ 
//| Check the values of rectangle's anchor points and set default    | 
//| values for empty ones                                            | 
//+------------------------------------------------------------------+ 
void ChangeRectangleEmptyPoints(datetime &time1,double &price1, 
                                datetime &time2,double &price2) 
  { 
//--- if the first point's time is not set, it will be on the current bar 
   if(!time1) 
      time1=TimeCurrent(); 
//--- if the first point's price is not set, it will have Bid value 
   if(!price1) 
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- if the second point's time is not set, it is located 9 bars left from the second one 
   if(!time2) 
     { 
      //--- array for receiving the open time of the last 10 bars 
      datetime temp[10]; 
      CopyTime(Symbol(),Period(),time1,10,temp); 
      //--- set the second point 9 bars left from the first one 
      time2=temp[0]; 
     } 
//--- if the second point's price is not set, move it 300 points lower than the first one 
   if(!price2) 
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT); 
  } 