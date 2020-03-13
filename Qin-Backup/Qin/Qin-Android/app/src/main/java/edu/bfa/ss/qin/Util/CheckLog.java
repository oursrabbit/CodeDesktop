package edu.bfa.ss.qin.Util;

import java.util.Date;

public class CheckLog implements Comparable<CheckLog> {
    public int StudentID;
    public int RoomID;
    public Date CheckDate;

    @Override
    public int compareTo(CheckLog o) {
        return (int) (o.CheckDate.getTime() - CheckDate.getTime());
    }
}
