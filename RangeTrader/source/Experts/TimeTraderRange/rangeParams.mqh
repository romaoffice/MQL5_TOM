#define SUBRANGECOUNT 4

double _rangeHIGH[SUBRANGECOUNT];
double _rangeLOW[SUBRANGECOUNT];
bool _goNow[SUBRANGECOUNT];// Go NOW For RANGE A
int _breakoutPeriodMinBar[SUBRANGECOUNT];
int _breakoutPeriodMaxBar[SUBRANGECOUNT];
string _breakoutPeriodMinTime[SUBRANGECOUNT];
string _breakoutPeriodMaxTime[SUBRANGECOUNT];
ENUM_ENTRY_MODE _entry_mode[SUBRANGECOUNT];
int _Additonal_pips_value[SUBRANGECOUNT];
int _No_of_time_breakout_value[SUBRANGECOUNT];
int _tpRangeMinBar[SUBRANGECOUNT];
int _tpRangeMaxBar[SUBRANGECOUNT];
string _tpRangeMinTime[SUBRANGECOUNT];
string _tpRangeMaxTime[SUBRANGECOUNT];
double _takeProfitRatio[SUBRANGECOUNT];
ENUM_STOPLOSS_METHOD _TP_SL_METHOD[SUBRANGECOUNT];
double _stopLossRatio[SUBRANGECOUNT];
int _StopLossPreviousbars[SUBRANGECOUNT];
double _entryAreaMin[SUBRANGECOUNT];
double _entryAreaMax[SUBRANGECOUNT];
int _noOfFullNextBar[SUBRANGECOUNT];
int _noOfCloseNextBar[SUBRANGECOUNT];
ENUM_DIRECTION_SUBRANGE  _directionSubRange[SUBRANGECOUNT];

input string _BATCH = "----- Batch settings -----";
input int breakoutPeriodMinforspecific=88888888;//Breakout Period Min for specific
input int breakoutPeriodMaxforspecific=88888888;//Breakout Period Max for specific
input string breakoutPeriodSubRange="AB";//Breakout Period Sub Range 
input int tpRangeMinforspecific=88888888;//TP Range Min for specific
input int tpRangeMaxforspecific=88888888;//TP Range Max for specific
input string tpRangeSubRange="AB";//TP Range  Sub Range 
input double takeprofitRationforspecific=88888888;//Takeprofit Ration for specific
input double stoplossRationforspecific=88888888;//STOP LOSS Ration for specific
input string TPSLRationSubrange="AB";//TP/SL Ration Sub-range
input double entryAreaMinforspecific=88888888;//Entry Area Min for specific
input double entryAreaMaxforspecific=88888888;//Entry Area Max for specific
input string EntryAreaSubrange="AB";//Entry Area Sub-range
input string _SUBRANGEA = "----- SUB RANGE A -----";
input double rangeHIGHA =1;
input double rangeLOWA =0.618;
input bool goNowA = false;// Go NOW For RANGE A
input int breakoutPeriodMinBarA = 2;//Breakout Period Min for RANGE A
input int breakoutPeriodMaxBarA = 5;//Breakout Period Max for RANGE A
input string breakoutPeriodMinTimeA = "";// Breakout Period Min Time for RANGE A
input string breakoutPeriodMaxTimeA = "";// Breakout Period Max Time for RANGE A
input ENUM_ENTRY_MODE entry_modeA = Market_Price_Entry;//Entry Mode for RANGE A
input int Additonal_pips_valueA = 3;//Additonal pips value for entry
input int No_of_time_breakout_valueA = 2; // No. of time breakout value
input int noOfFullNextBarA = 0; //No. of full next bar for RANGE A
input int noOfCloseNextBarA = 0; //No. of close next bar for RANGE A
input string _tpslA = "-----------------------------------";
input int tpRangeMinBarA = -10;//TP Range Min Bar for RANGE A
input int tpRangeMaxBarA = -2;//TP Range Max Bar for RANGE A
input string tpRangeMinTimeA = "0 10:00:00";// TP Range Min Time for RANGE A
input string TpRangeMaxTimeA = "0 18:00:00";// TP Range Max Time for RANGE A
input double takeProfitRatioA = 0.5;//Takeprofit Ration for RANGE A
input ENUM_STOPLOSS_METHOD TP_SL_METHODA = TP__SL_Range_Ration;// STOP LOSS METHOD for RANGE A
input double stopLossRatioA = 1;//Stoploss Ration for RANGE A
input int StopLossPreviousbarsA=2;//Stoploss Previous bars for RANGE A
input string _entryAreaA = "-----------------------------------";
input double entryAreaMinA=88888888;//Entry Area Min for RANGE A
input double entryAreaMaxA=88888888;//Entry Area Max for RANGE A
input ENUM_DIRECTION_SUBRANGE  directionSubRangeA= SUBRANGE_NONE;//Direction - SUB RANGE A


input string _SUBRANGEB = "----- SUB RANGE B -----";
input double rangeHIGHB =88888888;
input double rangeLOWB =88888888;
input bool goNowB = false;// Go NOW For RANGE B
input int breakoutPeriodMinBarB = 2;//Breakout Period Min for RANGE B
input int breakoutPeriodMaxBarB = 5;//Breakout Period Max for RANGE B
input string breakoutPeriodMinTimeB = "";// Breakout Period Min Time for RANGE B
input string breakoutPeriodMaxTimeB = "";// Breakout Period Max Time for RANGE B
input ENUM_ENTRY_MODE entry_modeB = Market_Price_Entry;//Entry Mode for RANGE B
input int Additonal_pips_valueB = 3;//Additonal pips value for entry for RANGE B
input int No_of_time_breakout_valueB = 2; // No. of time breakout value for RANGE B
input int noOfFullNextBarB = 2; //No. of full next bar for RANGE B
input int noOfCloseNextBarB = 2; //No. of close next bar for RANGE B

input string _tpslB = "-----------------------------------";
input int tpRangeMinBarB = -5;//TP Range Min Bar for RANGE B
input int tpRangeMaxBarB = -2;//TP Range Max Bar for RANGE B
input string tpRangeMinTimeB = "0 10:00:00";// TP Range Min Time for RANGE B
input string TpRangeMaxTimeB = "0 18:00:00";// TP Range Max Time for RANGE B
input double takeProfitRatioB = 0.5;//Takeprofit Ration for RANGE B
input ENUM_STOPLOSS_METHOD TP_SL_METHODB = TP__SL_Range_Ration;// STOP LOSS METHOD for RANGE B
input double stopLossRatioB = 1;//Stoploss Ration for RANGE B
input int StopLossPreviousbarsB=2;//Stoploss Previous bars for RANGE B
input string _entryAreaB = "-----------------------------------";
input double entryAreaMinB=1.382;//Entry Area Min for RANGE B
input double entryAreaMaxB=1.5;//Entry Area Max for RANGE B
input ENUM_DIRECTION_SUBRANGE  directionSubRangeB= SUBRANGE_NONE;//Direction - SUB RANGE B


input string _SUBRANGEC = "----- SUB RANGE C -----";
input double rangeHIGHC =88888888;
input double rangeLOWC =88888888;
input bool goNowC = false;// Go NOW For RANGE C
input int breakoutPeriodMinBarC = 2;//Breakout Period Min for RANGE C
input int breakoutPeriodMaxBarC = 5;//Breakout Period Max for RANGE C
input string breakoutPeriodMinTimeC = "";// Breakout Period Min Time for RANGE C
input string breakoutPeriodMaxTimeC = "";// Breakout Period Max Time for RANGE C
input ENUM_ENTRY_MODE entry_modeC = Market_Price_Entry;//Entry Mode for RANGE C
input int Additonal_pips_valueC = 3;//Additonal pips value for entry for RANGE C
input int No_of_time_breakout_valueC = 2; // No. of time breakout value
input int noOfFullNextBarC = 2; //No. of full next bar for RANGE C
input int noOfCloseNextBarC = 2; //No. of close next bar for RANGE C

input string _tpslC = "-----------------------------------";
input int tpRangeMinBarC = -5;//TP Range Min Bar for RANGE C
input int tpRangeMaxBarC = -2;//TP Range Max Bar for RANGE C
input string tpRangeMinTimeC = "0 10:00:00";// TP Range Min Time for RANGE C
input string TpRangeMaxTimeC = "0 18:00:00";// TP Range Max Time for RANGE C
input double takeProfitRatioC = 0.5;//Takeprofit Ration for RANGE C
input ENUM_STOPLOSS_METHOD TP_SL_METHODC = TP__SL_Range_Ration;// STOP LOSS METHOD for RANGE C
input double stopLossRatioC = 1;//Stoploss Ration for RANGE C
input int StopLossPreviousbarsC=2;//Stoploss Previous bars for RANGE C
input string _entryAreaC = "-----------------------------------";
input double entryAreaMinC=1.382;//Entry Area Min for RANGE C
input double entryAreaMaxC=1.5;//Entry Area Max for RANGE C
input ENUM_DIRECTION_SUBRANGE  directionSubRangeC= SUBRANGE_NONE;//Direction - SUB RANGE C

input string _SUBRANGED = "----- SUB RANGE D -----";
input double rangeHIGHD =88888888;
input double rangeLOWD =88888888;
input bool goNowD = false;// Go NOW For RANGE D
input int breakoutPeriodMinBarD = 2;//Breakout Period Min for RANGE D
input int breakoutPeriodMaxBarD = 5;//Breakout Period Max for RANGE D
input string breakoutPeriodMinTimeD = "";// Breakout Period Min Time for RANGE D
input string breakoutPeriodMaxTimeD = "";// Breakout Period Max Time for RANGE D
input ENUM_ENTRY_MODE entry_modeD = Market_Price_Entry;//Entry Mode for RANGE D
input int Additonal_pips_valueD = 3;//Additonal pips value for entry
input int No_of_time_breakout_valueD = 2; // No. of time breakout value
input int noOfFullNextBarD = 0; //No. of full next bar for RANGE D
input int noOfCloseNextBarD = 0; //No. of close next bar for RANGE D
input string _tpslD = "-----------------------------------";
input int tpRangeMinBarD = -5;//TP Range Min Bar for RANGE D
input int tpRangeMaxBarD = -2;//TP Range Max Bar for RANGE D
input string tpRangeMinTimeD = "0 10:00:00";// TP Range Min Time for RANGE D
input string TpRangeMaxTimeD = "0 18:00:00";// TP Range Max Time for RANGE D
input double takeProfitRatioD = 0.5;//Takeprofit Ration for RANGE D
input ENUM_STOPLOSS_METHOD TP_SL_METHODD = TP__SL_Range_Ration;// STOP LOSS METHOD for RANGE D
input double stopLossRatioD = 1;//Stoploss Ration for RANGE D
input int StopLossPreviousbarsD=2;//Stoploss Previous bars for RANGE D
input string _entryAreaD = "-----------------------------------";
input double entryAreaMinD=1.382;//Entry Area Min for RANGE D
input double entryAreaMaxD=1.5;//Entry Area Max for RANGE D
input ENUM_DIRECTION_SUBRANGE  directionSubRangeD= SUBRANGE_NONE;//Direction - SUB RANGE D

int getSubIndex(string sub){
   if(sub=="A") return 0;
   if(sub=="B") return 1;
   if(sub=="C") return 2;
   if(sub=="D") return 3;
   return(-1);
   
}
void prepareGlobalVarible(){
   
   int index = 0;
   _rangeHIGH[index] = rangeHIGHA;
   _rangeLOW[index] = rangeLOWA;
   _goNow[index] = goNowA;// Go NOW For RANGE A
   _breakoutPeriodMinBar[index]=breakoutPeriodMinBarA;
   _breakoutPeriodMaxBar[index]=breakoutPeriodMaxBarA;
   _breakoutPeriodMinTime[index]=breakoutPeriodMinTimeA;
   _breakoutPeriodMaxTime[index]=breakoutPeriodMaxTimeA;
   _entry_mode[index]= entry_modeA;
   _Additonal_pips_value[index] = Additonal_pips_valueA;
   _No_of_time_breakout_value[index] = No_of_time_breakout_valueA;
   _tpRangeMinBar[index] = tpRangeMinBarA;
   _tpRangeMaxBar[index] = tpRangeMaxBarA;
   _tpRangeMinTime[index] = tpRangeMinTimeA;
   _tpRangeMaxTime[index] = TpRangeMaxTimeA;
   _takeProfitRatio[index] = takeProfitRatioA;
   _TP_SL_METHOD[index] = TP_SL_METHODA;
   _stopLossRatio[index] = stopLossRatioA;
   _StopLossPreviousbars[index]=StopLossPreviousbarsA;
   _entryAreaMin[index] = entryAreaMinA;
   _entryAreaMax[index]=entryAreaMaxA;
   _noOfFullNextBar[index]=noOfFullNextBarA;
   _noOfCloseNextBar[index]=noOfCloseNextBarA;
   _directionSubRange[index] =directionSubRangeA;
   
   index = 1;
   _rangeHIGH[index] = rangeHIGHB;
   _rangeLOW[index] = rangeLOWB;
   _goNow[index] = goNowB;// Go NOW For RANGE A
   _breakoutPeriodMinBar[index]=breakoutPeriodMinBarB;
   _breakoutPeriodMaxBar[index]=breakoutPeriodMaxBarB;
   _breakoutPeriodMinTime[index]=breakoutPeriodMinTimeB;
   _breakoutPeriodMaxTime[index]=breakoutPeriodMaxTimeB;
   _entry_mode[index]= entry_modeB;
   _Additonal_pips_value[index] = Additonal_pips_valueB;
   _No_of_time_breakout_value[index] = No_of_time_breakout_valueB;
   _tpRangeMinBar[index] = tpRangeMinBarB;
   _tpRangeMaxBar[index] = tpRangeMaxBarB;
   _tpRangeMinTime[index] = tpRangeMinTimeB;
   _tpRangeMaxTime[index] = TpRangeMaxTimeB;
   _takeProfitRatio[index] = takeProfitRatioB;
   _TP_SL_METHOD[index] = TP_SL_METHODB;
   _stopLossRatio[index] = stopLossRatioB;
   _StopLossPreviousbars[index]=StopLossPreviousbarsB;
   _entryAreaMin[index] = entryAreaMinB;
   _entryAreaMax[index]=entryAreaMaxB;
   _noOfFullNextBar[index]=noOfFullNextBarB;
   _noOfCloseNextBar[index]=noOfCloseNextBarB;
   _directionSubRange[index] =directionSubRangeB;
   
   index = 2;
   _rangeHIGH[index] = rangeHIGHC;
   _rangeLOW[index] = rangeLOWC;
   _goNow[index] = goNowC;// Go NOW For RANGE A
   _breakoutPeriodMinBar[index]=breakoutPeriodMinBarC;
   _breakoutPeriodMaxBar[index]=breakoutPeriodMaxBarC;
   _breakoutPeriodMinTime[index]=breakoutPeriodMinTimeC;
   _breakoutPeriodMaxTime[index]=breakoutPeriodMaxTimeC;
   _entry_mode[index]= entry_modeC;
   _Additonal_pips_value[index] = Additonal_pips_valueC;
   _No_of_time_breakout_value[index] = No_of_time_breakout_valueC;
   _tpRangeMinBar[index] = tpRangeMinBarC;
   _tpRangeMaxBar[index] = tpRangeMaxBarC;
   _tpRangeMinTime[index] = tpRangeMinTimeC;
   _tpRangeMaxTime[index] = TpRangeMaxTimeC;
   _takeProfitRatio[index] = takeProfitRatioC;
   _TP_SL_METHOD[index] = TP_SL_METHODC;
   _stopLossRatio[index] = stopLossRatioC;
   _StopLossPreviousbars[index]=StopLossPreviousbarsC;
   _entryAreaMin[index] = entryAreaMinC;
   _entryAreaMax[index]=entryAreaMaxC;
   _noOfFullNextBar[index]=noOfFullNextBarC;
   _noOfCloseNextBar[index]=noOfCloseNextBarC;
   _directionSubRange[index] =directionSubRangeC;
   index = 3;
   _rangeHIGH[index] = rangeHIGHD;
   _rangeLOW[index] = rangeLOWD;
   _goNow[index] = goNowD;// Go NOW For RANGE A
   _breakoutPeriodMinBar[index]=breakoutPeriodMinBarD;
   _breakoutPeriodMaxBar[index]=breakoutPeriodMaxBarD;
   _breakoutPeriodMinTime[index]=breakoutPeriodMinTimeD;
   _breakoutPeriodMaxTime[index]=breakoutPeriodMaxTimeD;
   _entry_mode[index]= entry_modeD;
   _Additonal_pips_value[index] = Additonal_pips_valueD;
   _No_of_time_breakout_value[index] = No_of_time_breakout_valueD;
   _tpRangeMinBar[index] = tpRangeMinBarD;
   _tpRangeMaxBar[index] = tpRangeMaxBarD;
   _tpRangeMinTime[index] = tpRangeMinTimeD;
   _tpRangeMaxTime[index] = TpRangeMaxTimeD;
   _takeProfitRatio[index] = takeProfitRatioD;
   _TP_SL_METHOD[index] = TP_SL_METHODD;
   _stopLossRatio[index] = stopLossRatioD;
   _StopLossPreviousbars[index]=StopLossPreviousbarsD;
   _entryAreaMin[index] = entryAreaMinD;
   _entryAreaMax[index]=entryAreaMaxD;
   _noOfFullNextBar[index]=noOfFullNextBarD;
   _noOfCloseNextBar[index]=noOfCloseNextBarD;
   _directionSubRange[index] =directionSubRangeD;    
   
   for(int i=0;i<StringLen(breakoutPeriodSubRange);i++){
      string sub = StringSubstr(breakoutPeriodSubRange,i,1);
      StringToUpper(sub);
      int index = getSubIndex(sub);
      if(breakoutPeriodMinforspecific!=EMPTYVALUE){
         _breakoutPeriodMinBar[index]=breakoutPeriodMinforspecific;
      }
      if(breakoutPeriodMaxforspecific!=EMPTYVALUE){
         _breakoutPeriodMaxBar[index]=breakoutPeriodMaxforspecific;
      }
   }

   for(int i=0;i<StringLen(tpRangeSubRange);i++){
      string sub = StringSubstr(tpRangeSubRange,i,1);
      StringToUpper(sub);
      int index = getSubIndex(sub);
      if(tpRangeMinforspecific!=EMPTYVALUE){
         _tpRangeMinBar[index]=tpRangeMinforspecific;
      }
      if(tpRangeMaxforspecific!=EMPTYVALUE){
         _tpRangeMaxBar[index]=tpRangeMaxforspecific;
      }
   }


   for(int i=0;i<StringLen(TPSLRationSubrange);i++){
      string sub = StringSubstr(TPSLRationSubrange,i,1);
      StringToUpper(sub);
      int index = getSubIndex(sub);
      if(takeprofitRationforspecific!=EMPTYVALUE){
         _takeProfitRatio[index]=takeprofitRationforspecific;
      }
      if(stoplossRationforspecific!=EMPTYVALUE){
         _stopLossRatio[index]=stoplossRationforspecific;
      }
   }

   for(int i=0;i<StringLen(EntryAreaSubrange);i++){
      string sub = StringSubstr(EntryAreaSubrange,i,1);
      StringToUpper(sub);
      int index = getSubIndex(sub);
      if(entryAreaMinforspecific!=EMPTYVALUE){
         _entryAreaMin[index]=entryAreaMinforspecific;
      }
      if(entryAreaMaxforspecific!=EMPTYVALUE){
         _entryAreaMax[index]=entryAreaMaxforspecific;
      }
   }


}