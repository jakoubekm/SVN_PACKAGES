Insert into CTRL_PARAMETERS (PARAM_NAME,PARAM_CD,PARAM_TYPE,PARAM_VAL_INT,PARAM_VAL_CHAR,PARAM_VAL_DATE,PARAM_VAL_TS,DESCRIPTION)
select 
'INITIALIZATION_CURRDATE_RELATED',param_cd,'SCHEDULER',0,NULL,NULL,NULL,'Jestli inicializace vychazi z curr_date'
from ctrl_parameters where param_cd is not null
group by param_cd;


