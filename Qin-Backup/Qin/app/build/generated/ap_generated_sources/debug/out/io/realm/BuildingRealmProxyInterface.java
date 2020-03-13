package io.realm;


public interface BuildingRealmProxyInterface {
    public int realmGet$ID();
    public void realmSet$ID(int value);
    public String realmGet$Name();
    public void realmSet$Name(String value);
    public RealmList<edu.bfa.ss.qin.Util.Room> realmGet$Rooms();
    public void realmSet$Rooms(RealmList<edu.bfa.ss.qin.Util.Room> value);
}
