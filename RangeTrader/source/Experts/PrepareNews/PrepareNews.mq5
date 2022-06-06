#include "news.mqh";


//new data to use in tester
CNews news;

//+------------------------------------------------------------------+ 
//| Expert initialization function                                   | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- create timer 
   int nSize = ArraySize(news.event);
   Comment("Updating news files "+nSize );

   news.update();
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
//+------------------------------------------------------------------+ 
//| Expert tick function                                             | 
//+------------------------------------------------------------------+ 
void OnTick() 
  { 
//--- 
  
  } 
//+------------------------------------------------------------------+ 
//| Timer function                                                   | 
//+------------------------------------------------------------------+ 
void OnTimer() 
  {   
      Comment("Ready.");
      news.update();
      int nSize = ArraySize(news.event);
      if (nSize>0){
         Comment("News ready.",nSize,"items from ",news.event[0].time);
      }else{
         Comment("Waiting prepare news.");
      }
      
  } 
