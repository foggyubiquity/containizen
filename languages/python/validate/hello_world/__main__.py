# https://chriswarrick.com/blog/2014/09/15/python-apps-the-right-way-entry_points-and-scripts/
import sys, os

def main(args=None):
    if args is None:
        args = sys.argv[1:]
    gid = os.getgid()
    uid = os.getuid()

    print("GID: %s" % gid)
    print("UID: %s" % uid)

    if gid == 328 and uid == 289:
        print("Hello, world!")
    else:
        print("Root says Hello")

if __name__ == "__main__":
    main()
