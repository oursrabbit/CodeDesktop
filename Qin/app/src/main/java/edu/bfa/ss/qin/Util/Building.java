package edu.bfa.ss.qin.Util;

import io.realm.RealmList;
import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;

public class Building extends RealmObject {
    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public RealmList<Room> getRooms() {
        return Rooms;
    }

    public void setRooms(RealmList<Room> rooms) {
        Rooms = rooms;
    }

    public int getID() {
        return ID;
    }

    public void setID(int ID) {
        this.ID = ID;
    }

    @PrimaryKey
    public int ID;
    public String Name;
    public RealmList<Room> Rooms;
}
