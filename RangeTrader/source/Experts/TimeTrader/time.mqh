//module for manage specific time

//enum of time mode
enum ENUM_TIME_MODE {
   TIME_MODE,
   DATE_TIME_MODE,
   CALENDAR_EVENT_MODE
};

//enum of compare value selection
enum ENUM_COMPARE_VALUE_SELECTION {
   FORCASTED_VALUE,
   PREVIOUS_VALUE
};

//enum of compare value direction
enum ENUM_COMPARE_VALUE_DIRECTION {
   ACTUAL_VALUE_HIGHER_THEN_BUY,
   ACTUAL_VALUE_HIGHER_THEN_SELL,
   NO_NEED_COMPARE_EXECUTE_BREAKOUT_DIRECTION
};
enum BACKTESTMODE {
   Local,
   Cloud
};
int srv_distance_from_gmt() {return MathRound( (double)(TimeCurrent()-TimeGMT()) /60); }//result is distance from GMT & minutes

input string timemodeTraindg = "===== TIME MODE TRADING =====";
input BACKTESTMODE backtestMode = Cloud;
bool localMode = backtestMode == Local;//Backtest is localmode or cloud mode
input ENUM_TIME_MODE timeMode = CALENDAR_EVENT_MODE;
input string startTime ="8:00";//Specific Time
input string  eventIds = "840030016";//event id list from MQL5 calendar
input ENUM_COMPARE_VALUE_SELECTION compare_mode = FORCASTED_VALUE;
input ENUM_COMPARE_VALUE_DIRECTION compare_direction = ACTUAL_VALUE_HIGHER_THEN_BUY;

string startTimeList[];
string eventIdList[];
ulong  eventValueId;
bool buyFilter; // Buy filter for new time
bool sellFilter;// Sell filter for new time
datetime lastSpecificTime=NULL;// last invalid specific time


#include "eventdata.mqh";
//convert summertime
datetime actualTime(datetime servertime)
  {
  datetime rt =servertime;//+TimeDaylightSavings();
     
   if(MQLInfoInteger(MQL_TESTER)){
      Print("Converting time");
      MqlDateTime tm;
      TimeToStruct(servertime,tm);
      // make a rough guess
      bool summertime=true;
      if (tm.mon<=2 || (tm.mon==3 && tm.day<=7)) {summertime=false;}
      if ((tm.mon==11 && tm.day>=8) || tm.mon==12) {summertime=false;}
      
      if(tm.mon==3 && summertime==false){//check second sundday of march
         datetime march1 =StringToTime(tm.year+"."+tm.mon+".1");
         int countSunday = 0;
         for(datetime mtm = march1;mtm<=march1+tm.day*3600*24;mtm=mtm+3600*24){
            MqlDateTime tmTemp;
            TimeToStruct(mtm,tmTemp);
            if(tmTemp.day_of_week==0) countSunday++;
            if(countSunday==2) {
               summertime = true;
               break;
            }
         }
      }
      if(tm.mon==11 && summertime){//check first sunday of november
         datetime nov1 =StringToTime(tm.year+"."+tm.mon+".1");
         int countSunday = 0;
         for(datetime mtm = nov1;mtm<=nov1+tm.day*3600*24;mtm=mtm+3600*24){
            MqlDateTime tmTemp;
            TimeToStruct(mtm,tmTemp);
            //Print(tmTemp.day_of_week,tmTemp.day,",",tmTemp.mon,",",tmTemp.year);
            if(tmTemp.day_of_week==0) countSunday++;
            if(countSunday==1) {
               summertime = false;
               break;
            }
         }
      }
      Print("Summer time",summertime);
      
      if (summertime){rt =servertime;}
      else {rt = servertime-3600;};
    }else{
      rt = servertime;
    }
   Print(servertime,",",rt);
   
   
   return(rt);
  }



bool customeCalendarValueHistoryByEvent(ulong eventId, MyEventStruct& value, datetime date_from, datetime date_to){
   if (MQLInfoInteger(MQL_TESTER)){
      if(localMode){
         //apply half search method to speed up search 100000 history items;
         int upper = ArraySize(news.event)-1;
         int lower = 0;
         while(upper-lower>100){
            int halfIndex = (upper+lower)/2;
            if(news.event[halfIndex].time>=date_from){
               upper = halfIndex;
            }else{
               lower = halfIndex;
            }
         }
         //find all matched event values
         for(int i=lower;i<ArraySize(news.event);i++){
            if(news.event[i].time>date_from && news.event[i].time<date_to){
               if(news.event[i].event_id==eventId){
                  value.actual_value = news.event[i].actual_value;
                  value.prev_value = news.event[i].prev_value;
                  value.forecast_value = news.event[i].forecast_value;
                  value.time = news.event[i].time;
                  return(true);
               }
            }
         }
         
      }else{
         for(int i=0;i<ArraySize(eventdata);i++){
            datetime eventtime = eventdata[i].time;
            eventtime = eventtime+(gmtoffset_org-srv_distance_from_gmt());
            if(eventtime>date_from && eventtime<date_to){
               if(eventdata[i].event_id==eventId){
                  if(9223372036854775808!=eventdata[i].actual_value){
                     value.actual_value = eventdata[i].actual_value;
                     value.prev_value = eventdata[i].prev_value;
                     value.forecast_value = eventdata[i].forecast_value;
                     value.time = eventtime;
                     return(true);
                  }

               }
            }
         }
      }

      return (false);
   }else{
      MqlCalendarValue values[];
      bool rt = ::CalendarValueHistoryByEvent(eventId, values, date_from, date_to);
      if(rt){
         if(ArraySize(values)==0){
            rt = false;
         }else{
            value.actual_value = values[0].actual_value;
            value.prev_value = values[0].prev_value;
            value.forecast_value = values[0].forecast_value;
            value.time = values[0].time;
         }
      }
      return(rt);
   }
}
//get specific time for today
//if dont have specific time yet for today , return null
datetime getSpecificTime(){
    
    MqlDateTime today;
    TimeCurrent(today);
    
    //check it need to get specific time again for today
    // if we check NEWS continue , it will have may traffic
    // So if we got news release already, we dont need check new today
    if(lastSpecificTime){
      MqlDateTime last;
      TimeToStruct(lastSpecificTime,last);
      if(last.year == today.year && last.mon==today.mon && last.day == today.day){//dont need check again
         return(lastSpecificTime);
      }
    }

    string sep=";";                // A separator as a character
    ushort u_sep;                  // The code of the separator character
    int k,nSize;
    string specTimeString;
    ulong eventId;
    switch(timeMode){
      case TIME_MODE:
         specTimeString = today.year+"."+today.mon+"."+today.day+" "+startTime;
         buyFilter = true;
         sellFilter = true;
         break;
      case DATE_TIME_MODE:
         buyFilter = true;
         sellFilter = true;

         //--- Get the separator code
         u_sep=StringGetCharacter(sep,0);
         //--- Split the string to substrings
         k=StringSplit(startTime,u_sep,startTimeList);
      
         specTimeString = startTimeList[0];
         nSize = ArraySize(startTimeList);
         //find matched trading time
         for(int i=0;i<nSize;i++){
            datetime itemTime = StringToTime(startTimeList[i]);
            MqlDateTime mqlItemTime;
            TimeToStruct(itemTime,mqlItemTime);
            if(mqlItemTime.year == today.year && mqlItemTime.mon==today.mon && mqlItemTime.day==today.day){
               //got matched date
               specTimeString = startTimeList[i];
               break;
            }
         }
         break;

      case CALENDAR_EVENT_MODE:
         //--- Get the separator code
         u_sep=StringGetCharacter(sep,0);
         //--- Split the string to substrings
         k=StringSplit(eventIds,u_sep,eventIdList);
         nSize = ArraySize(eventIdList);
         //find matched event for today
         for(int i=0;i<nSize;i++){
            ulong eventId = (ulong)eventIdList[i];
            MyEventStruct eventValue;
            datetime date_from, date_to;
            //need get nearest time
            date_from = StringToTime(today.year+"."+today.mon+"."+today.day);
            date_to = date_from + PeriodSeconds(PERIOD_D1);
            if(customeCalendarValueHistoryByEvent(eventId, eventValue, date_from, date_to))
            {
               
               buyFilter = false;
               sellFilter = false;
               //check released new ?
               if (eventValue.actual_value!=LONG_MIN){//released news
                  
                  long actualValue = eventValue.actual_value;
                  long compareValue = eventValue.forecast_value;
                  if(compare_mode == PREVIOUS_VALUE) compareValue = eventValue.prev_value;
                  if(compare_direction==ACTUAL_VALUE_HIGHER_THEN_BUY){
                     buyFilter = actualValue>compareValue;
                     sellFilter = actualValue<compareValue;
                  }else if(compare_direction==ACTUAL_VALUE_HIGHER_THEN_SELL) {
                     buyFilter = actualValue<compareValue;
                     sellFilter = actualValue>compareValue;
                  }else{//NO_NEED_COMPARE_EXECUTE_BREAKOUT_DIRECTION, trade with break out just
                     buyFilter = true;
                     sellFilter = true;
                  }
                  lastSpecificTime = actualTime(eventValue.time);
                  specTimeString = lastSpecificTime ;
                  Print("Found news",eventId,",",date_from, ",",lastSpecificTime," buy filter ",buyFilter," sell filter ",sellFilter);
                  return(lastSpecificTime);     
               }
            }
         }    
         
         //dont have matched news today
         return NULL;
         break;
      
    }
    
    datetime specTime = StringToTime(specTimeString);
    lastSpecificTime = specTime;
    return(specTime);
}