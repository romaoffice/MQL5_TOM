//enum of exit timeout method
enum ENUM_TIMEOUT_METHOD {
   NO_Of_BAR_AFTER_EVENT,
   NO_OF_BAR_AFTER_ORDER_MADE,
   DEFINED_DATE_TIME,
   NONE_TIMEOUT_METHOD
};

input string timeoutMethodParams = "====== TIMEOUT METHOD =====";
input ENUM_TIMEOUT_METHOD  timeout_method = NO_Of_BAR_AFTER_EVENT;
input int no_of_Bar_after_Event_lauched_value = 10;
input int no_of_Bar_after_Order_Made_value = 10;
input datetime defined_date_time = D'2022.01.26 00:00:00';

//get date time for last order placed
datetime getLastOrderTime(){
   datetime last=0;
   int total=PositionsTotal(); // number of open positions   
   //--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      //--- parameters of the order
      string position_symbol=PositionGetString(POSITION_SYMBOL);                      // symbol 
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
      datetime  ordertime=PositionGetInteger(POSITION_TIME);                          // open time
      

      //--- check MagicNumber matches
      if(magic==MAGICNUMBER && position_symbol==Symbol())
        {
         if(ordertime>last) last = ordertime;
        }
     }
   return(last);
}
bool isTimeOut(){
   
   bool result = false;
   datetime lastorder = getLastOrderTime();
   if(lastorder ==0) return false;
   int orderIndex;
   //if(lastSpecificTime!=NULL && )
   switch(timeout_method){

      case NO_Of_BAR_AFTER_EVENT:
         result = lastSpecificTime!=NULL && iBarShift(Symbol(),PERIOD_CURRENT,lastSpecificTime)>no_of_Bar_after_Event_lauched_value;
         break;

      case NO_OF_BAR_AFTER_ORDER_MADE:
         orderIndex = iBarShift(Symbol(),PERIOD_CURRENT,lastorder);
         result = orderIndex>no_of_Bar_after_Order_Made_value;
         break;

      case DEFINED_DATE_TIME:
         result = TimeCurrent()>defined_date_time;
         break;
   }

   return(result);
}