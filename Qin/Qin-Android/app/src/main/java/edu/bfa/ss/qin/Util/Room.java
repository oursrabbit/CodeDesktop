package edu.bfa.ss.qin.Util;

import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;

public class Room extends RealmObject {
    public String getName() {
        return Name;
    }

    public void setName(String name) {
        Name = name;
    }

    public Building getLocation() {
        return Location;
    }

    public void setLocation(Building location) {
        Location = location;
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
    public Building Location;
}
