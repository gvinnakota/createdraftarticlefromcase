public class TriggerControl {

  @testVisible
  private static Map<System.Type, Boolean> hasRunMap = new Map<System.Type, Boolean>{
    Event.class => false,
    Opportunity.class => false
  };
  public static Boolean hasRun(System.Type entityType) {
    if (hasRunMap.containsKey(entityType)) {
      return hasRunMap.get(entityType);
    }
    return false;
  }
  public static void setHasRun(System.Type entityType) {
    hasRunMap.put(entityType, true);
  }
  public static void clearHasRun(System.Type entityType) {
    hasRunMap.put(entityType, false);
  }
}