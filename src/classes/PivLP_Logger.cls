/******************************************************************************
Name                :    PivLP_Logger
Author              :    Reid Beckett, Launchpad
Description         :    Logging class
Date                :    10/01/2018
*******************************************************************************/
public class PivLP_Logger {
    private static Boolean APEX_LOG_DEBUG = true;
    private static Boolean APEX_LOG_ERROR = true;
    private static Boolean APEX_LOG_SAVE = true;
    private static Boolean PERSIST_DEBUG = true;
    private static Boolean PERSIST_ERROR = true;
    private static Boolean PERSIST_SAVE = true;
    private static Boolean PERSIST_CONTEXT = true;
    private static Map<String,Object> context;

    private static String requestID = generateGUID();
    private static List<LogMessage> messages = new List<LogMessage>();

    private static String generateGUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
    }

    public static void put(String key, Object value){
        if(context == null) context = new Map<String, Object>();
        context.put(key,value);
    }

    public static void start(String element){
        debug(element+':start');
    }

    public static void finish(String element){
        debug(element+':end');
    }

    public static void debug(String msg){
        if(APEX_LOG_DEBUG) system.debug(msg);
        messages.add(new LogMessage(requestID, 'DEBUG', msg, null));
    }

    public static void error(String msg){
        if(APEX_LOG_ERROR) {
            system.debug(LoggingLevel.ERROR, msg);
        }
        messages.add(new LogMessage(requestID, 'ERROR', msg, null));
    }

    public static void error(Exception e){
        if(APEX_LOG_ERROR) {
            system.debug(LoggingLevel.ERROR, e.getMessage());
            system.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        messages.add(new LogMessage(requestID, 'ERROR', e.getMessage()+'\n'+e.getStackTraceString(), null));
    }

    public static void save(String msg){
        if(APEX_LOG_SAVE){
            system.debug(LoggingLevel.INFO, msg);
        }
        messages.add(new LogMessage(requestID, 'SAVE', msg, null));
    }

    public static void flush(){
        List<PivLP_Log__c > persistentLogs = new List<PivLP_Log__c>();
        if(context != null && !context.isEmpty() && PERSIST_CONTEXT){
	        messages.add(new LogMessage(requestID, 'SAVE', JSON.serialize(context), null));
        }
        Integer maxLength = PivLP_Log__c.Message__c.getDescribe().getLength();
        for(LogMessage m : messages){
            if(persist(m)){
                if(!String.isBlank(m.message) && m.message.length() > maxLength) {
                  m.message = m.message.substring(0, maxLength);
                }
                persistentLogs.add(new PivLP_Log__c (
                    Message__c = m.message, Log_Time__c = m.logTime, Request_ID__c = m.requestID
                ));
            }
        }
        insert persistentLogs;
    }

    private static Boolean persist(LogMessage m){
        if(m.level == 'DEBUG' && PERSIST_DEBUG) return true;
        else if(m.level == 'ERROR' && PERSIST_ERROR) return true;
        else if(m.level == 'SAVE' && PERSIST_SAVE) return true;
        return false;
    }

    class LogMessage {
        public String message;
        public DateTime logTime;
        public String requestID;
        public String level;
        public String recordID;

        public LogMessage(String requestID, String level, String message, String recordID){
            this.requestID = requestID;
            this.level = level;
            this.logTime = DateTime.now();
            this.message = message;
            this.recordID = recordID;
        }
    }

}