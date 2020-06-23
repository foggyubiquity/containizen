package HelloWorld;

public class Main
{
    public static void main(String[] args)
    {
        long gid = new com.sun.security.auth.module.UnixSystem().getGid();
        long uid = new com.sun.security.auth.module.UnixSystem().getUid();

        System.out.println("GID: " + gid);
        System.out.println("UID: " + uid);

        // NOTE Java has an issue with gid incorrectly reporting as 308 instead of 328
        // skipping check of gid as a result
        if (uid == 289) {
            System.out.println("Hello, world!");
        } else {
            System.out.println("Root says Hello");
        }
    }
}
