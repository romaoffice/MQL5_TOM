   struct  MyEventStruct {   long     actual_value;   long     prev_value;   long     forecast_value;   datetime     time;   long     event_id;};
int gmtoffset_org = 180;
MyEventStruct eventdata[36];
void init_event_data(){
eventdata[0].actual_value=202000000;
eventdata[0].prev_value=67000000;
eventdata[0].forecast_value=125000000;
eventdata[0].time=D'2020.01.08 16:15';
eventdata[0].event_id=840190001;

eventdata[1].actual_value=291000000;
eventdata[1].prev_value=202000000;
eventdata[1].forecast_value=125000000;
eventdata[1].time=D'2020.02.05 16:15';
eventdata[1].event_id=840190001;

eventdata[2].actual_value=183000000;
eventdata[2].prev_value=291000000;
eventdata[2].forecast_value=174000000;
eventdata[2].time=D'2020.03.04 16:15';
eventdata[2].event_id=840190001;

eventdata[3].actual_value=-27000000;
eventdata[3].prev_value=183000000;
eventdata[3].forecast_value=216000000;
eventdata[3].time=D'2020.04.01 15:15';
eventdata[3].event_id=840190001;

eventdata[4].actual_value=-20236000000;
eventdata[4].prev_value=-27000000;
eventdata[4].forecast_value=167000000;
eventdata[4].time=D'2020.05.06 15:15';
eventdata[4].event_id=840190001;

eventdata[5].actual_value=-2760000000;
eventdata[5].prev_value=-20236000000;
eventdata[5].forecast_value=-9000000000;
eventdata[5].time=D'2020.06.03 15:15';
eventdata[5].event_id=840190001;

eventdata[6].actual_value=2369000000;
eventdata[6].prev_value=-2760000000;
eventdata[6].forecast_value=-12515000000;
eventdata[6].time=D'2020.07.01 15:15';
eventdata[6].event_id=840190001;

eventdata[7].actual_value=167000000;
eventdata[7].prev_value=2369000000;
eventdata[7].forecast_value=2246000000;
eventdata[7].time=D'2020.08.05 15:15';
eventdata[7].event_id=840190001;

eventdata[8].actual_value=428000000;
eventdata[8].prev_value=167000000;
eventdata[8].forecast_value=58274000000;
eventdata[8].time=D'2020.09.02 15:15';
eventdata[8].event_id=840190001;

eventdata[9].actual_value=749000000;
eventdata[9].prev_value=428000000;
eventdata[9].forecast_value=59138000000;
eventdata[9].time=D'2020.09.30 15:15';
eventdata[9].event_id=840190001;

eventdata[10].actual_value=365000000;
eventdata[10].prev_value=749000000;
eventdata[10].forecast_value=576000000;
eventdata[10].time=D'2020.11.04 16:15';
eventdata[10].event_id=840190001;

eventdata[11].actual_value=307000000;
eventdata[11].prev_value=365000000;
eventdata[11].forecast_value=129000000;
eventdata[11].time=D'2020.12.02 16:15';
eventdata[11].event_id=840190001;

eventdata[12].actual_value=-123000000;
eventdata[12].prev_value=307000000;
eventdata[12].forecast_value=-417000000;
eventdata[12].time=D'2021.01.06 16:15';
eventdata[12].event_id=840190001;

eventdata[13].actual_value=174000000;
eventdata[13].prev_value=-123000000;
eventdata[13].forecast_value=-464000000;
eventdata[13].time=D'2021.02.03 16:15';
eventdata[13].event_id=840190001;

eventdata[14].actual_value=117000000;
eventdata[14].prev_value=174000000;
eventdata[14].forecast_value=-465000000;
eventdata[14].time=D'2021.03.03 16:15';
eventdata[14].event_id=840190001;

eventdata[15].actual_value=517000000;
eventdata[15].prev_value=117000000;
eventdata[15].forecast_value=-238000000;
eventdata[15].time=D'2021.03.31 15:15';
eventdata[15].event_id=840190001;

eventdata[16].actual_value=742000000;
eventdata[16].prev_value=517000000;
eventdata[16].forecast_value=742000000;
eventdata[16].time=D'2021.05.05 15:15';
eventdata[16].event_id=840190001;

eventdata[17].actual_value=978000000;
eventdata[17].prev_value=742000000;
eventdata[17].forecast_value=923000000;
eventdata[17].time=D'2021.06.03 15:15';
eventdata[17].event_id=840190001;

eventdata[18].actual_value=692000000;
eventdata[18].prev_value=978000000;
eventdata[18].forecast_value=1055000000;
eventdata[18].time=D'2021.06.30 15:15';
eventdata[18].event_id=840190001;

eventdata[19].actual_value=330000000;
eventdata[19].prev_value=692000000;
eventdata[19].forecast_value=845000000;
eventdata[19].time=D'2021.08.04 15:15';
eventdata[19].event_id=840190001;

eventdata[20].actual_value=374000000;
eventdata[20].prev_value=330000000;
eventdata[20].forecast_value=406000000;
eventdata[20].time=D'2021.09.01 15:15';
eventdata[20].event_id=840190001;

eventdata[21].actual_value=568000000;
eventdata[21].prev_value=374000000;
eventdata[21].forecast_value=74000000;
eventdata[21].time=D'2021.10.06 15:15';
eventdata[21].event_id=840190001;

eventdata[22].actual_value=571000000;
eventdata[22].prev_value=568000000;
eventdata[22].forecast_value=-663000000;
eventdata[22].time=D'2021.11.03 15:15';
eventdata[22].event_id=840190001;

eventdata[23].actual_value=534000000;
eventdata[23].prev_value=571000000;
eventdata[23].forecast_value=-366000000;
eventdata[23].time=D'2021.12.01 16:15';
eventdata[23].event_id=840190001;

eventdata[24].actual_value=807000000;
eventdata[24].prev_value=534000000;
eventdata[24].forecast_value=161000000;
eventdata[24].time=D'2022.01.05 16:15';
eventdata[24].event_id=840190001;

eventdata[25].actual_value=-301000000;
eventdata[25].prev_value=807000000;
eventdata[25].forecast_value=503000000;
eventdata[25].time=D'2022.02.02 16:15';
eventdata[25].event_id=840190001;

eventdata[26].actual_value=475000000;
eventdata[26].prev_value=-301000000;
eventdata[26].forecast_value=471000000;
eventdata[26].time=D'2022.03.02 16:15';
eventdata[26].event_id=840190001;

eventdata[27].actual_value=455000000;
eventdata[27].prev_value=475000000;
eventdata[27].forecast_value=238000000;
eventdata[27].time=D'2022.03.30 15:15';
eventdata[27].event_id=840190001;

eventdata[28].actual_value=247000000;
eventdata[28].prev_value=455000000;
eventdata[28].forecast_value=-31000000;
eventdata[28].time=D'2022.05.04 15:15';
eventdata[28].event_id=840190001;

eventdata[29].actual_value=-9223372036854775808;
eventdata[29].prev_value=247000000;
eventdata[29].forecast_value=-225000000;
eventdata[29].time=D'2022.06.02 15:15';
eventdata[29].event_id=840190001;

eventdata[30].actual_value=-9223372036854775808;
eventdata[30].prev_value=-9223372036854775808;
eventdata[30].forecast_value=-9223372036854775808;
eventdata[30].time=D'2022.07.07 15:15';
eventdata[30].event_id=840190001;

eventdata[31].actual_value=-9223372036854775808;
eventdata[31].prev_value=-9223372036854775808;
eventdata[31].forecast_value=-9223372036854775808;
eventdata[31].time=D'2022.08.03 15:15';
eventdata[31].event_id=840190001;

eventdata[32].actual_value=-9223372036854775808;
eventdata[32].prev_value=-9223372036854775808;
eventdata[32].forecast_value=-9223372036854775808;
eventdata[32].time=D'2022.08.31 15:15';
eventdata[32].event_id=840190001;

eventdata[33].actual_value=-9223372036854775808;
eventdata[33].prev_value=-9223372036854775808;
eventdata[33].forecast_value=-9223372036854775808;
eventdata[33].time=D'2022.10.05 15:15';
eventdata[33].event_id=840190001;

eventdata[34].actual_value=-9223372036854775808;
eventdata[34].prev_value=-9223372036854775808;
eventdata[34].forecast_value=-9223372036854775808;
eventdata[34].time=D'2022.11.02 15:15';
eventdata[34].event_id=840190001;

eventdata[35].actual_value=-9223372036854775808;
eventdata[35].prev_value=-9223372036854775808;
eventdata[35].forecast_value=-9223372036854775808;
eventdata[35].time=D'2022.11.30 16:15';
eventdata[35].event_id=840190001;

}
