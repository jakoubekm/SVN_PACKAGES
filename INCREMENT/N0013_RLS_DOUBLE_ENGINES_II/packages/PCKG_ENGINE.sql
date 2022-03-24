
  CREATE OR REPLACE PACKAGE "PDC"."PCKG_ENGINE"
AS
    TYPE REFCSR IS REF CURSOR;

    C_PCKG_NAME   CONSTANT VARCHAR2(64) := 'pckg_engine';

    PROCEDURE SP_ENG_GET_JOB_LIST(ENGINE_ID_IN IN NUMBER
                                , SYSTEM_NAME_IN IN VARCHAR2
                                , DEBUG_IN IN   INTEGER:= 0
                                , CSR   OUT NOCOPY REFCSR
                                , EXIT_CD   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_ENG_GET_LOAD_DATE(JOB_NAME_IN IN VARCHAR2
                                , DEBUG_IN IN   INTEGER:= 0
                                , JOB_ID_OUT   OUT INTEGER
                                , LOAD_DATE_OUT OUT DATE
                                , EXIT_CD   OUT NOCOPY NUMBER
                                , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                , ERRCODE_OUT   OUT NOCOPY NUMBER
                                , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_ENG_UPDATE_STATUS(JOB_ID_IN IN  NUMBER
                                 , LAUNCH_IN IN  NUMBER
                                 , SIGNAL_IN IN  VARCHAR2
                                 , REQUEST_IN IN VARCHAR2
                                 , ENGINE_ID_IN IN NUMBER
                                 , SYSTEM_NAME_IN IN VARCHAR2
                                 , QUEUE_NUMBER_IN IN NUMBER
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_ENG_CHECK_WD_STATUS(ENGINE_ID_IN IN NUMBER
                                   , SYSTEM_NAME_IN IN VARCHAR2
                                   , DEBUG_IN IN   INTEGER:= 0
                                   , NUMBER_OF_SECONDS_OUT   OUT NUMBER
                                   , EXIT_CD   OUT NOCOPY NUMBER
                                   , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                   , ERRCODE_OUT   OUT NOCOPY NUMBER
                                   , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_ENG_UPDATE_WD_STATUS(ENGINE_ID_IN IN NUMBER
                                    , SYSTEM_NAME_IN IN VARCHAR2
                                    , DEBUG_IN IN   INTEGER:= 0
                                    , EXIT_CD   OUT NOCOPY NUMBER
                                    , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                    , ERRCODE_OUT   OUT NOCOPY NUMBER
                                    , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    PROCEDURE SP_ENG_TAKE_CONTROL( ENGINE_ID_IN INTEGER
                                 , SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_VALUE_OUT   OUT NOCOPY NUMBER
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

     PROCEDURE SP_ENG_GIVE_CONTROL(ENGINE_ID_IN INTEGER
                                 , SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

  PROCEDURE SP_ENG_SYSTEM_ENABLE(  SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

   PROCEDURE SP_ENG_SYSTEM_DISABLE(SYSTEM_NAME_IN IN VARCHAR2
                                 , DEBUG_IN IN   INTEGER:= 0
                                 , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                 , EXIT_CD   OUT NOCOPY NUMBER
                                 , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                 , ERRCODE_OUT   OUT NOCOPY NUMBER
                                 , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

    FUNCTION F_ENG_CHECK_WD_STATUS(ENGINE_ID_IN NUMBER)
        RETURN NUMBER;
    FUNCTION F_ENG_CHECK_WD_SYS_STATUS(ENGINE_ID_IN NUMBER, SYSTEM_NAME_IN VARCHAR2)
        RETURN NUMBER;

      PROCEDURE SP_ENG_GUI_UPDATE_STATUS(JOB_ID_IN IN  NUMBER
                                       , LAUNCH_IN IN  NUMBER
                                       , SIGNAL_IN IN  VARCHAR2
                                       , REQUEST_IN IN VARCHAR2
                                       , ENGINE_ID_IN IN NUMBER
                                       , DEBUG_IN IN   INTEGER:= 0
                                       , RETURN_STATUS_OUT   OUT NOCOPY VARCHAR2
                                       , EXIT_CD   OUT NOCOPY NUMBER
                                       , ERRMSG_OUT   OUT NOCOPY VARCHAR2
                                       , ERRCODE_OUT   OUT NOCOPY NUMBER
                                       , ERRLINE_OUT   OUT NOCOPY VARCHAR2);

END PCKG_ENGINE;

