package edu.bfa.ss.qin.Util;

import io.realm.RealmObject;
import io.realm.annotations.PrimaryKey;

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

    public int getRoomID() {
        return RoomID;
    }

    public void setRoomID(int roomID) {
        RoomID = roomID;
    }

    @PrimaryKey
    public int RoomID;
    public String RoomName;
    public Building Location;
}
