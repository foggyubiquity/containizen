package HelloWorld;

public class Main
{
    public static void main(String[] args)
    {
        long gid = new com.sun.security.auth.module.UnixSystem().getGid();
        long uid = new com.sun.security.auth.module.UnixSystem().getUid();

        if (gid == 328 && uid == 289) {
            System.out.println("Hello, world!");
        } else {
            System.out.println("Root says Hello");
        }
    }
}
