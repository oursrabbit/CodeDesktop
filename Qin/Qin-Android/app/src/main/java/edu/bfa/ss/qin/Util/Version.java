package edu.bfa.ss.qin.Util;

public class Version {
    public int MainVersion;
    public int FunctionVersion;
    public int BugVersion;
    public int DatabaseVersion;

    public String VersionString;

    public Version(String versionString) {
        MainVersion = Integer.parseInt( versionString.split("\\.")[0]);
        FunctionVersion = Integer.parseInt( versionString.split("\\.")[1]);
        BugVersion = Integer.parseInt( versionString.split("\\.")[2]);
        DatabaseVersion = Integer.parseInt( versionString.split("\\.")[3]);
        VersionString = versionString;
    }
}
