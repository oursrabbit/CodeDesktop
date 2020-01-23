package edu.bfa.ss.qin.Util;

public class Student {
    public String LCObjectID;
    public String SchoolID;
    public String Advertising;
    public String BaiduFaceID;
    public int ID;
    public String Name;

    public byte[] getStudentBeaconMinor() {
        byte[] bytes = {0x00, 0x00};
        bytes[0] = (byte)(ID >> 8 & 0xFF);
        bytes[1] = (byte)(ID & 0xFF);
        return bytes;
    }
}
