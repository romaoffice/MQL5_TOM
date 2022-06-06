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




//new data to use in tester
CNews news;
#include "enum.mqh";
input string version = "===== version 0.5 =====";
input int EMPTYVALUE = 88888888;//EMPTY VALUE for bar index
//module to manage specific time
#include "time.mqh";

//module to manage entry mode
#include "entry.mqh";

input string _MAINRANGE = "===== MAIN RANGE =====";
input int mainRangeMinBar = -10;// Main Range Min Bar
input int mainRangeMaxBar = -2;// Main Range Max Bar
input string mainRangeMinTime = "";// Main Range Min Time
input string mainRangeMaxTime = "";// Main Range Max Time

#include "rangeParams.mqh";
input string _skip = "===== SKIP FLAG =====";
input bool skipIfLastBarIsTopBottom = false;//Skip if last bar is Top / Bottom

//module to manage exit before time out
#include "exit_before_timeout.mqh"
#include "timeout_method.mqh"
#include "exit_method_after_timeout.mqh"

input int MAGICNUMBER = 88888888;
CTrade            m_trade;                      // trading object
int range; // length to calculate range


int OnInit()
  {
   
   ObjectsDeleteAll(0);
   m_trade.SetExpertMagicNumber(MAGICNUMBER); 
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
   m_trade.SetDeviationInPoints(30);
   
   init_event_data();
   prepareGlobalVarible();
//--- create timer to run every second
   EventSetTimer(1);
   int nSize = ArraySize(news.event);
   Print("News size=",nSize);
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
   ObjectsDeleteAll(0);
   
   
  }

//get breakoutmax datetime  
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
   datetime timespecDay =timespec+PeriodSeconds(PERIOD_D1)*dayField;
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
    //Comment("Waiting working time period.");
    
    //convert time to bar index for specific time 
    int barIndexSpecTime = iBarShift(Symbol(),PERIOD_CURRENT,specTime);
    if(barIndexSpecTime<0) return;
    //get main range
    int _mainRangeMinBar =mainRangeMinBar;
    int _mainRangeMaxBar = mainRangeMaxBar;
    if(_mainRangeMinBar==EMPTYVALUE){
      _mainRangeMinBar= getBarFromTime(mainRangeMinTime,specTime);
      if(EMPTYVALUE ==_mainRangeMinBar) return;
    }
    if(_mainRangeMaxBar==EMPTYVALUE){
      _mainRangeMaxBar= getBarFromTime(mainRangeMaxTime,specTime);
      if(EMPTYVALUE ==_mainRangeMaxBar) return;
    }
    if(barIndexSpecTime<_mainRangeMaxBar+1) return;
    range_main = getRange(barIndexSpecTime,
      _mainRangeMinBar,
      _mainRangeMaxBar,
      hh_mainRange,
      ll_mainRange); 
    string objName = Symbol()+"_"+PERIOD_CURRENT+"_"+specTime+"main";
    if(ObjectFind(0,objName)<0){//draw box
      RectangleCreate(0,objName,0,
         iTime(Symbol(),PERIOD_CURRENT,barIndexSpecTime-_mainRangeMinBar),hh_mainRange,
         iTime(Symbol(),PERIOD_CURRENT,barIndexSpecTime-_mainRangeMaxBar),ll_mainRange);
    }
    if(skipIfLastBarIsTopBottom){
      if(iHigh(Symbol(),PERIOD_CURRENT,barIndexSpecTime-_mainRangeMaxBar)==hh_mainRange ||
         iLow(Symbol(),PERIOD_CURRENT,barIndexSpecTime-_mainRangeMaxBar)==ll_mainRange){
         //Print("skip by skipIfLastBarIsTopBottom");
         return;
      }
    }
    for(int i=0;i<SUBRANGECOUNT;i++){//iterate all sub range

      //get sub range high,low
       double hh_subrange,ll_subrange,range_subrange;
       if(_rangeHIGH[i]==EMPTYVALUE || _rangeLOW[i]==EMPTYVALUE ) continue;
       if(_rangeHIGH[i]<=_rangeLOW[i]) continue;
       
       hh_subrange = ll_mainRange+_rangeHIGH[i]*range_main;
       ll_subrange = ll_mainRange+_rangeLOW[i]*range_main;
       range_subrange = hh_subrange-ll_subrange;
       
       string objName = Symbol()+"_"+PERIOD_CURRENT+"_"+specTime+"submain"+i;
       if(ObjectFind(0,objName)<0){//draw box
         RectangleCreate(0,objName,0,
            iTime(Symbol(),PERIOD_CURRENT,barIndexSpecTime-_mainRangeMinBar),hh_subrange,
            iTime(Symbol(),PERIOD_CURRENT,barIndexSpecTime-_mainRangeMaxBar),ll_subrange,clrBlue,STYLE_DASH,1,true);
       }

      enableGoNow = _goNow[i] ;
      
       //check breakout
       int breakoutPeriodMin=_breakoutPeriodMinBar[i];
       int breakoutPeriodMax=_breakoutPeriodMaxBar[i];
       
       if(breakoutPeriodMin==EMPTYVALUE){
         if(_breakoutPeriodMaxTime[i]!=""){
            breakoutPeriodMin = getBarFromTime(_breakoutPeriodMinTime[i],specTime);
            if(EMPTYVALUE==breakoutPeriodMin && enableGoNow==false) {
               Print("Canceled by NULL",breakoutPeriodMin);
               continue;
            }
         }
       }
       
       datetime breakoutMaxDateTime = getTimeByShift(_breakoutPeriodMaxBar[i],_breakoutPeriodMaxTime[i],specTime);
       

       if(breakoutPeriodMax==EMPTYVALUE){
         if(_breakoutPeriodMaxTime[i]!=""){
            breakoutPeriodMax = getBarFromTime(_breakoutPeriodMaxTime[i],specTime);
         }
       }
       //current bar is over of periodMax 
       if(breakoutPeriodMax>0 && barIndexSpecTime>breakoutPeriodMax  && enableGoNow==false) {
         continue;
       }
       //current bar is before of breakoutPeriodMinBar
       int gonowbar = _mainRangeMaxBar>0?barIndexSpecTime-_mainRangeMaxBar-1:barIndexSpecTime;
       if(enableGoNow==true ){
         if(gonowbar!=0 && barIndexSpecTime<breakoutPeriodMin ) continue;
       }else{
         if(barIndexSpecTime<breakoutPeriodMin ) continue;
       }
       /**
       if((enableGoNow==true && gonowbar!=0 && barIndexSpecTime<breakoutPeriodMin ) ||
       (enableGoNow==false &&  breakoutPeriodMax==EMPTYVALUE && breakoutPeriodMin==EMPTYVALUE && 
       _breakoutPeriodMinTime[i]=="" && _breakoutPeriodMinTime[i]=="")) continue;
       **/
         
       // get range for tp calculate ============================
       int tpMin=_tpRangeMinBar[i];
       int tpMax=_tpRangeMaxBar[i];
       
       if(_tpRangeMinBar[i]==EMPTYVALUE){
         tpMin = getBarFromTime(_tpRangeMinTime[i],specTime);
         if(EMPTYVALUE==tpMin) continue;
       }
       if(_tpRangeMaxBar[i]==EMPTYVALUE){
         tpMax = getBarFromTime(_tpRangeMaxTime[i],specTime);
         if(EMPTYVALUE==tpMax) continue;
       }
       if(barIndexSpecTime<tpMax) continue;
       
       double hhTp,llTp;
       double rangeTP = getRange(barIndexSpecTime,tpMin,tpMax,hhTp,llTp); 
       //set variable for sub range
      entry_mode = _entry_mode[i];
      Additonal_pips_value = _Additonal_pips_value[i];
      No_of_time_breakout_value = _No_of_time_breakout_value[i];
      
      takeProfitRatio =_takeProfitRatio[i];
      TP_SL_METHOD = _TP_SL_METHOD[i];
      stopLossRatio = _stopLossRatio[i];
      StopLossPreviousbars=_StopLossPreviousbars[i];//Stoploss Previous bars
      
      entryAreaMin = _entryAreaMin[i];
      entryAreaMax = _entryAreaMax[i];
      
      noOfFullNextBar = _noOfFullNextBar[i];
      noOfCloseNextBar = _noOfCloseNextBar[i];
      
              
       //process for directinon sub range
       if(_directionSubRange[i]==SUBRANGE_UP){
         buyFilter= true;
         sellFilter = false;  
       }
       if(_directionSubRange[i]==SUBRANGE_DOWN){
         buyFilter= false;
         sellFilter = true;  
       }
       //try to place order
       createOrder(barIndexSpecTime,specTime,hh_subrange,ll_subrange,rangeTP,breakoutPeriodMin,i,breakoutMaxDateTime,gonowbar );
    }
    
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