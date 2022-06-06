enum ENUM_DIRECTION_SUBRANGE {
   SUBRANGE_UP,
   SUBRANGE_DOWN,
   SUBRANGE_NONE,
};
enum ENUM_BREAKOUT_COUTING {
   Max_Count_Bar,
   Max_Count_Time
};



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
   TP__SL_Prev_bars,
   TP_Top_Bottom
   
};