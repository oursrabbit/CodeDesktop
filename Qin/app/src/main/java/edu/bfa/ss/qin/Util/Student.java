package edu.bfa.ss.qin.Util;

public class Student {
    public String ObjectID;
    public String StudentID;
    public String Advertising;
    public String BaiduFaceID;

    public byte[] getStrudingIDBytes() {
        byte[] bytes = {0x00, 0x00, 0x00, 0x00};
        int studentID = Integer.parseInt(StudentID);
        bytes[0] = (byte)(studentID >> 32 & 0xFF);
        bytes[1] = (byte)(studentID >> 16 & 0xFF);
        bytes[2] = (byte)(studentID >> 8 & 0xFF);
        bytes[3] = (byte)(studentID & 0xFF);
        return bytes;
    }
}
