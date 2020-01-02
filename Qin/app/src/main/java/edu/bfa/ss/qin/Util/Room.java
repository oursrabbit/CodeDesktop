package edu.bfa.ss.qin.Util;

import io.realm.RealmObject;

public class Room extends RealmObject {
    public String getRoomName() {
        return RoomName;
    }

    public void setRoomName(String roomName) {
        RoomName = roomName;
    }

    public Building getLocation() {
        return Location;
    }

    public void setLocation(Building location) {
        Location = location;
    }

    public String RoomName;
    public Building Location;
}
