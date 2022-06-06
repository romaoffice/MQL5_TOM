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

bool isTimeOut(){
   
   bool result = false;
   int orderIndex;
   datetime lastorder = GlobalVariableGet(Symbol()+PERIOD_CURRENT+"lastorder"+MAGICNUMBER);
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