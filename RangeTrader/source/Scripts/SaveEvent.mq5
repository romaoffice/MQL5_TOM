//+------------------------------------------------------------------+
//|                                                    SaveEvent.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
input int event_id = 840030016;
input datetime dateFrom = D'2020.01.01';
input datetime dateTo = D'2023.01.01';
input string folderTimeTrader = "TimeTrader";
#import "kernel32.dll"
   int CopyFileW(string strExistingFile, string strCopyOfFile, int OverwriteIfCopyAlreadyExists);
   int GetLastError();
#import
int srv_distance_from_gmt() {return MathRound( (double)(TimeCurrent()-TimeGMT()) /60); }//result is distance from GMT & minutes
#define SW_SHOWNORMAL       1
string filename = "eventdata.mqh";
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
bool MyFileCopy()
{

    string strFrom = TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+filename;
    string strTo =TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Experts\\";
    if(folderTimeTrader!=""){
      strTo = strTo+folderTimeTrader+"\\";
    }
    strTo  = strTo  + filename;
    int rt = CopyFileW(strFrom, strTo,0);
    Print("==========",rt);
    return (rt>0);
   
}

bool write_event(MqlCalendarValue&  values[]){
   string cnt="   struct  MyEventStruct "
      "{"
      "   long     actual_value;"
      "   long     prev_value;"
      "   long     forecast_value;"
      "   datetime     time;"
      "   long     event_id;"
      "};\r\n";
   cnt = cnt+"int gmtoffset_org = "+srv_distance_from_gmt()+";\r\n";
   cnt = cnt+"MyEventStruct eventdata["+ArraySize(values)+"];\r\n";
   cnt = cnt+"void init_event_data(){\r\n";
   for(int i = 0;i<ArraySize(values);i++){
      cnt = cnt+"eventdata["+i+"].actual_value="+values[i].actual_value+";\r\n";
      cnt = cnt+"eventdata["+i+"].prev_value="+values[i].prev_value+";\r\n";
      cnt = cnt+"eventdata["+i+"].forecast_value="+values[i].forecast_value+";\r\n";
      cnt = cnt+"eventdata["+i+"].time=D'"+TimeToString(values[i].time)+"';\r\n";
      cnt = cnt+"eventdata["+i+"].event_id="+event_id+";\r\n";
      cnt = cnt+"\r\n";
   }
   cnt = cnt+"}\r\n";
   
   int handle = FileOpen(filename,FILE_WRITE|FILE_TXT);
   uint rt = FileWriteString(handle,cnt,StringLen(cnt));
   FileClose(handle);
   return (rt>0);
      
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   MqlCalendarValue eventdata[];
   bool rt = CalendarValueHistoryByEvent(event_id,eventdata,dateFrom,dateTo);
   if(rt==false){
      Alert("Fail to get news event . please check network connection");
      Comment("Fail to get news event . please check network connection");
      return;
   }
   if(ArraySize(eventdata)==0){
      Alert("There are not new event for "+event_id);
      Comment("There are not new event for "+event_id);
      return;
   }
   Alert("Success get events for "+event_id);
   string result = "";
   result = "Success get events for "+event_id+"\r\n";
   if(write_event(eventdata)==false){
      Alert("Fail to generate event data file");
      Comment("Fail to generate event data file");
      return;
   };
   if(MyFileCopy()==false){
      Alert("Fail to copy event data file. Please check you are running with administrator right.");
      Comment("Fail to copy event data file. Please check you are running with administrator right.");
      return;
   }
   Alert("Success to prepare news data for "+event_id);
   Alert("Please compile timetrader again.");
   Comment("Success to prepare news data for "+event_id);
         
  }
//+------------------------------------------------------------------+
