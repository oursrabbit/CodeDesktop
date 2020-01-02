package edu.bfa.ss.qin.Util;

import java.util.List;

import io.realm.RealmList;
import io.realm.RealmObject;

public class Building extends RealmObject {
    public String getBuildingName() {
        return BuildingName;
    }

    public void setBuildingName(String buildingName) {
        BuildingName = buildingName;
    }

    public RealmList<Room> getRooms() {
        return Rooms;
    }

    public void setRooms(RealmList<Room> rooms) {
        Rooms = rooms;
    }

    public String BuildingName;
    public RealmList<Room> Rooms;
}